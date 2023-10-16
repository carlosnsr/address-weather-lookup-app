class Place < ApplicationRecord
  validates_presence_of :address
  after_validation :call_geocoder

  private

  def call_geocoder
    if self.address.present?
      result = Geocoder.search(self.address).first
      self.latitude = result.latitude
      self.longitude = result.longitude
      self.postal_code = result.postal_code || "#{result.city}::#{result.country_code}"
    end
  end
end
