require "spec_helper"

module Bankin
  describe Account do
    before do
      configure_bankin
    end

    describe ".get" do
      before do
        stub_request(:get, "https://sync.bankin.com/v2/accounts/2341501?client_id=client-id&client_secret=client-secret").
          with(headers: { 'Bankin-Version' => '2018-06-15', 'Authorization' => 'Bearer test-token' }).
          to_return(status: 200, body: response_json('account'))

        @account = Bankin::Account.get('test-token', 2341501)
      end

      it "returns instance of Account with correct attributes" do
        expect(@account).to be_a(Account)
        expect(@account.id).to eq(2341501)
        expect(@account.name).to eq('Compte Crédit Immobilier')
        expect(@account.balance).to eq(-140200)
        expect(@account.status).to eq(0)
        expect(@account.last_refresh_date).to eq('2016-04-06T13:53:12Z')
      end
    end

    describe ".list" do
      before do
        stub_request(:get, "https://sync.bankin.com/v2/accounts?client_id=client-id&client_secret=client-secret").
          with(headers: { 'Bankin-Version' => '2018-06-15', 'Authorization' => 'Bearer test-token' }).
          to_return(status: 200, body: response_json('accounts'))

        @accounts = Bankin::Account.list('test-token')
      end

      it "returns collection with Account elements" do
        expect(@accounts).to be_a(Collection)
        expect(@accounts.size).to eq(1)
        @accounts.each do |account|
          expect(account).to be_a(Account)
        end
      end
    end

    describe "related resources" do
      before do
        stub_request(:get, "https://sync.bankin.com/v2/accounts/2341501?client_id=client-id&client_secret=client-secret").
          with(headers: { 'Bankin-Version' => '2018-06-15', 'Authorization' => 'Bearer test-token' }).
          to_return(status: 200, body: response_json('account'))

        @account = Bankin::Account.get('test-token', 2341501)
      end

      describe "bank" do
        before do
          @bank = @account.bank
        end

        it "returns Bank instance with id" do
          expect(@bank).to be_a(Bank)
          expect(@bank.id).to eq(408)
        end

        it "loads other attributtes" do
          stub_request(:get, "https://sync.bankin.com/v2/banks/408?client_id=client-id&client_secret=client-secret").
            with(headers: { 'Bankin-Version'=>'2018-06-15' }).
            to_return(status: 200, body: response_json('bank'))

          expect(@bank.name).to eq('Crédit Agricole Languedoc')
          expect(@bank.country_code).to eq('FR')
          expect(@bank.automatic_refresh).to eq(true)
        end
      end

      describe "item" do
        before do
          @item = @account.item
        end

        it "returns Item instance with id" do
          expect(@item).to be_a(Item)
          expect(@item.id).to eq(187791)
        end

        it "loads other attributtes" do
          stub_request(:get, "https://sync.bankin.com/v2/items/187791?client_id=client-id&client_secret=client-secret").
            with(headers: { 'Bankin-Version' => '2018-06-15', 'Authorization' => 'Bearer test-token' }).
            to_return(status: 200, body: response_json('item'))

          expect(@item.status).to eq(0)
        end
      end
    end
  end
end
