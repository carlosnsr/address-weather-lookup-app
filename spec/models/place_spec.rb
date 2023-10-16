require 'rails_helper'

RSpec.describe Place, type: :model do
  let(:paris_json) do
    {
      "results"=> [{
        "address_components"=> [
          {"long_name"=>"Paris", "short_name"=>"Paris", "types"=>["locality", "political"]},
          {"long_name"=>"Paris", "short_name"=>"Paris", "types"=>["administrative_area_level_2", "political"]},
          {"long_name"=>"Île-de-France", "short_name"=>"IDF", "types"=>["administrative_area_level_1", "political"]},
         {"long_name"=>"France", "short_name"=>"FR", "types"=>["country", "political"]}
        ],
        "formatted_address"=>"Paris, France",
        "geometry"=> {
          "bounds"=> {
            "northeast"=>{"lat"=>48.9021475, "lng"=>2.4698509},
            "southwest"=>{"lat"=>48.8155622, "lng"=>2.2242191}
          },
          "location"=>{"lat"=>48.856614, "lng"=>2.3522219},
          "location_type"=>"APPROXIMATE",
          "viewport"=> {
            "northeast"=>{"lat"=>48.9021475, "lng"=>2.4698509},
            "southwest"=>{"lat"=>48.8155622, "lng"=>2.2242191}
          }
        },
        "place_id"=>"ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
        "types"=>["locality", "political"]
      }],
      "status"=>"OK"
    }.to_json
  end
  let(:geocode_url) { "https://maps.googleapis.com/maps/api/geocode/json" }

  before(:each) do
    stub_request(:get, geocode_url)
        .with(
           query: {
             address: "Paris",
             key: ENV["GOOGLE_MAPS_API_KEY"],
             language: "en",
             sensor: "false"
           }
        ).to_return(status: 200, body: paris_json, headers: {})
  end

  context "if is valid" do
    subject { Place.new(address: "Paris") }

    it "populates latitude" do
      expect { subject.valid? }.to change { subject.latitude }.from(nil).to(48.856614)
    end

    it "populates longitude" do
      expect { subject.valid? }.to change { subject.longitude }.from(nil).to(2.3522219)
    end

    it "populates postal_code" do
      expect { subject.valid? }.to change { subject.postal_code }.from(nil).to("Paris::FR")
    end
  end

  it "is not valid without an address" do
    expect(Place.new(address: nil)).to_not be_valid
  end

  context "if is invalid" do
    subject { Place.new(address: nil) }

    it "does NOT populate latitude" do
      expect { subject.valid? }.not_to change { subject.latitude }.from(nil)
    end

    it "does NOT populate longitude if invalid" do
      expect { subject.valid? }.not_to change { subject.longitude }.from(nil)
    end

    it "does NOT populate postal_code if invalid" do
      expect { subject.valid? }.not_to change { subject.postal_code }.from(nil)
    end
  end
end
