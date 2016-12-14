require "spec_helper"

module Bankin
  describe Bank do
    before do
      configure_bankin
    end

    describe ".get" do
      before do
        stub_request(:get, "https://sync.bankin.com/v2/banks/64?client_id%5B%5D=client-id&client_id%5B%5D=client-secret&client_secret=client-secret").
          with(headers: { 'Bankin-Version'=>'2016-01-18' }).
          to_return(status: 200, body: response_json('bank'))

        @bank = Bank.get(64)
      end

      it "returns instance of a Bank with correct attributes" do
        expect(@bank).to be_a(Bank)
        expect(@bank.id).to eq(64)
        expect(@bank.name).to eq('Crédit Agricole Languedoc')
        expect(@bank.country_code).to eq('FR')
        expect(@bank.automatic_refresh).to eq(true)
      end
    end

    describe ".list" do
      before do
        stub_request(:get, "https://sync.bankin.com/v2/banks?client_id%5B%5D=client-id&client_id%5B%5D=client-secret&client_secret=client-secret").
          with(headers: { 'Bankin-Version'=>'2016-01-18' }).
          to_return(status: 200, body: response_json('banks'))

        @banks = Bank.list
      end

      it "returns collection with Bank elements" do
        expect(@banks).to be_a(Collection)
        expect(@banks.size).to eq(2)
        @banks.each do |bank|
          expect(bank).to be_a(Bank)
        end
      end
    end
  end
end
