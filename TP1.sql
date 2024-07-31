	/* EXERCICE1 */
    
    /* obtenir la liste des 10 villes les plus peuplées en 2012 */
    SELECT * FROM new_schema.villes_france_free
	ORDER BY ville_population_2012 DESC LIMIT 10;
    
    /* Obtenir la liste des 50 villes ayant la plus faible superficie*/
    SELECT * FROM new_schema.villes_france_free
    ORDER BY ville_surface LIMIT 50;
    
    /* Obtenir la liste des départements d’outres-mer, c’est-à-dire ceux dont le numéro de 
		département commencent par “97”*/
    SELECT * FROM new_schema.departement 
    WHERE departement_code LIKE '97%';
    
    /* Obtenir le nom des 10 villes les plus peuplées en 2012,
		ainsi que le nom du département associé*/
	SELECT new_schema.villes_france_free.ville_nom,new_schema.departement.departement_nom
	FROM new_schema.villes_france_free
	INNER JOIN new_schema.departement ON new_schema.villes_france_free.ville_departement = new_schema.departement.departement_id
	ORDER BY new_schema.villes_france_free.ville_population_2012 DESC
	LIMIT 10;
    
    /* Obtenir la liste du nom de chaque département, associé à son code et du nombre de
	commune au sein de ces département, en triant afin d’obtenir en priorité les
	départements qui possèdent le plus de communes*/
	SELECT new_schema.departement.departement_nom, new_schema.departement.departement_code, COUNT(*) AS nombre_de_communes  
	FROM new_schema.departement  
	INNER JOIN new_schema.villes_france_free ON new_schema.departement.departement_code = new_schema.villes_france_free.ville_departement  
	GROUP BY new_schema.departement.departement_nom, new_schema.departement.departement_code  
	ORDER BY nombre_de_communes DESC LIMIT 0, 1000;
    
    /* Obtenir la liste des 10 plus grands départements, en terme de superficie*/
    SELECT departement_nom, ville_surface 
    FROM new_schema.departement,new_schema.villes_france_free
    ORDER BY ville_surface DESC 
    LIMIT 10;
    
    /* Compter le nombre de villes dont le nom commence par “Saint”*/
    SELECT count(*) as Nombre  FROM new_schema.villes_france_free 
    WHERE ville_nom LIKE 'Saint%';
    
    /* Obtenir la liste des villes qui ont un nom existants plusieurs fois, et trier afin d’obtenir
		en premier celles dont le nom est le plus souvent utilisé par plusieurs communes*/
    SELECT ville_nom, COUNT(*) AS nombre_de_villes
	FROM new_schema.villes_france_free
	GROUP BY ville_nom
	HAVING COUNT(*) > 1
	ORDER BY nombre_de_villes DESC;
    
    /* Obtenir en une seule requête SQL la liste des villes dont la superficie est supérieur à la
	superficie moyenne*/
    SELECT * FROM villes_france_free 
    WHERE ville_surface > (SELECT AVG(ville_surface) FROM villes_france_free);
    
    /* Obtenir la liste des départements qui possèdent plus de 2 millions d’habitants*/
	SELECT departement.departement_nom, SUM(villes_france_free.ville_population_2010) AS population_totale
	FROM departement
	INNER JOIN villes_france_free ON departement.departement_code = villes_france_free.ville_departement
	GROUP BY departement.departement_code, departement.departement_nom
	HAVING population_totale > 2000000
	ORDER BY departement.departement_code
	LIMIT 0, 1000;
    
    /* Remplacez les tirets par un espace vide, pour toutes les villes commençant par
	“SAINT-” (dans la colonne qui contient les noms en majuscule).*/
    UPDATE villes_france_free
	SET ville_commune = REPLACE(ville_commune, '-', ' ')
	WHERE ville_commune LIKE 'SAINT-%' AND ville_id > 0;


/*  EXERCICE 2 */

/* Obtenir l’utilisateur ayant le prénom “Muriel” et le mot de passe “test11”, sachant que
l’encodage du mot de passe est effectué avec l’algorithme Sha1 */
SELECT * FROM client WHERE prenom = 'Muriel' AND password = SHA1('test11');

/* Obtenir la liste de tous les produits qui sont présent sur plusieurs commandes */
SELECT nom FROM commande_ligne 
GROUP BY nom 
HAVING COUNT(*) > 1  LIMIT 0, 1000;

/* Obtenir la liste de tous les produits qui sont présent sur plusieurs commandes et y
ajouter une colonne qui liste les identifiants des commandes associées. */
SELECT commande_ligne.commande_id, GROUP_CONCAT(DISTINCT commande.id SEPARATOR ', ') AS commande_ids
FROM commande_ligne
INNER JOIN commande ON commande_ligne.commande_id = commande.id
GROUP BY commande_ligne.commande_id
HAVING COUNT(*) > 1;

/* Enregistrer le prix total à l’intérieur de chaque ligne des commandes, en fonction du
prix unitaire et de la quantité */
UPDATE commande_ligne SET prix_total = prix_unitaire * quantite;

/* Obtenir le montant total pour chaque commande et y voir facilement la date associée à
cette commande ainsi que le prénom et nom du client associé */
SELECT client.prenom, client.nom, commande.date_achat, SUM(commande_ligne.prix_total) AS montant_total
FROM commande
INNER JOIN client ON commande.client_id = client.id
INNER JOIN commande_ligne  ON commande.id = commande_ligne.commande_id
GROUP BY commande.id;

/* (difficulté très haute) Enregistrer le montant total de chaque commande dans le champ
intitulé “cache_prix_total” */
UPDATE commande
SET cache_prix_total = (SELECT SUM(prix_total) FROM commande_ligne WHERE commande_id = commande.id);

/* Obtenir le montant global de toutes les commandes, pour chaque mois */
SELECT MONTH(date_achat) AS mois, YEAR(date_achat) AS annee, SUM(cache_prix_total) AS montant_total
FROM commande
GROUP BY MONTH(date_achat), YEAR(date_achat);


