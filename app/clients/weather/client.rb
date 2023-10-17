module Weather
  module Client
    WEATHER_API_URL = "https://api.weather.gov/points"
    POINTS_API_URL = "#{WEATHER_API_URL}/points"
    MAX_PRECISION = 4

    def self.make_geo_points_url(latitude, longitude)
      # API requires a maximum precision of 4 decimal places
      "#{WEATHER_API_URL}/#{latitude.truncate(MAX_PRECISION)},#{longitude.truncate(MAX_PRECISION)}"
    end

    # Using the given (lat,lng), call the Weather API to get the forecast url.
    # This is the url that will give us the weather forecast at that location.
    def self.get_forecast_url(latitude, longitude)
      response = Faraday.get(make_geo_points_url(latitude, longitude))
      if response.status == 200
        JSON.parse(response.body).dig("properties", "forecast")
      else
        raise WeatherApiError.new(JSON.parse(response.body).dig("detail"))
      end
    end

    def self.get_forecast(latitude, longitude)
      response = Faraday.get(get_forecast_url(latitude, longitude))

      periods = JSON.parse(response.body).dig("properties", "periods")
      decode_forecast(periods) if periods.present?
    end

    # The weather data comes in 12-hour periods for each day (or remainder of today).
    # This function pairs the relevant temperatures to each day.
    def self.decode_forecast(periods)
      dailies = periods.inject([]) do |acc, period|
        name = period["name"]
        temperature = {
          value: "#{period["temperature"]}#{period["temperatureUnit"]}",
          icon: period["icon"],
        }

        if name =~ /^\w+day$/
          acc << {
            when: name,
            temperatures: [temperature],
          }
        elsif name =~ /^\w+day Night$/
          acc.last[:temperatures] << temperature
        elsif acc.empty?
          acc << {
            when: "Today",
            temperatures: [temperature],
          }
        else
          acc.last[:temperatures] << temperature
        end

        acc
      end

      # At the end of the day, the last 12-hour period extends into the 8th day.  Drop this.
      if dailies.last.dig(:temperatures)&.size == 1
        dailies.pop
      end

      dailies
    end
  end

  class WeatherApiError < StandardError
  end
end
