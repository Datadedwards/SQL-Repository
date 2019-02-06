USE sakila

-- 1a. Display the first and last names of all actors from the table actor.

SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS Actor_Name
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:

SELECT *
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT *
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

ALTER TABLE actor
ADD description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(last_name) AS same_name
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, COUNT(last_name) AS same_name
FROM actor
GROUP BY last_name
HAVING same_name > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

UPDATE actor
SET first_name = 'HARPO'
WHERE actor_id = 172;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

UPDATE actor
set first_name = IF(first_name = 'HARPO', 'GROUCHO', 'GROUCHO')
WHERE actor_id = 172;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
use sakila;

show create table address;

CREATE TABLE address
(
address_id SMALLINT(5) AUTO_INCREMENT NOT NULL,
address VARCHAR(50) NOT NULL,
address2 VARCHAR(50) NULL,
district VARCHAR(20) NOT NULL,
city_id SMALLINT(5) NOT NULL,
postal_code VARCHAR(10) NULL,
phone VARCHAR(20) NOT NULL,
location GEOMETRY NOT NULL,
last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
PRIMARY KEY (address_id)
);

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT s.first_name, s.last_name, a.address
FROM staff AS s
INNER JOIN address AS a
	ON s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT s.first_name, s.last_name, SUM(p.amount) AS Total_Amount_Rung
FROM staff AS s
INNER JOIN payment AS p
	ON s.staff_id = p.staff_id
WHERE p.payment_date BETWEEN '2005-08-1' AND '2005-08-31'
GROUP BY s.first_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT f.title, count(f.title) AS Number_of_Actors
FROM film_actor AS fa
INNER JOIN film AS f
	ON fa.film_id = f.film_id
GROUP BY f.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT f.title AS film, count(i.film_id) AS Copies
FROM inventory AS i
INNER JOIN film AS f
	ON i.film_id=f.film_id
WHERE f.title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT c.first_name, c.last_name, SUM(p.amount) AS Total_Paid
FROM payment AS p
INNER JOIN customer AS c
	ON p.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title
FROM film
WHERE title LIKE 'Q%' OR title LIKE 'K%'
	AND language_id =
    (
    SELECT language_id
    FROM language
    WHERE name = 'English'
    );

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name
FROM actor
WHERE actor_ID IN 
	(
    SELECT actor_ID
    FROM film_actor
    WHERE film_id =
		(
        SELECT film_id
        FROM film
        WHERE title = 'Alone Trip'
        )
    );

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT cu.first_name, cu.last_name, cu.email
FROM customer AS cu
INNER JOIN address AS a
	ON cu.address_id = a.address_id
INNER JOIN city AS ci
	ON a.city_id = ci.city_id
INNER JOIN country AS co
	ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT f.title, f.rating
FROM film AS f
INNER JOIN film_category AS fc
	ON f.film_id = fc.film_id
INNER JOIN category AS c
	ON fc.category_id = c.category_id
WHERE c.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.

SELECT f.title, COUNT(r.rental_id) as Times_Rented
FROM rental AS r
INNER JOIN inventory AS i
	ON i.inventory_id = r.inventory_id
INNER JOIN film as f
	on f.film_id = i.film_id
GROUP BY f.title
ORDER BY Times_Rented DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT s.store_id, SUM(p.amount) AS Revenue
FROM staff AS s
INNER JOIN payment AS p
	ON p.staff_id = s.staff_id
GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT s.store_ID, ci.city, co.country
FROM store AS s
INNER JOIN address AS a
	ON s.address_id = a.address_id
INNER JOIN city AS ci
	ON a.city_id = ci.city_id
INNER JOIN country AS co
	ON ci.country_id = co.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT c.name, SUM(p.amount) AS Gross_Revenue
FROM category AS c
INNER JOIN film_category AS f
	ON c.category_id = f.category_id
INNER JOIN inventory AS i
	ON f.film_id = i.film_id
INNER JOIN rental AS r
	ON i.inventory_id = r.inventory_id
INNER JOIN payment AS p
	ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY Gross_Revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW Top_5_Genre_By_Gross_Revenue AS
SELECT c.name, SUM(p.amount) AS Gross_Revenue
FROM category AS c
INNER JOIN film_category AS f
	ON c.category_id = f.category_id
INNER JOIN inventory AS i
	ON f.film_id = i.film_id
INNER JOIN rental AS r
	ON i.inventory_id = r.inventory_id
INNER JOIN payment AS p
	ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY Gross_Revenue DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM Top_5_Genre_By_Gross_Revenue;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW Top_5_Genre_By_Gross_Revenue;

/*  
    ************
       PART 2
    ************
				*/

/* Using your gwsis database, develop a stored procedure that will drop an individual student's enrollment from a class. 
Be sure to refer to the existing stored procedures, enroll_student and terminate_all_class_enrollment in the gwsis database for reference. */

USE gwsis



