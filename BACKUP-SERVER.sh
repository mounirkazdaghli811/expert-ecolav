#!/bin/sh
set -eu
cd "$(dirname "$0")"
mkdir -p backups
chmod 700 backups
stamp=$(date -u +%Y%m%dT%H%M%SZ)
docker compose exec -T app node backup.mjs "/tmp/wash-$stamp.sqlite"
docker compose cp "app:/tmp/wash-$stamp.sqlite" "backups/wash-$stamp.sqlite"
chmod 600 "backups/wash-$stamp.sqlite"
docker compose exec -T app rm "/tmp/wash-$stamp.sqlite"
echo "Sauvegarde: backups/wash-$stamp.sqlite"
