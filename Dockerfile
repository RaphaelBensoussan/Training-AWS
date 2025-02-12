# Étape 1 : Utiliser l'image officielle de Node.js comme base
FROM node:16 AS build

# Étape 2 : Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Étape 3 : Copier les fichiers package.json et package-lock.json (ou yarn.lock)
COPY package*.json ./

# Étape 4 : Installer les dépendances de l'application
RUN npm install

# Étape 5 : Copier tout le code source dans le conteneur
COPY . .

# Étape 6 : Construire l'application React pour la production
RUN npm run build

# Étape 7 : Utiliser une image légère de Nginx pour servir les fichiers
FROM nginx:alpine

# Étape 8 : Copier les fichiers construits depuis l'étape précédente
COPY --from=build /app/build /usr/share/nginx/html

# Étape 9 : Exposer le port 5000 pour accéder à l'application
EXPOSE 5000

# Étape 10 : Démarrer Nginx, mais sans configuration personnalisée
CMD ["nginx", "-g", "daemon off;"]
