require 'rails_helper'
require 'rspec_helper'

RSpec.describe "Items (of Merchant) endpoints", type: :request do
  
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

  describe "#index tests" do
    it "happy path: returns all items of specified merchant (two examples)" do
      #Merchant with only one item
      get "/api/v1/merchants/#{@merchant1.id}/items"
      items_of_merchant = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(items_of_merchant[:data].length).to eq(1)
      expect(items_of_merchant[:data][0][:id].to_i).to eq(@item1.id)
      expect(items_of_merchant[:data][0][:attributes][:name]).to eq(@item1.name)

      #Merchant with two items (proper array)
      get "/api/v1/merchants/#{@merchant4.id}/items"
      items_of_merchant = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(items_of_merchant[:data].length).to eq(2)
      expect(items_of_merchant[:data][0][:id].to_i).to eq(@item5.id)
      expect(items_of_merchant[:data][0][:attributes][:name]).to eq(@item5.name)
      expect(items_of_merchant[:data][1][:id].to_i).to eq(@item6.id)
      expect(items_of_merchant[:data][1][:attributes][:name]).to eq(@item6.name)
    end

    it "sad path: returns error if merchant does not exist" do
      nonexistant_id = 100000
      get "/api/v1/merchants/#{nonexistant_id}/items"
      error_message = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(response.status).to eq(404)
      #Related: could I group some of these (DRY)?  I suspect so...
      expect(error_message[:message]).to eq("Your request could not be completed.")
      expect(error_message[:errors]).to be_a(Array)
      expect(error_message[:errors].first[:message]).to eq("Couldn't find Merchant with 'id'=#{nonexistant_id}")
    end

    it "correctly returns empty array for merchant with no associated items" do
      surprise_merchant = Merchant.create!(name: "Big Riggz")
      get "/api/v1/merchants/#{surprise_merchant.id}/items"
      items_of_merchant = JSON.parse(response.body, symbolize_names: true)

      #NOTE / ASK: Should this return an error or sorts for developer empathy?
      expect(response).to be_successful
      expect(items_of_merchant[:data]).to eq([])
    end
  end

end
