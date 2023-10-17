module Weather
  class Client
    WEATHER_API_URL = "https://api.weather.gov/points"
    POINTS_API_URL = "#{WEATHER_API_URL}/points"
    MAX_PRECISION = 4

    def make_geo_points_url(latitude, longitude)
      # API requires a maximum precision of 4 decimal places
      "#{WEATHER_API_URL}/#{latitude.truncate(MAX_PRECISION)},#{longitude.truncate(MAX_PRECISION)}"
    end

    # Using the given (lat,lng), call the Weather API to get the forecast url.
    # This is the url that will give us the weather forecast at that location.
    def get_forecast_url(latitude, longitude)
      response = Faraday.get(make_geo_points_url(latitude, longitude))
      if response.status == 200
        JSON.parse(response.body).dig("properties", "forecast")
      else
        raise WeatherApiError.new(JSON.parse(response.body).dig("detail"))
      end
    end

    def get_forecast(latitude, longitude)
      response = Faraday.get(get_forecast_url(latitude, longitude))

      periods = JSON.parse(response.body).dig("properties", "periods")
      decode_forecast(periods) if periods.present?
    end

    def decode_forecast(periods)
      periods.map do |p|
        temp = {}

        temp[:when] = p["name"]

        temp[:temp] = {
          value: "#{p["temperature"]}#{p["temperatureUnit"]}",
          icon: p["icon"],
        }

        temp
      end.inject([]) do |acc, temp|
        if temp[:when] =~ /^\w+day$/
          acc << {
            when: temp[:when],
            temperatures: [temp[:temp]],
          }
        elsif temp[:when] =~ /^\w+day Night$/
          acc.last[:temperatures] << temp[:temp]
        elsif acc.empty?
          acc << {
            when: "Today",
            temperatures: [temp[:temp]],
          }
        else
          acc.last[:temperatures] << temp[:temp]
        end

        acc
      end
    end
  end

  class WeatherApiError < StandardError
  end
end
