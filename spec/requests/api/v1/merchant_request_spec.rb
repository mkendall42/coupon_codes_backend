require 'rails_helper'

describe 'Merchant API' do
    it 'can delete a specific merchant' do
        merchant = create!(:merchant)

        expect { delete 'api/v1/merchants/#{merchant.id}' }.to change(Merchant, :count).by(-1)
        expect { Merchant.find(merchant.id) }.to raise_error(ActiveRecord::RecordNotFound)
        
    end
end