# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
addresses = [
  'Statue of Liberty',
  'White House',
  'Grand Canyon',
]

puts "Clearing seeds..."

Place.destroy_all

puts "Seeds cleared."

puts "Seeding database"

addresses.each { |address| Place.create!(address: address) }

puts "Created #{Place.all.count} places."
