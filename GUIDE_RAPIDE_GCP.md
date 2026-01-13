# 🚀 Guide Rapide - Configuration GCP

## Configuration actuelle

- **VM GCP** : `nextjs-vm`
- **IP Publique** : `34.39.55.123`
- **Utilisateur** : `quentin.cialone-gcp`
- **Clé SSH** : `~/.ssh/gcp_nextjs`

---

## ✅ Étape 1 : Vérifier la clé SSH

Assurez-vous que votre clé SSH existe et a les bonnes permissions :

```bash
# Vérifier que la clé existe
ls -la ~/.ssh/gcp_nextjs

# Si elle n'existe pas, créez-la
ssh-keygen -t rsa -b 4096 -f ~/.ssh/gcp_nextjs -C "quentin@nextjs"

# Copier la clé publique sur le serveur
ssh-copy-id -i ~/.ssh/gcp_nextjs quentin.cialone-gcp@34.39.55.123

# Tester la connexion SSH
ssh -i ~/.ssh/gcp_nextjs quentin.cialone-gcp@34.39.55.123
```

---

## ✅ Étape 2 : Installer Ansible sur votre Mac

```bash
# Installer Ansible via Homebrew
brew install ansible

# Vérifier l'installation
ansible --version
```

---

## ✅ Étape 3 : Tester la connexion Ansible

Depuis le répertoire du projet :

```bash
cd /Users/quentinho/Projets/EEMI/AnsibleTest

# Tester le ping
ansible -i inventory.ini webserver -m ping

# Résultat attendu :
# 34.39.55.123 | SUCCESS => {
#     "changed": false,
#     "ping": "pong"
# }
```

### Si ça ne fonctionne pas :

```bash
# Tester avec verbose pour voir les erreurs
ansible -i inventory.ini webserver -m ping -vvv

# Tester la connexion SSH directe
ssh -i ~/.ssh/gcp_nextjs quentin.cialone-gcp@34.39.55.123 "echo 'Connexion OK'"
```

---

## ✅ Étape 4 : Configurer le pare-feu GCP

### Via la console GCP :

1. Allez sur **VPC Network** → **Firewall**
2. Créez une règle avec ces ports :
   - **22** (SSH)
   - **80** (HTTP)
   - **443** (HTTPS)
   - **3000** (Next.js)

### Via gcloud CLI :

```bash
# Créer une règle de pare-feu pour Next.js
gcloud compute firewall-rules create allow-nextjs \
    --allow tcp:3000 \
    --source-ranges 0.0.0.0/0 \
    --description "Allow Next.js on port 3000"

# Créer une règle pour HTTP/HTTPS
gcloud compute firewall-rules create allow-http-https \
    --allow tcp:80,tcp:443 \
    --source-ranges 0.0.0.0/0 \
    --description "Allow HTTP and HTTPS"

# Vérifier les règles
gcloud compute firewall-rules list
```

---

## ✅ Étape 5 : Créer votre repo GitHub

```bash
cd /Users/quentinho/Projets/EEMI/AnsibleTest

# Initialiser Git
git init
git add .
git commit -m "Initial commit - NextJS Ansible Deploy"
git branch -M main

# Créer le repo sur GitHub (via l'interface web)
# Puis ajouter le remote
git remote add origin https://github.com/VOTRE_USERNAME/AnsibleTest.git
git push -u origin main
```

---

## ✅ Étape 6 : Configurer les secrets GitHub

1. Allez sur votre repo GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. Créez ces 3 secrets :

### SSH_PRIVATE_KEY

```bash
# Afficher votre clé privée
cat ~/.ssh/gcp_nextjs
```

Copiez **TOUT** le contenu (incluant les lignes BEGIN et END)

### SERVER_IP

```
34.39.55.123
```

### REMOTE_USER

```
quentin.cialone-gcp
```

---

## ✅ Étape 7 : Modifier le playbook avec votre repo GitHub

Éditez `deploy.yml` ligne 6 :

```yaml
github_repo: "https://github.com/VOTRE_USERNAME/AnsibleTest.git"
```

Remplacez `VOTRE_USERNAME` par votre nom d'utilisateur GitHub.

---

## ✅ Étape 8 : Déploiement manuel (test)

```bash
cd /Users/quentinho/Projets/EEMI/AnsibleTest

# Lancer le déploiement
ansible-playbook -i inventory.ini deploy.yml

# Suivre l'exécution (prend environ 5-10 minutes)
```

---

## ✅ Étape 9 : Vérifier le déploiement

```bash
# Ouvrir dans le navigateur
open http://34.39.55.123:3000

# Ou avec curl
curl http://34.39.55.123:3000
```

---

## ✅ Étape 10 : Activer le CI/CD

Une fois que le déploiement manuel fonctionne :

```bash
# Faire un changement
echo "// Test CI/CD" >> pages/index.js

# Commit et push
git add .
git commit -m "Test CI/CD automatique"
git push origin main
```

Vérifiez sur GitHub → **Actions** pour voir le workflow s'exécuter !

---

## 🔍 Commandes de dépannage

### Sur votre Mac

```bash
# Tester la connexion SSH
ssh -i ~/.ssh/gcp_nextjs quentin.cialone-gcp@34.39.55.123

# Vérifier les permissions de la clé
chmod 600 ~/.ssh/gcp_nextjs

# Tester Ansible avec verbose
ansible -i inventory.ini webserver -m ping -vvv
```

### Sur la VM GCP

```bash
# Se connecter
ssh -i ~/.ssh/gcp_nextjs quentin.cialone-gcp@34.39.55.123

# Vérifier le service
sudo systemctl status nextjs-app

# Voir les logs
sudo journalctl -u nextjs-app -f

# Redémarrer le service
sudo systemctl restart nextjs-app

# Vérifier que le port 3000 écoute
sudo netstat -tulpn | grep 3000
```

---

## 📝 Checklist

- [ ] Clé SSH créée et copiée sur le serveur
- [ ] Connexion SSH fonctionne
- [ ] Ansible installé sur Mac
- [ ] Ansible ping fonctionne
- [ ] Pare-feu GCP configuré (ports 22, 80, 443, 3000)
- [ ] Repo GitHub créé
- [ ] Secrets GitHub configurés
- [ ] deploy.yml modifié avec le bon repo GitHub
- [ ] Déploiement manuel réussi
- [ ] Application accessible sur http://34.39.55.123:3000
- [ ] CI/CD testé avec un push

---

## 🎉 Bravo !

Une fois toutes ces étapes complétées, votre pipeline CI/CD est opérationnel !

Chaque push sur `main` déclenchera automatiquement un déploiement sur votre VM GCP. 🚀

