require 'sinatra'
require 'sinatra/reloader'
require 'httparty'
require 'pry'

get '/' do
  erb(:index)
end

get '/results/:movie_name' do

  movie = params[:movie_name]

  result = HTTParty.get("http://www.omdbapi.com/?s=#{movie}")

  @mv_search_result = result['Search']

  erb(:results)

end


get '/results/about/:movie_name' do  #this is the route
  movie = params[:movie_name]

# Attempt at passing the whole data piece
#===========================================
  # page_contents_arr = []
  #
  # result.each do |key, val|
  #   page_contents_arr.push(key + ": " + val + "\n")
  # end
  #
  # page_contents = page_contents_arr.join

  result = HTTParty.get("http://www.omdbapi.com/?i=#{movie}")

  @mv_title = result['Title']

  @mv_basic_info = "<b>Title:</b> '#{result['Title']}' <br> <b>Year Released:</b> #{result['Year']} &nbsp&nbsp <b>Rating:</b> #{result['Rated']} &nbsp&nbsp <b>Runtime:</b> #{result['Runtime']} <br> <b>Genre:</b> #{result['Genre']}"

  @mv_people = "<b>Director:</b> #{result['Director']} <br> <b>Actors:</b> #{result['Actors']} <br> <b>Writers:</b> #{result['Writer']}"

  @mv_plot = "<b>Plot:</b> #{result['Plot']}"

  @mv_ratings = "<b>Metascore:</b> #{result['Metascore']} &nbsp&nbsp&nbsp <b>IMDB Rating:</b> #{result['imdbRating']}"

  @mv_picture = result['Poster']


  erb(:about)
end


get '/about' do
  redirect to "/about/#{ params[:movie_name] }"
end


get '/results' do
  redirect to "/results/#{ params[:movie_name] }"
end
