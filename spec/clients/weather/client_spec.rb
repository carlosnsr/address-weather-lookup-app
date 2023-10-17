require 'rails_helper'

RSpec.describe Weather::Client do
  let(:latitude) { 38.8976633 }
  let(:longitude) { -77.0365739 }
  let(:forecast_url) { "https://api.weather.gov/gridpoints/LWX/97,71/forecast" }

  subject { Weather::Client.new() }

  describe "#make_geo_points_url" do
    it "generates the url from the latitude and longitude" do
      expect(subject.make_geo_points_url(38, -77))
        .to eq("https://api.weather.gov/points/38,-77")
    end

    it "truncates the latitude and longitude" do
      expect(subject.make_geo_points_url(latitude, longitude))
        .to eq("https://api.weather.gov/points/38.8976,-77.0365")
    end
  end

  describe "#get_forecast_url" do
    let(:points_json) do
      {
        "properties"=> {
          "@id"=>"https://api.weather.gov/points/38.8976,-77.0365",
          "forecast"=>forecast_url,
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
    let(:forecast_json) do
      {
        "@context"=> [
          "https://geojson.org/geojson-ld/geojson-context.jsonld",
          {
            "@version"=>"1.1",
            "wx"=>"https://api.weather.gov/ontology#",
            "geo"=>"http://www.opengis.net/ont/geosparql#",
            "unit"=>"http://codes.wmo.int/common/unit/",
            "@vocab"=>"https://api.weather.gov/ontology#"
          }
        ],
        "type"=>"Feature",
        "geometry"=> {
          "type"=>"Polygon",
          "coordinates"=> [[
            [-77.0369962, 38.900789],
            [-77.0407548, 38.878836500000006],
            [-77.0125519, 38.8759086],
            [-77.0087876, 38.897860800000004],
            [-77.0369962, 38.900789]
          ]]
        },
        "properties"=> {
          "updated"=>"2023-10-16T14:29:52+00:00",
          "units"=>"us",
          "forecastGenerator"=>"BaselineForecastGenerator",
          "generatedAt"=>"2023-10-16T16:18:46+00:00",
          "updateTime"=>"2023-10-16T14:29:52+00:00",
          "validTimes"=>"2023-10-16T08:00:00+00:00/P7DT17H",
          "elevation"=>{"unitCode"=>"wmoUnit:m", "value"=>6.096},
          "periods"=> [
            {
              "number"=>1,
              "name"=>"This Afternoon",
              "startTime"=>"2023-10-16T12:00:00-04:00",
              "endTime"=>"2023-10-16T18:00:00-04:00",
              "isDaytime"=>true,
              "temperature"=>61,
              "temperatureUnit"=>"F",
              "temperatureTrend"=>nil,
              "probabilityOfPrecipitation"=>{"unitCode"=>"wmoUnit:percent", "value"=>20},
              "dewpoint"=>{"unitCode"=>"wmoUnit:degC", "value"=>8.88888888888889},
              "relativeHumidity"=>{"unitCode"=>"wmoUnit:percent", "value"=>62},
              "windSpeed"=>"10 mph",
              "windDirection"=>"NW",
              "icon"=>"https://api.weather.gov/icons/land/day/rain_showers,20?size=medium",
              "shortForecast"=>"Isolated Rain Showers",
              "detailedForecast"=>
              "Isolated rain showers after 5pm. Mostly cloudy, with a high near 61. Northwest wind around 10 mph. Chance of precipitation is 20%."
            },
            {
              "number"=>2,
              "name"=>"Tonight",
              "startTime"=>"2023-10-16T18:00:00-04:00",
              "endTime"=>"2023-10-17T06:00:00-04:00",
              "isDaytime"=>false,
              "temperature"=>48,
              "temperatureUnit"=>"F",
              "temperatureTrend"=>nil,
              "probabilityOfPrecipitation"=>{"unitCode"=>"wmoUnit:percent", "value"=>20},
              "dewpoint"=>{"unitCode"=>"wmoUnit:degC", "value"=>10},
              "relativeHumidity"=>{"unitCode"=>"wmoUnit:percent", "value"=>96},
              "windSpeed"=>"8 mph",
              "windDirection"=>"NW",
              "icon"=>"https://api.weather.gov/icons/land/night/rain_showers,20/bkn?size=medium",
              "shortForecast"=>"Isolated Rain Showers then Mostly Cloudy",
              "detailedForecast"=>
              "Isolated rain showers before 8pm. Mostly cloudy, with a low around 48. Northwest wind around 8 mph. Chance of precipitation is 20%."
            },
            {
              "number"=>3,
              "name"=>"Tuesday",
              "startTime"=>"2023-10-17T06:00:00-04:00",
              "endTime"=>"2023-10-17T18:00:00-04:00",
              "isDaytime"=>true,
              "temperature"=>65,
              "temperatureUnit"=>"F",
              "temperatureTrend"=>nil,
              "probabilityOfPrecipitation"=>{"unitCode"=>"wmoUnit:percent", "value"=>nil},
              "dewpoint"=>{"unitCode"=>"wmoUnit:degC", "value"=>9.444444444444445},
              "relativeHumidity"=>{"unitCode"=>"wmoUnit:percent", "value"=>100},
              "windSpeed"=>"8 mph",
              "windDirection"=>"NW",
              "icon"=>"https://api.weather.gov/icons/land/day/bkn?size=medium",
              "shortForecast"=>"Partly Sunny",
              "detailedForecast"=>"Partly sunny, with a high near 65. Northwest wind around 8 mph."
            },
            {
              "number"=>4,
              "name"=>"Tuesday Night",
              "startTime"=>"2023-10-17T18:00:00-04:00",
              "endTime"=>"2023-10-18T06:00:00-04:00",
              "isDaytime"=>false,
              "temperature"=>47,
              "temperatureUnit"=>"F",
              "temperatureTrend"=>nil,
              "probabilityOfPrecipitation"=>{"unitCode"=>"wmoUnit:percent", "value"=>nil},
              "dewpoint"=>{"unitCode"=>"wmoUnit:degC", "value"=>9.444444444444445},
              "relativeHumidity"=>{"unitCode"=>"wmoUnit:percent", "value"=>93},
              "windSpeed"=>"2 to 6 mph",
              "windDirection"=>"NW",
              "icon"=>"https://api.weather.gov/icons/land/night/sct?size=medium",
              "shortForecast"=>"Partly Cloudy",
              "detailedForecast"=>"Partly cloudy, with a low around 47. Northwest wind 2 to 6 mph."
            },
            {
              "number"=>5,
              "name"=>"Wednesday",
              "startTime"=>"2023-10-18T06:00:00-04:00",
              "endTime"=>"2023-10-18T18:00:00-04:00",
              "isDaytime"=>true,
              "temperature"=>67,
              "temperatureUnit"=>"F",
              "temperatureTrend"=>nil,
              "probabilityOfPrecipitation"=>{"unitCode"=>"wmoUnit:percent", "value"=>nil},
              "dewpoint"=>{"unitCode"=>"wmoUnit:degC", "value"=>8.88888888888889},
              "relativeHumidity"=>{"unitCode"=>"wmoUnit:percent", "value"=>100},
              "windSpeed"=>"2 to 6 mph",
              "windDirection"=>"W",
              "icon"=>"https://api.weather.gov/icons/land/day/sct?size=medium",
              "shortForecast"=>"Mostly Sunny",
              "detailedForecast"=>"Mostly sunny, with a high near 67. West wind 2 to 6 mph."
            },
            {
              "number"=>6,
              "name"=>"Wednesday Night",
              "startTime"=>"2023-10-18T18:00:00-04:00",
              "endTime"=>"2023-10-19T06:00:00-04:00",
              "isDaytime"=>false,
              "temperature"=>49,
              "temperatureUnit"=>"F",
              "temperatureTrend"=>nil,
              "probabilityOfPrecipitation"=>{"unitCode"=>"wmoUnit:percent", "value"=>nil},
              "dewpoint"=>{"unitCode"=>"wmoUnit:degC", "value"=>10},
              "relativeHumidity"=>{"unitCode"=>"wmoUnit:percent", "value"=>96},
              "windSpeed"=>"5 mph",
              "windDirection"=>"SE",
              "icon"=>"https://api.weather.gov/icons/land/night/few?size=medium",
              "shortForecast"=>"Mostly Clear",
              "detailedForecast"=>"Mostly clear, with a low around 49."
            },
            {
              "number"=>7,
              "name"=>"Thursday",
              "startTime"=>"2023-10-19T06:00:00-04:00",
              "endTime"=>"2023-10-19T18:00:00-04:00",
              "isDaytime"=>true,
              "temperature"=>71,
              "temperatureUnit"=>"F",
              "temperatureTrend"=>nil,
              "probabilityOfPrecipitation"=>{"unitCode"=>"wmoUnit:percent", "value"=>nil},
              "dewpoint"=>{"unitCode"=>"wmoUnit:degC", "value"=>10.555555555555555},
              "relativeHumidity"=>{"unitCode"=>"wmoUnit:percent", "value"=>100},
              "windSpeed"=>"5 to 13 mph",
              "windDirection"=>"S",
              "icon"=>"https://api.weather.gov/icons/land/day/sct?size=medium",
              "shortForecast"=>"Mostly Sunny",
              "detailedForecast"=>"Mostly sunny, with a high near 71."
            },
            {
              "number"=>8,
              "name"=>"Thursday Night",
              "startTime"=>"2023-10-19T18:00:00-04:00",
              "endTime"=>"2023-10-20T06:00:00-04:00",
              "isDaytime"=>false,
              "temperature"=>56,
              "temperatureUnit"=>"F",
              "temperatureTrend"=>nil,
              "probabilityOfPrecipitation"=>{"unitCode"=>"wmoUnit:percent", "value"=>nil},
              "dewpoint"=>{"unitCode"=>"wmoUnit:degC", "value"=>11.666666666666666},
              "relativeHumidity"=>{"unitCode"=>"wmoUnit:percent", "value"=>83},
              "windSpeed"=>"14 mph",
              "windDirection"=>"S",
              "icon"=>"https://api.weather.gov/icons/land/night/bkn/rain_showers?size=medium",
              "shortForecast"=>"Mostly Cloudy then Slight Chance Rain Showers",
              "detailedForecast"=>
              "A slight chance of rain showers after 2am. Mostly cloudy, with a low around 56."
            },
            {
              "number"=>9,
              "name"=>"Friday",
              "startTime"=>"2023-10-20T06:00:00-04:00",
              "endTime"=>"2023-10-20T18:00:00-04:00",
              "isDaytime"=>true,
              "temperature"=>70,
              "temperatureUnit"=>"F",
              "temperatureTrend"=>nil,
              "probabilityOfPrecipitation"=>{"unitCode"=>"wmoUnit:percent", "value"=>50},
              "dewpoint"=>{"unitCode"=>"wmoUnit:degC", "value"=>13.88888888888889},
              "relativeHumidity"=>{"unitCode"=>"wmoUnit:percent", "value"=>90},
              "windSpeed"=>"12 mph",
              "windDirection"=>"S",
              "icon"=>"https://api.weather.gov/icons/land/day/rain_showers,30/rain_showers,50?size=medium",
              "shortForecast"=>"Chance Rain Showers",
              "detailedForecast"=>
              "A chance of rain showers. Mostly cloudy, with a high near 70. Chance of precipitation is 50%."
            },
            {
              "number"=>10,
              "name"=>"Friday Night",
              "startTime"=>"2023-10-20T18:00:00-04:00",
              "endTime"=>"2023-10-21T06:00:00-04:00",
              "isDaytime"=>false,
              "temperature"=>54,
              "temperatureUnit"=>"F",
              "temperatureTrend"=>nil,
              "probabilityOfPrecipitation"=>{"unitCode"=>"wmoUnit:percent", "value"=>60},
              "dewpoint"=>{"unitCode"=>"wmoUnit:degC", "value"=>15},
              "relativeHumidity"=>{"unitCode"=>"wmoUnit:percent", "value"=>100},
              "windSpeed"=>"12 mph",
              "windDirection"=>"SW",
              "icon"=>"https://api.weather.gov/icons/land/night/tsra,60?size=medium",
              "shortForecast"=>"Showers And Thunderstorms Likely",
              "detailedForecast"=>
              "A chance of rain showers before 8pm, then showers and thunderstorms likely. Mostly cloudy, with a low around 54. Chance of precipitation is 60%."
            },
            {
              "number"=>11,
              "name"=>"Saturday",
              "startTime"=>"2023-10-21T06:00:00-04:00",
              "endTime"=>"2023-10-21T18:00:00-04:00",
              "isDaytime"=>true,
              "temperature"=>63,
              "temperatureUnit"=>"F",
              "temperatureTrend"=>nil,
              "probabilityOfPrecipitation"=>{"unitCode"=>"wmoUnit:percent", "value"=>60},
              "dewpoint"=>{"unitCode"=>"wmoUnit:degC", "value"=>12.777777777777779},
              "relativeHumidity"=>{"unitCode"=>"wmoUnit:percent", "value"=>100},
              "windSpeed"=>"9 to 14 mph",
              "windDirection"=>"W",
              "icon"=>"https://api.weather.gov/icons/land/day/rain_showers,60/rain_showers,40?size=medium",
              "shortForecast"=>"Rain Showers Likely",
              "detailedForecast"=>
              "Rain showers likely. Partly sunny, with a high near 63. Chance of precipitation is 60%."
            },
            {
              "number"=>12,
              "name"=>"Saturday Night",
              "startTime"=>"2023-10-21T18:00:00-04:00",
              "endTime"=>"2023-10-22T06:00:00-04:00",
              "isDaytime"=>false,
              "temperature"=>50,
              "temperatureUnit"=>"F",
              "temperatureTrend"=>nil,
              "probabilityOfPrecipitation"=>{"unitCode"=>"wmoUnit:percent", "value"=>40},
              "dewpoint"=>{"unitCode"=>"wmoUnit:degC", "value"=>8.88888888888889},
              "relativeHumidity"=>{"unitCode"=>"wmoUnit:percent", "value"=>83},
              "windSpeed"=>"15 mph",
              "windDirection"=>"W",
              "icon"=>"https://api.weather.gov/icons/land/night/rain_showers,40/rain_showers?size=medium",
              "shortForecast"=>"Chance Rain Showers",
              "detailedForecast"=>
              "A chance of rain showers. Partly cloudy, with a low around 50. Chance of precipitation is 40%."
            },
            {
              "number"=>13,
              "name"=>"Sunday",
              "startTime"=>"2023-10-22T06:00:00-04:00",
              "endTime"=>"2023-10-22T18:00:00-04:00",
              "isDaytime"=>true,
              "temperature"=>61,
              "temperatureUnit"=>"F",
              "temperatureTrend"=>nil,
              "probabilityOfPrecipitation"=>{"unitCode"=>"wmoUnit:percent", "value"=>nil},
              "dewpoint"=>{"unitCode"=>"wmoUnit:degC", "value"=>7.222222222222222},
              "relativeHumidity"=>{"unitCode"=>"wmoUnit:percent", "value"=>83},
              "windSpeed"=>"14 to 20 mph",
              "windDirection"=>"W",
              "icon"=>"https://api.weather.gov/icons/land/day/rain_showers/sct?size=medium",
              "shortForecast"=>"Slight Chance Rain Showers then Mostly Sunny",
              "detailedForecast"=>
              "A slight chance of rain showers before 8am. Mostly sunny, with a high near 61."
            },
            {
              "number"=>14,
              "name"=>"Sunday Night",
              "startTime"=>"2023-10-22T18:00:00-04:00",
              "endTime"=>"2023-10-23T06:00:00-04:00",
              "isDaytime"=>false,
              "temperature"=>45,
              "temperatureUnit"=>"F",
              "temperatureTrend"=>nil,
              "probabilityOfPrecipitation"=>{"unitCode"=>"wmoUnit:percent", "value"=>nil},
              "dewpoint"=>{"unitCode"=>"wmoUnit:degC", "value"=>5.555555555555555},
              "relativeHumidity"=>{"unitCode"=>"wmoUnit:percent", "value"=>83},
              "windSpeed"=>"13 to 20 mph",
              "windDirection"=>"W",
              "icon"=>"https://api.weather.gov/icons/land/night/few?size=medium",
              "shortForecast"=>"Mostly Clear",
              "detailedForecast"=>"Mostly clear, with a low around 45."}
          ]
        }}.to_json
    end
    let(:expected_dailies) do
        [
          {
            when: "Today",
            temperatures: [
              {
                value: "61F",
                icon: "https://api.weather.gov/icons/land/day/rain_showers,20?size=medium",
              },
              {
                value: "48F",
                icon: "https://api.weather.gov/icons/land/night/rain_showers,20/bkn?size=medium",
              },
            ],
          },
          {
            when: "Tuesday",
            temperatures: [
              {
                value: "65F",
                icon: "https://api.weather.gov/icons/land/day/bkn?size=medium",
              },
              {
                value: "47F",
                icon: "https://api.weather.gov/icons/land/night/sct?size=medium",
              },
            ],
          },
          {
            when: "Wednesday",
            temperatures: [
              {
                value: "67F",
                icon: "https://api.weather.gov/icons/land/day/sct?size=medium",
              },
              {
                value: "49F",
                icon: "https://api.weather.gov/icons/land/night/few?size=medium",
              },
            ],
          },
          {
            when: "Thursday",
            temperatures: [
              {
                value: "71F",
                icon: "https://api.weather.gov/icons/land/day/sct?size=medium",
              },
              {
                value: "56F",
                icon: "https://api.weather.gov/icons/land/night/bkn/rain_showers?size=medium",
              },
            ],
          },
          {
            when: "Friday",
            temperatures: [
              {
                value: "70F",
                icon: "https://api.weather.gov/icons/land/day/rain_showers,30/rain_showers,50?size=medium",
              },
              {
                value: "54F",
                icon: "https://api.weather.gov/icons/land/night/tsra,60?size=medium",
              },
            ],
          },
          {
            when: "Saturday",
            temperatures: [
              {
                value: "63F",
                icon: "https://api.weather.gov/icons/land/day/rain_showers,60/rain_showers,40?size=medium",
              },
              {
                value: "50F",
                icon: "https://api.weather.gov/icons/land/night/rain_showers,40/rain_showers?size=medium",
              },
            ],
          },
          {
            when: "Sunday",
            temperatures: [
              {
                value: "61F",
                icon: "https://api.weather.gov/icons/land/day/rain_showers/sct?size=medium",
              },
              {
                value: "45F",
                icon: "https://api.weather.gov/icons/land/night/few?size=medium",
              },
            ],
          },
        ]
    end

    before(:each) do
      allow(subject).to receive(:get_forecast_url).and_return(forecast_url)
      stub_request(:get, forecast_url)
        .to_return(status: 200, body: forecast_json, headers: {})
    end

    it "calls the forecast API" do
      subject.get_forecast(latitude, longitude)
      expect(a_request(:get, forecast_url)).to have_been_made.once
    end

    it "returns the daily highs and lows" do
      expect(subject.get_forecast(latitude, longitude))
        .to eq(expected_dailies)
    end
  end

  describe "#decode_forecast" do
    let(:tuesday) do
      {
        "number"=>3,
        "name"=>"Tuesday",
        "startTime"=>"2023-10-17T06:00:00-04:00",
        "endTime"=>"2023-10-17T18:00:00-04:00",
        "isDaytime"=>true,
        "temperature"=>65,
        "temperatureUnit"=>"F",
        "temperatureTrend"=>nil,
        "probabilityOfPrecipitation"=>{"unitCode"=>"wmoUnit:percent", "value"=>nil},
        "dewpoint"=>{"unitCode"=>"wmoUnit:degC", "value"=>9.444444444444445},
        "relativeHumidity"=>{"unitCode"=>"wmoUnit:percent", "value"=>100},
        "windSpeed"=>"8 mph",
        "windDirection"=>"NW",
        "icon"=>"https://api.weather.gov/icons/land/day/bkn?size=medium",
        "shortForecast"=>"Partly Sunny",
        "detailedForecast"=>"Partly sunny, with a high near 65. Northwest wind around 8 mph."
      }
    end
    let(:tuesday_night) do
      {
        "number"=>4,
        "name"=>"Tuesday Night",
        "startTime"=>"2023-10-17T18:00:00-04:00",
        "endTime"=>"2023-10-18T06:00:00-04:00",
        "isDaytime"=>false,
        "temperature"=>47,
        "temperatureUnit"=>"F",
        "temperatureTrend"=>nil,
        "probabilityOfPrecipitation"=>{"unitCode"=>"wmoUnit:percent", "value"=>nil},
        "dewpoint"=>{"unitCode"=>"wmoUnit:degC", "value"=>9.444444444444445},
        "relativeHumidity"=>{"unitCode"=>"wmoUnit:percent", "value"=>93},
        "windSpeed"=>"2 to 6 mph",
        "windDirection"=>"NW",
        "icon"=>"https://api.weather.gov/icons/land/night/sct?size=medium",
        "shortForecast"=>"Partly Cloudy",
        "detailedForecast"=>"Partly cloudy, with a low around 47. Northwest wind 2 to 6 mph."
      }
    end
    let(:expected_tuesday) do
      {
        when: "Tuesday",
        temperatures: [
          {
            value: "65F",
            icon: "https://api.weather.gov/icons/land/day/bkn?size=medium",
          },
          {
            value: "47F",
            icon: "https://api.weather.gov/icons/land/night/sct?size=medium",
          },
        ],
      }
    end

    context "if two 12-hour periods for today" do
      let(:periods) do
        [
          {
            "number"=>1,
            "name"=>"This Afternoon",
            "startTime"=>"2023-10-16T12:00:00-04:00",
            "endTime"=>"2023-10-16T18:00:00-04:00",
            "isDaytime"=>true,
            "temperature"=>61,
            "temperatureUnit"=>"F",
            "temperatureTrend"=>nil,
            "probabilityOfPrecipitation"=>{"unitCode"=>"wmoUnit:percent", "value"=>20},
            "dewpoint"=>{"unitCode"=>"wmoUnit:degC", "value"=>8.88888888888889},
            "relativeHumidity"=>{"unitCode"=>"wmoUnit:percent", "value"=>62},
            "windSpeed"=>"10 mph",
            "windDirection"=>"NW",
            "icon"=>"https://api.weather.gov/icons/land/day/rain_showers,20?size=medium",
            "shortForecast"=>"Isolated Rain Showers",
            "detailedForecast"=>
            "Isolated rain showers after 5pm. Mostly cloudy, with a high near 61. Northwest wind around 10 mph. Chance of precipitation is 20%."
          },
          {
            "number"=>2,
            "name"=>"Tonight",
            "startTime"=>"2023-10-16T18:00:00-04:00",
            "endTime"=>"2023-10-17T06:00:00-04:00",
            "isDaytime"=>false,
            "temperature"=>48,
            "temperatureUnit"=>"F",
            "temperatureTrend"=>nil,
            "probabilityOfPrecipitation"=>{"unitCode"=>"wmoUnit:percent", "value"=>20},
            "dewpoint"=>{"unitCode"=>"wmoUnit:degC", "value"=>10},
            "relativeHumidity"=>{"unitCode"=>"wmoUnit:percent", "value"=>96},
            "windSpeed"=>"8 mph",
            "windDirection"=>"NW",
            "icon"=>"https://api.weather.gov/icons/land/night/rain_showers,20/bkn?size=medium",
            "shortForecast"=>"Isolated Rain Showers then Mostly Cloudy",
            "detailedForecast"=>
            "Isolated rain showers before 8pm. Mostly cloudy, with a low around 48. Northwest wind around 8 mph. Chance of precipitation is 20%."
          },
        ].concat([tuesday, tuesday_night])
      end

      it "returns a high and low for today, and each day" do
        expect(subject.decode_forecast(periods)).to eq([
          {
            when: "Today",
            temperatures: [
              {
                value: "61F",
                icon: "https://api.weather.gov/icons/land/day/rain_showers,20?size=medium",
              },
              {
                value: "48F",
                icon: "https://api.weather.gov/icons/land/night/rain_showers,20/bkn?size=medium",
              },
            ],
          },
          expected_tuesday,
        ])
      end
    end

    context "if one 12-hour periods for today" do
      let(:periods) do
        [
          {
            "number"=>1,
            "name"=>"Tonight",
            "startTime"=>"2023-10-16T18:00:00-04:00",
            "endTime"=>"2023-10-17T06:00:00-04:00",
            "isDaytime"=>false,
            "temperature"=>48,
            "temperatureUnit"=>"F",
            "temperatureTrend"=>nil,
            "probabilityOfPrecipitation"=>{"unitCode"=>"wmoUnit:percent", "value"=>20},
            "dewpoint"=>{"unitCode"=>"wmoUnit:degC", "value"=>10},
            "relativeHumidity"=>{"unitCode"=>"wmoUnit:percent", "value"=>96},
            "windSpeed"=>"8 mph",
            "windDirection"=>"NW",
            "icon"=>"https://api.weather.gov/icons/land/night/rain_showers,20/bkn?size=medium",
            "shortForecast"=>"Isolated Rain Showers then Mostly Cloudy",
            "detailedForecast"=>
            "Isolated rain showers before 8pm. Mostly cloudy, with a low around 48. Northwest wind around 8 mph. Chance of precipitation is 20%."
          },
        ].concat([tuesday, tuesday_night])
      end

      it "returns a high for today, and high and low for each day" do
        expect(subject.decode_forecast(periods)).to eq([
          {
            when: "Today",
            temperatures: [
              {
                value: "48F",
                icon: "https://api.weather.gov/icons/land/night/rain_showers,20/bkn?size=medium",
              },
            ],
          },
          expected_tuesday,
        ])
      end
    end
  end
end
