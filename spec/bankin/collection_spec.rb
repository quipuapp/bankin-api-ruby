require "spec_helper"

module Bankin
  class TestResource < Resource
    has_fields :id, :name
  end

  describe Collection do
    let :api_response_resources do
      {
        'resources' => [
          { 'id' => 1, 'name' => 'name-1'},
          { 'id' => 2, 'name' => 'name-2'},
        ]
      }
    end

    describe "initialization" do
      before do
        pagination_data = {
          'pagination' => { 'previous_uri' => nil, 'next_uri' => '2-page-uri'}
        }
        @collection = Collection.new(api_response_resources.merge(pagination_data), TestResource, 'token')
      end

      it "creates collection with two instances of TestResource with token" do
        expect(@collection.size).to eq(2)
        @collection.each do |resource|
          expect(resource).to be_an_instance_of(TestResource)
        end
      end

      it "sets token and item_class" do
        expect(@collection.instance_variable_get(:@token)).to eq('token')
        expect(@collection.instance_variable_get(:@item_class)).to eq(TestResource)
      end

      it "sets pagination variables" do
        expect(@collection.instance_variable_get(:@next_page_uri)).to eq('2-page-uri')
        expect(@collection.instance_variable_get(:@previous_page_uri)).to be_nil
      end
    end

    describe "page methods" do
      before do
        @collection = Collection.new(api_response_resources.merge(pagination_data), TestResource)
      end

      context "when it's first page" do
        let :pagination_data do
          { 'pagination' => { 'previous_uri' => nil, 'next_uri' => '2-page-uri'} }
        end

        it "returns correct values" do
           expect(@collection.next_page?).to be_truthy
           expect(@collection.previous_page?).to be_falsey
        end
      end

      context "when it's last page" do
        let :pagination_data do
          { 'pagination' => { 'previous_uri' => '2-page-uri', 'next_uri' => nil} }
        end

        it "returns correct values" do
           expect(@collection.next_page?).to be_falsey
           expect(@collection.previous_page?).to be_truthy
        end
      end

      context "when it's middle page" do
        let :pagination_data do
          { 'pagination' => { 'previous_uri' => '1-page-uri', 'next_uri' => '3-page-uri'} }
        end

        it "returns correct values" do
           expect(@collection.next_page?).to be_truthy
           expect(@collection.previous_page?).to be_truthy
        end
      end
    end

    describe "#next_page!" do
      before do
        pagination_data = {
          'pagination' => { 'previous_uri' => nil, 'next_uri' => '2-page-uri'}
        }
        @collection = Collection.new(api_response_resources.merge(pagination_data), TestResource)
        expect(Bankin).to receive(:api_call).with(:get, '2-page-uri', {}, nil).once {
          {
            'resources' => [{ 'id' => 3, 'name' => 'name-13'}],
            'pagination' => {'pagination' => { 'previous_uri' => nil, 'next_uri' => nil}}
          }
        }
      end

      it "calls API for the next page and appends items to collection" do
        @collection.next_page!
        expect(@collection.size).to be(3)
        expect(@collection.last).to be_an_instance_of(TestResource)
      end
    end

    describe "#load_all!" do
      before do
        1.upto(3) do |index|
          next_url = (index < 3) ? "uri-#{index + 1}" : nil
          response = {
            'resources' => [{ 'id' => index, 'name' => "name-#{index}" }],
            'pagination' => { 'previous_uri' => nil, 'next_uri' => next_url }
          }
          allow(Bankin).to receive(:api_call).with(:get, "uri-#{index}", {}, nil) { response }
        end

        response = Bankin.api_call(:get, 'uri-1', {}, nil)
        @collection = Collection.new(response, TestResource)
      end

      it "populates method until pagination has next_uri" do
        expect(Bankin).to receive(:api_call).twice
        @collection.load_all!
        expect(@collection.size).to eq(3)
      end
    end
  end
end
