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
    let(:forecast_url) { "https://api.weather.gov/gridpoints/LWX/97,71/forecast" }
    let(:points_json) do
      {
        "properties"=> {
          "@id"=> forecast_url,
          "forecast"=>"https://api.weather.gov/gridpoints/LWX/97,71/forecast",
          "forecastHourly"=>"https://api.weather.gov/gridpoints/LWX/97,71/forecast/hourly",
          "forecastGridData"=>"https://api.weather.gov/gridpoints/LWX/97,71",
        }
      }.to_json
    end

    context "for a successful call" do
      before(:each) do
        stub_request(:get, /api\.weather\.gov\/points/)
          .to_return(status: 200, body: points_json, headers: {})
      end

      it "calls the weather API" do
        subject.get_forecast_url(latitude, longitude)
        expect(a_request(:get, /api\.weather\.gov\/points/)).to have_been_made.once
      end

      it "returns the forecast url" do
        expect(subject.get_forecast_url(latitude, longitude)).to eq(forecast_url)
      end
    end

    context "for a unsuccessful call" do
      let(:call_body) { { detail: "Unsuccessful" }.to_json }

      before(:each) do
        stub_request(:get, /api\.weather\.gov\/points/)
          .to_return(status: 301, body: call_body, headers: {})
      end

      it "throws an exception" do
        expect{ subject.get_forecast_url(latitude, longitude) }
          .to raise_error(Weather::WeatherApiError)
      end
    end
  end

  describe "#get_forecast" do
    it "calls the forecast url"
    it "gets the response"
    it "returns the daily highs and lows"
  end
end
