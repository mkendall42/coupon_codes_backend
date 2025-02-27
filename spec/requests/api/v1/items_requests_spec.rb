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

  describe 'can delete an item by id' do
    it 'can delete an item by a specific id' do
      item_to_delete = @item1.id
      expect(Item.count).to eq(6)
      delete "/api/v1/items/#{item_to_delete}"
      expect(response).to be_successful
      expect(Item.count).to eq(5)
      expect{ Item.find(item_to_delete) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "deletes all invoice_items associated with a deleted item" do
      item_to_delete = @item1.id
      expect(Item.count).to eq(6)
      delete "/api/v1/items/#{item_to_delete}"
      expect(response).to be_successful
      expect(Item.count).to eq(5)
      expect(InvoiceItem.count).to eq(@item1.invoice_items.count)
      expect{ Item.find(item_to_delete) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(InvoiceItem.count).to eq(@item1.invoice_items.count - @item1.invoice_items.count)
      expect(InvoiceItem.where(item_id: item_to_delete).count).to eq(0)
    end

    it 'sends appropriate 204 status code when item is deleted' do
      item_to_delete = @item1.id
      delete "/api/v1/items/#{item_to_delete}"
      expect(response).to be_successful
      expect(response.status).to eq(204)
      expect{ Item.find(item_to_delete) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

end