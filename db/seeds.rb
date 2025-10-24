# db/seeds.rb
require "open-uri"
require "nokogiri"
require "date"

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

# URL of the page to scrape
page_url = "https://www.in-muenchen.de/veranstaltungen"
html = URI.open(page_url)
doc = Nokogiri::HTML(html)

# Helper for category inference (adjust as needed)
def infer_category(title, description)
  text = "#{title} #{description}".downcase
  return "Entertainment" if text.match?(/concert|festival|music|movie|party|show|performance/)
  return "Education" if text.match?(/lecture|seminar|class|course|workshop|conference|talk|ausstellung|kunst|exhibition/)
  return "Work-Related" if text.match?(/tech|startup|networking|coding|business|career/)
  return "Personal" if text.match?(/birthday|meetup|friends|family|community/)
  "Entertainment"
end

# Helper for attaching photo (placeholder optional)
PLACEHOLDERS = {
  "Entertainment" => "https://images.unsplash.com/photo-1518972559570-7cc1309f3229",
  "Education"     => "https://images.unsplash.com/photo-1524995997946-a1c2e315a42f",
  "Work-Related"  => "https://images.unsplash.com/photo-1519389950473-47ba0277781c",
  "Personal"      => "https://images.unsplash.com/photo-1517841905240-472988babdf9"
}

def attach_photo(event, image_url)
  placeholder = PLACEHOLDERS[event.category] || PLACEHOLDERS["Entertainment"]
  begin
    file = URI.open(image_url)
    event.photo.attach(io: file, filename: "#{event.title.parameterize}.jpg", content_type: "image/jpeg")
    puts "✅ Attached image for #{event.title}"
  rescue
    puts "⚠️ Failed to attach image, using placeholder"
    file = URI.open(placeholder)
    event.photo.attach(io: file, filename: "#{event.category.parameterize}-placeholder.jpg", content_type: "image/jpeg")
  end
end

puts "Scraping events..."

# Loop over teaser items
doc.css("div#event-list div.teaser-item.medium").each do |item|
  title = item.at_css("a.title")&.text&.strip
  description = item.at_css("a.description")&.text&.strip || "No description available"
  image_url = item.at_css("a.image-wrapper img")&.[]("src")
  location = item.at_css("div.location a")&.text&.strip
  date_text = item.at_css("div.date span")&.text&.strip

  # Parse date string (example: "So, 26.10.2025, 10:00 Uhr")
  begin
    date = Date.strptime(date_text.split(",")[1].strip, "%d.%m.%Y") if date_text
  rescue
    date = Date.today
  end

  category = infer_category(title, description)

  event = Event.create!(
    title: title,
    description: description,
    contact: item.at_css("a.title")&.[]("href") || "N/A",
    category: category,
    location: location,
    date: date,
    user: user
  )

  attach_photo(event, image_url)
  puts "🎟️ Created #{event.title} (#{category})"
end

puts "✅ Finished! Created #{Event.count} Events."

# # db/seeds.rb
# require "open-uri"
# require "json"
# require "net/http"
# require "date"

# puts "Cleaning database..."
# Event.destroy_all
# User.destroy_all
# puts "Database cleaned."

# puts "Creating user..."
# user = User.find_or_create_by!(email: "template1@lewagon.com") do |u|
#   u.password = "password"
#   u.password_confirmation = "password"
# end
# puts "User created: #{user.email}"

# # --- Placeholders for each category ---
# PLACEHOLDERS = {
#   "Entertainment" => "https://images.unsplash.com/photo-1518972559570-7cc1309f3229",
#   "Education"     => "https://images.unsplash.com/photo-1524995997946-a1c2e315a42f",
#   "Work-Related"  => "https://images.unsplash.com/photo-1519389950473-47ba0277781c",
#   "Personal"      => "https://images.unsplash.com/photo-1517841905240-472988babdf9"
# }

# # --- Fetch SerpAPI JSON ---
# puts "Fetching events from SerpAPI..."
# url = URI("https://serpapi.com/searches/e6a9462c1703e3b8/68fb52d6e6cb303548ea1d66.json")
# response = Net::HTTP.get(url)
# data = JSON.parse(response)
# events = data["events_results"]
# puts "Fetched #{events.count} events."

# # --- Helper for category inference ---
# def infer_category(title, description)
#   text = "#{title} #{description}".downcase
#   return "Entertainment" if text.match?(/concert|festival|music|movie|party|show|performance/)
#   return "Education" if text.match?(/lecture|seminar|class|course|workshop|conference|talk/)
#   return "Work-Related" if text.match?(/tech|startup|networking|coding|business|career/)
#   return "Personal" if text.match?(/birthday|meetup|friends|family|community/)
#   "Entertainment"
# end

# # --- Helper for attaching photo ---
# def attach_photo(event, image_url)
#   placeholder = PLACEHOLDERS[event.category] ||
#                 "https://images.unsplash.com/photo-1518972559570-7cc1309f3229"

#   begin
#     if image_url.present?
#       file = URI.open(image_url)
#       event.photo.attach(io: file, filename: "#{event.title.parameterize}.jpg", content_type: "image/jpeg")
#       puts "✅ Attached image for #{event.title}"
#     else
#       raise "Missing image URL"
#     end
#   rescue => e
#     puts "⚠️ Image unavailable for #{event.title}, using placeholder (#{event.category})"
#     file = URI.open(placeholder)
#     event.photo.attach(io: file, filename: "#{event.category.parameterize}-placeholder.jpg", content_type: "image/jpeg")
#   end
# end

# # --- Create events from API ---
# puts "Creating events..."

# events.first(6).each do |e|
#   title = e["title"]
#   description = e["description"] || "No description available."
#   contact = e["link"] || "N/A"
#   category = infer_category(title, description)
#   location = (e["address"] || []).join(", ")
#   date_string = e.dig("date", "start_date")

#   year = Date.today.year
#   begin
#     date = Date.parse("#{date_string} #{year}")
#   rescue
#     date = Date.today
#   end

#   event = Event.create!(
#     title: title,
#     description: description,
#     contact: contact,
#     category: category,
#     location: location,
#     date: date,
#     user: user
#   )

#   image_url = e["image"] || e.dig("venue", "thumbnail")
#   attach_photo(event, image_url)

#   puts "🎟️ Created #{event.title} (#{category})"
# end

# puts "✅ Finished! Created #{Event.count} Events."

# BACKUP

# # db/seeds.rb
# require "open-uri"

# puts "Cleaning database..."
# Event.destroy_all
# User.destroy_all
# puts "Database cleaned."

# puts "Creating user..."
# user = User.find_or_create_by!(email: "template1@lewagon.com") do |u|
#   u.password = "password"
#   u.password_confirmation = "password"
# end
# puts "User created: #{user.email}"

# # Define one image URL to reuse
# image_url = "https://images.squarespace-cdn.com/content/v1/6298fd6ae35e6a0a8ca448fc/537f2b0f-716f-4e5f-bad8-2be9396cdf39/KelseyFloyd_Viv.Events_OspreyParty_web_418.jpg"

# def attach_photo(event, url)
#   file = URI.open(url)
#   event.photo.attach(io: file, filename: "#{event.title.parameterize}.jpg", content_type: "image/jpeg")
# end

# puts "Creating events..."

# events_data = [
#   {
#     title: "The Hives concert",
#     description: "The Hives are a Swedish rock band formed in 1989...",
#     contact: "https://thehives.com/",
#     category: "Entertainment",
#     location: "Lilienthalallee 29, 80939, Munich, Germany",
#     date: Date.new(2025, 10, 24)
#   },
#   {
#     title: "get your gig coding session",
#     description: "A collaborative coding session to build our app.",
#     contact: "https://github.com/schmojojo/rails_get_your_gig",
#     category: "Work-Related",
#     date: Date.new(2025, 10, 22)
#   },
#   {
#     title: "LeWagon class lecture",
#     description: "Change your life, learn to code. Le Wagon is ranked as the world's best coding bootcamp...",
#     contact: "https://kitt.lewagon.com/",
#     category: "Education",
#     date: Date.new(2025, 10, 21)
#   },
#   {
#     title: "Dimitru's birthday",
#     description: "Let's celebrate!",
#     contact: "N/A",
#     category: "Personal",
#     location: "Lilienthalallee 29, 80939, Munich, Germany",
#     date: Date.new(2025, 11, 15)
#   },
#   {
#     title: "The long walk movie",
#     description: "In a near future, a repressive regime governs the USA...",
#     contact: "https://www.museum-lichtspiele.de/detail/122317/The%20Long%20Walk",
#     category: "Entertainment",
#     location: "Museum Lichtspiele, Lilienstrasse 2, 81669 München",
#     date: Date.new(2025, 10, 26)
#   },
#   {
#     title: "Mental Health festival",
#     description: "The Mental Health Arts Festival provides a platform for art...",
#     contact: "https://www.gasteig.de/en/festivals/mental-health-arts-festival/",
#     category: "Education",
#     date: Date.new(2025, 10, 22)
#   }
# ]

# events_data.each do |event_attrs|
#   event = Event.create!(**event_attrs, user: user)
#   attach_photo(event, image_url)
#   puts "Created #{event.title}"
# end

# puts "Finished! Created #{Event.count} Events."


# BACKUP CODE FOR SEEDS - DO NOT DELETE
# puts "Cleaning database..."

# Event.destroy_all
# User.destroy_all
# puts "Database cleaned."

# puts "Creating user..."
# user = User.find_or_create_by!(email: "template1@lewagon.com") do |u|
#   u.password = "password"
#   u.password_confirmation = "password"
# end
# puts "User created: #{user.email}"


# puts "Creating events..."
# Event.create!(
#   title: "The Hives concert",
#   description: "The Hives are a Swedish rock band formed in 1989...",
#   contact: "https://thehives.com/",
#   category: "Entertainment",
#   location: "Lilienthalallee 29, 80939, Munich, Germany",
#   date: Date.new(2025, 10, 24),
#   user: user
# )
# puts "Created The Hives"

# Event.create!(
#   title: "get your gig coding session",
#   description: "A collaborative coding session to build our app.",
#   contact: "https://github.com/schmojojo/rails_get_your_gig",
#   category: "Work-Related",
#   date: Date.new(2025, 10, 22),
#   user: user
# )
# puts "Created get your gig coding session"

# Event.create!(
#   title: "LeWagon class lecture",
#   description: "Change your life, learn to code. Le Wagon is ranked as the world's best coding bootcamp...",
#   contact: "https://kitt.lewagon.com/",
#   category: "Education",
#   date: Date.new(2025, 10, 21),
#   user: user
# )
# puts "Created LeWagon class lecture"

# Event.create!(
#   title: "Dimitru's birthday",
#   description: "Let's celebrate!",
#   contact: "N/A",
#   category: "Personal",
#   location: "Lilienthalallee 29, 80939, Munich, Germany",
#   date: Date.new(2025, 11, 15),
#   user: user
# )
# puts "Created D's birthday"

# Event.create!(
#   title: "The long walk movie",
#   description: "In a near future, a repressive regime governs the USA...",
#   contact: "https://www.museum-lichtspiele.de/detail/122317/The%20Long%20Walk",
#   category: "Entertainment",
#   location: "Museum Lichtspiele, Lilienstrasse 2, 81669 München",
#   date: Date.new(2025, 10, 26),
#   user: user
# )
# puts "Created The long walk movie"

# Event.create!(
#   title: "Mental Health festival",
#   description: "The Mental Health Arts Festival provides a platform for art...",
#   contact: "https://www.gasteig.de/en/festivals/mental-health-arts-festival/",
#   category: "Education",
#   date: Date.new(2025, 10, 22),
#   user: user
# )
# puts "Created Mental Health festival"

# puts "Finished! Created #{Event.count} Events."
