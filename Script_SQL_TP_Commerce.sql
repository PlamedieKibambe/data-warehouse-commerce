-- TP Master 2 : Entrepôt de données - Domaine Commerce
-- MySQL 8. Exécuter dans une base de travail dédiée.
CREATE DATABASE IF NOT EXISTS dw_commerce CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE dw_commerce;

-- Tables de staging : importer les feuilles Excel dans ces tables ou adapter les noms
-- aux tables créées lors de l'import. Les colonnes sources sont volontairement conservées.
CREATE TABLE IF NOT EXISTS STG_VENTES (
  code_vente VARCHAR(30), date_vente VARCHAR(30), code_client VARCHAR(30),
  code_produit VARCHAR(30), code_magasin VARCHAR(30), quantite DECIMAL(12,2),
  prix_unitaire DECIMAL(12,2), devise VARCHAR(10), statut VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS DIM_TEMPS (
  date_key INT PRIMARY KEY,
  date_complete DATE NOT NULL UNIQUE,
  jour TINYINT, mois TINYINT, nom_mois VARCHAR(20), trimestre TINYINT, annee SMALLINT
);
CREATE TABLE IF NOT EXISTS DIM_CLIENT (
  client_key INT AUTO_INCREMENT PRIMARY KEY,
  code_client VARCHAR(30) NOT NULL UNIQUE,
  segment VARCHAR(100), ville VARCHAR(100)
);
CREATE TABLE IF NOT EXISTS DIM_PRODUIT (
  produit_key INT AUTO_INCREMENT PRIMARY KEY,
  code_produit VARCHAR(30) NOT NULL UNIQUE,
  nom_produit VARCHAR(150), categorie VARCHAR(100), prix_catalogue_usd DECIMAL(12,2)
);
CREATE TABLE IF NOT EXISTS DIM_MAGASIN (
  magasin_key INT AUTO_INCREMENT PRIMARY KEY,
  code_magasin VARCHAR(30) NOT NULL UNIQUE,
  nom_magasin VARCHAR(150), ville VARCHAR(100)
);
CREATE TABLE IF NOT EXISTS FAIT_VENTES (
  vente_key BIGINT AUTO_INCREMENT PRIMARY KEY,
  code_vente VARCHAR(30) NOT NULL UNIQUE,
  date_key INT NOT NULL,
  client_key INT NOT NULL,
  produit_key INT NOT NULL,
  magasin_key INT NOT NULL,
  quantite DECIMAL(12,2) NOT NULL,
  prix_unitaire DECIMAL(12,2) NOT NULL,
  montant_vente DECIMAL(14,2) NOT NULL,
  devise VARCHAR(10) NOT NULL,
  statut VARCHAR(30) NOT NULL,
  CONSTRAINT fk_fv_temps FOREIGN KEY(date_key) REFERENCES DIM_TEMPS(date_key),
  CONSTRAINT fk_fv_client FOREIGN KEY(client_key) REFERENCES DIM_CLIENT(client_key),
  CONSTRAINT fk_fv_produit FOREIGN KEY(produit_key) REFERENCES DIM_PRODUIT(produit_key),
  CONSTRAINT fk_fv_magasin FOREIGN KEY(magasin_key) REFERENCES DIM_MAGASIN(magasin_key)
);

CREATE TABLE IF NOT EXISTS ETL_REJETS (
  rejet_key BIGINT AUTO_INCREMENT PRIMARY KEY,
  code_vente VARCHAR(30),
  raison_rejet VARCHAR(255) NOT NULL,
  date_rejet TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Diagnostic sur staging
SELECT COUNT(*) AS lignes_source FROM STG_VENTES;
SELECT code_vente, COUNT(*) AS occurrences
FROM STG_VENTES GROUP BY code_vente HAVING COUNT(*) > 1;
SELECT * FROM STG_VENTES WHERE quantite IS NULL OR quantite <= 0;
SELECT * FROM STG_VENTES WHERE prix_unitaire IS NULL OR prix_unitaire <= 0;
SELECT * FROM STG_VENTES WHERE devise NOT IN ('USD','CDF') OR devise IS NULL;
SELECT v.* FROM STG_VENTES v
LEFT JOIN DIM_CLIENT c ON c.code_client=v.code_client
WHERE c.client_key IS NULL;

-- Requêtes analytiques après chargement
-- 1. Chiffre d'affaires par magasin et devise
SELECT m.nom_magasin, f.devise, SUM(f.montant_vente) AS chiffre_affaires
FROM FAIT_VENTES f JOIN DIM_MAGASIN m ON m.magasin_key=f.magasin_key
WHERE f.statut='Payée'
GROUP BY m.nom_magasin, f.devise
ORDER BY f.devise, chiffre_affaires DESC;

-- 2. Chiffre d'affaires par catégorie et devise
SELECT p.categorie, f.devise, SUM(f.montant_vente) AS chiffre_affaires
FROM FAIT_VENTES f JOIN DIM_PRODUIT p ON p.produit_key=f.produit_key
WHERE f.statut='Payée'
GROUP BY p.categorie, f.devise
ORDER BY f.devise, chiffre_affaires DESC;

-- 3. Top 10 produits par quantité vendue
SELECT p.code_produit, p.nom_produit, SUM(f.quantite) AS quantite_totale
FROM FAIT_VENTES f JOIN DIM_PRODUIT p ON p.produit_key=f.produit_key
WHERE f.statut='Payée' AND f.quantite>0
GROUP BY p.code_produit, p.nom_produit
ORDER BY quantite_totale DESC LIMIT 10;

-- 4. Chiffre d'affaires par segment de clientèle et devise
SELECT c.segment, f.devise, SUM(f.montant_vente) AS chiffre_affaires
FROM FAIT_VENTES f JOIN DIM_CLIENT c ON c.client_key=f.client_key
WHERE f.statut='Payée'
GROUP BY c.segment, f.devise
ORDER BY f.devise, chiffre_affaires DESC;

-- 5. Volume et taux de ventes par statut
SELECT statut, COUNT(*) AS nombre_ventes,
       ROUND(100*COUNT(*)/(SELECT COUNT(*) FROM FAIT_VENTES),2) AS pourcentage
FROM FAIT_VENTES GROUP BY statut;

-- 6. Evolution mensuelle du CA payé par devise
SELECT t.annee, t.mois, f.devise, SUM(f.montant_vente) AS chiffre_affaires
FROM FAIT_VENTES f JOIN DIM_TEMPS t ON t.date_key=f.date_key
WHERE f.statut='Payée'
GROUP BY t.annee,t.mois,f.devise
ORDER BY t.annee,t.mois,f.devise;
