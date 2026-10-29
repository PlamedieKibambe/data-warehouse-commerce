Data Warehouse Commerce

1. Présentation du projet

Ce projet consiste à concevoir et à mettre en œuvre un Data Warehouse pour l'analyse des ventes d'une entreprise commerciale.

Il a été réalisé dans le cadre des travaux pratiques du cours de Data Warehouse. Il vise à centraliser les données commerciales et à faciliter leur exploitation pour la production d'indicateurs d'aide à la décision.

2. Objectifs

- Collecter et intégrer les données commerciales.
- Organiser les données dans une architecture décisionnelle.
- Mettre en place des tables de dimensions et une table de faits.
- Analyser les ventes par période, par produit et par magasin.
- Calculer des indicateurs utiles à la prise de décision.

3. Technologies utilisées

- SGBD : MySQL
- Outil d'administration : phpMyAdmin
- Langage de requêtes : SQL
- Gestion et partage du projet : GitHub
- Sources de données : fichiers Excel et scripts SQL

4. Architecture du Data Warehouse

La base de données utilisée est "dw_commerce".

Elle comprend notamment les tables suivantes :

Tables de staging

- "STG_CLIENTS"
- "STG_PRODUITS"
- "STG_MAGASINS"
- "STG_VENTES"

Tables de dimensions

- "DIM_CLIENT"
- "DIM_PRODUIT"
- "DIM_MAGASIN"
- "DIM_TEMPS"

Table de faits

- "FAIT_VENTES"

Cette architecture permet d'organiser les données autour des ventes et de faciliter les analyses multidimensionnelles.

5. Travaux réalisés

- Importation des données sources.
- Chargement des tables de staging.
- Alimentation des dimensions.
- Chargement de la table de faits.
- Analyse du chiffre d'affaires par mois.
- Identification des produits les plus vendus ou générant les meilleures ventes.
- Analyse des ventes par magasin.

6. Structure du dépôt

Le dépôt contient les fichiers sources du projet, notamment les fichiers Excel, les scripts SQL et l'export de la base de données.

Le fichier SQL "database/dw_commerce.sql" permet de conserver une copie exportée de la base de données à la date de l'exportation.

7. Installation et utilisation

1. Installer MySQL et phpMyAdmin, ou un environnement équivalent.
2. Créer une base de données nommée "dw_commerce".
3. Importer le fichier "database/dw_commerce.sql" dans phpMyAdmin.
4. Exécuter les scripts SQL nécessaires pour examiner les données et reproduire les analyses.

8. Conclusion

Ce projet met en pratique les principales étapes de réalisation d'un Data Warehouse commercial, depuis l'intégration des données jusqu'à leur exploitation à travers des requêtes analytiques.

Il constitue une base pour le suivi des ventes et l'aide à la décision.

9. Plamidie KIBAMBE MUSAWU

Réalisé l'assistant Plamedie Kibambe Musawu 
