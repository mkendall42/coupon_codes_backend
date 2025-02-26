require 'rails_helper'
require 'date'

RSpec.describe "Merchants Controller tests", type: :request do
  before(:each) do
    #NOTE: forgot that in testing env, the DB is empty.  ARRGH!
    Merchant.destroy_all
    @merchant1 = Merchant.create!(name: "Schroeder-Jerde")
    @merchant2 = Merchant.create!(name: "Nile")
    @merchant3 = Merchant.create!(name: "Avago Technologies")
    @merchant4 = Merchant.create!(name: "Midwest Tungsten Service")
  end

  describe "Updating (patch) tests" do
    it "can update a Merchant record with only name provided" do
      # found_merchant = Merchant.find_by(id: id)
      previous_merchant_name = @merchant1.name
      updated_merchant_attributes = { name: "Schrodinger-Jorgensen" }

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
      #These seem superfluous now that I've specified the full structure
      # expect(merchant_data.count).to eq(1)
      # expect(merchant_data[:data].count).to eq(3)
      # expect(merchant_data[:data][:attributes].count).to eq(1)
    end

    it "correcltly ignore attributes beyond name in updating" do
      previous_merchant_name = @merchant1.name
      updated_merchant_attributes = {
        name: "Schrodinger-Jorgensen",
        created_at: Time.now,
        id: 10000,
        random_attr: "illegal value"
      }

      #Then run update request on that id (to ensure valid)
      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/merchants/#{@merchant1.id}", headers: headers, params: JSON.generate(updated_merchant_attributes)
      
      #Asseration(s) - test the response JSON text, AND that the record is updated in the DB
      #NOTE: WEIRD - @merchant1 persists in memory even after DB is changes (and it's not in DB anymore)...is this b/c it's @ ?
      updated_merchant = Merchant.find_by(id: @merchant1.id)
      
      expect(response).to be_successful
      expect(updated_merchant.name).to eq(updated_merchant_attributes[:name])
      expect(updated_merchant.created_at).to_not eq(updated_merchant_attributes[:created_at])

    end

    it "handles empty body request properly" do
      previous_merchant_name = @merchant1.name
      updated_merchant_attributes = {}

      #NOTE: for some reason, it doesn't like empty params - 400 code.  Is patch command illegal without body?
      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/merchants/#{@merchant1.id}", headers: headers, params: JSON.generate(updated_merchant_attributes)

      binding.pry

      updated_merchant = Merchant.find_by(id: @merchant1.id)
      
      expect(response).to be_successful
      expect(updated_merchant.name).to eq(previous_merchant_name)

      #Could consider checking that DB count doesn't change
    end

    it "sends appropriate 400 level error when no id found" do

    end

  end

end