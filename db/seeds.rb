# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb
# 1. Clean the database 🗑️
puts "Cleaning database..."
Event.destroy_all

User.create!(email: "template1@lewagon.com", password: "template1@lewagon.com")


# 2. Create the instances 🏗️
puts "Creating events..."
Event.create!(title: "The Hives concert", description: "The Hives are a Swedish rock band formed in 1989. They came to prominence at the turn of the 21st century, heralding the garage rock revival along with The Strokes, The Vines and The White Stripes", contact: "https://thehives.com/", category: "Entertainment", location: "Lilienthalallee 29, 80939, Munich, Germany", date: Date.new(2025,10,24), user_id: 1)
puts "Created The Hives"
Event.create!(title: "get your gig coding session", description: "", contact: "https://github.com/schmojojo/rails_get_your_gig", category: "Work-Related", date: Date.new(2025,10,22), user_id: 1)
puts "Creted get your gig coding session"
Event.create!(title: "LeWagon class lecture", description: "Change your life, learn to code. Le Wagon is ranked as the world's best coding bootcamp and has enabled thousands of people to change their careers.", contact: "https://kitt.lewagon.com/", category: "Education", date: Date.new(2025,10,21),  user_id: 1)
puts "Created LeWagon class lecture"
Event.create!(title: "Dimitru's birthday", category: "Personal", location: "Lilienthalallee 29, 80939, Munich, Germany", date: Date.new(2025,11,15), user_id: 1)
puts "Created Dimitru's birthday"
Event.create!(title: "The long walk movie", description: "In a near future, a repressive regime governs the USA. The authoritarian Major runs a police state with strict rules and a brutal competition. Each year, one hundred teenagers participate, but only one can win: the one who survives the march.", contact: "https://www.museum-lichtspiele.de/detail/122317/The%20Long%20Walk", category: "Entertainment", location: "Museum Lichtspiele, Lilienstrasse 2, 81669 München", date: Date.new(2025,10,26), user_id: 1)
puts "Created The long walk movie"
Event.create!(title: "Mental Health festival", description: " the Mental Health Arts Festival provides a platform for art as well as an opportunity to actively take part in a host of activities. Everyone can participate and benefit from the feel-good factor in dancing, relaxing or being creative", contact: "https://www.gasteig.de/en/festivals/mental-health-arts-festival/", category: "Education", date: Date.new(2025,10,22), user_id: 1)
puts "Created Mental Health festival"

# 3. Display a message 🎉
puts "Finished! Created #{Event.count} Events."
