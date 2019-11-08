require "spec_helper"

module Bankin
  describe Item do
    before do
      configure_bankin
    end

    describe "#delete" do
      before do
        stub_request(:delete, "https://sync.bankin.com/v2/items/187791?client_id=client-id&client_secret=client-secret").
          with(headers: { 'Bankin-Version' => '2018-06-15', 'Authorization' => 'Bearer test-token' }).
          to_return(status: 204)

        @item = Item.new('resource_uri' => '/v2/items/187791')
        @item.instance_variable_set(:@token, 'test-token')
      end

      it "uses correct url and not fails at least" do
        expect {
          @item.delete
        }.to_not raise_error
      end
    end

    describe "#refresh" do
      before do
        stub_request(:post, "https://sync.bankin.com/v2/items/187791/refresh?client_id=client-id&client_secret=client-secret").
          with(headers: { 'Bankin-Version' => '2018-06-15', 'Authorization' => 'Bearer test-token' }).
          to_return(status: 202)

        @item = Item.new('resource_uri' => '/v2/items/187791')
        @item.instance_variable_set(:@token, 'test-token')
      end

      it "uses correct url and not fails at least" do
        expect {
          @item.refresh
        }.to_not raise_error
      end
    end

    describe "#refresh_status" do
      before do
        stub_request(:get, "https://sync.bankin.com/v2/items/187791/refresh/status?client_id=client-id&client_secret=client-secret").
          with(headers: { 'Bankin-Version' => '2018-06-15', 'Authorization' => 'Bearer test-token' }).
          to_return(status: 200, body: response_json('item_status'))

        @item = Item.new('resource_uri' => '/v2/items/187791')
        @item.instance_variable_set(:@token, 'test-token')
        @status = @item.refresh_status
      end

      it "return status of Item using resource_uri" do
        expect(@status['status']).to eq('finished')
        expect(@status['mfa']).to be_nil
        expect(@status['refreshed_at']).to eq('2016-04-06T09:19:15Z')
        expect(@status['refreshed_accounts_count']).to be_nil
        expect(@status['total_accounts_count']).to be_nil
      end
    end

    describe "#edit_url" do
      before do
        stub_request(:get, "https://sync.bankin.com/v2/connect/items/edit/url?client_id=client-id&client_secret=client-secret&item_id=187791").
          with(headers: { 'Bankin-Version' => '2018-06-15', 'Authorization' => 'Bearer test-token' }).
          to_return(status: 200, body: response_json('item_edit_url'))
      end

      before do
        @item = Item.new({"id" => 187791})
        @item.instance_variable_set(:@token, 'test-token')
      end

      it "returns edit item url" do
        expect(@item.edit_url)
          .to eq('https://pa.tu.casa/item/whatever')
      end
    end

    describe "#fill_in_otp_url" do
      before do
        stub_request(:get, "https://sync.bankin.com/v2/connect/items/sync?client_id=client-id&client_secret=client-secret&item_id=183319").
          with(headers: { 'Bankin-Version' => '2018-06-15', 'Authorization' => 'Bearer test-token' }).
          to_return(status: 200, body: response_json('item_fill_in_otp_url'))
      end

      before do
        @item = Item.new({"id" => 183319})
        @item.instance_variable_set(:@token, 'test-token')
      end

      it "returns fill in OTP url" do
        expect(@item.fill_in_otp_url)
          .to eq('https://pa.tu.otp/item/whatever')
      end
    end

    describe ".add_url" do
      before do
        stub_request(:get, "https://sync.bankin.com/v2/connect/items/add/url?client_id=client-id&client_secret=client-secret&a=1&b=2&redirect_url=somewhere").
          with(headers: { 'Bankin-Version' => '2018-06-15', 'Authorization' => 'Bearer test-token' }).
          to_return(status: 200, body: response_json('item_add_url'))
      end

      it "returns correct url" do
        expect(Bankin::Item.add_url('test-token', 'somewhere', { a: 1, b: 2}))
          .to eq('https://pa.tu.add/item/whatever')
      end
    end

    describe ".connect_url" do
      it "returns correct url" do
        url = Bankin::Item.connect_url('test-token', 408, 'redirect-url')
        expect(url).to eq('https://sync.bankin.com/v2/items/connect?client_id=client-id&bank_id=408&access_token=test-token&redirect_url=redirect-url')
      end
    end

    describe ".list" do
      before do
        stub_request(:get, "https://sync.bankin.com/v2/items?client_id=client-id&client_secret=client-secret").
          with(headers: { 'Bankin-Version' => '2018-06-15', 'Authorization' => 'Bearer test-token' }).
          to_return(status: 200, body: response_json('items'))

        @items = Bankin::Item.list('test-token')
      end

      it "returns collection with Item elements" do
        expect(@items).to be_a(Collection)
        expect(@items.size).to eq(2)
        @items.each do |item|
          expect(item).to be_a(Item)
        end
      end
    end

    describe ".get" do
      before do
        stub_request(:get, "https://sync.bankin.com/v2/items/187791?client_id=client-id&client_secret=client-secret").
          with(headers: { 'Bankin-Version' => '2018-06-15', 'Authorization' => 'Bearer test-token' }).
          to_return(status: 200, body: response_json('item'))

        @item = Bankin::Item.get('test-token', 187791)
      end

      it "returns instance of Item with correct attributes" do
        expect(@item).to be_a(Item)
        expect(@item.id).to eq(187791)
      end
    end

    describe "related resources" do
      before do
        stub_request(:get, "https://sync.bankin.com/v2/items/187791?client_id=client-id&client_secret=client-secret").
          with(headers: { 'Bankin-Version' => '2018-06-15', 'Authorization' => 'Bearer test-token' }).
          to_return(status: 200, body: response_json('item'))

        @item = Bankin::Item.get('test-token', 187791)
      end

      describe "bank" do
        before do
          @bank = @item.bank
        end

        it "returns Bank instance with id" do
          expect(@bank).to be_a(Bank)
          expect(@bank.id).to eq(408)
        end

        it "loads other attributtes" do
          stub_request(:get, "https://sync.bankin.com/v2/banks/408?client_id=client-id&client_secret=client-secret").
            with(headers: { 'Bankin-Version' => '2018-06-15', 'Authorization' => 'Bearer test-token' }).
            to_return(status: 200, body: response_json('bank'))

          expect(@bank.name).to eq('Crédit Agricole Languedoc')
          expect(@bank.country_code).to eq('FR')
          expect(@bank.automatic_refresh).to eq(true)
        end
      end

      describe "accounts" do
        before do
          stub_request(:get, "https://sync.bankin.com/v2/accounts/2341501?client_id=client-id&client_secret=client-secret").
            with(headers: { 'Bankin-Version' => '2018-06-15', 'Authorization' => 'Bearer test-token' }).
            to_return(status: 200, body: response_json('account'))

          @accounts = @item.accounts
          @account = @accounts.first
        end

        it "returns array of Account instances" do
          expect(@accounts).to be_a(Array)
          expect(@accounts.size).to eq(4)
          @accounts.each do |account|
            expect(account).to be_a(Account)
          end
        end

        it "loads other attributtes for the first item" do
          expect(@account).to be_a(Account)
          expect(@account.id).to eq(2341501)
          expect(@account.name).to eq('Compte Crédit Immobilier')
          expect(@account.balance).to eq(-140200)
          expect(@account.status).to eq(0)
          expect(@account.last_refresh_date).to eq('2016-04-06T13:53:12Z')
        end
      end
    end
  end
end
