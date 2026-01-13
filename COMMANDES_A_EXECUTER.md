# 🚀 Commandes à exécuter dans l'ordre

## Configuration actuelle détectée

- **VM GCP** : `nextjs-vm`
- **IP** : `34.39.55.123`
- **Utilisateur** : `quentin.cialone-gcp`
- **Clé SSH** : `~/.ssh/gcp_nextjs`

---

## Étape 1️⃣ : Vérifier/Créer la clé SSH

```bash
# Si la clé n'existe pas encore
ssh-keygen -t rsa -b 4096 -f ~/.ssh/gcp_nextjs -C "quentin@nextjs"

# Copier la clé sur le serveur
ssh-copy-id -i ~/.ssh/gcp_nextjs quentin.cialone-gcp@34.39.55.123

# Tester la connexion
ssh -i ~/.ssh/gcp_nextjs quentin.cialone-gcp@34.39.55.123
```

---

## Étape 2️⃣ : Installer Ansible (si pas déjà fait)

```bash
# Sur macOS
brew install ansible

# Vérifier
ansible --version
```

---

## Étape 3️⃣ : Tester la configuration

```bash
# Aller dans le dossier du projet
cd /Users/quentinho/Projets/EEMI/AnsibleTest

# Lancer le script de test automatique
./test-connexion.sh
```

**Si tous les tests passent**, continuez à l'étape 4.

---

## Étape 4️⃣ : Configurer le pare-feu GCP

### Option A : Via la console GCP (recommandé pour débutants)

1. Allez sur [Google Cloud Console](https://console.cloud.google.com)
2. **VPC Network** → **Firewall** → **CREATE FIREWALL RULE**
3. Créez une règle nommée `allow-nextjs` :
   - **Targets** : All instances in the network
   - **Source IPv4 ranges** : `0.0.0.0/0`
   - **Protocols and ports** : `tcp:3000,tcp:80,tcp:443`

### Option B : Via gcloud CLI

```bash
gcloud compute firewall-rules create allow-nextjs \
    --allow tcp:3000,tcp:80,tcp:443 \
    --source-ranges 0.0.0.0/0 \
    --description "Allow Next.js and HTTP/HTTPS"
```

---

## Étape 5️⃣ : Modifier deploy.yml avec votre repo GitHub

**⚠️ IMPORTANT** : Avant de déployer, vous devez créer un repo GitHub.

### Créer le repo sur GitHub :

1. Allez sur [github.com/new](https://github.com/new)
2. Nom du repo : `AnsibleTest` (ou autre nom)
3. Laissez **public** ou **private** (au choix)
4. **NE PAS** initialiser avec README (on a déjà le code)
5. Cliquez sur **Create repository**

### Modifier le fichier deploy.yml :

Ouvrez `deploy.yml` et modifiez la ligne 6 :

```yaml
github_repo: "https://github.com/VOTRE_USERNAME/AnsibleTest.git"
```

Remplacez `VOTRE_USERNAME` par votre nom d'utilisateur GitHub réel.

---

## Étape 6️⃣ : Pousser le code sur GitHub

```bash
cd /Users/quentinho/Projets/EEMI/AnsibleTest

# Initialiser Git (si pas déjà fait)
git init
git add .
git commit -m "Initial commit - NextJS Ansible Deploy"
git branch -M main

# Ajouter le remote (remplacez VOTRE_USERNAME)
git remote add origin https://github.com/VOTRE_USERNAME/AnsibleTest.git

# Pousser le code
git push -u origin main
```

---

## Étape 7️⃣ : Déploiement manuel (TEST)

```bash
cd /Users/quentinho/Projets/EEMI/AnsibleTest

# Lancer le déploiement
ansible-playbook -i inventory.ini deploy.yml

# Cela prendra environ 5-10 minutes
# Attendez que tout soit terminé
```

### Vérifier le déploiement :

```bash
# Option 1 : Dans le navigateur
open http://34.39.55.123:3000

# Option 2 : Avec curl
curl http://34.39.55.123:3000
```

Vous devriez voir votre application Next.js ! 🎉

---

## Étape 8️⃣ : Configurer GitHub Actions (CI/CD)

### Ajouter les secrets GitHub :

1. Allez sur votre repo GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. **New repository secret**

### Secret 1 : SSH_PRIVATE_KEY

```bash
# Afficher la clé
cat ~/.ssh/gcp_nextjs
```

Copiez **TOUT** (incluant `-----BEGIN OPENSSH PRIVATE KEY-----` et `-----END OPENSSH PRIVATE KEY-----`)

- **Name** : `SSH_PRIVATE_KEY`
- **Value** : (collez tout le contenu)

### Secret 2 : SERVER_IP

- **Name** : `SERVER_IP`
- **Value** : `34.39.55.123`

### Secret 3 : REMOTE_USER

- **Name** : `REMOTE_USER`
- **Value** : `quentin.cialone-gcp`

---

## Étape 9️⃣ : Tester le CI/CD

```bash
cd /Users/quentinho/Projets/EEMI/AnsibleTest

# Faire un petit changement
echo "// Test CI/CD" >> pages/index.js

# Commit et push
git add .
git commit -m "Test du CI/CD automatique"
git push origin main
```

### Vérifier que ça marche :

1. Allez sur votre repo GitHub
2. Cliquez sur l'onglet **Actions**
3. Vous verrez le workflow "Deploy Next.js App" en cours
4. Attendez qu'il se termine (symbole ✅ vert)
5. Rafraîchissez http://34.39.55.123:3000

---

## 🔟 Commandes utiles pour le debug

### Sur votre Mac :

```bash
# Tester la connexion SSH
ssh -i ~/.ssh/gcp_nextjs quentin.cialone-gcp@34.39.55.123

# Tester Ansible avec verbose
ansible -i inventory.ini webserver -m ping -vvv

# Relancer le déploiement
ansible-playbook -i inventory.ini deploy.yml
```

### Sur la VM (après connexion SSH) :

```bash
# Voir le statut du service
sudo systemctl status nextjs-app

# Voir les logs en temps réel
sudo journalctl -u nextjs-app -f

# Redémarrer le service
sudo systemctl restart nextjs-app

# Vérifier que le port écoute
sudo ss -tulpn | grep 3000

# Aller dans le dossier du projet
cd ~/nextjs-app

# Vérifier la dernière mise à jour
git log --oneline -n 5
```

---

## 📋 Checklist complète

Cochez au fur et à mesure :

- [ ] Clé SSH créée (`~/.ssh/gcp_nextjs`)
- [ ] Clé SSH copiée sur le serveur (`ssh-copy-id`)
- [ ] Connexion SSH fonctionne
- [ ] Ansible installé (`brew install ansible`)
- [ ] Script de test réussi (`./test-connexion.sh`)
- [ ] Pare-feu GCP configuré (ports 3000, 80, 443)
- [ ] Repo GitHub créé
- [ ] `deploy.yml` modifié avec le bon repo GitHub
- [ ] Code poussé sur GitHub (`git push`)
- [ ] Déploiement manuel réussi (`ansible-playbook`)
- [ ] Application accessible sur http://34.39.55.123:3000
- [ ] Secrets GitHub configurés (3 secrets)
- [ ] CI/CD testé avec un push
- [ ] Workflow GitHub Actions passe au vert ✅

---

## 🎉 Vous avez terminé !

Votre pipeline CI/CD est maintenant opérationnel !

Chaque fois que vous ferez un `git push` sur la branche `main`, votre application sera automatiquement déployée sur votre VM GCP.

**Prochaines étapes possibles :**

- Configurer Nginx comme reverse proxy (servir sur le port 80)
- Ajouter un certificat SSL avec Let's Encrypt
- Configurer un nom de domaine
- Ajouter des tests automatiques dans le workflow
- Configurer des notifications (Slack, Discord)

Bon déploiement ! 🚀

