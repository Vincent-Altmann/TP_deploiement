#!/bin/bash

# ====== CONFIGURATION ======
API_DIR="api"
INVENTORY_FILE="ansible/inventory.ini"
PLAYBOOK_FILE="ansible/deploy.yml"

# ====== BUMP VERSION (standard-version) ======
echo "🔁 Mise à jour de la version..."
cd $API_DIR
npx standard-version

if [ $? -ne 0 ]; then
  echo "❌ Erreur lors de la génération du changelog."
  exit 1
fi

# ====== GIT PUSH + TAG ======
echo "🔁 Push du code et du tag Git..."
git push --follow-tags origin main

if [ $? -ne 0 ]; then
  echo "❌ Erreur lors du push Git."
  exit 1
fi

cd ..

# ====== DÉPLOIEMENT VIA ANSIBLE ======
echo "🚀 Lancement du déploiement Ansible..."
ansible-playbook -i "$INVENTORY_FILE" "$PLAYBOOK_FILE"

if [ $? -ne 0 ]; then
  echo "❌ Le déploiement Ansible a échoué."
  exit 1
fi

echo "✅ Déploiement terminé avec succès."
