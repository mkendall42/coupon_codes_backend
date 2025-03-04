require 'rails_helper'
require 'rspec_helper'

RSpec.describe Api::V1::Items::SearchController, type: :controller do
  before(:each) do

    Merchant.destroy_all
    @merchant1 = Merchant.create!(name: "Barbara")
    @merchant2 = Merchant.create!(name: "Mark")
    
    Item.destroy_all
    @item1 = Item.create!(name: "Ring World", description: "world of rings", unit_price: 10.00, merchant_id: @merchant1[:id])
    @item2 = Item.create!(name: "orange cream soda", description: "tasty and citrusy", unit_price: 20.00, merchant_id: @merchant2[:id])
    @item3 = Item.create!(name: "root beer", description: "smooth saspirilla", unit_price: 30.00, merchant_id: @merchant2[:id])
  end
  describe 'GET #find' do
    it 'returns the first item that matches the name, case-insensitive' do
      get :find, params: { name: 'ring' }

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['data']['attributes']['name']).to eq('Ring World')
    end

    it 'returns an error if no items match the name' do
      get :find, params: { name: 'bruh' }

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq('Item not found')
    end

    it 'returns an error if both name and price' do
      get :find, params: { name: 'ring', min_price: 20 }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to eq('Cannot send both name and price')
    end

    context 'when searching by min_price' do
      it 'returns the first item with a price greater than or equal to min_price' do
        get :find, params: { min_price: 30 }

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['data']['attributes']['name']).to eq('root beer')
      end

      it 'returns an error if no items match the min_price' do
        get :find, params: { min_price: 1000 }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Item not found')
      end

      it 'returns an error if both name and min_price are provided' do
        get :find, params: { name: 'ring', min_price: 20 }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Cannot send both name and price parameters')
      end
    end

    context 'when searching by max_price' do
      it 'returns the first item with a price less than or equal to max_price' do
        get :find, params: { max_price: 24.00 }

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['data']['attributes']['name']).to eq('Ring World')
      end

      it 'returns an error if no items match the max_price' do
        get :find, params: { max_price: 0.1 }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Item not found')
      end

      it 'returns an error if both name and max_price are provided' do
        get :find, params: { name: 'ring', max_price: 20 }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Cannot send both name and price parameters')
      end
    end

    context 'when searching by both min_price and max_price' do
      it 'returns the first item with a price within the range' do
        get :find, params: { min_price: 20, max_price: 30 }

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['data']['attributes']['name']).to eq('orange cream soda')
      end
    end

    context 'when no parameters are provided' do
      it 'returns an error message' do
        get :find

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq("Parameter 'name' or 'min_price/max_price' must be provided")
      end
    end
  end
end