require 'rails_helper'

RSpec.describe Weather::Client do
  let(:latitude) { 38.8976633 }
  let(:longitude) { -77.0365739 }

  subject { Weather::Client.new() }

  describe "#make_weather_url" do
    it "generates the url from the latitude and longitude" do
      expect(subject.make_weather_url(38, -77))
        .to eq("https://api.weather.gov/points/38,-77")
    end

    it "truncates the latitude and longitude" do
      expect(subject.make_weather_url(latitude, longitude))
        .to eq("https://api.weather.gov/points/38.8976,-77.0365")
    end
  end

  describe "#get_forecast_url" do
    it "calls the weather API"
    it "returns the forecast url"
  end

  describe "#get_forecast" do
    it "calls the forecast url"
    it "gets the response"
    it "returns the daily highs and lows"
  end
end
