# Please excuse the heavy documentation in the code. It was for my own benefit as I learn to utilise APIs and DBs.

require 'sinatra'
require 'sinatra/reloader'
require 'httparty'
require 'pg'
require 'pry'

def run_sql(sql)
  db = PG.connect(dbname: 'moviesearches')
  results = db.exec(sql)
  db.close
  return results
end

# Behaviour for loading index page
get '/' do
  erb(:index)
end

# Behaviour for loading results page
get '/results/:movie_name' do
  # params from input with name = "movie_name" in index
  movie = params[:movie_name]

  # stealing Google's 'did you mean' feature, data came as a string with nested arrays
  googlesearch = HTTParty.get("http://suggestqueries.google.com/complete/search?output=firefox&client=chrome&hl=en-US&q=#{movie}")

  # using OMDB API - data is a hash
  result = HTTParty.get("http://www.omdbapi.com/?s=#{movie}")

  # if no data found, API gives another hash, with key "Response" mapped to the value 'False'
  if result['Response'] == 'False'
    # giving the Google suggestion if no movie found JSON.parse used to convert string to array
    @google_suggest = JSON.parse(googlesearch)[1].first
    result = HTTParty.get("http://www.omdbapi.com/?s=#{@google_suggest}")
    @mv_search_link = result['Search'][0]['imdbID']
    # above info passed into error.erb to link user to suggested page

    erb(:error) # don't forget to route to error.erb!

  elsif result['Search'].length == 1
    # in cases where only one result exists, skip results and move straight to about
    redirect to "/results/about/#{result['Search'][0]['imdbID']}"

  else

    @mv_search_result = result['Search']

    erb(:results)

  end

end



get '/results/about/:movie_name' do  #this is the dynamic route to the about page
  movie = params[:movie_name]
  sql = "SELECT title FROM movies WHERE imdbID='#{movie}';"
  imdbIDs = run_sql(sql) #will be empty array if not present in db.

  if imdbIDs.any? #movie already in database?
    movie = params[:movie_name]
    sql = "SELECT * FROM movies WHERE imdbID='#{movie}';"
    details = run_sql(sql)

    @mv_title = details[0]['title'] + " from DB"

    @mv_basic_info = "<b>Title:</b> '#{details[0]['title']}' <br> <b>Year Released:</b> #{details[0]['year']} &nbsp&nbsp <b>Rating:</b> #{details[0]['rated']} &nbsp&nbsp <b>Runtime:</b> #{details[0]['runtime']} <br> <b>Genre:</b> #{details[0]['genre']}"

    @mv_people = "<b>Director:</b> #{details[0]['director']} <br> <b>Actors:</b> #{details[0]['actors']} <br> <b>Writers:</b> #{details[0]['writer']}"

    @mv_plot = "<b>Plot:</b> #{details[0]['plot']}"

    @mv_ratings = "<b>Metascore:</b> #{details[0]['metascore']} &nbsp&nbsp&nbsp <b>IMDB Rating:</b> #{details[0]['imdbRating']}"

    @mv_picture = details[0]['poster_url']

  else
    result = HTTParty.get("http://www.omdbapi.com/?i=#{movie}")

    if result['Title'].include? "'"
      result['Title'].gsub!("'","&#39")
    end
    #require 'uri' use URI.escape()
    if result['Plot'].include? "'"
      result['Plot'].gsub!("'","&#39")
    end

  # instance variables used to pass into about.erb
    @mv_title = result['Title']

    @mv_basic_info = "<b>Title:</b> '#{result['Title']}' <br> <b>Year Released:</b> #{result['Year']} &nbsp&nbsp <b>Rating:</b> #{result['Rated']} &nbsp&nbsp <b>Runtime:</b> #{result['Runtime']} <br> <b>Genre:</b> #{result['Genre']}"

    @mv_people = "<b>Director:</b> #{result['Director']} <br> <b>Actors:</b> #{result['Actors']} <br> <b>Writers:</b> #{result['Writer']}"

    @mv_plot = "<b>Plot:</b> #{result['Plot']}"

    @mv_ratings = "<b>Metascore:</b> #{result['Metascore']} &nbsp&nbsp&nbsp <b>IMDB Rating:</b> #{result['imdbRating']}"

    @mv_picture = result['Poster']

    #creating entry into database moviesearches - table movies
    sql1 = "INSERT INTO movies (title, director, writer, actors, plot, year, rated, runtime, genre, poster_url, metascore, imdbRating, imdbID) VALUES ('#{result['Title']}', '#{result['Director']}', '#{result['Writer']}', '#{result['Actors']}', '#{result['Plot']}',"

    sql2 = " '#{result['Year']}', '#{result['Rated']}', '#{result['Runtime']}', '#{result['Genre']}', '#{result['Poster']}', '#{result['Metascore']}', '#{result['imdbRating']}', '#{result['imdbID']}');"

    sql = sql1 + sql2

    run_sql(sql)
  end

  erb(:about)
end


get '/results' do

  movie = params[:movie_name]
  # replaces spaces and apostraphes with + and url version (thx Lock)
  if movie.include? " "
    movie.gsub!(" ","+")
  end

  if movie.include? "'"
    movie.gsub!("'","%27")
  end
  # clean route to avoid '/?='
  redirect to "/results/#{ params[:movie_name] }"
end


get '/about' do

  movie = params[:movie_name]

  if movie.include? " "
    movie.gsub!(" ","+")
  end

  if movie.include? "'"
    movie.gsub!("'","%27")
  end

  redirect to "/about/#{ params[:movie_name] }"
end
