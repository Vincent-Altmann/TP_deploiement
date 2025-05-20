# Rapport de Projet – Pipeline de Déploiement Continu

## 🎯 Contexte

Ce projet vise à mettre en place un pipeline de déploiement continu pour une API de supervision de capteurs environnementaux. L’objectif est de provisionner automatiquement l’infrastructure, de déployer l’API sur une machine distante, et d’automatiser l’ensemble du cycle de release à l’aide d’un outil CI/CD.

---

## 🧱 1. Architecture de l'infrastructure & Choix du provider

### Choix du provider : **Microsoft Azure**

Azure a été retenu pour sa simplicité d'intégration avec Terraform, son interface graphique intuitive, et son offre gratuite permettant de créer une machine virtuelle Ubuntu avec un groupe de sécurité configuré.

### Ressources créées via Terraform :

- ✅ Groupe de ressources
- ✅ Réseau virtuel + sous-réseau
- ✅ Adresse IP publique
- ✅ Interface réseau
- ✅ Groupe de sécurité réseau avec règles pour :
  - Port **22** (SSH)
  - Port **3000** (API Node.js)
- ✅ Machine virtuelle Ubuntu 18.04

L’adresse IP publique de la VM est récupérée automatiquement et affichée dans la sortie de `terraform apply`.

---

## ⚙️ 2. Fonctionnement de Terraform & Ansible

### 🔹 Configuration Terraform

Le dossier `infra/` contient :
- `main.tf` : décrit toutes les ressources Azure
- `variables.tf` : stocke les variables de configuration
- `outputs.tf` : affiche l’IP publique de la VM

Exécution :
```bash
cd infra
terraform init
terraform plan
terraform apply
```

Le mot de passe de la VM est saisi à l’exécution via variable. L’utilisateur par défaut est `azureuser`.

---

### 🔹 Playbook Ansible

Le dossier `ansible/` contient :
- `inventory.ini` : IP et identifiants de la VM
- `deploy.yml` : playbook qui effectue les opérations suivantes :
  1. Mise à jour des paquets
  2. Installation de Git et Node.js
  3. Clonage ou mise à jour du dépôt API
  4. Installation des dépendances avec `npm install`
  5. Démarrage de l’API avec **PM2**, persisté après reboot

Commande d’exécution locale :
```bash
ansible-playbook -i ansible/inventory.ini ansible/deploy.yml
```

---

## 🔁 3. Déroulé du pipeline CI/CD

### Outil choisi : **GitHub Actions**

GitHub Actions a été sélectionné pour son intégration native avec GitHub, sa simplicité de configuration, et sa gratuité pour les petits projets.

### Étapes automatisées via le pipeline :
1. À chaque `push` de **tag**, GitHub Actions :
   - Clône le dépôt
   - Exécute le script `release.sh`
2. Le script `release.sh` :
   - Bump la version avec `standard-version`
   - Génère un changelog
   - Push les tags sur Git
   - Déclenche le **playbook Ansible** pour déployer l’API

Le fichier de workflow se trouve dans :
```
.github/workflows/deploy.yml
```

Extrait :
```yaml
on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Ansible
        run: sudo apt-get install ansible -y
      - name: Execute release script
        run: ./release.sh
```

---

## 🧪 Tests réalisés

- ✅ Déploiement initial via Ansible validé
- ✅ API accessible depuis l’extérieur (`http://<IP_VM>:3000`)
- ✅ Pipeline GitHub déclenché automatiquement sur tag `vX.Y.Z`

---

## 🧩 Problèmes rencontrés

- ❗ Node.js n’était pas préinstallé sur la VM — résolu par ajout d’un script d’installation NodeSource dans le playbook.
- ❗ Configuration du mot de passe SSH — solution : utilisation de variables Terraform et non de clé SSH pour simplifier.
- ❗ Autorisation du port 3000 — résolu par l'ajout d’une règle de sécurité dans le NSG Terraform.

---

## 📁 Structure finale du dépôt

```
.
├── api/                ← Code source de l’API Node.js
├── ansible/            ← Playbook de déploiement Ansible
├── infra/              ← Configuration Terraform (Azure)
├── .github/workflows/  ← Pipeline GitHub Actions
├── release.sh          ← Script de release automatisée
└── rapport.md          ← Ce document
```

---

## ✅ Conclusion

Ce projet démontre comment industrialiser une chaîne complète de déploiement continu, de l’infrastructure jusqu’au code applicatif, à l’aide d’outils professionnels (Terraform, Ansible, GitHub Actions).

Le résultat : une solution prête à être utilisée et extensible pour de futurs microservices ou environnements (staging, prod).
