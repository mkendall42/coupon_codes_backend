require 'rails_helper'

RSpec.describe "Items Controller tests", type: :request do
  before(:each) do
    #Need to also create merchants to assign items to
    Item.destroy_all
    Merchant.destroy_all

    @merchant1 = Merchant.create!(name: "Schroeder-Jerde")
    @merchant2 = Merchant.create!(name: "Nile")
    @merchant3 = Merchant.create!(name: "Avago Technologies")
    @merchant4 = Merchant.create!(name: "Midwest Tungsten Service")

    @item1 = Item.create!(name: "widget", description: "it's a shapeshifting widget!", unit_price: 29.99, merchant_id: @merchant1.id)
    @item2 = Item.create!(name: "wodget", description: "it's NOT a widget!", unit_price: 740.00, merchant_id: @merchant1.id)
    @item3 = Item.create!(name: "purifier", description: "for various supercritical fluids", unit_price: 3154.50, merchant_id: @merchant2.id)
    @item4 = Item.create!(name: "cube", description: "not just any rectangular prism", unit_price: 8.00, merchant_id: @merchant4.id)
    @item5 = Item.create!(name: "cylinder", description: "like the coordinates", unit_price: 18000.01, merchant_id: @merchant4.id)
    @item6 = Item.create!(name: "sphere", description: "now if only it were a cow", unit_price: 512.00, merchant_id: @merchant4.id)

  end

  describe "Updating (patch) tests" do
    it "updates an Item record with all valid attributes" do
      previous_item_name = @item4.name    #We'll choose to update item4 (because we can!)
      updated_item_attributes = {
        name: "hypercube",
        description: "now with one additional dimension!",
        unit_price: 8.00 ** (4 / 3),     #Hyuk hyuk
        merchant_id: @merchant4.id      #Alt: could assign to different merchant, then check
      }

      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/items/#{@item4.id}", headers: headers, params: JSON.generate(updated_item_attributes)
      
      #Asseration(s) - test the response JSON text, AND that the record is updated in the DB
      #NOTE: WEIRD - @merchant1 persists in memory even after DB is changes (and it's not in DB anymore)...is this b/c it's @ ?
      updated_item = Item.find_by(id: @item4.id)
      
      expect(response).to be_successful
      expect(updated_item.name).to_not eq(previous_item_name)
      expect(updated_item.name).to eq(updated_item_attributes[:name])
      expect(updated_item.description).to eq(updated_item_attributes[:description])
      expect(updated_item.unit_price).to eq(updated_item_attributes[:unit_price])
      expect(updated_item.merchant_id).to eq(updated_item_attributes[:merchant_id])

      item_data = JSON.parse(response.body, symbolize_names: true)
      expected_message = {
        data: {
          id: @item4.id.to_s,
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

    end

    it "correctly ignore invalid attributes in updating" do
      #Just make sure the object and record are completely unchanged
    end

    it "handles empty body request properly" do

    end

    it "sends appropriate 400 level error when no id found" do

    end
  end

end
