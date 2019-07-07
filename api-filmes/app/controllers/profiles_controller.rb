class ProfilesController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :set_profile, only: [:show, :update, :destroy]
  before_action :authenticate
  before_action :verify_token

  # GET /profiles
  def index 
    if params[:user_id]      
     @profiles = Profile.where(user_id:params[:user_id])
    else
      @profiles = Profile.all
    end
    render json: @profiles
  end

  # POST /profiles
  def create
    if Profile.where(user_id:params[:user_id]).count >= 4
      render json: {"message":"The user can have a maximum of 4 profiles"}
    else
      @profile = Profile.new(profile_params)
      if @profile.save
        render json: @profile, status: :created, location: @profile
      else
        render json: @profile.errors, status: :unprocessable_entity
      end
    end   
  end

  # PATCH/PUT /profiles/1
  def update
    if @profile.update(profile_params)
      render json: @profile
    else
      render json: @profile.errors, status: :unprocessable_entity
    end
  end

  # DELETE /profiles/1
  def destroy
    @profile.destroy
  end

  private
    def set_profile
      @profile = Profile.find(params[:id])
    end

    def profile_params
      params.require(:profile).permit(:name, :user_id)
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
end
