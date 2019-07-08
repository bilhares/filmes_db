class MoviesController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :set_movie, only: [:show, :update, :destroy]
  before_action :authenticate
  before_action :verify_token, except: [:search]

  require 'net/http'
  require 'json'
  require "uri"

  #GET /search-movies
  def search
    title = params[:title]
    retorno = request_movie_db(base_url+'/search/movie?api_key='+api_key+'&query='+title)
    render json: retorno
  end

  # POST /add-movie
  def add_movie
    m = Movie.find_by(movie_id:params[:movie_id], profile_id:params[:profile])
    if m.present?   
      render json: {"messagem": "movie already added"}
    else
        movie = request_movie_db(base_url+'/movie/'+params[:movie_id]+'?api_key='+api_key);
        movie_parsed = parse_to_movie(movie, params[:profile]);
        if movie_parsed.save
          render json: movie_parsed, status: :created, location: movie_parsed
        else
          render json: movie_parsed.errors, status: :unprocessable_entity
        end
      end
  end

  # GET /movies?profile= || watched=true||false
  def index
    if params[:profile]
      if params[:watched]
        @movies = Movie.where(profile_id:params[:profile], watched:params[:watched])
      else
        @movies = Movie.where(profile_id:params[:profile])
      end  
    else
      render json: {"message":"The request must have a parameter 'profile' "}
    end
    render json: @movies
  end

  # GET /movies/1
  def show
    render json: @movie
  end

  # GET /suggested-movies
  def suggested_movies
    genres = ""
    @lastAdded = Movie.where(profile_id:params[:profile]).order(created_at: :desc).first
    genres << @lastAdded["genre"]
    render json: request_movie_db(base_url+'/discover/movie?api_key='+api_key+'&sort_by=popularity.desc&page='+params[:page]+'&with_genres='+genres)
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
    def set_movie
      @movie = Movie.find(params[:id])
    end

    def movie_params
      params.require(:movie).permit(:movie_id, :title, :overview, :poster, :vote_average, :profile_id, :watched)
    end

    def authenticate
      authenticate_or_request_with_http_token do |token, options|   
        @user = User.find_by(token: token)    
      end
    end
  
    def verify_token
      if params[:profile] 
        @profile = Profile.find(params[:profile])
        @user = User.find(@profile.user_id)
        render json: {"message":"the profile and the user token do not match"} unless @user.token == get_token
      else
        render json: {"message":"The request must contain the parameter 'profile'"}
      end
    end

    def get_token
      pattern = /^Token /
      header  = request.headers['Authorization']
      header.gsub(pattern, '') if header && header.match(pattern)
    end
    
    def request_movie_db(url)
      url = URI.parse(url)
      req = Net::HTTP::Get.new(url)
      res = Net::HTTP.start(url.host) {|http|
       http.request(req)
      }
      return JSON.parse(res.body)
    end

    def parse_to_movie(movie,profile)  
      Movie.new(
        :title=>movie["title"],
        :movie_id=>movie["id"],
        :overview=>movie["overview"],
        :poster=>'https://image.tmdb.org/t/p/w200'+movie["poster_path"],
        :vote_average=>movie["vote_average"],
        :profile_id=>profile,
        :genre=>movie["genres"].map{|g| g["id"].to_s}.join(', ')
        ); 
    end
    
end
