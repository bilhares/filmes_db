class UsersController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :authenticate, only: [:show, :update, :destroy]

  #POST /login
  def login
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      render json: {"token":user.token, "user_id":user.id}
    else
      render json: {"message":"Username or password is invalid"}
    end 
  end

  # POST /users
  def create
    @user = User.new(user_params)
    @user.password = params[:password]
    if @user.save
      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :birthdate, :password_digest)
    end

    def authenticate
      authenticate_or_request_with_http_token do |token, options|   
        @user = User.find_by(token: token)    
      end
    end
end
