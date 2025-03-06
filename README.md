# 📌 Compte rendu du déploiement automatisé

Ce document décrit les étapes du déploiement automatisé d'une application React sur AWS EC2 en utilisant Docker et GitHub Actions.

---

## 🔹 1. Préparation et Sécurisation

### Génération de clé SSH
- Création d'une clé SSH pour sécuriser les communications entre l'ordinateur local, GitHub et le serveur AWS.

### Configuration du VPS
- Mise en place d'une instance **EC2 Debian**.
- Ajout de la clé SSH pour l'authentification.

---

## 🔹 2. Mise en place de l'infrastructure

### Installation de Docker
- Installation de Docker sur le VPS.
- Test de son fonctionnement avec :
  ```sh
  docker run hello-world
  ```

### Configuration de GitHub Actions
- Création de **secrets** pour stocker les informations sensibles (clé SSH privée, etc.).
- Configuration du fichier **ci.yml** pour automatiser le déploiement.

---

## 🔹 3. Préparation de l'application

### Création des fichiers Docker
- Rédaction des fichiers `Dockerfile` et `docker-compose.yml` pour définir l'environnement d'exécution de l'application.

---

## 🔹 4. Sécurité et validation

### Configuration de la sécurité AWS
- Ouverture du **port 5000** pour permettre l'accès à l'application.

### Tests finaux
- Vérification du déploiement après un **push** sur GitHub.
- Test de l'accès à l'application.

---

## Script d'automatisation (`ci.yml`)

```yaml
name: Deploy Application

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Check secrets
        run: |
          echo "SSH_HOST: ${{ secrets.SSH_HOST }}"
          echo "SSH_USER: ${{ secrets.SSH_USER }}"

      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y openssh-client

      - name: Set up SSH keys
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.SSH_PRIVATE_KEY }}" | base64 --decode > ~/.ssh/ssh_aws
          chmod 600 ~/.ssh/ssh_aws
          ssh-keyscan -H ${{ secrets.SSH_HOST }} >> ~/.ssh/known_hosts

      - name: Deploy application via SSH
        run: |
          ssh ${{ secrets.SSH_USER }}@${{ secrets.SSH_HOST }} << 'EOF'
            cd ${{ secrets.WORK_DIR }}
            git pull origin main
            docker-compose down
            docker system prune -af
            docker-compose up --build -d
          EOF

      - name: Clean up SSH keys
        run: |
          rm -rf ~/.ssh
```

---

## Dockerfile

```dockerfile
# Utiliser l'image officielle de Node.js comme base
FROM node:16 AS build

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers package.json et package-lock.json
COPY package*.json ./

# Installer les dépendances
RUN npm install

# Copier tout le code source
COPY . .

# Construire l'application React pour la production
RUN npm run build

# Utiliser une image légère de Nginx
FROM nginx:alpine

# Copier les fichiers construits
COPY --from=build /app/build /usr/share/nginx/html

# Exposer le port 5000
EXPOSE 5000

# Démarrer Nginx
CMD ["nginx", "-g", "daemon off;"]
```

---

## `docker-compose.yml`

```yaml
version: '3'

services:
  react-app:
    build: .
    ports:
      - "5000:3000"
```

---

