require "spec_helper"

describe Bankin do
  before do
    subject.configure do |config|
      config.client_id = '123456789'
      config.client_secret = 'client-secret'
    end
  end

  describe "Configuration" do
    describe ".configuration" do
      it "should return Configuration class instance" do
        expect(subject.configuration).to be_a(Bankin::Configuration)
      end
    end

    describe ".configure" do
      it "should store credentials" do
        expect(subject.configuration.client_id).to eq('123456789')
        expect(subject.configuration.client_secret).to eq('client-secret')
      end
    end
  end

  describe ".api_call" do
    it "should call api with params" do
      allow(RestClient::Request).to receive(:execute) { {}.to_json }
      expected_params = {
        method: :somemethod,
        url: 'https://sync.bankin.com/somepath',
        headers: {
          'Bankin-Version': '2016-01-18',
          params: {
            client_id: '123456789',
            client_secret: 'client-secret',
            some: :param
          },
          Authorization: 'Bearer some-token'
        }
      }
      expect(RestClient::Request).to receive(:execute).with(expected_params)
      subject.api_call(:somemethod, '/somepath', { some: :param }, 'some-token')
    end

    it "returns parsed object" do
      allow(RestClient::Request).to receive(:execute) { { key: :val }.to_json }
      expect(subject.api_call(:whatever, 'whatever')).to eq({ 'key' => 'val' })
    end

    it "should raise Bankin::Error" do
      expect { subject.api_call(:get, '/v2/not-found') }.to raise_error(Bankin::Error)
    end
  end
end
