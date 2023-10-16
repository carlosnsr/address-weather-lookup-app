class PlacesController < ApplicationController
  def index
    @places = Place.where.not(latitude: nil, longitude: nil)
  end
end
