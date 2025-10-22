puts "Cleaning database..."

Event.destroy_all
User.destroy_all
puts "Database cleaned."

puts "Creating user..."
user = User.find_or_create_by!(email: "template1@lewagon.com") do |u|
  u.password = "password"
  u.password_confirmation = "password"
end
puts "User created: #{user.email}"


puts "Creating events..."
Event.create!(
  title: "The Hives concert",
  description: "The Hives are a Swedish rock band formed in 1989...",
  contact: "https://thehives.com/",
  category: "Entertainment",
  location: "Lilienthalallee 29, 80939, Munich, Germany",
  date: Date.new(2025, 10, 24),
  user: user
)
puts "Created The Hives"

Event.create!(
  title: "get your gig coding session",
  description: "A collaborative coding session to build our app.",
  contact: "https://github.com/schmojojo/rails_get_your_gig",
  category: "Work-Related",
  date: Date.new(2025, 10, 22),
  user: user
)
puts "Created get your gig coding session"

Event.create!(
  title: "LeWagon class lecture",
  description: "Change your life, learn to code. Le Wagon is ranked as the world's best coding bootcamp...",
  contact: "https://kitt.lewagon.com/",
  category: "Education",
  date: Date.new(2025, 10, 21),
  user: user
)
puts "Created LeWagon class lecture"

Event.create!(
  title: "Dimitru's birthday",
  description: "Let's celebrate!",
  contact: "N/A",
  category: "Personal",
  location: "Lilienthalallee 29, 80939, Munich, Germany",
  date: Date.new(2025, 11, 15),
  user: user
)
puts "Created D's birthday"

Event.create!(
  title: "The long walk movie",
  description: "In a near future, a repressive regime governs the USA...",
  contact: "https://www.museum-lichtspiele.de/detail/122317/The%20Long%20Walk",
  category: "Entertainment",
  location: "Museum Lichtspiele, Lilienstrasse 2, 81669 München",
  date: Date.new(2025, 10, 26),
  user: user
)
puts "Created The long walk movie"

Event.create!(
  title: "Mental Health festival",
  description: "The Mental Health Arts Festival provides a platform for art...",
  contact: "https://www.gasteig.de/en/festivals/mental-health-arts-festival/",
  category: "Education",
  date: Date.new(2025, 10, 22),
  user: user
)
puts "Created Mental Health festival"

puts "Finished! Created #{Event.count} Events."
