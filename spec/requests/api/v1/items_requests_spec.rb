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
  end


  describe "#index" do
    it 'can retrieve all items' do

      get '/api/v1/items'

      expect(response).to be_successful
      items = JSON.parse(response.body, symbolize_names: true)

      expect(items[:data].count).to eq(4)
    end

    it 'can sort items by ascending price' do

      get '/api/v1/items?sorted=price'

      expect(response).to be_successful
      items = JSON.parse(response.body, symbolize_names: true)
      
      expect(items[:data].first[:attributes][:name]).to eq("Cat toy")
      expect(items[:data].last[:attributes][:name]).to eq("can of ground peas")
    end
  end
end