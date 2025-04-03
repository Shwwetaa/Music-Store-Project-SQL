Q1: Who is the Most senior employee based on job title?
 
select * from employee
order by levels desc
limit 1

Q2: Which countries have the most invoices?

select count(*) as c,billing_country 
from invoice
group by billing_country
order by c desc

Q3: what are top 3 values of total invoices?

select total from invoice
order by total desc
limit 3

Q4: Which city has the best customer? 
we would like to throw a promotional musical festival in the city we made the most money. 
write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoices totals.

select SUM(total) as invoice_total,billing_city 
from invoice
group by billing_city
order by invoice_total desc

Q5: who is the best customer?
the customer who has spent the most money will be declared the best customer. 
write a query that returns the person who has spent the most money.

select customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1

Q6: Write a query to return the email, first name, last name, & genre of all the rock music listeners.
Return your list ordered alphabetically by email starting with A.

select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
WHERE track_id in(
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'
)
order by email;

Q7: let s invite the artist who have written the most rock music in our dataset. 
write a query that returns the artist name and total track count of the top 10 rock bands.

select artist.artist_id, artist.name, COUNT(artist.artist_id) as number_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10

Q8: Return all the track names that have a song length longer than the average song length.
return the name and milliseconds for each track.
order by song length with the longest songs listed first.

select name, milliseconds
from track
where milliseconds >(
	select avg(milliseconds) as avg_track_length
	from track)
order by milliseconds desc

Q9: Find how much amount spent by eack customer on artist?
write the query to return the customer name, artist name and total spent.

with best_selling_artist as (
select artist.artist_id as artist_id, artist.name as artist_name,
SUM(invoice_line.unit_price * invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id = invoice_line.track_id
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
group by 1
order by 3 desc
limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
SUM(il.unit_price * il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id= i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc

Q10. We want to find out the most popular music genre for each country.
we determine the most popular genre as the genre with the highest amount of purchase.
write a query that returns each country along with the top genre.
for countries where the maximum number of purchase s is shared return all genres.

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1


Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount.

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1



