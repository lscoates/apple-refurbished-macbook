require 'nokogiri'
require 'open-uri'
require 'twilio-ruby'

class Checker
  URL = 'https://www.apple.com/ca/shop/refurbished/mac/macbook-air'.freeze

  def self.call
    item = doc.at('li:contains("13.3-inch MacBook Air Apple M1 Chip with 8‑Core CPU and 7‑Core GPU")')
    return if item.nil?

    price = item.css('div').text.gsub(/[$,]/, '').to_f
    send_sms("New Refurbished Mac: #{URL}") if price < 1200
  end

  def self.client
    @client ||= Twilio::REST::Client.new(
      ENV['TWILIO_ACCOUNT_SID'],
      ENV['TWILIO_AUTH_TOKEN']
    )
  end

  def self.send_sms(message)
    client.messages.create(
      from: ENV['TWILIO_TRIAL_NUMBER'],
      to: ENV['PERSONAL_NUMBER'],
      body: message
    )
  end

  def self.doc
    @doc ||= Nokogiri::HTML(URI.open(URL))
  end
end
