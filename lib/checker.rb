require 'nokogiri'
require 'open-uri'
require 'twilio-ruby'

class Checker
  URL = 'https://www.apple.com/ca/shop/refurbished/mac/macbook-air'.freeze

  class << self
    def call
      return if item.nil?
      return if price > 1200

      send_sms
    end

    private

    def client
      Twilio::REST::Client.new(
        ENV['TWILIO_ACCOUNT_SID'],
        ENV['TWILIO_AUTH_TOKEN']
      )
    end

    def doc
      Nokogiri::HTML(URI.open(URL))
    end

    def item
      doc.at(
        'li:contains("13.3-inch MacBook Air Apple M1 Chip with 8‑Core CPU and 7‑Core GPU - Space Grey")'
      )
    end

    def price
      item.css('div').text.gsub(/[$,]/, '').to_f
    end

    def send_sms
      client.messages.create(
        from: ENV['TWILIO_TRIAL_NUMBER'],
        to: ENV['PERSONAL_NUMBER'],
        body: "New Refurbished Mac: #{URL}"
      )
    end
  end
end
