require "spec_helper"

module Bankin
  describe Transaction do
    before do
      configure_bankin
    end

    describe ".get" do
      before do
        stub_request(:get, "https://sync.bankin.com/v2/transactions/1000013102238?client_id=client-id&client_secret=client-secret").
          with(headers: { 'Bankin-Version' => '2018-06-15', 'Authorization' => 'Bearer test-token' }).
          to_return(status: 200, body: response_json('transaction'))

        @transaction = Bankin::Transaction.get('test-token', 1000013102238)
      end

      it "returns instance of Account with correct attributes" do
        expect(@transaction).to be_a(Transaction)
        expect(@transaction.id).to eq(1000013102238)
        expect(@transaction.description).to eq('CB Monop Paris')
        expect(@transaction.raw_description).to eq('Paiement Carte 029412 75 monop paris')
        expect(@transaction.amount).to eq(-9.39)
        expect(@transaction.date).to eq('2016-02-22')
        expect(@transaction.updated_at).to eq('2016-02-22T13:27:53Z')
        expect(@transaction.currency_code).to eq('EUR')
        expect(@transaction.is_deleted).to eq(false)
      end
    end

    describe ".list" do
      before do
        stub_request(:get, "https://sync.bankin.com/v2/transactions?client_id=client-id&client_secret=client-secret").
          with(headers: { 'Bankin-Version' => '2018-06-15', 'Authorization' => 'Bearer test-token' }).
          to_return(status: 200, body: response_json('transactions'))

        @transactions = Bankin::Transaction.list('test-token')
      end

      it "returns collection with Transaction elements" do
        expect(@transactions).to be_a(Collection)
        expect(@transactions.size).to eq(1)
        @transactions.each do |transaction|
          expect(transaction).to be_a(Transaction)
        end
      end
    end

    describe ".list_updated" do
      before do
        stub_request(:get, "https://sync.bankin.com/v2/transactions/updated?client_id=client-id&client_secret=client-secret").
          with(headers: { 'Bankin-Version' => '2018-06-15', 'Authorization' => 'Bearer test-token' }).
          to_return(status: 200, body: response_json('transactions'))

        @transactions = Bankin::Transaction.list_updated('test-token')
      end

      it "returns collection with Transaction elements" do
        expect(@transactions).to be_a(Collection)
        expect(@transactions.size).to eq(1)
        @transactions.each do |transaction|
          expect(transaction).to be_a(Transaction)
        end
      end
    end

    describe "related resources" do
      before do
        stub_request(:get, "https://sync.bankin.com/v2/transactions/1000013102238?client_id=client-id&client_secret=client-secret").
          with(headers: { 'Bankin-Version' => '2018-06-15', 'Authorization' => 'Bearer test-token' }).
          to_return(status: 200, body: response_json('transaction'))

        @transaction = Bankin::Transaction.get('test-token', 1000013102238)
      end

      describe "account" do
        before do
          @account = @transaction.account
        end

        it "returns Account instance with id" do
          expect(@account).to be_a(Account)
          expect(@account.id).to eq(2341501)
        end

        it "loads other attributtes" do
          stub_request(:get, "https://sync.bankin.com/v2/accounts/2341501?client_id=client-id&client_secret=client-secret").
            with(headers: { 'Bankin-Version' => '2018-06-15', 'Authorization' => 'Bearer test-token' }).
            to_return(status: 200, body: response_json('account'))

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
