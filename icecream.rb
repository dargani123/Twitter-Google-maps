require 'json'
require 'addressable/uri'
require 'rest-client'
require 'nokogiri'

## get longitude and latitude

def getLocation
  loc = Addressable::URI.new(
      :scheme => "https",
      :host => "maps.googleapis.com",
      :path => "maps/api/geocode/json",
      :query_values => {:address => "160+Folsom,+San+Francisco,+CA",
                        :sensor => "false"}).to_s

  location_request = RestClient.get(loc)
  parsed_location_request = JSON.parse(location_request)

  lat = parsed_location_request["results"][0]["geometry"]["location"]["lat"].to_s
  lng = parsed_location_request["results"][0]["geometry"]["location"]["lng"].to_s

  [lat,lng]
end


def get_place_names
  text_search = Addressable::URI.new(
    :scheme => "https",
    :host => "maps.googleapis.com",
    :path => "maps/api/place/textsearch/json",
    :query_values => {:key => "AIzaSyC1q5rAuNnAcD7GCnc7Ul3SBJ57JJDA-DA",
                      :location => "#{getLocation[0]},#{getLocation[1]}",
                      :query => "ice+cream",
                      :radius => "35",
                      :sensor => "false"}).to_s

  response = RestClient.get(text_search)
  parsed_text_response = JSON.parse(response)

  results = parsed_text_response["results"]

  add_and_names = {}
  results.each_with_index { |store, index| add_and_names[index] = {store["name"] => store["formatted_address"]} }
  add_and_names
end

def print_directions (start_address, end_address)
  direction_search = Addressable::URI.new(
    :scheme => "https",
    :host => "maps.googleapis.com",
    :path => "maps/api/directions/json",
    :query_values => {:origin => "160+Folsom,+San+Francisco,+CA",
                      :destination => "#{end_address}",
                      :sensor => "false"}).to_s
  response = RestClient.get(direction_search)
  parsed_response = JSON.parse(response)

  directions = parsed_response["routes"][0]["legs"][0]["steps"]

  dir = "#{start_address} to #{end_address}"
  directions.each_with_index do |step, index|
    puts "#{index.to_i}:#{Nokogiri::HTML(step["html_instructions"]).text}"
    puts "#{step["distance"]["text"]}, for #{step["duration"]["text"]} \n\n"
  end
  dir

end

puts "Pick an ice cream shop:"
ice_cream_stores = get_place_names
ice_cream_stores.each { |index, name| print "#{index}) #{name.keys[0]} \n" }
choice = gets.chomp.to_i

end_address = ice_cream_stores[choice][ice_cream_stores[choice].keys[0]]
end_address.gsub!(" ","+")
p end_address

print_directions("", end_address)







# QUESTION: Geocoding is a time and resource intensive task. Whenever possible, pre-geocode known addresses (using the Geocoding API described here or another geocoding service), and store your results in a temporary cache of your own design.






