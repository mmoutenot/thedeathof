require 'twitter'

client = Twitter::Streaming::Client.new do |config|
  config.consumer_key = 'IgFAJBcKpEEk17VlJbuWLn7TE'
  config.consumer_secret = 'Yo6jJdqO0W53tKv6rT808lHXdqbbVgtXOwz4mUWX5HgWw7rsrN'
  config.access_token = '14211659-DsDjwozkhoVTAZwK7D4AjLFtZZ0vkFOZKjq2N13jB'
  config.access_token_secret = 'VDyA0MNG11nLejSL2CELz01KsydrGFkN2dU2NGARGYeey'
end

client.filter(:track => 'tesla') do |object|
    puts object.text if object.is_a?(Twitter::Tweet)
end
