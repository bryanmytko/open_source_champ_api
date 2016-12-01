class Api::V1::PlayersController < ApplicationController
  #before_action :set_player, only: [:show, :update, :destroy]
  #protect_from_forgery with: :null_session
  #protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format.include? 'application/json' }
  wrap_parameters format: [:json]

  # GET /players
  def index
    @players = Player.all
    render json: @players
  end

  # GET /players/:id
  def show
    @player = Player.find_by(id: params[:id])

    if @player.nil?
      not_found
    else
      render json: @player
    end
  end

  # GET /search?login=
  def search
    player= Player.find_by(:login => params[:login])

    if player
      render json: player
    else
      response = hit_github_for_player({login: params[:login]})

      if response["message"] && response["message"] == "Not Found"
        not_found
      else
        create_player = Player.create(
          :login => response["login"],
          :avatar_url => response["avatar_url"],
          :blog => response["blog"],
          :github_created_at => response["created_at"],
          :followers => response["followers"],
          :following => response["following"],
          :public_repos => response["public_repos"],
          :public_gists => response["public_gists"],
          :location => response["location"],
          :company => response["company"],
          :kind => response["type"],
          :github_id => response["id"]
        )

        new_player = Player.find_by :login => response["login"]
        render json: new_player, status: :created
      end
    end

  end

  # POST /players
  def create
    @player = Player.new(player_params)

    if @player.save
      render json: @player, status: :created
    else
      render json: {:error => "That user already exists", status: :unprocessable_entity}
    end
  end

  # PATCH/PUT /players/:id
  def update
    @player = Player.find_by(id: params[:player][:id])
    if @player.update(player_params)
      render json: @player
    else
      render json: @player.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = Player.find(params[:id])
    end


    # Only allow a trusted parameter "white list" through.
    def player_params
      params.require(:player).permit(:github_id, :login, :avatar_url, :blog, :github_created_at, :followers, :following, :public_repos, :public_gists, :location, :company)
    end
end
