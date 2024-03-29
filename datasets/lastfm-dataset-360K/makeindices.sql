create index on users_artists(user_id);
create index on users_artists(artist_id);
create index on users_artists(plays);
create index on users(id, gender, age, country);
--create index on users_artists(user_id, artist_id, plays);

create table top_artists as
select artist_id, gender, age, country, sum(plays) as plays
from users_artists ua join users u on ua.user_id = u.id
group by artist_id, gender, age, country
order by artist_id;
--order by plays desc;

--create index on top_artists(gender);
create index on top_artists(artist_id);
cluster top_artists_artist_id_idx on top_artists;

create table countries2 (id serial primary key, name varchar(44));
insert into countries2(name) select distinct(country) from top_artists order by country;

create table top_artists2 as
select artist_id, gender, age, countries2.id as country_id, plays from top_artists join countries2 on country = countries2.name
order by artist_id;

create index top_artists2_artist_id_idx on top_artists2(artist_id);
cluster top_artists2_artist_id_idx on top_artists2;


create table top_artists2_no_country as
select artist_id, gender, age, sum(plays) as plays from top_artists2
group by artist_id, gender, age
order by artist_id;

create index top_artists2_no_country_artist_id_idx on top_artists2_no_country(artist_id);
cluster top_artists2_no_country_artist_id_idx on top_artists2_no_country;


create table top_artists2_no_age as
select artist_id, gender, country_id, sum(plays) as plays from top_artists2
group by artist_id, gender, country_id
order by artist_id;

create index top_artists2_no_age_artist_id_idx on top_artists2_no_age(artist_id);
cluster top_artists2_no_age_artist_id_idx on top_artists2_no_age;

alter table countries2 rename to countries;


create table top_artists2_no_age_no_country as
select artist_id, gender, sum(plays) as plays from top_artists2_no_age
group by artist_id, gender
order by artist_id;

create index top_artists2_no_age_no_country_artist_id_idx on top_artists2_no_age_no_country(artist_id);
cluster top_artists2_no_age_no_country_artist_id_idx on top_artists2_no_age_no_country;


create index top_artists2_age_country_id_idx on top_artists2(age,country_id);


alter table countries add column code char(2);
create unique index countries_code_idx on countries(code);

alter table countries add column plays integer;
update countries set plays = total
from (select country_id, sum(plays) as total from top_artists2_no_age group by country_id) ct
where ct.country_id = id;


alter table users_artists rename to user_artists;


alter table users add column country_id integer;
update users set country_id = countries.id
from countries
where countries.name = users.country;



alter table countries add column users integer;
update countries set users = total
from (select country_id, count(1) as total from users group by country_id) ct
where ct.country_id = id;


alter table countries rename column users to user_count;

