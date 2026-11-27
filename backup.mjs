import {DatabaseSync} from 'node:sqlite';
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
const root=path.dirname(fileURLToPath(import.meta.url));
const dir=process.env.DATA_DIR||path.join(root,'data');
const dest=path.resolve(process.argv[2]||path.join(dir,'backups',`wash-${new Date().toISOString().replace(/[:.]/g,'-')}.sqlite`));
if(!fs.existsSync(path.join(dir,'wash.sqlite')))throw Error('Base de données introuvable.');
fs.mkdirSync(path.dirname(dest),{recursive:true});
if(fs.existsSync(dest))throw Error('La sauvegarde existe déjà.');
const db=new DatabaseSync(path.join(dir,'wash.sqlite'));
db.exec('PRAGMA busy_timeout=10000');
try{db.prepare('VACUUM INTO ?').run(dest);console.log('Sauvegarde : '+dest);}finally{db.close();}
