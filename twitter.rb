require 'addressable/uri'
require 'launchy'
require 'oauth'
require 'yaml'
require 'json'
require 'uri'


class Status

  def initialize(tweet, user)
    @tweet = tweet
    @user = user
  end

  def self.mentions (post_hash)

    mentions = post_hash["entities"]["user_mentions"][0]
    return mentions["screen_name"] unless mentions.nil?
  end

  def self.hash_tags(post_hash)
   hash_arr = post_hash["entities"]["hashtags"]
   hash_arr[0]["text"] unless hash_arr.empty?
  end

end

class Hashtag

  def initialize (tag)
    @tag = tag
  end

  def statuses ## not working yet.
    cleaner = URI::Parser.new
    EndUser.access_token.get("https://stream.twitter.com/1.1/statuses/filter.json?track=cleaner.escape(##{@tag})")
  end

end

class User
  attr_reader :username

  def initialize(username)
    @username = username
  end

end

class EndUser < User

  attr_accessor :username

  CONSUMER_KEY = "sEsws2EvUyeFDWd6ifoS5g"
  CONSUMER_SECRET = "t5ZPJiaGyO5teqVcUxw6PmY9E8dDDIPpWGNnFdULkBc"

  CONSUMER = OAuth::Consumer.new(
  CONSUMER_KEY, CONSUMER_SECRET, :site => "https://twitter.com")

  def self.login(username)
    @@access_token = get_token("token_here")
    new_user = EndUser.new(username)
    @@current_user = new_user
  end

  def self.access_token= (token)
    @@access_token = token
  end

  def self.access_token
    @@access_token
  end

  def self.current_user= (user)
    @@current_user = user
  end

  def self.current_user
    @@current_user
  end

  def self.request_access_token
    request_token = CONSUMER.get_request_token
    authorize_url = request_token.authorize_url
    puts "Go to this URL: #{authorize_url}"

    Launchy.open(authorize_url)

    puts "Login, and type your verification code in"
    oauth_verifier = gets.chomp
    ## QUESTIONS - Can we have two people log into here?
    request_token.get_access_token(:oauth_verifier => oauth_verifier)

  end

  def timeline
    responses = JSON.parse(@@access_token.get("https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=#{@@current_user.username}&count=5").body)

    responses.each do |response|
      puts "#{response["text"]}, Mentions: #{Status.mentions(response)}, HashTags: #{Status.hash_tags(response)}"
    end
  end

  # loc = Addressable::URI.new(
  #     :scheme => "https",
  #     :host => "maps.googleapis.com",
  #     :path => "maps/api/geocode/json",
  #     :query_values => {:address => "160+Folsom,+San+Francisco,+CA",
  #                       :sensor => "false"}).to_s

  def dm(target_user, message)
    cleaner = URI::Parser.new
    a= @@access_token.post("https://api.twitter.com/1.1/direct_messages/new.json?text=#{cleaner.escape(message)}&screen_name=#{target_user.username}")
  end

  def tweet(message)
    @@access_token.post("https://api.twitter.com/1.1/statuses/update.json?status=#{message}")
  end

  def self.get_token(token_file_name)

    if File.exist?(token_file_name)
      File.open(token_file_name) { |f| YAML.load(f) }
    else
      access_token = request_access_token
      File.open(token_file_name, "w") { |f| YAML.dump(access_token, f) }

      access_token
    end

end

you = EndUser.new("xulander")
EndUser.login("dargandhi123")
EndUser.current_user.timeline
EndUser.current_user.dm(you, "yessirr")
#EndUser.current_user.tweet("SF")

hash_tag = Hashtag.new("YOLO")
puts hash_tag.statuses






#
# # ask the user to authorize the application
# def request_access_token
#   # send user to twitter URL to authorize application
#   request_token = CONSUMER.get_request_token
#   authorize_url = request_token.authorize_url
#   puts "Go to this URL: #{authorize_url}"
#   # launchy is a gem that opens a browser tab for us
#   Launchy.open(authorize_url)
#
#   # because we don't use a redirect URL; user will receive an "out of
#   # band" verification code that the application may exchange for a
#   # key; ask user to give it to us
#   puts "Login, and type your verification code in"
#   oauth_verifier = gets.chomp
#
#   # ask the oauth library to give us an access token, which will allow
#   # us to make requests on behalf of this user
#   access_token = request_token.get_access_token(
#       :oauth_verifier => oauth_verifier)
# end
#
# # fetch a user's timeline
# def user_timeline(access_token)
#   access_token.get("http://api.twitter.com/1.1/statuses/user_timeline.json?").body
# end
#

end