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

  
    @customer1 = Customer.create!(first_name: "John J.", last_name: "Jingleheimerschmidt")
    @customer2 = Customer.create!(first_name: "Timmy", last_name: "Turner")
    @customer3 = Customer.create!(first_name: "Spongebob", last_name: "Squarepants")
    
    @invoice1 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant1.id, status: "shipped")
    @invoice2 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant1.id, status: "returned")
    @invoice3 = Invoice.create!(customer_id: @customer2.id, merchant_id: @merchant2.id, status: "shipped")
    @invoice4 = Invoice.create!(customer_id: @customer3.id, merchant_id: @merchant2.id, status: "shipped")

    @invoice_item1 = InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice1.id, quantity: 4, unit_price: 1.00)
    @invoice_item2 = InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice2.id, quantity: 3, unit_price: 2.00)
    @invoice_item3 = InvoiceItem.create!(item_id: @item2.id, invoice_id: @invoice3.id, quantity: 5, unit_price: 3.00)
  end


  describe "#index" do
    it 'can retrieve all items' do

      get '/api/v1/items'

      expect(response).to be_successful
      items = JSON.parse(response.body, symbolize_names: true)

      expect(items[:data].count).to eq(6)
      expect(items[:data][0][:id]).to eq("#{@item1.id}")
      expect(items[:data][0][:type]).to eq("item")
      expect(items[:data][0][:attributes]).to be_a(Hash)
      expect(items[:data][0][:attributes][:name]).to eq("Cat toy")
      expect(items[:data][0][:attributes][:description]).to eq("wiggling fish")
      expect(items[:data][0][:attributes][:unit_price]).to eq(0.34)
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
        merchant_id: @merchant4.id
      }

      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/items/#{@item5.id}", headers: headers, params: JSON.generate(updated_item_attributes)
      
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
      
      updated_item = Item.find_by(id: @item6.id)
      
      expect(response).to be_successful
      expect(updated_item.name).to eq(updated_item_attributes[:name])
      expect(updated_item.description).to eq(previous_item.description)
      expect(updated_item.unit_price).to eq(updated_item_attributes[:unit_price])
      expect(updated_item.merchant_id).to eq(previous_item.merchant_id)
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
      expect(updated_item.name).to eq(previous_item.name)
      expect(updated_item.description).to eq(previous_item.description)
      expect(updated_item.unit_price).to eq(previous_item.unit_price)
      expect(updated_item.merchant_id).to eq(previous_item.merchant_id)
      expect(updated_item.created_at).to eq(previous_item.created_at)
      expect(updated_item.updated_at).to eq(previous_item.updated_at)
    end

    it "sad path: sends appropriate 400 level error when no id found" do
      invalid_id = 100000
      updated_item_attributes = {
        name: "hypercube",
        description: "now with one additional dimension!",
        unit_price: 8.00 ** (4 / 3),
        merchant_id: @merchant4.id
      }

      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/items/#{invalid_id}", headers: headers, params: JSON.generate(updated_item_attributes)
      error_message = JSON.parse(response.body, symbolize_names: true)
      
      expect(response).to_not be_successful
      expect(error_message[:data][:message]).to eq("Item not found")
      expect(error_message[:data][:errors]).to eq(["Couldn't find Item with 'id'=#{invalid_id}"])
    end
  end


  describe "#show (single item)" do
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

    it "sad path: returns json error message if params not met" do
    
      get "/api/v1/items/999"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data][:message]).to eq("Item not found")
      expect(json[:data][:errors]).to eq(["Couldn't find Item with 'id'=999"])
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
      expect(json[:data][:message]).to eq("Item was not created")
      expect(json[:data][:errors]).to eq(["param is missing or the value is empty: item"])
    end

    it "sad path: returns appropriate error message if subset of parameters are missing (2 examples)" do
      new_incomplete_item = {
        name: "New Item",
        description: "description",
        merchant_id: @merchant1.id
      }

      headers = { "CONTENT_TYPE" => "application/json" }
      post "/api/v1/items", headers: headers, params: JSON.generate(item: new_incomplete_item)
      response_message = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_message[:data][:message]).to eq("Item was not created")
      expect(response_message[:data][:errors]).to eq(["Validation failed: Unit price can't be blank"])

      another_incomplete_item = { merchant_id: @merchant1.id }

      headers = { "CONTENT_TYPE" => "application/json" }
      post "/api/v1/items", headers: headers, params: JSON.generate(item: another_incomplete_item)
      response_message = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_message[:data][:message]).to eq("Item was not created")
      expect(response_message[:data][:errors]).to eq(["Validation failed: Name can't be blank, Description can't be blank, Unit price can't be blank"])
    end
  end

  describe 'can delete an item by id' do
    it 'can delete an item by a specific id' do
      item_to_delete = @item1.id
      expect(Item.count).to eq(6)
      delete "/api/v1/items/#{item_to_delete}"
      expect(response).to be_successful
      expect(response.status).to eq(204)
      expect(Item.count).to eq(5)
      expect{ Item.find(item_to_delete) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "deletes all invoice_items associated with a deleted item" do
      item_to_delete = @item1.id
      expect(Item.count).to eq(6)

      delete "/api/v1/items/#{item_to_delete}"

      expect(response).to be_successful
      expect(Item.count).to eq(5)
      expect(InvoiceItem.count).to eq(@item2.invoice_items.count)
      expect(InvoiceItem.where(item_id: item_to_delete).count).to eq(0)
    end

    it 'sad path: sends appropriate error if no item found to delete"sends appropriate 204 status code when item is deleted' do
      nonexistant_id = 100000

      delete "/api/v1/items/#{nonexistant_id}"
      error_message = JSON.parse(response.body, symbolize_names: true)

      expect(error_message[:data][:message]).to eq("Item not found")
      expect(error_message[:data][:errors]).to eq(["Couldn't find Item with 'id'=#{nonexistant_id}"])   
    end
  end

end