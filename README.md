# Weather App

## Word from the Author

Thank you for setting an interesting assessment.

I submit this version (after having scrapped several others) because it is simpler to evaluate and fulfills the requested requirements.
If I was to continue this project, I would want to make the changes listed in the below roadmap.

For your convenience, the API keys that I used were separately submitted to the recruiter.
I will retire these API keys in 14 days.

### Roadmap

- use asynchronous (background) jobs to handle the querying of external APIs (e.g. Geocoder and Weather)
    - as it is currently implemented, I'm assuming no/little lag and 100% up-time. These won't always be true.
    - a job could retry the query (with limited retries and exponential back-off) if it happened to fail
    - the database and front-end can then be updated when the job completes
- use a separate React front-end to consume the API
    - smoother transitions between the Saved Addresses page and the page entering a new address
    - show a loading circle while the Geocoder/Weather jobs are fetching their respective payloads
    - update the page with Geocoder/Weather info once the jobs have completed
    - integrate with an address validator/autocomplete to give user address suggestions as they type
    - display a map showing the selected address
- set up a separate cache storage (e.g. Redis)
    - the default Rails cache storage is `:memory_store` which is not persistent and disappears once the server is killed
    - a separate cache storage could also be shared across multiple server instances
- use a different API for getting the weather at the given address
    - currently, we're using an API provided by the [National Weather Service](https://www.weather.gov/documentation/services-web-api)
    - the forecast is always 14 12-hour segments, so one gets odd edge cases when querying it at the very end of the day
      (e.g. The current day only having the night-time temperature, and there being the morning temperature for an 8th day)
- better error-handling
    - handling what happens if the Geocoder/Weather API errors or is unavailable
    - better handling what `postal_code` gets saved against the address when Geocoder cannot determine a postal/zip code.
      Thus preventing cache-hits returning an irrelevant result.
- more testing
    - request tests
    - view tests
    - cache tests

## Dependencies

### Geocoder and Google Maps API

This project uses the [geocoder](https://github.com/alexreisner/geocoder) gem.
In turn, geocoder uses the [Google Maps Platform](https://developers.google.com/maps).
You will need to create an new app with the following products enabled:
- Geocoding API
- Directions API
- Maps JavaScript API

Generate an unrestricted API key for the server (will remain secret and be called `GOOGLE_MAPS_API_KEY`).

Alternatively, use the API key that I provided the recruiter (valid until Nov 1, 2023)

### Save the API Keys

    cp dev.env.example .env
    # Open .env in your editor and enter the API keys that you generated above.
    # The dotenv gem export the values in .env to the shell.

## Installation

### Prerequisites

- An API key for Google Maps Platform (see [Geocoder and Google Maps API](#geocoder-and-google-maps-api))
- An environment file with the above API key (see [Save the API Keys](#save-the-api-keys))

### To Install

    bundle
    rails db:create
    rails db:seed

### To Run in Development

    # Toggles the dev cache
    ./bin/rails dev:cache
    ./bin/dev

## Testing

    rspec

Testing was done using RSpec.
In the interest of time, the testing was mainly restricted to the more impactful features (i.e. geocoding and the weather API).
