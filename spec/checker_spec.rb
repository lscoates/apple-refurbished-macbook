require 'checker'

RSpec.describe Checker, ".call" do
  before do
    allow(Checker).to receive(:doc).and_return(html)
  end

  context "when the item is present and under $1,200.00" do
    let(:html) do
      Nokogiri::HTML(
        "<html><body><li>13.3-inch MacBook Air Apple M1 Chip with 8‑Core CPU and 7‑Core GPU<div>$1,099.00</div></li></body></html>"
      )
    end

    it "sends a message via the Twilio client" do
      expect(Twilio::REST::Client)
        .to receive(:new)
        .and_return(double(messages: double(create: true)))

      described_class.call
    end
  end

  context "when the item is present but over $1,200.00" do
    let(:html) do
      Nokogiri::HTML(
        "<html><body><li>13.3-inch MacBook Air Apple M1 Chip with 8‑Core CPU and 7‑Core GPU<div>$1,299.00</div></li></body></html>"
      )
    end

    it "sends a message via the Twilio client" do
      expect(Twilio::REST::Client)
        .to_not receive(:new)

      described_class.call
    end
  end

  context "when the item is not present" do
    let(:html) do
      Nokogiri::HTML(
        "<html><body><li>Some other MacBook Air <div>$1,299.00</div></li></body></html>"
      )
    end

    it "sends a message via the Twilio client" do
      expect(Twilio::REST::Client)
        .to_not receive(:new)

      described_class.call
    end
  end
end
