class PlacesController < ApplicationController
  def index
    @places = Place.where.not(latitude: nil, longitude: nil)
  end

  def show
    @place = Place.find(params[:id])
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
