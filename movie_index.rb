require 'pry'
require 'sinatra'
require 'sinatra/reloader'
require 'csv'


def get_lists
  @lists = []
  CSV.foreach('movies.csv', headers: true, header_converters: :symbol) do |row|
    @lists << row.to_hash
  end
  @lists.sort_by! { |mov| mov[:title] }
  @lists
end

def individual_movie(movie_id)
  get_lists
  @book_by_id = @lists.find do |mov|
    mov[:id] == movie_id
  end
end

def paginate(collection, page)
  page ||= 1
  start = (page.to_i * 20) - 20
  collection.slice(start, 20)
end

def display_page(collection)
  collection.length / 20
end

def search_query(collection, query)
  return collection if query.nil?

  collection.find_all do |movie|
    movie[:title].downcase.include?(query.downcase) ||
    movie[:synopsis].downcase.split(' ').include?(query.downcase) if movie[:synopsis].class != NilClass
  end
end

get '/' do
  redirect :movies
end

get '/movies' do
  @movies = search_query(get_lists, params[:query])
  @movies = paginate(@movies, params[:page])
  @length = display_page(@movies)

  erb :movies
end

get '/movies/:id' do
  individual_movie(params[:id])
  erb :individual_movie
end


