module Weather
  class Client
    WEATHER_API_URL = "https://api.weather.gov/points"
    MAX_PRECISION = 4

    def make_weather_url(latitude, longitude)
      # API requires a maximum precision of 4 decimal places
      "#{WEATHER_API_URL}/#{latitude.truncate(MAX_PRECISION)},#{longitude.truncate(MAX_PRECISION)}"
    end
  end
end
