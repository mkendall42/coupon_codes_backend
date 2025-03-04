require 'rails_helper'
require 'rspec_helper'
RSpec.describe Api::V1::Merchants::SearchController, type: :controller do
  before(:each) do
    Merchant.destroy_all
    @merchant1 = Merchant.create!(name: "Barbara")
    @merchant2 = Merchant.create!(name: "Mark")
    @merchant3 = Merchant.create!(name: "Ring World")
    @merchant4 = Merchant.create!(name: "Turing")
  end

  describe 'GET #find_all' do
    it 'returns all merchants that match the name' do
      get :find_all, params: { name: 'ring' }

      expect(response).to have_http_status(:success)
      result = JSON.parse(response.body)['data']

      expect(result.length).to eq(2)
      expect(result.first['attributes']['name']).to eq('Ring World')
      expect(result.second['attributes']['name']).to eq('Turing')
    end

    it 'returns an empty array if no merchants match the name' do
      get :find_all, params: { name: 'bruh' }

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['data']).to eq([])
    end

    it 'returns an error if the name parameter is empty' do
      get :find_all, params: { name: '' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to eq("Parameter 'name' cannot be empty")
    end
  end
end

    