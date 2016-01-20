CREATE DATABASE moviesearches;

CREATE TABLE movies (
  id SERIAL4 PRIMARY KEY,
  title VARCHAR(100),
  year VARCHAR(100),
  rated VARCHAR(100),
  runtime VARCHAR(100),
  genre VARCHAR(200),
  director VARCHAR,
  writer VARCHAR,
  actors VARCHAR,
  plot VARCHAR,
  poster_url VARCHAR(100),
  metascore VARCHAR(100),
  imdbRating VARCHAR(100),
  imdbID VARCHAR(100)
);
