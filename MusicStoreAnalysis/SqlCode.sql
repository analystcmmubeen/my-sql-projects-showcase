--						Question Set - Easy Question
-- Q1. Who is the senior most employee based on job title?

SELECT TOP 1 first_name, last_name, title, levels 
FROM employee
ORDER BY levels DESC

-- Q2. Which countries have the most Invoices?

SELECT billing_country ,COUNT(*) total_invoices FROM invoice
GROUP BY billing_country
ORDER BY COUNT(*) DESC

-- Q3. What are top 3 values of total invoice?

SELECT TOP 3 billing_country,total FROM invoice
ORDER BY total DESC

-- Q4. Which city has the best customer? We would like to throw a promotional music
-- festival in the city we made the most money. Write a query that returns one city
-- that has the highest sum of invoice totals. Return both the city name & sum of all
-- all invoice totals.

SELECT TOP 1 billing_city, SUM(total) total_invoice_sum FROM invoice
GROUP BY billing_city
ORDER BY SUM(total) DESC

-- Q5. Who is the best customer? The the customer who has spent the most money will be
-- declared the best customer. Write a query that returns the person who has spent the
-- most money.

SELECT TOP 1 c.customer_id, c.first_name, c.last_name, SUM(i.total) total_purch 
FROM invoice i
JOIN customer c ON i.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY SUM(i.total) DESC

--						Question Set - Moderate
-- Q1. Write query to return the email, first name, last name & Genre of all ROCK music
-- listners. Return your list ordered alphabetically by email starting with A

SELECT c.first_name, c.last_name, c.email Genre_Type FROM invoice i
JOIN customer c ON i.customer_id = c.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY c.first_name, c.last_name, c.email, g.name
ORDER BY c.email ASC

-- SECOND METHOD - this is optimized query as this use only 3 joins

SELECT c.first_name, c.last_name, c.email FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
WHERE il.track_id IN(
		SELECT t.track_id FROM track t
		JOIN genre g ON t.genre_id = g.genre_id
		WHERE g.name = 'Rock'
		)
GROUP BY c.first_name, c.last_name, c.email
ORDER  BY c.email ASC

-- Q2. Let's invite artists who have written the most rock music in our dataset. Write
-- a query that returns ARTIST NAME & TOTAL TRACK COUNT of the top 10 music bands.

SELECT TOP 10 ar.name, COUNT(t.track_id) number_of_songs FROM track t
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY ar.name
ORDER BY number_of_songs DESC

-- Q3. Return all the track names that have a song length longer than the average song
-- length. Return the NAME and MILLISECONDS for each track. Order by the song length
-- with the logest songs listed first.

SELECT name Song_Name, milliseconds FROM track
WHERE milliseconds > (
		SELECT AVG(milliseconds) 
		FROM track
		)
ORDER BY milliseconds DESC

--						Question Set - Advance

-- Q1. Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent.

WITH best_selling_artist AS(
	SELECT TOP 1 ar.artist_id, ar.name artist_name, SUM(il.unit_price*il.quantity)
	total_spent
	FROM invoice_line il
	JOIN track t ON il.track_id = t.track_id
	JOIN album al ON t.album_id = al.album_id
	JOIN artist ar ON al.artist_id = ar.artist_id
	GROUP BY ar.artist_id, ar.name
	ORDER BY total_spent DESC
)
SELECT c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity)
total_spent
FROM invoice_line il
JOIN invoice i ON il.invoice_id = i.invoice_id
JOIN customer c ON i.customer_id = c.customer_id
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN best_selling_artist bsa ON al.artist_id = bsa.artist_id
GROUP BY c.first_name, c.last_name, bsa.artist_name
ORDER BY total_spent DESC

-- Q2. We want to find out the most popular music genre for each country. We determine
-- the most popular genre as the genre with highest amount of purchases. Write a query
-- that returns each country along with the top genre. For countries where the maximum
-- number of purchahses is shared return all Genre.

WITH most_popular_genre AS(
		SELECT COUNT(il.quantity) purchases, c.country, g.name,
		ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC)
		AS rowno
		FROM invoice_line il
		JOIN invoice i ON il.invoice_id = i.invoice_id
		JOIN track t ON il.track_id = t.track_id
		JOIN genre g ON t.genre_id = g.genre_id
		JOIN customer c ON i.customer_id = c.customer_id
		GROUP BY c.country,g.name
		)
SELECT * FROM most_popular_genre WHERE rowno<=1

-- Q2. We want to find out the most popular music genre for each country. We determine
-- the most popular genre as the genre with highest amount of purchases. Write a query
-- that returns each country along with the top genre. For countries where the maximum
-- number of purchahses is shared return all Genre.

WITH most_populer_genre AS(
		SELECT c.country, COUNT(il.quantity) purchases, g.name genre_name,
		ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) RowNo
		FROM invoice_line il
		JOIN invoice i ON il.invoice_id = i.invoice_id
		JOIN customer c ON i.customer_id = c.customer_id
		JOIN track t ON il.track_id = t.track_id
		JOIN genre g ON t.genre_id = g.genre_id
		GROUP BY c.country, g.name
		)
SELECT * FROM most_populer_genre WHERE RowNo <= 1
ORDER BY purchases DESC

-- Write a query that determines the customer has spent the most on music for each
-- country. Write a query that returns the country along with the top customer and how
-- much they spent. For countries where the top amount spent is shered, provide all
-- customers who spent this amount.

WITH customer_with_country AS(
	SELECT c.customer_id, c.first_name, c.last_name, i.billing_country, SUM(i.total) 
	total_spending,
	ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) RowNO
	FROM invoice i
	JOIN customer c ON i.customer_id = c.customer_id
	GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
)
SELECT * FROM customer_with_country WHERE RowNO <= 1
ORDER BY total_spending DESC
