#!/bin/bash

# Script de test de connexion pour GCP
# Vérifie que tout est bien configuré avant le déploiement

echo "🔍 Test de connexion pour VM GCP"
echo "================================"
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables
SSH_KEY="$HOME/.ssh/gcp_nextjs"
SERVER_IP="34.39.55.123"
REMOTE_USER="quentin.cialone-gcp"

# Test 1 : Vérifier que la clé SSH existe
echo "📋 Test 1 : Vérification de la clé SSH"
if [ -f "$SSH_KEY" ]; then
    echo -e "${GREEN}✓ Clé SSH trouvée : $SSH_KEY${NC}"
    
    # Vérifier les permissions
    PERMS=$(stat -f "%A" "$SSH_KEY" 2>/dev/null || stat -c "%a" "$SSH_KEY" 2>/dev/null)
    if [ "$PERMS" = "600" ]; then
        echo -e "${GREEN}✓ Permissions correctes (600)${NC}"
    else
        echo -e "${YELLOW}⚠ Permissions incorrectes ($PERMS), correction...${NC}"
        chmod 600 "$SSH_KEY"
        echo -e "${GREEN}✓ Permissions corrigées${NC}"
    fi
else
    echo -e "${RED}✗ Clé SSH non trouvée : $SSH_KEY${NC}"
    echo "Créez-la avec : ssh-keygen -t rsa -b 4096 -f $SSH_KEY"
    exit 1
fi
echo ""

# Test 2 : Vérifier la connexion SSH
echo "📋 Test 2 : Test de connexion SSH"
if ssh -i "$SSH_KEY" -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$REMOTE_USER@$SERVER_IP" "echo 'SSH OK'" 2>/dev/null; then
    echo -e "${GREEN}✓ Connexion SSH réussie${NC}"
else
    echo -e "${RED}✗ Connexion SSH échouée${NC}"
    echo "Vérifiez :"
    echo "  - L'IP du serveur : $SERVER_IP"
    echo "  - L'utilisateur : $REMOTE_USER"
    echo "  - La clé SSH est bien copiée sur le serveur"
    echo ""
    echo "Pour copier la clé :"
    echo "  ssh-copy-id -i $SSH_KEY $REMOTE_USER@$SERVER_IP"
    exit 1
fi
echo ""

# Test 3 : Vérifier qu'Ansible est installé
echo "📋 Test 3 : Vérification d'Ansible"
if command -v ansible &> /dev/null; then
    VERSION=$(ansible --version | head -n 1)
    echo -e "${GREEN}✓ Ansible est installé : $VERSION${NC}"
else
    echo -e "${RED}✗ Ansible n'est pas installé${NC}"
    echo "Installez-le avec : brew install ansible"
    exit 1
fi
echo ""

# Test 4 : Tester le ping Ansible
echo "📋 Test 4 : Test de ping Ansible"
if ansible -i inventory.ini webserver -m ping 2>&1 | grep -q "SUCCESS"; then
    echo -e "${GREEN}✓ Ping Ansible réussi${NC}"
else
    echo -e "${RED}✗ Ping Ansible échoué${NC}"
    echo "Exécutez avec verbose pour plus de détails :"
    echo "  ansible -i inventory.ini webserver -m ping -vvv"
    exit 1
fi
echo ""

# Test 5 : Vérifier les fichiers requis
echo "📋 Test 5 : Vérification des fichiers"
FILES=("inventory.ini" "deploy.yml" "ansible.cfg" "package.json")
ALL_GOOD=true
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ $file${NC}"
    else
        echo -e "${RED}✗ $file manquant${NC}"
        ALL_GOOD=false
    fi
done

if [ "$ALL_GOOD" = false ]; then
    exit 1
fi
echo ""

# Résumé
echo "================================"
echo -e "${GREEN}🎉 Tous les tests sont passés !${NC}"
echo ""
echo "Vous pouvez maintenant :"
echo "  1. Lancer le déploiement manuel :"
echo "     ansible-playbook -i inventory.ini deploy.yml"
echo ""
echo "  2. Ou créer votre repo GitHub et configurer le CI/CD"
echo "     (voir GUIDE_RAPIDE_GCP.md)"
echo ""

