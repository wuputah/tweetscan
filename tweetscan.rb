require 'eventmachine'
require 'em-http'
require 'json'

creds = [ENV['TWITTER_USERNAME'], ENV['TWITTER_PASSWORD']]
url = 'https://stream.twitter.com/1/statuses/filter.json'

def handle_tweet(tweet)
  return unless tweet['text']
  puts "#{tweet['user']['screen_name']}: #{tweet['text']}"
end

EventMachine.run do
  buffer = ""
  http = EventMachine::HttpRequest.new(url).post(
    :body => { 'track' => 'twitter' },
    :head => { 'Authorization' => creds })

  http.stream do |chunk|
    buffer += chunk
    while line = buffer.slice!(/.+\r?\n/)
      handle_tweet JSON.parse(line)
    end
  end
end
