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
