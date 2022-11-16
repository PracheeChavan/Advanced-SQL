USE imdb_ijs;

-- The big picture
-- 1.How many actors are there in the actors table?
select distinct count(id) from actors;
-- ANS 817718

-- 2.How many directors are there in the directors table?
select distinct count(id) from directors;
-- Ans 86880

-- 3.How many movies are there in the movies table?
select  distinct count(id) from movies;
-- Ans 388269

-- Exploring the movies
-- 1.From what year are the oldest and the newest movies? What are the names of those movies?
select min(year) from movies;
select max(year) from movies;
select name, year from movies order by year asc;

SELECT name, year
FROM movies
WHERE year = (SELECT MAX(year) FROM movies)
OR year = (SELECT MIN(year) FROM movies);

-- 2.What movies have the highest and the lowest ranks?
select min(movies.rank) from movies ;
select name from movies where movies.rank=1;

select max(movies.rank) from movies ;
select name from movies where movies.rank=9.9;

SELECT name, `rank` 
FROM movies
WHERE `rank` = (SELECT MAX(`rank`) FROM movies)
OR `rank` = (SELECT MIN(`rank`) FROM movies);

-- 3.What is the most common movie title?
SELECT name, COUNT(name)
FROM movies
GROUP BY name
ORDER BY 2 DESC;

-- Understanding the database

-- 1.Are there movies with multiple directors?
SELECT movie_id, COUNT(director_id)
FROM movies_directors
GROUP BY movie_id
HAVING COUNT(director_id) > 1
ORDER BY 2 DESC;
-- 

-- 2.What is the movie with the most directors? Why do you think it has so many?
select m.name, count(director_id) as count from movies as m inner join movies_directors as md on m.id=md.movie_id  group by m.id order by count desc limit 1;

SELECT m.name, COUNT(md.director_id)
FROM movies_directors md
JOIN movies m
	ON md.movie_id = m.id
GROUP BY movie_id
HAVING COUNT(director_id) > 1
ORDER BY 2 DESC;

-- 3.On average, how many actors are listed by movie?
WITH actors_per_movie AS (
	SELECT movie_id, COUNT(actor_id) AS no_actors
	FROM roles
	GROUP BY movie_id)
SELECT AVG(no_actors)
FROM actors_per_movie;

-- 4.Are there movies with more than one “genre”?
select m.name, mg.genre as genre_type from movies as m inner join movies_genres as mg on m.id=mg.movie_id  where m.name= '$10,000 Under a Pillow';
select m.name, count(genre) as count from movies as m inner join movies_genres as mg on m.id=mg.movie_id  group by m.id  ;

SELECT movie_id, COUNT(genre)
FROM movies_genres
GROUP BY movie_id
HAVING COUNT(genre) > 1
ORDER BY COUNT(genre) DESC;

-- Looking for specific movies

-- 1.Can you find the movie called “Pulp Fiction”? Who directed it? Which actors where casted on it?
select * from movies where name='Pulp Fiction';

select a.first_name as A_first,a.last_name as a_last
from movies as m
inner join roles as r
on m.id=r.movie_id inner join actors as a
on r.actor_id=a.id
where m.name= 'Pulp Fiction';

SELECT d.first_name, d.last_name
FROM directors d
JOIN movies_directors md
	ON d.id = md.director_id
JOIN movies m
	ON md.movie_id = m.id
WHERE m.name LIKE "pulp fiction";

-- 2.Can you find the movie called “La Dolce Vita”? Who directed it? Which actors where casted on it?

SELECT d.first_name, d.last_name
FROM directors d
JOIN movies_directors md
	ON d.id = md.director_id
JOIN movies m
	ON md.movie_id = m.id
WHERE m.name LIKE "Dolce Vita, la";

SELECT a.first_name, a.last_name
FROM actors a
JOIN roles r
	ON a.id = r.actor_id
JOIN movies m
	ON r.movie_id = m.id
WHERE m.name LIKE "Dolce Vita, la";

-- 3.When was the movie “Titanic” by James Cameron released?
-- Hint: there are many movies named “Titanic”. We want the one directed by James Cameron.
-- Hint 2: the name “James Cameron” is stored with a weird character on it.
select m.name, m.year as Year,d.first_name as df,d.last_name as dl
from movies as m 
inner join movies_directors as md 
on m.id=md.movie_id 
inner join directors as d
on md.director_id=d.id 
where m.name= 'Titanic' And (d.first_name like '%James%' AND d.last_name like '%Cameron%');
-- 1997

-- Actors and directors

-- 1.Who is the actor that acted more times as “Himself”?
SELECT a.first_name, a.last_name, COUNT(a.id)
FROM actors a
JOIN roles r
	ON a.id = r.actor_id
WHERE role LIKE "himself"
GROUP BY a.id, a.first_name, a.last_name
ORDER BY COUNT(a.id) DESC;


-- 2.What is the most common name for actors? 

SELECT first_name, COUNT(first_name)
FROM actors
GROUP BY 1
ORDER BY 2 DESC;
/* # first_name, COUNT(first_name)
John, 4371 */

SELECT last_name, COUNT(last_name)
FROM actors
GROUP BY 1
ORDER BY 2 DESC;
/* # last_name, COUNT(last_name)
Smith, 2425 */

WITH concat_names as (SELECT 
    concat(first_name,' ',last_name) fullname
FROM
	actors)
SELECT fullname, COUNT(fullname)
FROM concat_names
GROUP BY 1
ORDER BY 2 DESC;
/* # fullname, COUNT(fullname)
Shauna MacDonald, 7 */

	-- And for directors?
SELECT first_name, COUNT(first_name)
FROM directors
GROUP BY 1
ORDER BY 2 DESC;
/* # first_name, COUNT(first_name)
Michael, 670 */

SELECT last_name, COUNT(last_name)
FROM directors
GROUP BY 1
ORDER BY 2 DESC;
/* # last_name, COUNT(last_name)
Smith, 243 */

WITH concat_names as (SELECT 
    concat(first_name,' ',last_name) fullname
FROM
	directors)
SELECT fullname, COUNT(fullname)
FROM concat_names
GROUP BY 1
ORDER BY 2 DESC;
/* # fullname, COUNT(fullname)
Kaoru UmeZawa, 10 */


-- Analysing genders

-- 1.How many actors are male and how many are female?
select Count(gender) as Male from actors where gender='M';
-- 513306
select Count(gender) as Male from actors where gender='F';
-- 304412
select Count(gender) as Male from actors;
-- 817718

-- 2. What percentage of actors are female, and what percentage are male?
select (select Count(gender) as Male from actors where gender='M')/(select Count(gender) as Male from actors) as Male_percentage;
-- Male=513306/817718*100= 62.77%  
select (select Count(gender) as Male from actors where gender='F')/(select Count(gender) as Male from actors) as Female_percentage;
-- Female= 304412/817718*100= 37.23%

-- Movies across time
-- 1.How many of the movies were released after the year 2000?
select count(name) Total from movies where year>2000;
-- 46006

-- 2.How many of the movies where released between the years 1990 and 2000?
 select count(name) Total from movies where year between 1990 and 2000;
-- 91138

-- 3.Which are the 3 years with the most movies? How many movies were produced on those years?
select year, count(name) as count from movies  group by year order by count desc limit 3;

WITH cte AS (SELECT
	RANK() OVER (ORDER BY COUNT(id) DESC) ranking,
    year,
    count(id) total
FROM movies
GROUP BY year
ORDER BY 1)
SELECT ranking, year, total
FROM cte
WHERE ranking <= 3;
/* # ranking, year, total
1, 2002, 12056
2, 2003, 11890
3, 2001, 11690 */


-- 4.What are the top 5 movie genres?
WITH cte AS (SELECT
	RANK() OVER (ORDER BY COUNT(movie_id) DESC) ranking,
    genre,
    COUNT(movie_id) total
FROM movies_genres
GROUP BY genre
ORDER BY 1)
SELECT ranking, genre, total
FROM cte
WHERE ranking <= 5;
/* # ranking, genre, total
1, Short, 81013
2, Drama, 72877
3, Comedy, 56425
4, Documentary, 41356
5, Animation, 17652 */


-- 5.What are the top 5 movie genres before 1920?

WITH cte AS (SELECT
	RANK() OVER (ORDER BY COUNT(movie_id) DESC) ranking,
    genre,
    COUNT(movie_id) total
FROM movies_genres
WHERE movie_id IN (SELECT id FROM movies WHERE year < 1920)
GROUP BY genre
ORDER BY 1)
SELECT ranking, genre, total
FROM cte
WHERE ranking <= 5;
/* # ranking, genre, total
1, Short, 18559
2, Comedy, 8676
3, Drama, 7692
4, Documentary, 3780
5, Western, 1704 */

-- 6.What is the evolution of the top movie genres across all the decades of the 20th century?
select year, count(name) as count from movies  group by year order by count desc;
with genre_count_per_decade as (
select rank() over (partition by decade order by movies_per_genre desc) ranking, genre, decade
from (SELECT 
    genre,
    FLOOR(m.year / 10) * 10 AS decade,
    COUNT(genre) AS movies_per_genre
FROM
    movies_genres mg
        JOIN
    movies m ON m.id = mg.movie_id
GROUP BY decade , genre) as a
)
select genre, decade
FROM genre_count_per_decade
WHERE ranking = 1;
/*
# genre, decade
Short, 1880
Documentary, 1890
Short, 1900
Short, 1910
Short, 1920
Short, 1930
Short, 1940
Drama, 1950
Drama, 1960
Drama, 1970
Drama, 1980
Drama, 1990
Short, 2000
*/

-- Putting it all together: names, genders and time

-- 1.Has the most common name for actors changed over time? 2. Get the most common actor name for each decade in the XX century.
with cte as (
SELECT RANK() OVER (PARTITION BY DECADE ORDER BY TOTALS DESC) AS ranking, 
	fname, 
	totals, 
	decade
from (SELECT a.first_name as fname, 
	COUNT(a.first_name) as totals, 
	FLOOR(m.year / 10) * 10 as decade
FROM actors a
JOIN roles r
	ON a.id = r.actor_id
JOIN movies m
	ON r.movie_id = m.id
GROUP BY decade, fname) sub)
SELECT decade, 
	fname, 
	totals
FROM cte
WHERE ranking = 1
-- AND decade >= 1900
-- AND decade < 1900
ORDER BY decade;
/* # decade, name, totals
1890, Petr, 26
1900, Florence, 180
1910, Harry, 1662
1920, Charles, 1009
1930, Harry, 2161
1940, George, 2128
1950, John, 2027
1960, John, 1823
1970, John, 2657
1980, John, 3855
1990, Michael, 5929
2000, Michael, 3914 */

with cte as (
SELECT RANK() OVER (PARTITION BY DECADE ORDER BY TOTALS DESC) AS ranking, fullname, totals, decade
from (SELECT concat(a.first_name,' ',a.last_name) as fullname, COUNT(concat(a.first_name,' ',a.last_name)) as totals, FLOOR(m.year / 10) * 10 as decade
FROM actors a
JOIN roles r
	ON a.id = r.actor_id
JOIN movies m
	ON r.movie_id = m.id
GROUP BY decade, concat(a.first_name,' ',a.last_name)) sub)
SELECT decade, fullname, totals
FROM cte
WHERE ranking = 1
-- AND decade >= 1900
-- AND decade < 1900
ORDER BY decade;

/*
# decade, fullname, totals
1890, Petr Lenícek, 26
1900, Mack Sennett, 168
1910, Lee (I) Moran, 315
1910, Gilbert M. 'Broncho Billy' Anderson, 315
1920, Oliver Hardy, 130
1930, Lee Phelps, 284
1940, Mel Blanc, 300
1950, Mel Blanc, 258
1960, Sung-il Shin, 225
1970, Adoor Bhasi, 306
1980, Robert Mammone, 212
1990, Frank Welker, 180
2000, Kevin Michael Richardson, 90
*/


-- 3.Re-do the analysis on most common names, splitted for males and females.

with cte as (
SELECT RANK() OVER (PARTITION BY DECADE ORDER BY TOTALS DESC) AS ranking, fname, totals, decade
from (SELECT a.first_name as fname, COUNT(a.first_name) as totals, FLOOR(m.year / 10) * 10 as decade
FROM actors a
JOIN roles r
	ON a.id = r.actor_id
JOIN movies m
	ON r.movie_id = m.id
WHERE a.gender LIKE 'f'
-- WHERE a.gender LIKE 'm'
GROUP BY decade, fname) sub)
SELECT decade, fname, totals
FROM cte
WHERE ranking = 1
-- AND decade >= 1900
-- AND decade < 1900
ORDER BY decade;
/* FEMALE
# decade, name, totals
1890, Rosemarie, 16
1900, Florence, 180
1910, Florence, 782
1920, Mary, 649
1930, Dorothy, 830
1940, Maria, 739
1950, María, 1005
1960, Maria, 1059
1970, María, 1191
1980, Maria, 1228
1990, Maria, 1728
2000, María, 1148 */

/* MALE
# decade, fname, totals
1890, Petr, 26
1900, Mack, 168
1910, Harry, 1662
1920, Charles, 1009
1930, Harry, 2161
1940, George, 2128
1950, John, 2027
1960, John, 1823
1970, John, 2657
1980, John, 3855
1990, Michael, 5907
2000, Michael, 3899
*/

with cte as (
SELECT RANK() OVER (PARTITION BY DECADE ORDER BY TOTALS DESC) AS ranking, fullname, totals, decade
from (SELECT concat(a.first_name,' ',a.last_name) as fullname, COUNT(concat(a.first_name,' ',a.last_name)) as totals, FLOOR(m.year / 10) * 10 as decade
FROM actors a
JOIN roles r
	ON a.id = r.actor_id
JOIN movies m
	ON r.movie_id = m.id
WHERE a.gender LIKE 'f'
-- WHERE a.gender LIKE 'm'
GROUP BY decade, concat(a.first_name,' ',a.last_name)) sub)
SELECT decade, fullname, totals
FROM cte
WHERE ranking = 1
-- AND decade >= 1900
-- AND decade < 1900
ORDER BY decade;

/*
# decade, fullname, totals
1890, Rosemarie Quednau, 16
1900, Florence Lawrence, 135
1910, Mabel Normand, 211
1920, Gertrude Astor, 83
1920, Dot Farley, 83
1930, Bess Flowers, 203
1940, Bess Flowers, 232
1950, Bess Flowers, 177
1960, Ji-mi Kim, 164
1970, Carla Mancini, 145
1980, Bunsri Sribunruttanachai, 158
1990, Lisa (I) Comshaw, 128
2000, Grey DeLisle, 77
*/

/*
# decade, fullname, totals
1890, Petr Lenícek, 26
1900, Mack Sennett, 168
1910, Lee (I) Moran, 315
1910, Gilbert M. 'Broncho Billy' Anderson, 315
1920, Oliver Hardy, 130
1930, Lee Phelps, 284
1940, Mel Blanc, 300
1950, Mel Blanc, 258
1960, Sung-il Shin, 225
1970, Adoor Bhasi, 306
1980, Robert Mammone, 212
1990, Frank Welker, 180
2000, Kevin Michael Richardson, 90
*/

-- 4.How many movies had a majority of females among their cast?.What percentage of the total movies had a majority female cast?
SELECT COUNT(movie_title)
FROM (select
  r.movie_id as movie_title,
  count(case when a.gender='M' then 1 end) as male_count,
  count(case when a.gender='F' then 1 end) as female_count
from roles r
JOIN actors a
    ON r.actor_id = a.id
GROUP BY r.movie_id) sub
WHERE female_count > male_count;
-- 50666 movies with more female actors than male (absolute)

SELECT
(SELECT COUNT(movie_title)
FROM (select
  r.movie_id as movie_title,
  count(case when a.gender='M' then 1 end) as male_count,
  count(case when a.gender='F' then 1 end) as female_count
from roles r
JOIN actors a
    ON r.actor_id = a.id
GROUP BY r.movie_id) sub
WHERE female_count > male_count)
/
(SELECT COUNT(DISTINCT(movie_id))
FROM roles)
-- 0.1687 17% of movies have more female actors than males (relative)