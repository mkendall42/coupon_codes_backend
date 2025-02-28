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

    it "correcltly ignore attributes beyond name in updating" do
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

  describe "show single merchant" do
    it "should return specific merchant based on id given" do
      merchant = Merchant.create!(name: "Single Merchant")
      get "/api/v1/merchants/#{merchant.id}"

      # binding.pry
      expect(response).to be_successful
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:data][:id].to_i).to eq(merchant.id)
      expect(json[:data][:attributes][:name]).to eq(merchant.name)
    end
  end

  describe "GET #show when merchant does not exist" do
    it "returns an error message" do
      get "/api/v1/merchants/1000" # becuase 'a' is not a real id

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:error]).to eq("Merchant not found")
    end
  end

  describe "create merchant" do
    it "creates a new merchant when given json data" do
      body = { name: "New Merchant" }
      post "/api/v1/merchants", params: body, as: :json
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:created)
      expect(json[:data][:attributes][:name]).to eq("New Merchant")
      expect(json[:data][:type]).to eq("merchant")
    end
  end

  describe "create merchant failure" do
    it "should give sad path message when it does not work" do
      post "/api/v1/merchants", params: {}, headers: { "CONTENT_TYPE" => "application/json" }
      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:error]).to eq("Merchant was not created")
    end
  end
end