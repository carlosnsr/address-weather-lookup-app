class PlacesController < ApplicationController
  def index
    @places = Place.where.not(latitude: nil, longitude: nil)
  end

  def show
    @place = Place.find(params[:id])

    @cached = true
    @dailies = Rails.cache.fetch(@place.postal_code, expires_in: 30.minutes) do
      @cached = false
      Weather::Client.get_forecast(@place.latitude, @place.longitude)
    end

  rescue ActiveRecord::RecordNotFound => e
    flash[:notice] = "No saved place with that ID"
    redirect_to action: :index
  end

  def new
    @place = Place.new
  end

  def create
    @place = Place.new(place_params)

    if @place.save
      redirect_to @place
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def place_params
    params.require(:place).permit(:address)
  end
end
