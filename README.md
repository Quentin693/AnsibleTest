# 🚀 Déploiement CI/CD d'une Application Next.js avec Ansible

Ce projet démontre comment mettre en place un déploiement automatisé d'une application Next.js sur un serveur distant en utilisant Ansible et GitHub Actions.

## 📋 Table des matières

- [Objectif](#objectif)
- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Étape 1 : Configuration AWS EC2](#étape-1--configuration-aws-ec2)
- [Étape 2 : Préparation du serveur](#étape-2--préparation-du-serveur)
- [Étape 3 : Déploiement manuel avec Ansible](#étape-3--déploiement-manuel-avec-ansible)
- [Étape 4 : Automatisation avec GitHub Actions](#étape-4--automatisation-avec-github-actions)
- [Étape 5 : Test du CI/CD](#étape-5--test-du-cicd)
- [Dépannage](#dépannage)

## 🎯 Objectif

Mettre en place un déploiement automatisé d'une application Next.js sur un serveur distant en utilisant Ansible et GitHub Actions. À la fin, chaque push sur GitHub déclenchera automatiquement un déploiement sur votre serveur.

## 🏗️ Architecture

```
┌─────────────┐      ┌──────────────────┐      ┌─────────────────┐
│   GitHub    │─────▶│ GitHub Actions   │─────▶│   Serveur AWS   │
│ Repository  │ Push │   + Ansible      │ SSH  │   Ubuntu + EC2  │
└─────────────┘      └──────────────────┘      └─────────────────┘
                             │
                             └──────────────────▶ Next.js déployé
```

## 📦 Prérequis

### Sur votre machine locale :
- Git installé
- Un compte GitHub
- Accès SSH à votre serveur
- Ansible installé (pour les tests manuels)

### Sur AWS :
- Une instance EC2 Ubuntu
- Une paire de clés SSH (.pem)
- Ports ouverts dans le Security Group

## 🔧 Étape 1 : Configuration AWS EC2

### 1.1 Configurer le Security Group

Assurez-vous que votre Security Group AWS EC2 autorise ces ports :

| Type   | Protocole | Port | Source    | Description                    |
|--------|-----------|------|-----------|--------------------------------|
| SSH    | TCP       | 22   | 0.0.0.0/0 | Accès SSH                      |
| HTTP   | TCP       | 80   | 0.0.0.0/0 | Nginx (production)             |
| HTTPS  | TCP       | 443  | 0.0.0.0/0 | SSL (optionnel)                |
| Custom | TCP       | 3000 | 0.0.0.0/0 | Next.js (test avant Nginx)     |

### 1.2 Récupérer votre clé SSH

```bash
# Téléchargez votre clé .pem depuis AWS
# Placez-la dans ~/.ssh/
mv ~/Downloads/nextjs-key.pem ~/.ssh/
chmod 600 ~/.ssh/nextjs-key.pem
```

## 🖥️ Étape 2 : Préparation du serveur

### 2.1 Se connecter au serveur

```bash
ssh -i ~/.ssh/nextjs-key.pem ubuntu@VOTRE_IP_PUBLIQUE
```

### 2.2 Installer les prérequis sur le serveur

```bash
# Mettre à jour le système
sudo apt update && sudo apt upgrade -y

# Installer Git et Nginx
sudo apt install -y git nginx

# Installer Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Vérifier les installations
node -v
npm -v
git --version
nginx -v
```

### 2.3 Configurer le pare-feu (optionnel)

```bash
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 3000
sudo ufw enable
```

## 📂 Étape 3 : Déploiement manuel avec Ansible

### 3.1 Installer Ansible sur votre machine locale

**Sur macOS :**
```bash
brew install ansible
```

**Sur Ubuntu/Debian :**
```bash
sudo apt update && sudo apt install -y ansible
```

### 3.2 Configurer le fichier inventory.ini

Modifiez le fichier `inventory.ini` :

```ini
[webserver]
# Remplacez par l'IP de votre serveur AWS
54.123.45.67 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/nextjs-key.pem
```

### 3.3 Modifier le playbook deploy.yml

Modifiez les variables dans `deploy.yml` :

```yaml
vars:
  github_repo: "https://github.com/VOTRE_USERNAME/VOTRE_REPO.git"
  project_name: "nextjs-app"
  node_version: "18.x"
```

### 3.4 Tester la connexion Ansible

```bash
ansible -i inventory.ini webserver -m ping
```

Résultat attendu :
```
54.123.45.67 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### 3.5 Exécuter le déploiement manuel

```bash
ansible-playbook -i inventory.ini deploy.yml
```

### 3.6 Vérifier le déploiement

Ouvrez votre navigateur : `http://VOTRE_IP:3000`

Vous devriez voir votre application Next.js !

## 🤖 Étape 4 : Automatisation avec GitHub Actions

### 4.1 Créer un dépôt GitHub

```bash
# Depuis le répertoire du projet
git init
git add .
git commit -m "Initial commit - Projet Ansible Next.js"
git branch -M main
git remote add origin https://github.com/VOTRE_USERNAME/VOTRE_REPO.git
git push -u origin main
```

### 4.2 Configurer les secrets GitHub

Allez dans votre dépôt GitHub :
**Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Créez ces secrets :

| Nom              | Valeur                                      | Description                        |
|------------------|---------------------------------------------|------------------------------------|
| `SSH_PRIVATE_KEY`| Contenu de votre clé privée SSH             | Copiez le contenu de votre .pem    |
| `SERVER_IP`      | Votre IP publique AWS                       | Ex: 54.123.45.67                   |
| `REMOTE_USER`    | ubuntu                                      | Utilisateur du serveur             |

**Pour obtenir votre clé privée :**
```bash
cat ~/.ssh/nextjs-key.pem
```

Copiez **tout le contenu** (y compris `-----BEGIN RSA PRIVATE KEY-----` et `-----END RSA PRIVATE KEY-----`)

### 4.3 Créer le dossier pour Ansible dans GitHub

Le workflow GitHub Actions cherchera les fichiers Ansible dans un dossier spécifique. Créez cette structure :

```bash
mkdir -p ansible-playbook
cp deploy.yml ansible-playbook/
cp ansible.cfg ansible-playbook/
```

Modifiez `.github/workflows/deploy.yml` pour utiliser le bon chemin, ou modifiez le playbook pour qu'il pointe vers votre repo.

### 4.4 Ajuster le workflow si nécessaire

Le fichier `.github/workflows/deploy.yml` est déjà configuré, mais vous pouvez le personnaliser :

- Changer la branche de déclenchement (actuellement `main`)
- Ajouter des notifications (Slack, Discord, etc.)
- Ajouter des étapes de tests avant le déploiement

## ✅ Étape 5 : Test du CI/CD

### 5.1 Faire un changement dans le code

Modifiez `pages/index.js` :

```javascript
<h1 className={styles.title}>
  Bienvenue sur <span className={styles.highlight}>Next.js v2.0</span>
</h1>
```

### 5.2 Commit et push

```bash
git add .
git commit -m "Mise à jour de la version"
git push origin main
```

### 5.3 Vérifier GitHub Actions

1. Allez dans votre dépôt GitHub
2. Cliquez sur l'onglet **Actions**
3. Vous verrez le workflow en cours d'exécution
4. Attendez qu'il se termine (symbole vert ✅)

### 5.4 Vérifier le déploiement

Actualisez `http://VOTRE_IP:3000` dans votre navigateur.

Vous devriez voir les changements ! 🎉

## 🔍 Dépannage

### Erreur : "Permission denied (publickey)"

```bash
# Vérifiez les permissions de votre clé
chmod 600 ~/.ssh/nextjs-key.pem

# Testez la connexion SSH
ssh -i ~/.ssh/nextjs-key.pem ubuntu@VOTRE_IP
```

### Erreur : "Host key verification failed"

```bash
# Ajoutez l'hôte aux known_hosts
ssh-keyscan -H VOTRE_IP >> ~/.ssh/known_hosts
```

### Le service Next.js ne démarre pas

```bash
# Connectez-vous au serveur
ssh -i ~/.ssh/nextjs-key.pem ubuntu@VOTRE_IP

# Vérifiez les logs du service
sudo systemctl status nextjs-app
sudo journalctl -u nextjs-app -f

# Redémarrez le service
sudo systemctl restart nextjs-app
```

### Le port 3000 ne répond pas

```bash
# Vérifiez que le processus écoute
sudo netstat -tulpn | grep 3000

# Ou avec ss
sudo ss -tulpn | grep 3000

# Vérifiez le Security Group AWS
# Assurez-vous que le port 3000 est ouvert
```

### GitHub Actions échoue

1. Vérifiez que tous les secrets sont correctement configurés
2. Vérifiez les logs dans l'onglet Actions de GitHub
3. Assurez-vous que le chemin vers le playbook est correct
4. Vérifiez que votre clé SSH est correctement formatée (avec les retours à la ligne)

## 📊 Commandes utiles

### Sur le serveur

```bash
# Voir les logs de l'application
sudo journalctl -u nextjs-app -f

# Redémarrer l'application
sudo systemctl restart nextjs-app

# Arrêter l'application
sudo systemctl stop nextjs-app

# Vérifier le statut
sudo systemctl status nextjs-app

# Voir les processus Node
ps aux | grep node

# Vérifier l'espace disque
df -h
```

### En local

```bash
# Tester la connexion Ansible
ansible -i inventory.ini webserver -m ping

# Exécuter le playbook avec verbose
ansible-playbook -i inventory.ini deploy.yml -vvv

# Exécuter seulement certaines tâches
ansible-playbook -i inventory.ini deploy.yml --tags "deploy"
```

## 🎓 Concepts clés

### Ansible
- **Inventory** : Liste des serveurs à gérer
- **Playbook** : Fichier YAML décrivant les tâches à exécuter
- **Tasks** : Actions individuelles (installer un package, copier un fichier, etc.)
- **Modules** : Commandes Ansible prédéfinies (apt, git, npm, etc.)

### GitHub Actions
- **Workflow** : Processus automatisé déclenché par des événements
- **Jobs** : Ensemble de steps exécutés sur un runner
- **Steps** : Actions individuelles dans un job
- **Secrets** : Variables sécurisées stockées dans GitHub

### CI/CD
- **CI (Continuous Integration)** : Intégration continue du code
- **CD (Continuous Deployment)** : Déploiement continu en production
- **Pipeline** : Chaîne d'actions automatisées (build, test, deploy)

## 🚀 Améliorations possibles

1. **Ajouter Nginx comme reverse proxy** : Servir l'app via le port 80
2. **Configurer SSL avec Let's Encrypt** : HTTPS automatique
3. **Ajouter des tests** : Exécuter des tests avant le déploiement
4. **Utiliser PM2** : Gestionnaire de processus Node.js plus robuste
5. **Ajouter un rollback** : Revenir à la version précédente en cas d'erreur
6. **Variables d'environnement** : Gérer les secrets de l'application
7. **Notifications** : Slack, Discord ou email après déploiement
8. **Monitoring** : Uptime monitoring avec Pingdom ou UptimeRobot

## 📝 Structure du projet

```
AnsibleTest/
├── .github/
│   └── workflows/
│       └── deploy.yml          # Workflow GitHub Actions
├── pages/
│   ├── _app.js                 # Configuration Next.js
│   └── index.js                # Page d'accueil
├── styles/
│   ├── globals.css             # Styles globaux
│   └── Home.module.css         # Styles de la page d'accueil
├── public/                     # Fichiers statiques
├── ansible.cfg                 # Configuration Ansible
├── inventory.ini               # Inventaire des serveurs
├── deploy.yml                  # Playbook Ansible
├── package.json                # Dépendances Node.js
├── next.config.js              # Configuration Next.js
├── .gitignore                  # Fichiers à ignorer
└── README.md                   # Ce fichier
```

## 📚 Ressources

- [Documentation Ansible](https://docs.ansible.com/)
- [Documentation GitHub Actions](https://docs.github.com/en/actions)
- [Documentation Next.js](https://nextjs.org/docs)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)

## 👨‍💻 Auteur

Projet EEMI - Exercice guidé sur le déploiement CI/CD

## 📄 Licence

Ce projet est à des fins éducatives.

---

**Bon déploiement ! 🚀**

