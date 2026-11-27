# L’Expert Eco’Lav — version 2.0

Application française de réservation et gestion de station de lavage. Cette version conserve les prestations, tarifs, planning, rapports, dépenses, reçus et import vCard de la version 1, et ajoute le logo fourni, les mots de passe clients, l’activation sécurisée des anciens comptes et la préparation au déploiement HTTPS.

## Mise à jour sur Windows (conserver les données)

1. Arrêtez le serveur actuel (Ctrl+C dans sa fenêtre noire). Ne supprimez pas l’ancien dossier.
2. Décompressez le nouveau ZIP dans un nouveau dossier permanent.
3. Copiez **le dossier `data` entier** de l’ancien dossier `wash-station-manager` dans le nouveau dossier `wash-station-manager-v2`. S’il n’existe pas, l’application crée une nouvelle base. Ne copiez pas une base pendant que le serveur tourne.
4. Double-cliquez sur `START-WINDOWS.bat`. Ouvrez http://127.0.0.1:3000.
5. Le mot de passe administrateur précédent reste valable si vous avez copié `data`. Une nouvelle installation affiche un mot de passe aléatoire dans le terminal. Conservez-le en privé.
6. Les anciens clients (même ceux créés lors des essais) doivent recevoir un code d’activation. Leurs réservations et profils restent dans la base. Les anciennes sessions clients sont invalidées.

## Connexion et activation

Un nouveau client crée un compte avec son nom, numéro tunisien et mot de passe (12 à 128 caractères). Pour les contacts déjà importés ou ajoutés par l’admin, il faut un code personnel. Dans **Administration → Paramètres → Activation / réinitialisation client**, vérifiez l’identité de la personne, saisissez son numéro, générez un code et communiquez-le en privé. Le client choisit « Activer mon ancien compte / Mot de passe oublié », puis saisit le code et choisit son mot de passe. Le code expire après 48 heures, ne peut être utilisé qu’une fois et remplace les anciens identifiants. Aucun SMS payant n’est utilisé. Les nouveaux numéros auto-inscrits ne sont pas vérifiés par SMS : le personnel doit confirmer le numéro si une identité vérifiée est indispensable. Ne publiez pas les codes ni les données clients.

## Horaires et notifications

Les créneaux sont stockés en minutes depuis minuit, heure de Tunis (Africa/Tunis), sans conversion selon le téléphone ou le PC. Le tableau administrateur s’actualise toutes les 30 s, l’historique client toutes les 15 s et au retour sur l’onglet. Une modification ne doit plus choisir automatiquement un créneau différent si l’ancien est indisponible. Les tests vérifient la correspondance entre les deux API après modification. Les deux espaces partagent le cookie de connexion d’un navigateur ; pour tester les deux rôles simultanément, utilisez deux profils de navigateur ou une fenêtre privée.

Notifications : cliquez sur Notifications → Activer → autoriser → Tester. En production HTTPS, sur iPhone, ouvrez l’app depuis l’icône ajoutée à l’écran d’accueil Safari. Sur Android utilisez un navigateur compatible. Le test indique si le service de push a accepté l’envoi, pas s’il a été affiché par le téléphone. Les clés VAPID sont conservées dans la base. Un changement d’origine (localhost vers site public) exige une nouvelle activation sur chaque appareil. Livraison réelle à vérifier.

## Déploiement public — préparation incluse

L’application fonctionne avec Node.js 22.13+ et SQLite, sans dépendance npm externe. `Dockerfile`, `compose.yaml`, `Caddyfile` et `.env.example` sont fournis pour un serveur Linux disposant de Docker et du plugin Compose. Le volume Docker `wash_data` conserve la base entre redémarrages ; ne lancez jamais `docker compose down -v` sauf si vous voulez effacer les données. Le proxy Caddy gère les certificats HTTPS automatiquement si le DNS et les ports sont corrects.

### Hébergement sans abonnement (sous conditions)

Un serveur Linux déjà disponible ou une VM Oracle Cloud Always Free est une possibilité. L’offre Oracle nécessite un compte, une vérification de carte, de la capacité disponible et peut récupérer les VM inactives. Ne sélectionnez pas d’instance ou service payant. Référence : https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm. Les hébergements Node gratuits avec disque éphémère (ex. Render gratuit) ne conviennent pas à cette base SQLite : risque de perte de données. Un domaine existant ou un sous-domaine DNS gratuit pointant vers la VM est nécessaire ; aucun domaine payant n’est obligatoire. Un compte hébergeur et un DNS restent à configurer avant une mise en ligne réelle.

1. Préparez une VM Linux gratuite et installez Docker/Compose depuis la documentation officielle : https://docs.docker.com/engine/install/ubuntu/ (si Ubuntu). Restreignez SSH aux IP autorisées et ouvrez TCP 80/443 côté VM et réseau cloud. Ne publiez pas le port 3000.
2. Décompressez le projet sur la VM. Créez une entrée DNS A (ou AAAA si IPv6 fonctionnel) vers son IP publique. Copiez `.env.example` vers `.env`, remplacez `SITE_HOST` par le vrai nom DNS, sans `https://`.
3. Lancez `docker compose up -d --build`. Consultez `docker compose logs app` en privé pour relever le mot de passe généré si nouvelle base.
4. Pour importer une sauvegarde locale, avant ouverture aux clients : arrêtez l’app (`docker compose stop app`), copiez un fichier `wash.sqlite` créé par `BACKUP-WINDOWS.bat` dans le volume en utilisant une commande Compose ponctuelle avec droits corrects, puis redémarrez. Ne mélangez jamais une ancienne base avec des fichiers WAL/SHM d’une autre base. Demandez de l’aide si vous n’êtes pas sûr. Le fichier contient des données personnelles et des secrets.
5. Vérifiez https://VOTRE-NOM-DNS, connexion admin, client, réservation, annulation, reçu, rapports, blocage et réception de notifications sur téléphone avant de partager l’adresse.

`docker compose logs` aide au diagnostic. Le serveur et le proxy redémarrent automatiquement tant que la VM fonctionne. Ne déployez pas de données réelles dans un environnement de démonstration. Vérifiez les coordonnées, les conditions de traitement des données et la politique de confidentialité avec le propriétaire avant publication. HTTPS et contrôle des identifiants sont préparés mais ne remplacent pas un audit de sécurité de production. Aucun compte cloud n’a été créé et aucun déploiement public n’a été exécuté.

## Sauvegardes

Double-cliquez sur `BACKUP-WINDOWS.bat` pour créer une copie SQLite cohérente (même si l’application tourne) dans `data/backups`. Sur le serveur : `./BACKUP-SERVER.sh` crée une copie dans `backups/`. Conservez également une sauvegarde chiffrée hors de la VM, et testez régulièrement la restauration. Ne publiez ni le dossier `data`, ni `backups`, ni `.env` sur GitHub. Les 237 anciens contacts Replit et leurs anciennes réservations ne sont pas fournis : il faut un export séparé pour les récupérer.

## Tests et limites

`npm test` vérifie les opérations de réservation, les deux pistes, les conflits, les blocages, les autorisations, les mots de passe, l’activation des comptes importés, l’invalidation des sessions, les rapports et la correspondance des heures. Les tests de navigateur dans l’environnement de création ont été bloqués par sa politique réseau. La réception push sur téléphone, le rendu visuel complet, l’impression réelle et le déploiement cloud n’ont pas été validés en conditions réelles. Les revenus affichés sont les montants des réservations confirmées, pas des paiements encaissés. Aucun service payant n’a été activé.

## Version 2.1 — hébergement Render + Neon (offres gratuites)

`render.yaml` configure un seul service web gratuit à Francfort. Le programme conserve son moteur SQLite testé et réplique son état compressé dans une ligne PostgreSQL (table `ecolav_state`). Une transaction PostgreSQL sérialise les accès et confirme chaque écriture avant la réponse HTTP. Ce stockage n'est pas une migration relationnelle complète. Les fichiers locaux sur Render ne sont pas la source de vérité. Le service doit rester en instance unique. Ne pas publier de fichiers `.env`, `data/`, de sauvegardes ou de mots de passe sur GitHub.

Configurer `DATABASE_URL` (connexion Neon avec TLS) comme secret Render, et `ADMIN_PASSWORD` comme secret généré, de 12 à 128 caractères. Le mot de passe initial n'est pas journalisé si la variable est définie. Le déploiement est en HTTPS. Une base vide reçoit les six prestations par défaut ; les données sur l'ancien ordinateur ou dans Replit ne sont pas importées automatiquement. Sauvegarder régulièrement la base Neon et ne pas supprimer le projet. Pour récupérer le mot de passe initial, consulter la variable d'environnement dans le tableau de bord Render. Le plan gratuit peut se mettre en veille et comporte des limites de ressources.

Les tests locaux s'exécutent avec `npm test` sans accès au cloud. `node test-cloud.mjs` teste le stockage transactionnel avec un double de test PostgreSQL. Un test réel de PostgreSQL et du déploiement est nécessaire avant ouverture au public.
