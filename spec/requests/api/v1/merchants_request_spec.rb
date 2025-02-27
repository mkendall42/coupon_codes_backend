require "rails_helper"

RSpec.describe "Merchants endpoints", type: :request do
  before(:each) do
    Merchant.destroy_all
    @merchant1 = Merchant.create!(name: "Barbara")
    @merchant2 = Merchant.create!(name: "Mark")
    @merchant3 = Merchant.create!(name: "Jackson")
    @merchant4 = Merchant.create!(name: "Jason")
  end

  describe "#index" do
    it "can retrieve all merchants" do

      get "/api/v1/merchants"

      expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants[:data].count).to eq(4)
    end

    it "can retrieve merchants sorted by creation, newest first" do

      get "/api/v1/merchants?sorted=age"

      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants[:data].first[:attributes][:name]).to eq("Jason")
    end

    it "can display item_count for a merchant when called for" do
      get "/api/v1/merchants?count=true"

      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants[:data].first[:attributes][:item_count]).to be_an(Integer)
    end
  end

  describe "Updating (patch) tests" do
    it "can update a Merchant record with only name provided" do
      #NOTE: might change which @merchant referred to in different spots for better coverage
      # found_merchant = Merchant.find_by(id: id)
      previous_merchant_name = @merchant1.name
      updated_merchant_attributes = { name: "Babs" }

      #Then run update request on that id (to ensure valid)
      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/merchants/#{@merchant1.id}", headers: headers, params: JSON.generate(updated_merchant_attributes)
      
      #Asseration(s) - test the response JSON text, AND that the record is updated in the DB
      #NOTE: WEIRD - @merchant1 persists in memory even after DB is changes (and it's not in DB anymore)...is this b/c it's @ ?
      updated_merchant = Merchant.find_by(id: @merchant1.id)
      
      expect(response).to be_successful
      expect(updated_merchant.name).to_not eq(previous_merchant_name)
      expect(updated_merchant.name).to eq(updated_merchant_attributes[:name])

      merchant_data = JSON.parse(response.body, symbolize_names: true)
      expected_message = {
        data: {
          id: @merchant1.id.to_s,
          type: "merchant",
          attributes: { name: updated_merchant.name }
        }
      }
      expect(merchant_data).to eq(expected_message)
    end

    it "correctly ignores attributes beyond name in updating" do
      previous_merchant_name = @merchant2
      updated_merchant_attributes = {
        name: "Marky Mark",
        created_at: Time.now,
        id: 10000,
        random_attr: "illegal value"
      }

      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/merchants/#{previous_merchant_name.id}", headers: headers, params: JSON.generate(updated_merchant_attributes)
      
      #Asseration(s) - test the response JSON text, AND that the record is updated in the DB
      #NOTE: WEIRD - @merchant2 persists in memory even after DB is changes (and it's not in DB anymore)...is this b/c it's @ ?
      updated_merchant = Merchant.find_by(id: @merchant2.id)
      
      # binding.pry

      expect(response).to be_successful
      expect(updated_merchant.name).to eq(updated_merchant_attributes[:name])
      expect(updated_merchant.created_at).to_not eq(updated_merchant_attributes[:created_at])

    end

    it "handles empty body request properly" do
      # previous_merchant_name = @merchant1.name
      previous_merchant = @merchant1
      updated_merchant_attributes = {}

      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/merchants/#{@merchant1.id}", headers: headers, params: JSON.generate(updated_merchant_attributes)

      updated_merchant = Merchant.find_by(id: @merchant1.id)
      
      expect(response).to_not be_successful
      #Check each attribute (full object equality is NOT sufficient here - subtle issue!)
      expect(updated_merchant.id).to eq(previous_merchant.id)
      expect(updated_merchant.name).to eq(previous_merchant.name)
      expect(updated_merchant.created_at).to eq(previous_merchant.created_at)
      expect(updated_merchant.updated_at).to eq(previous_merchant.updated_at)

      #Could consider checking that DB count doesn't change
    end

    it "sends appropriate 400 level error when no id found" do
      #Choose very large id (could choose random one not present to be REALLY thorough later)
      nonexistant_id = 100000
      updated_merchant_attributes = { name: "J-son" }

      # binding.pry

      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/merchants/#{nonexistant_id}", headers: headers, params: JSON.generate(updated_merchant_attributes)
      
      updated_merchant = Merchant.find_by(id: nonexistant_id)
      
      expect{ Merchant.find(nonexistant_id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(response).to_not be_successful
      expect(response.status).to eq(404)
    end
    
    #NOTE FOR LATER: may need to check response body (depending on 400-level code)
  end

  describe 'can delete a merchant by id' do
    it 'can delete a merchant by a specific id' do
      merchant_to_delete = @merchant1.id
      expect(Merchant.count).to eq(4)
      delete "/api/v1/merchants/#{merchant_to_delete}"
      expect(response).to be_successful
      expect(Merchant.count).to eq(3)
      expect{ Merchant.find(merchant_to_delete) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "deletes all items associated with a deleted merchant" do
      merchant_to_delete = @merchant1.id
      expect(Merchant.count).to eq(4)
      expect(Item.count).to eq(@merchant1.items.count)
      delete "/api/v1/merchants/#{merchant_to_delete}"
      expect(response).to be_successful
      expect(Merchant.count).to eq(3)
      expect{ Merchant.find(merchant_to_delete) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Item.count).to eq(@merchant1.items.count - @merchant1.items.count)
      expect(Item.where(merchant_id: merchant_to_delete).count).to eq(0)
    end

    it 'sends appropriate 204 status code when merchant is deleted' do
      merchant_to_delete = @merchant1.id
      delete "/api/v1/merchants/#{merchant_to_delete}"
      expect(response).to be_successful
      expect(response.status).to eq(204)
      expect{ Merchant.find(merchant_to_delete) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end