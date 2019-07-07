class MoviesController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :set_movie, only: [:show, :update, :destroy]
  before_action :authenticate
  before_action :verify_token, except: [:search]

  require 'net/http'
  require 'json'
  require "uri"

  def teste
    url = URI.parse(base_url+'&query=Jack+Reacher')
    req = Net::HTTP::Get.new(url)
    res = Net::HTTP.start(url.host) {|http|
      http.request(req)
    }
    parsed_response = JSON.parse(res.body)
    retorno = []
    parsed_response["results"].each do |movie|      
      retorno << Movie.new(
        :title=>movie["title"],
        :movie_id=>movie["id"],
        :overview=>movie["overview"],
        :poster=>movie["poster_path"],
        :vote_average=>movie["vote_average"]
        ); 
    end    
    render json: retorno
  end

  def search
    title = params[:title]
    retorno = search_movie(title)
    render json: retorno
  end

  def add_movie
    movie_id = params[:movie_id]
    movie = search_movie_by_id(movie_id);
    movie_parsed = parse_to_movie(movie);
    # render json: movie_parsed
    if movie_parsed.save
      render json: movie_parsed, status: :created, location: movie_parsed
    else
      render json: movie_parsed.errors, status: :unprocessable_entity
    end
  end

  # GET /movies
  def index
    @movies = Movie.all
    render json: @movies
  end

  # GET /movies/1
  def show
    render json: @movie
  end

  # POST /movies
  def create
    @movie = Movie.new(movie_params)
    if @movie.save
      render json: @movie, status: :created, location: @movie
    else
      render json: @movie.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /movies/1
  def update
    if @movie.update(movie_params)
      render json: @movie
    else
      render json: @movie.errors, status: :unprocessable_entity
    end
  end

  # DELETE /movies/1
  def destroy
    @movie.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def movie_params
      params.require(:movie).permit(:movie_id, :title, :overview, :poster, :vote_average, :profile_id)
    end

    def authenticate
      authenticate_or_request_with_http_token do |token, options|   
        @user = User.find_by(token: token)    
      end
    end
  
    def verify_token
      if params[:user_id] 
        @user = User.find(params[:user_id])
        render json: {"message":"the user_id and the token do not match"} unless @user.token == get_token
      else
        render json: {"message":"The request must contain the parameter user_id"}
      end
    end

    def get_token
      pattern = /^Token /
      header  = request.headers['Authorization']
      header.gsub(pattern, '') if header && header.match(pattern)
    end

    def search_movie(param)
      # url = URI.parse(base_url+'&query='+param)
      url = URI.parse(base_url+'/search/movie?api_key='+api_key+'&query='+param)
      req = Net::HTTP::Get.new(url)
      res = Net::HTTP.start(url.host) {|http|
       http.request(req)
      }
      return JSON.parse(res.body)
    end

    def search_movie_by_id (id)
      url = URI.parse(base_url+'/movie/'+id+'?api_key='+api_key)
      req = Net::HTTP::Get.new(url)
      res = Net::HTTP.start(url.host) {|http|
       http.request(req)
      }
      return JSON.parse(res.body)
    end

    def parse_to_movie(movie)
      Movie.new(
        :title=>movie["title"],
        :movie_id=>movie["id"],
        :overview=>movie["overview"],
        :poster=>movie["poster_path"],
        :vote_average=>movie["vote_average"]
        ); 
    end
end
