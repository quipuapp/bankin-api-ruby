require "spec_helper"

module Bankin
  describe User do
    before do
      configure_bankin
    end

    describe ".create" do
      before do
        stub_request(:post, "https://sync.bankin.com/v2/users?client_id%5B%5D=client-id&client_id%5B%5D=client-secret&client_secret=client-secret&email=test@example.com&password=testpassword").
          with(headers: { 'Bankin-Version' => '2016-01-18' }).
          to_return(status: 200, body: response_json('user'))

        @user = User.create('test@example.com', 'testpassword')
      end

      it "returns instance of User with correct attributes" do
        expect(@user).to be_a(User)
        expect(@user.uuid).to eq('79c8961c-bdf7-11e5-88a3-4f2c2aec0665')
        expect(@user.email).to eq('test@example.com')
      end
    end


    describe ".athenticate" do
      before do
        stub_request(:post, "https://sync.bankin.com/v2/authenticate?client_id%5B%5D=client-id&client_id%5B%5D=client-secret&client_secret=client-secret&email=test@example.com&password=testpassword").
          with(headers: { 'Bankin-Version' => '2016-01-18' }).
          to_return(status: 200, body: response_json('authenticate'))

        @user = User.authenticate('test@example.com', 'testpassword')
      end

      it "returns instance of User with correct attributes and token" do
        expect(@user).to be_a(User)
        expect(@user.uuid).to eq('c2a26c9e-dc23-4f67-b887-bbae0f26c415')
        expect(@user.email).to eq('test@example.com')
        expect(@user.token).to eq('.....')
      end
    end

    describe ".delete_all" do
      before do
        stub_request(:delete, "https://sync.bankin.com/v2/users?client_id%5B%5D=client-id&client_id%5B%5D=client-secret&client_secret=client-secret").
          with(headers: { 'Bankin-Version' => '2016-01-18' }).
          to_return(status: 204)
      end

      it "uses correct url and not fails at least" do
        expect {
          User.delete_all
        }.to_not raise_error
      end
    end

    describe ".list" do
      before do
        stub_request(:get, "https://sync.bankin.com/v2/users?client_id%5B%5D=client-id&client_id%5B%5D=client-secret&client_secret=client-secret").
          with(headers: { 'Bankin-Version' => '2016-01-18' }).
          to_return(status: 200, body: response_json('users'))

        @users = User.list
      end

      it "returns collection with Bank elements" do
        expect(@users).to be_a(Collection)
        expect(@users.size).to eq(2)
        @users.each do |user|
          expect(user).to be_a(User)
        end
      end
    end

    describe "#delete" do
      before do
        stub_request(:delete, "https://sync.bankin.com/v2/user-uri?client_id%5B%5D=client-id&client_id%5B%5D=client-secret&client_secret=client-secret&password=test-password").
          with(headers: { 'Bankin-Version' => '2016-01-18' }).
          to_return(status: 204)

        @user = User.new({ 'uuid' => 'test-uuid', 'email' => 'test@example.com', 'resource_uri' => '/v2/user-uri' })
        @user.token = 'test-token'
      end

      it "uses correct url and not fails at least" do
        expect {
          @user.delete('test-password')
        }.to_not raise_error
      end
    end

    describe "#item_connect_url" do
      it "calls Item.connect_url with correct arguments" do
        @user = User.new({})
        @user.token = 'test-token'
        expect(Item).to receive(:connect_url).with('test-token', 408, 'redirect-url')
        @user.item_connect_url(408, 'redirect-url')
      end
    end

    describe "athorized resources" do
      before do
        @user = User.new({})
        @user.token = 'test-token'
      end

      describe "items" do
        before do
          stub_request(:get, "https://sync.bankin.com/v2/items?client_id%5B%5D=client-id&client_id%5B%5D=client-secret&client_secret=client-secret").
            with(headers: { 'Bankin-Version' => '2016-01-18', 'Authorization' => 'Bearer test-token' }).
            to_return(status: 200, body: response_json('items'))

          @items = @user.items
        end

        it "returns collection with Item elements" do
          expect(@items).to be_a(Collection)
          expect(@items.size).to eq(2)
          @items.each do |item|
            expect(item).to be_a(Item)
          end
        end
      end

      describe "item" do
        before do
          stub_request(:get, "https://sync.bankin.com/v2/items/187791?client_id%5B%5D=client-id&client_id%5B%5D=client-secret&client_secret=client-secret").
            with(headers: { 'Bankin-Version' => '2016-01-18', 'Authorization' => 'Bearer test-token' }).
            to_return(status: 200, body: response_json('item'))

          @item = @user.item(187791)
        end

        it "returns instance of Item with correct attributes" do
          expect(@item).to be_a(Item)
          expect(@item.id).to eq(187791)
          expect(@item.status).to eq(0)
        end
      end

      describe "accounts" do
        before do
          stub_request(:get, "https://sync.bankin.com/v2/accounts?client_id%5B%5D=client-id&client_id%5B%5D=client-secret&client_secret=client-secret").
            with(headers: { 'Bankin-Version' => '2016-01-18', 'Authorization' => 'Bearer test-token' }).
            to_return(status: 200, body: response_json('accounts'))

          @accounts = @user.accounts
        end

        it "returns collection with Account elements" do
          expect(@accounts).to be_a(Collection)
          expect(@accounts.size).to eq(1)
          @accounts.each do |account|
            expect(account).to be_a(Account)
          end
        end
      end

      describe "account" do
        before do
          stub_request(:get, "https://sync.bankin.com/v2/accounts/2341501?client_id%5B%5D=client-id&client_id%5B%5D=client-secret&client_secret=client-secret").
            with(headers: { 'Bankin-Version' => '2016-01-18', 'Authorization' => 'Bearer test-token' }).
            to_return(status: 200, body: response_json('account'))

          @account = @user.account(2341501)
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

      describe "transactions" do
        before do
          stub_request(:get, "https://sync.bankin.com/v2/transactions?client_id%5B%5D=client-id&client_id%5B%5D=client-secret&client_secret=client-secret").
            with(headers: { 'Bankin-Version' => '2016-01-18', 'Authorization' => 'Bearer test-token' }).
            to_return(status: 200, body: response_json('transactions'))

          @transactions = @user.transactions
        end

        it "returns collection with Transaction elements" do
          expect(@transactions).to be_a(Collection)
          expect(@transactions.size).to eq(1)
          @transactions.each do |transaction|
            expect(transaction).to be_a(Transaction)
          end
        end
      end

      describe "updated_transactions" do
        before do
          stub_request(:get, "https://sync.bankin.com/v2/transactions/updated?client_id%5B%5D=client-id&client_id%5B%5D=client-secret&client_secret=client-secret").
            with(headers: { 'Bankin-Version' => '2016-01-18', 'Authorization' => 'Bearer test-token' }).
            to_return(status: 200, body: response_json('transactions'))

          @transactions = @user.updated_transactions
        end

        it "returns collection with Transaction elements" do
          expect(@transactions).to be_a(Collection)
          expect(@transactions.size).to eq(1)
          @transactions.each do |transaction|
            expect(transaction).to be_a(Transaction)
          end
        end
      end

      describe "transaction" do
        before do
          stub_request(:get, "https://sync.bankin.com/v2/transactions/1000013102238?client_id%5B%5D=client-id&client_id%5B%5D=client-secret&client_secret=client-secret").
            with(headers: { 'Bankin-Version' => '2016-01-18', 'Authorization' => 'Bearer test-token' }).
            to_return(status: 200, body: response_json('transaction'))

          @transaction = @user.transaction(1000013102238)
        end

        it "returns instance of Transaction with correct attributes" do
          expect(@transaction).to be_a(Transaction)
          expect(@transaction.id).to eq(1000013102238)
          expect(@transaction.description).to eq('CB Monop Paris')
          expect(@transaction.raw_description).to eq('Paiement Carte 029412 75 monop paris')
          expect(@transaction.amount).to eq(-9.39)
          expect(@transaction.date).to eq('2016-02-22')
          expect(@transaction.update_date).to eq('2016-02-22T13:27:53Z')
          expect(@transaction.is_deleted).to eq(false)
        end
      end
    end
  end
end
