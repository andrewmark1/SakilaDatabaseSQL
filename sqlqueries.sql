USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name," ",last_name) as "actor name"
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT first_name, last_name
FROM actor
WHERE UPPER(last_name) like "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT first_name, last_name
FROM actor
WHERE UPPER(last_name) like "%LI%"
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE upper(country) IN ("AFGHANISTAN", "BANGLADESH", "CHINA");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER table actor
ADD COLUMN description blob; 

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER table actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name as "Last Name", count(last_name) as "Count of Last Name"
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(last_name)
FROM actor
GROUP BY last_name
HAVING count(last_name) > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
SET SQL_SAFE_UPDATES = 0;
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SELECT *
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLES.TABLE_NAME = "address";

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT stf.first_name, stf.last_name, addr.address
FROM staff as stf
LEFT JOIN address as addr
ON stf.address_id = addr.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT stf.first_name, stf.last_name, sum(pmt.amount) as "Total Rung Up", pmt.payment_date
FROM payment AS pmt
RIGHT JOIN staff as stf
ON stf.staff_id = pmt.staff_id
WHERE MONTH(pmt.payment_date) = 8 AND YEAR(pmt.payment_date) = 2005
GROUP BY stf.first_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT flm.title, count(act.actor_id)
FROM film as flm
INNER JOIN film_actor as act
ON flm.film_id = act.film_id
GROUP BY flm.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT flm.title as "Title", count(inv.inventory_id) as "# of Copies"
FROM inventory as inv
INNER JOIN film as flm
ON flm.film_id = inv.film_id
WHERE upper(flm.title) = "HUNCHBACK IMPOSSIBLE";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT cust.last_name, cust.first_name, sum(pmt.amount) as "Total Paid"
FROM customer as cust
INNER JOIN payment as pmt
ON cust.customer_id = pmt.customer_id
GROUP BY cust.customer_id
ORDER BY last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title FROM 
	(SELECT flm.title
	FROM film AS flm
	LEFT JOIN language AS lang
	ON flm.language_id = lang.language_id
	WHERE lang.name = "English"
    ) AS subquery
WHERE UPPER(title) LIKE "Q%" OR UPPER(title) LIKE "K%";

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT flmact.First_Name, flmact.Last_Name, film.title
FROM
	(SELECT flmact.actor_id AS "Actor_ID", flmact.film_id "Film_ID", act.first_name AS "First_Name", act.last_name AS "Last_Name"
	FROM film_actor as flmact
	LEFT JOIN actor as act
	ON act.actor_id = flmact.actor_id
	) AS flmact
LEFT JOIN film
ON flmact.Film_ID = film.film_id
WHERE UPPER(film.title) = "ALONE TRIP";

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT cust.first_name, cust.last_name, cust.email, adrcnt.country
FROM customer as cust
LEFT JOIN(
	SELECT cntcty.country,adr.*
	FROM
		(SELECT cnt.country, cty.city_id
		FROM country AS cnt
		INNER JOIN city AS cty
		ON cnt.country_id = cty.country_id
		) AS cntcty
	RIGHT JOIN address as adr
	ON adr.city_id = cntcty.city_id
    ) as adrcnt
ON cust.address_id = adrcnt.address_id
WHERE adrcnt.country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT filmcat.name AS Category, film.*
FROM
	(SELECT filmcat.film_id, catname.name
	FROM
		(SELECT cat.category_id, cat.name
		FROM category as cat
		WHERE cat.name = "Family"
		) AS catname
	INNER JOIN film_category as filmcat
	ON filmcat.category_id = catname.category_id
    ) as filmcat
INNER JOIN film
ON film.film_id = filmcat.film_id;

-- 7e. Display the most frequently rented movies in descending order.
SELECT count(filmrentals.film_id) as "Rental_Count", film.*
FROM
    (SELECT inv.film_id, rental.*
	FROM rental
	JOIN inventory as inv
	ON rental.inventory_id = inv.inventory_id
    ) AS filmrentals
INNER JOIN film
ON filmrentals.film_id = film.film_id
GROUP BY film.title
ORDER BY Rental_Count DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT sum(storepmt.amount) AS "Total Revenue", store.*, sum(storepmt.amount)
FROM
    (SELECT pmt.amount, stf.store_id
	FROM payment as pmt
	INNER JOIN staff as stf
	ON pmt.staff_id = stf.staff_id
    ) as storepmt
INNER JOIN store
ON store.store_id = storepmt.store_id
GROUP BY store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT strcity.store_id, strcity.city, country.country
FROM    
    (SELECT city.city, city.country_id, stradr.store_id
	FROM
		(SELECT str.store_id, str.address_id, adr.city_id
		FROM store AS str
		INNER JOIN address AS adr
		ON adr.address_id = str.address_id
		) as stradr
	INNER JOIN city
	ON city.city_id = stradr.city_id
    ) as strcity
INNER JOIN country
ON country.country_id = strcity.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name, sum(p.amount) as "Gross_Revenue"
FROM category AS c
JOIN film_category AS f
ON c.category_id = f.category_id
JOIN inventory AS i
ON i.film_id = f.film_id
JOIN rental AS r
ON r.inventory_id = i.inventory_id
JOIN payment AS p
ON p.rental_id = r.rental_id
GROUP BY name
ORDER BY Gross_Revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top5Genres AS
	SELECT c.name, sum(p.amount) as "Gross_Revenue"
	FROM category AS c
	JOIN film_category AS f
	ON c.category_id = f.category_id
	JOIN inventory AS i
	ON i.film_id = f.film_id
	JOIN rental AS r
	ON r.inventory_id = i.inventory_id
	JOIN payment AS p
	ON p.rental_id = r.rental_id
	GROUP BY name
	ORDER BY Gross_Revenue DESC
	LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM Top5Genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW Top5Genres;