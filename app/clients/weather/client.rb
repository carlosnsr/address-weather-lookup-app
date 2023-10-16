module Weather
  class Client
    WEATHER_API_URL = "https://api.weather.gov/points"
    MAX_PRECISION = 4

    def make_weather_url(latitude, longitude)
      # API requires a maximum precision of 4 decimal places
      "#{WEATHER_API_URL}/#{latitude.truncate(MAX_PRECISION)},#{longitude.truncate(MAX_PRECISION)}"
    end

    def get_forecast_url(latitude, longitude)
      response = Faraday.get(make_weather_url(latitude, longitude))
      if response.status == 200
        JSON.parse(response.body).dig("properties", "forecast")
      else
        raise WeatherApiError.new(JSON.parse(response.body).dig("detail"))
      end
    end

    def get_forecast(latitude, longitude)
      response = Faraday.get(get_forecast_url(latitude, longitude))
      dailies = Array.new(7) { |_i| {} }

      JSON.parse(response.body)
        .dig("properties", "periods")
        &.each_with_index do |p, i|
          index = i / 2

          dailies[index][:when] = p["name"].split(" ").first

          key = i % 2 == 0 ? :high : :low
          dailies[index][key] = {
            value: "#{p["temperature"]}#{p["temperatureUnit"]}",
            icon: p["icon"],
          }
        end

      dailies[0][:when] = "Today"

      dailies
    end
  end

  class WeatherApiError < StandardError
  end
end
