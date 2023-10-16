# Weather App

## Dependencies

### Geocoder and Google Maps API

This project uses the [geocoder](https://github.com/alexreisner/geocoder) gem.
In turn, geocoder uses the [Google Maps Platform](https://developers.google.com/maps).
You will need to create an new app with the following products enabled:
- Geocoding API
- Directions API
- Maps JavaScript API

Generate an unrestricted API key for the server (will remain secret and be called GOOGLE_MAPS_API_KEY).

### Save the API Keys

    cp dev.env.example .env
    # open .env in your editor and enter the API keys that you generated above

## Installation

### Prerequisites

- An API key for Google Maps Platform (see [Geocoder and Google Maps API](#geocoder-and-google-maps-api))
- An environment file with the above API key (see [Save the API Keys](save-the-api-keys))

### To Install and Run

    bundle
    rails db:create
    rails db:seed
    ./bin/dev

- To Do
  - Installation
      - Database creation
      - Database initialization
      - Configuration
  - Testing
  - Usage
  - Deployment
  - Services (job queues, cache servers, search engines, etc.)
