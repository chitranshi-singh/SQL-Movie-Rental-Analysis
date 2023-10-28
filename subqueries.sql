-- 1 Find the average amount paid by the top 5 customers.

SELECT round(AVG(total_amount_paid), 2) AS avg_amount_paid
FROM (
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
             FROM customer B
                      JOIN address address ON customer.address_id = address.address_id
                      JOIN city city ON address.city_id = city.city_id
                      JOIN country country ON city.country_id = country.country_id
             WHERE country.country IN (
                 SELECT country.country
                 FROM customer B
                          JOIN address address ON customer.address_id = address.address_id
                          JOIN city city ON address.city_id = city.city_id
                          JOIN country country ON city.country_id = country.country_id
                 GROUP BY country.country
                 ORDER BY COUNT(customer.customer_id) DESC
             LIMIT 10
     )
GROUP BY country.country,
         city.city
ORDER BY COUNT(customer.customer_id) DESC LIMIT
10 )
GROUP BY customer.customer_id, customer.first_name, customer.last_name, country.country, city.city
ORDER BY SUM (payment.amount) DESC
    LIMIT 5
    ) AS total_amount_paid_by_top_5_customers

------------------------------------------------------------------------------

-- 2 Find out how many of the top 5 customers are based within each country.

select country.country,
       count(distinct customer.customer_id)        as all_customer_count,
       count(distinct top_5_customers.customer_id) as top_customer_count
from customer customer
         join address address on customer.address_id = address.address_id
         join city city on address.city_id = city.city_id
         join country country on city.country_id = country.country_id
         left join (
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
            ORDER BY COUNT(customer.customer_id) DESC LIMIT
        10)
GROUP BY country.country, city.city
ORDER BY COUNT(customer.customer_id) DESC LIMIT 10
)
GROUP BY
    customer.customer_id, customer.first_name, customer.last_name, country.country, city.city
ORDER BY SUM (payment.amount) DESC
    LIMIT 5
    ) as top_5_customers
on customer.customer_id = top_5_customers.customer_id
group by
    country.country
order by
    top_customer_count desc limit
    5

