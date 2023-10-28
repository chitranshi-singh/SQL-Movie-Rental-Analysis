-- 1 Find the average amount paid by the top 5 customers

WITH total_amount_paid_by_top_5_customers_cte (customer_id,
                                               first_name,
                                               last_name,
                                               country,
                                               city, total_amount_paid
    ) AS (SELECT customer.customer_id,
                 customer.first_name,
                 customer.last_name,
                 country.country,
                 city.city,
                 sum(payment.amount) AS total_amount_paid
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
                  ORDER BY COUNT(customer.customer_id) DESC LIMIT
    10 )
GROUP BY country.country, city.city
ORDER BY COUNT (customer.customer_id) DESC
    LIMIT 10
    )
GROUP BY
    customer.customer_id, customer.first_name, customer.last_name, country.country, city.city
ORDER BY SUM (payment.amount) DESC
    LIMIT 5
    )
SELECT round(AVG(total_amount_paid), 2) AS avg_amount_paid
FROM total_amount_paid_by_top_5_customers_cte

------------------------------------------------------------------------------

-- 2 Find out how many of the top 5 customers are based within each country

WITH top_5_customers_cte (customer_id,
                          first_name,
                          last_name,
                          country,
                          city, total_amount_paid
    ) AS (SELECT customer.customer_id,
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
                  ORDER BY COUNT(customer.customer_id) DESC LIMIT
    10 )
GROUP BY country.country, city.city
ORDER BY COUNT (customer.customer_id) DESC
    LIMIT 10
    )
GROUP BY
    customer.customer_id, customer.first_name, customer.last_name, country.country, city.city
ORDER BY SUM (payment.amount) DESC
    LIMIT 5
    )
SELECT country.country,
       count(distinct customer.customer_id)                  AS all_customer_count,
       count(distinct top_5_customers_ctcountry.customer_id) AS top_customer_count
FROM customer B
         join address address ON customer.address_id = address.address_id
         join city city ON address.city_id = city.city_id
         join country country ON city.country_id = country.country_id
         left join top_5_customers_cte ON top_5_customers_cte.customer_id = customer.customer_id
GROUP BY country.country
ORDER BY top_customer_count desc LIMIT 5