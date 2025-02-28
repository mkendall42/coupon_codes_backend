require 'rails_helper'
require 'pry'

RSpec.describe "Items endpoints", type: :request do
  
  before(:each) do
    Merchant.destroy_all
    @merchant1 = Merchant.create!(name: "Barbara")
    @merchant2 = Merchant.create!(name: "Mark")
    @merchant3 = Merchant.create!(name: "Jackson")
    @merchant4 = Merchant.create!(name: "Jason")
    
    
    Item.destroy_all
    @item1 = Item.create!(name: "Cat toy", description: "wiggling fish", unit_price: 0.34, merchant_id: @merchant1[:id])
    @item2 = Item.create!(name: "orange cream soda", description: "tasty and citrusy", unit_price: 3, merchant_id: @merchant2[:id])
    @item3 = Item.create!(name: "root beer", description: "smooth saspirilla", unit_price: 2, merchant_id: @merchant2[:id])
    @item4 = Item.create!(name: "can of ground peas", description: "mush", unit_price: 5, merchant_id: @merchant3[:id])
    @item5 = Item.create!(name: "cube", description: "not just any rectangular prism", unit_price: 8.00, merchant_id: @merchant4[:id])
    @item6 = Item.create!(name: "sphere", description: "now if only it were a cow", unit_price: 512.00, merchant_id: @merchant4[:id])
  end


  describe "#index" do
    it 'can retrieve all items' do

      get '/api/v1/items'

      expect(response).to be_successful
      items = JSON.parse(response.body, symbolize_names: true)

      expect(items[:data].count).to eq(6)
    end

    it 'can sort items by ascending price' do

      get '/api/v1/items?sorted=price'

      expect(response).to be_successful
      items = JSON.parse(response.body, symbolize_names: true)
      
      expect(items[:data].first[:attributes][:name]).to eq("Cat toy")
      expect(items[:data].last[:attributes][:name]).to eq("sphere")
    end
  end


  describe "Updating (patch) tests" do
    it "updates an Item record with all valid attributes" do
      previous_item = @item5
      updated_item_attributes = {
        name: "hypercube",
        description: "now with one additional dimension!",
        unit_price: 8.00 ** (4 / 3),     #Hyuk hyuk
        merchant_id: @merchant4.id      #Alt: could assign to different merchant, then check
      }

      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/items/#{@item5.id}", headers: headers, params: JSON.generate(updated_item_attributes)
      
      #Asseration(s) - test the response JSON text, AND that the record is updated in the DB
      #NOTE: WEIRD - @merchant1 persists in memory even after DB is changed (and it's not in DB anymore)...is this b/c it's @ ?
      updated_item = Item.find_by(id: @item5.id)

      expect(response).to be_successful
      expect(updated_item.name).to_not eq(previous_item.name)
      expect(updated_item.name).to eq(updated_item_attributes[:name])
      expect(updated_item.description).to eq(updated_item_attributes[:description])
      expect(updated_item.unit_price).to eq(updated_item_attributes[:unit_price])
      expect(updated_item.merchant_id).to eq(updated_item_attributes[:merchant_id])

      item_data = JSON.parse(response.body, symbolize_names: true)
      expected_message = {
        data: {
          id: @item5.id.to_s,
          type: "item",
          attributes: {
            name: updated_item.name,
            description: updated_item.description,
            unit_price: updated_item.unit_price,
            merchant_id: updated_item.merchant_id
          }
        }
      }

      expect(item_data).to eq(expected_message)
    end

    it "updates an Item record with some valid attributes" do
      previous_item = @item6
      updated_item_attributes = {
        name: "ellipsoid",
        unit_price: 256.00
      }

      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/items/#{@item6.id}", headers: headers, params: JSON.generate(updated_item_attributes)
      
      #Asseration(s) - test the response JSON text, AND that the record is updated in the DB
      #NOTE: WEIRD - @merchant1 persists in memory even after DB is changes (and it's not in DB anymore)...is this b/c it's @ ?
      updated_item = Item.find_by(id: @item6.id)
      
      expect(response).to be_successful
      expect(updated_item.name).to eq(updated_item_attributes[:name])
      expect(updated_item.description).to eq(previous_item.description)
      expect(updated_item.unit_price).to eq(updated_item_attributes[:unit_price])
      expect(updated_item.merchant_id).to eq(previous_item.merchant_id)

      #Probably don't need to check JSON data again...
    end

    it "correctly ignore invalid attributes in updating" do
      #Just make sure the object and record are completely unchanged
      previous_item = @item6
      invalid_item_attributes = {
        # name: "spheroid",
        additional_feature: "backdoor",
        updated_at: Time.now,       #Should be handled by DB, not client!
        random_attribute: "sneaking in"
      }
      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/items/#{previous_item.id}", headers: headers, params: JSON.generate(invalid_item_attributes)

      updated_item = Item.find_by(id: previous_item.id)

      expect(response).to be_successful
      #PROBLEM: the below commented line will pass even if attribute(s) are different
      # expect(updated_item).to eq(previous_item)   #The entire object should be identical (no changes)
      
      #Refactor later into common method?
      expect(updated_item.name).to eq(previous_item.name)
      expect(updated_item.description).to eq(previous_item.description)
      expect(updated_item.unit_price).to eq(previous_item.unit_price)
      expect(updated_item.merchant_id).to eq(previous_item.merchant_id)
      expect(updated_item.created_at).to eq(previous_item.created_at)
      expect(updated_item.updated_at).to eq(previous_item.updated_at)

    end

    it "handles empty body request properly" do
      previous_item = @item6
      empty_attributes = {}
      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/items/#{previous_item.id}", headers: headers, params: JSON.generate(empty_attributes)

      updated_item = Item.find_by(id: previous_item.id)
      
      expect(response).to_not be_successful
      expect(response.status).to eq(400)
      #Refactor later into common method (:let?)
      expect(updated_item.name).to eq(previous_item.name)
      expect(updated_item.description).to eq(previous_item.description)
      expect(updated_item.unit_price).to eq(previous_item.unit_price)
      expect(updated_item.merchant_id).to eq(previous_item.merchant_id)
      expect(updated_item.created_at).to eq(previous_item.created_at)
      expect(updated_item.updated_at).to eq(previous_item.updated_at)
    end

    it "sends appropriate 400 level error when no id found" do
      invalid_id = 100000
      updated_item_attributes = {
        name: "hypercube",
        description: "now with one additional dimension!",
        unit_price: 8.00 ** (4 / 3),
        merchant_id: @merchant4.id
      }

      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/items/#{invalid_id}", headers: headers, params: JSON.generate(updated_item_attributes)
      
      # binding.pry
      
      expect{ Item.find(invalid_id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(response).to_not be_successful
    end

    #NOTE FOR LATER: may need to check response body (depending on 400-level code)

  end

  describe "show a single item" do
    it "brings up specfic item based on id" do
      
      item = Item.create!(name: "New Item", description: "description", unit_price: 100.00, merchant_id: @merchant1.id)

      get "/api/v1/items/#{item.id}"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json[:data][:id]).to eq("#{item.id}")
      expect(json[:data][:type]).to eq("item")
      expect(json[:data][:attributes][:name]).to eq("New Item")
      expect(json[:data][:attributes][:description]).to eq("description")
      expect(json[:data][:attributes][:unit_price]).to eq(100.00)
    end
  end

  describe "show item error" do
    it "returns json error message if params not met" do
    
      get "/api/v1/items/999"

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json[:errors]).to eq("Item not found")
    end
  end

  describe "create item" do
    it "will create a new item based on json" do

      
      new_item = {
        name: "New Item",
        description: "description",
        unit_price: 20.00,
        merchant_id: @merchant1.id
      }
  
      headers = { "CONTENT_TYPE" => "application/json" }
  
      post "/api/v1/items", headers: headers, params: JSON.generate(item: new_item)
  
      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to have_http_status(:created)
  
      expect(json[:data][:attributes][:name]).to eq(new_item[:name])
      expect(json[:data][:attributes][:description]).to eq(new_item[:description])
      expect(json[:data][:attributes][:unit_price]).to eq(new_item[:unit_price])
      expect(json[:data][:attributes][:merchant_id]).to eq(new_item[:merchant_id])
    end
  
    it "will return an error if the required parameters are missing" do
      post "/api/v1/items", params: {}, headers: { "CONTENT_TYPE" => "application/json" }
  
      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:error]).to eq("Item was not created")

    end
  end
end