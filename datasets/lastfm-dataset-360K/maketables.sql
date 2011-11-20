create table artists (
	id integer primary key,
	mbid varchar(36),
	name text
);

create table users (
	id integer primary key,
	gender char(1),
	age integer,
	country varchar(44),
	registered date
);

create table users_artists (
	user_id integer,
	artist_id integer,
	plays integer
);

