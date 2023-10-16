class PlacesController < ApplicationController
  def index
    @places = Place.where.not(latitude: nil, longitude: nil)
  end

  def show
    @place = Place.find(params[:id])
  end
end
