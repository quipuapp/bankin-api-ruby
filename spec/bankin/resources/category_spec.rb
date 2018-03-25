require "spec_helper"

module Bankin
  describe Category do
    before do
      configure_bankin
    end

    describe ".get" do
      before do
        stub_request(:get, "https://sync.bankin.com/v2/categories/321?client_id=client-id&client_secret=client-secret").
          with(headers: { 'Bankin-Version' => '2016-01-18' }).
          to_return(status: 200, body: response_json('category'))

        @category = Bankin::Category.get(321)
      end

      it "returns instance of Category with correct attributes" do
        expect(@category).to be_a(Category)
        expect(@category.id).to eq(321)
      end
    end

    describe ".list" do
      before do
        stub_request(:get, "https://sync.bankin.com/v2/categories?client_id=client-id&client_secret=client-secret").
          with(headers: { 'Bankin-Version' => '2016-01-18' }).
          to_return(status: 200, body: response_json('categories'))

        @categories = Bankin::Category.list
      end

      it "returns collection with Category elements" do
        expect(@categories).to be_a(Collection)
        expect(@categories.size).to eq(1)
        @categories.each do |category|
          expect(category).to be_a(Category)
        end
      end
    end

    describe "related resources" do
      before do
        stub_request(:get, "https://sync.bankin.com/v2/categories/321?client_id=client-id&client_secret=client-secret").
          with(headers: { 'Bankin-Version' => '2016-01-18' }).
          to_return(status: 200, body: response_json('category'))

        @category = Bankin::Category.get(321)
      end

      describe "parent" do
        before do
          @parent = @category.parent
        end

        it "returns Category instance with id" do
          expect(@parent).to be_a(Category)
          expect(@parent.id).to eq(315)
        end

        it "loads other attributtes" do
          stub_request(:get, "https://sync.bankin.com/v2/categories/315?client_id=client-id&client_secret=client-secret").
            with(headers: { 'Bankin-Version' => '2016-01-18' }).
            to_return(status: 200, body: response_json('category'))

          expect(@parent).to be_a(Category)
          expect(@parent.id).to eq(315)
          expect(@parent.name).to eq('Beauty care')
        end
      end
    end
  end
end
