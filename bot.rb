require 'soda/client'
require "dotenv"
require "twitter"
require 'twitter-text'

# set up Socrata
client = SODA::Client.new({:domain => 'data.seattle.gov', :app_token => ENV['SOCRATA_TOKEN']})

TREES = [
  Twitter::Unicode::U1F331, # seedling
  Twitter::Unicode::U1F334, # palm tree
  Twitter::Unicode::U1F335, # cactus
  Twitter::Unicode::U1F337, # tulip
  Twitter::Unicode::U1F338,
  Twitter::Unicode::U1F339,
  Twitter::Unicode::U1F33B,
  Twitter::Unicode::U1F33C,
  Twitter::Unicode::U1F33E, # rice ear
  Twitter::Unicode::U1F33F, # herb
  Twitter::Unicode::U1F342, # falling leaf
  Twitter::Unicode::U1F332, # evergreen
  Twitter::Unicode::U1F333, # deciduous tree
] # use it: " #{TREES.sample}"

# set up Twitter
Dotenv.load
twitter_client = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV['CONSUMER_KEY']
  config.consumer_secret = ENV['CONSUMER_SECRET']
  config.access_token = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['TOKEN_SECRET']
end

def build_tweet(string)
  if string.length > 140
    return "#{string[0..137]}..."
  elsif string.length == 140 || string.length >= 134
    return string
  elsif string.length > 100
    return "#{TREES.sample} #{string}"
  elsif string.length > 60
    return "#{TREES.sample} #{string} #{TREES.sample}"
  else
    return ["#{TREES.sample} #{string} #{TREES.sample} #{TREES.sample}", "#{TREES.sample} #{TREES.sample} #{string} #{TREES.sample}"].sample
  end
end

tweeted = []
i = 0

loop do
  response = client.get("myje-ith7", {:case_group => "WEEDS AND VEGETATION"})
  twitter_client.user_timeline("weed_violations").each do |tweet|
    tweeted << tweet.text
    tweeted << tweet.text[2..-1]
    tweeted << tweet.text[2..-4]
    tweeted << tweet.text[4..-2]
    tweeted << tweet.text[2..-4]
  end if tweeted.length == 0
  if tweeted.include?(response[i].description)
    puts "already tweeted"
    i += 1
    sleep 1
  else
    if response[i].description.nil?
      puts "nil response"
      i += 1
    else
      tweet = build_tweet(response[i].description)
      twitter_client.update(tweet)
      tweeted << response[i].description
      i = 0
      sleep 10800 # every 30 mins is 1800
    end
  end
end

