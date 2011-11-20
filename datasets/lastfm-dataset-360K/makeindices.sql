create index on users_artists(user_id);
create index on users_artists(artist_id);
create index on users_artists(plays);
create index on users(id, gender, age, country);
--create index on users_artists(user_id, artist_id, plays);

create table top_artists as
select artist_id, gender, age, country, sum(plays) as plays
from users_artists ua join users u on ua.user_id = u.id
group by artist_id, gender, age, country
order by plays desc;

--create index on top_artists(gender);
create index on top_artists(artist_id);
cluster top_artists_artist_id_idx on top_artists;
