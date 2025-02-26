require 'rails_helper'

RSpec.describe "Items Controller tests", type: :requests do
  describe "Updating (patch) tests" do
    it "can update a Merchant record with only name provided" do
      #First, extract some Merchant record's id
      #Later: could create new merchant, find its id, etc.
      # found_merchant = Merchant.find_by(id: id)
      merchant = Merchant.first
      previous_merchant_name = merchant.name
      
      #Supply param (name) to adjust:
      updated_merchant_attributes = { name: "Schrodinger-Jorgensen" }

      #Then run update request on that id (to ensure valid)
      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/merchants/#{selected_merchant.id}", headers: headers, params: JSON.generate(updated_merchant_attributes)
      
      #Asseration(s) at end - test the response JSON text, AND that the record is updated in the DB
      expect(response).to be_successful
      expect(merchant.name).to_not eq(previous_merchant_name)
      expect(poster.name).to eq(updated_merchant_attributes[:name])

      merchant_data = JSON.parse(response.body, symbolize_names: true)
      expected_message = {
        data: {
          id: merchant.id,
          type: "merchant",
          attributes: { name: merchant.name }
        }
      }
      expect(merchant_data).to eq(expected_message)
      #These seem superfluous now that I've specified the full structure
      # expect(merchant_data.count).to eq(1)
      # expect(merchant_data[:data].count).to eq(3)
      # expect(merchant_data[:data][:attributes].count).to eq(1)
      
    end

    it "correcltly ignore attributes beyond name in updating" do

    end

    it "handles empty body request properly" do

    end

    it "sends appropriate 400 level error when no id found" do

    end

  end

end
