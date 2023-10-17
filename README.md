# Weather App

## Word from the Author

Thank you for setting an interesting assessment.

I submit this version (after having scrapped several others) because it is simpler to evaluate and fulfills the requested requirements.
If I was to continue this project, I would want to make the changes listed in the below roadmap.

The API keys were separately submitted to the recruiter.  Just in case, I will retire the API keys in 14 days.

### Roadmap

- use jobs to handle the querying of external APIs (e.g. Geocoder and Weather)
    - as it is currently implemented, I'm assuming no/little lag and 100% up-time.  These won't always be true and should be handled in a production-ready app.
- use a separate React front-end to consume the API
    - smoother transitions between the Saved Addresses page and the page entering a new address
    - show a loading circle while the Geocoder/Weather jobs are fetching their respective payloads
    - update the page with Geocoder/Weather info once the jobs have completed
    - integrate with an address validator/autocomplete to give user address suggestions as they type
    - display a map showing the selected address
- set up a separate cache storage (most likely Redis)
    - the default Rails cache storage is `:memory_store` which is not persistent and disappears once the server is killed
    - a separate cache storage could also be shared across multiple server instances
- better error-handling
    - handling what happens if the Geocoder/Weather API errors or is unavailable
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
