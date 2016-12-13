require "spec_helper"

module Bankin
  class TestResource < Resource
    has_fields :id, :name, :status

    has_resource :related_res, 'TestRelatedResource'
    has_collection :related_col, 'TestRelatedResource'
  end

  class TestRelatedResource < Resource
    has_fields :id, :title, :length
  end

  class TestUserResource < Resource
    attr_accessor :token
    has_fields :email

    auth_delegate :test_res, class: TestResource, method: :list
  end

  describe Resource do
    describe "fields" do
      it "sets class variables" do
        resource = TestResource.new('id' => 5)
        fields = [:resource_type, :resource_uri, :id, :name, :status]
        expect(TestResource.fields).to eq(fields)
        expect(resource.fields).to eq(fields)
      end

      context "when initialized form full set of data" do
        before do
          @resource = TestResource.new({ 'id' => 5, 'name' => 'test-name', 'status' => 3 })
        end

        it "returns vlaues without calling the API" do
          expect(Bankin).to_not receive(:api_call)
          expect(@resource.id).to eq(5)
          expect(@resource.name).to eq('test-name')
          expect(@resource.status).to eq(3)
        end
      end

      context "when initialized from partial data set" do
        before do
          @resource = TestResource.new({ 'id' => 5, 'resource_uri' => 'resource-uri' })
          allow(Bankin).to receive(:api_call) { {'id' => 5, 'name' => 'test-name', 'status' => 4} }
        end

        it "returns loaded vlaues without calling the API" do
          expect(Bankin).to_not receive(:api_call)
          expect(@resource.id).to eq(5)
        end

        it "calls API and load resource data" do
          expect(Bankin).to receive(:api_call).once
          expect(@resource.name).to eq('test-name')
          expect(@resource.status).to eq(4)
        end

        it "calls API usign resource uri" do
          expect(Bankin).to receive(:api_call).with(:get, 'resource-uri', {}, nil)
          @resource.name
        end
      end
    end

    describe ".auth_delegate" do
      before do
        allow(TestResource).to receive(:list) { 'test-result' }
        @user = TestUserResource.new({ email: 'email@exmaple.com' })
        @user.token = 'test-token'
      end

      it "creates instance method and call related resource method with token" do
        expect(@user).to respond_to(:test_res)
        expect(TestResource).to receive(:list).with('test-token', limit: 100)
        expect(@user.test_res(limit: 100)).to eq('test-result')
      end
    end

    describe "related resources" do
      before do
        @resource = TestResource.new('id' => 1, 'related_res' => { 'id' => 1, 'resource_uri' => 'test-uri' })
      end

      it "sets class variables" do
        exp_relation = { name: :related_res, klass: "TestRelatedResource" }
        expect(TestResource.resources).to include(exp_relation)
        expect(@resource.resources).to include(exp_relation)
      end

      it "creates instance method and retun id without calling the API" do
        expect(Bankin).to_not receive(:api_call)
        expect(@resource).to respond_to(:related_res)
        expect(@resource.related_res).to be_an_instance_of(TestRelatedResource)
        expect(@resource.related_res.id).to eq(1)
      end

      it "loads data from the API once" do
        expect(Bankin).to receive(:api_call).with(:get, 'test-uri', {}, nil).once {
          { 'id' => 1, 'title' => 'test-title', 'length' => 10 }
        }
        expect(@resource.related_res.title).to eq('test-title')
        expect(@resource.related_res.length).to eq(10)
      end
    end

    describe "related collection" do
      before do
        @resource = TestResource.new('id' => 1, 'name' => 'test-name',
        'related_col' => [
          { 'id' => 1, 'resource_uri' => 'test-uri-1' },
          { 'id' => 2, 'resource_uri' => 'test-uri-2' }
        ])
      end

      it "sets class variables" do
        exp_relation = { name: :related_col, klass: "TestRelatedResource" }
        expect(TestResource.collections).to include(exp_relation)
        expect(@resource.collections).to include(exp_relation)
      end

      it "creates instance method and retun an array of resources" do
        expect(Bankin).to_not receive(:api_call)
        expect(@resource).to respond_to(:related_col)
        array = @resource.related_col
        array.each do |resource|
          expect(resource).to be_a(TestRelatedResource)
        end
      end

      it "loads data from API when accessing field" do
        expect(Bankin).to receive(:api_call).with(:get, 'test-uri-1', {}, nil).once {
          { 'id' => 1, 'title' => 'test-title', 'length' => 2 }
        }
        related_item = @resource.related_col.first
        expect(related_item.title).to eq('test-title')
        expect(related_item.length).to eq(2)
      end
    end
  end
end
