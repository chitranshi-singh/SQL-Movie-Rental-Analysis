-- 1 Find the top 10 countries for Rockbuster in terms of customer numbers

SELECT country.country,
       count(customer.customer_id) AS total_customers
FROM country country
         JOIN city city ON country.country_id = city.country_id
         JOIN address address ON city.city_id = address.city_id
         JOIN customer customer ON address.address_id = customer.address_id
GROUP BY country.country
ORDER BY count(customer.customer_id) DESC LIMIT 10

------------------------------------------------------------------------------

-- 2 Find the top 10 cities within the top 10 countries identified in 1

SELECT country.country,
       city.city,
       COUNT(customer.customer_id) AS total_customers
FROM customer customer
         JOIN address address ON customer.address_id = address.address_id
         JOIN city city ON address.city_id = city.city_id
         JOIN country country ON city.country_id = country.country_id
WHERE country.country IN (
    SELECT country.country
    FROM customer A
             JOIN address address ON customer.address_id = address.address_id
             JOIN city city ON address.city_id = city.city_id
             JOIN country country ON city.country_id = country.country_id
    GROUP BY country.country
    ORDER BY COUNT(customer.customer_id) DESC
    LIMIT 10
    )
GROUP BY
    country.country,
    city.city
ORDER BY
    COUNT (customer.customer_id) DESC LIMIT
    10

------------------------------------------------------------------------------

-- Find the top 5 customers in the top 10 cities who have paid the highest total amounts to Rockbuster

SELECT customer.customer_id,
       customer.first_name,
       customer.last_name,
       country.country,
       city.city,
       SUM(payment.amount) AS total_amount_paid
FROM payment payment
         JOIN customer customer ON payment.customer_id = customer.customer_id
         JOIN address address ON customer.address_id = address.address_id
         JOIN city city ON address.city_id = city.city_id
         JOIN country country ON city.country_id = country.country_id
WHERE city.city IN (
    SELECT city.city
    FROM customer customer
             JOIN address address ON customer.address_id = address.address_id
             JOIN city city ON address.city_id = city.city_id
             JOIN country country ON city.country_id = country.country_id
    WHERE country.country IN (
        SELECT country.country
        FROM customer customer
                 JOIN address address ON customer.address_id = address.address_id
                 JOIN city city ON address.city_id = city.city_id
                 JOIN country country ON city.country_id = country.country_id
        GROUP BY country.country
        ORDER BY COUNT(customer.customer_id) DESC
    LIMIT 10
    )
GROUP BY
    country.country,
    city.city
ORDER BY
    COUNT (customer.customer_id) DESC LIMIT
    10 )
GROUP BY customer.customer_id, customer.first_name, customer.last_name, country.country, city.city
ORDER BY SUM (payment.amount) DESC
    LIMIT 5
