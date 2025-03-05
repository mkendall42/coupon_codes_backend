require 'rails_helper'

RSpec.describe Item, type: :model do

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

  describe "relationships" do
    it { should belong_to :merchant }
  end

  describe ".sorted_by_price" do
    it "returns items sorted by ascending price" do
      expected_order = [@item1, @item3, @item2, @item4, @item5, @item6]
    
      expect(Item.sorted_by_price).to eq(expected_order)
    end
  end

  describe ".find_by_name_string" do
    it "finds first item (alphabetically by name) containing substring" do
      string_to_search = "ea"

      expect(Item.find_by_name_string(string_to_search)).to eq(@item4)
    end

    it "works correctly in case-insensitive manner" do
      string_to_search = "eA"

      expect(Item.find_by_name_string(string_to_search)).to eq(@item4)
    end

    it "nonexistant substring returns nil" do
      string_to_search = "Scandium"

      expect(Item.find_by_name_string(string_to_search)).to eq(nil)
    end
  end


  describe ".find_by_price_range" do
    #NOTE: these do not check if max < min, or min || max < 0;
    #That is done in the conroller for error handling
    it "finds correct item (first one, alphabetically) given legal mix, max price range (2 examples)" do
      min_price_A = 2.25
      max_price_A = 291

      found_item_A = Item.find_by_price_range(min_price_A, max_price_A)
      expect(found_item_A).to eq(@item4)

      min_price_B = 1.00
      max_price_B = 3.14

      found_item_B = Item.find_by_price_range(min_price_B, max_price_B)
      expect(found_item_B).to eq(@item2)
    end

    it "finds correct items with only min specified" do
      min_price = 8.99
      max_price = nil

      found_item = Item.find_by_price_range(min_price, max_price)
      expect(found_item).to eq(@item6)
    end

    it "finds correct items with only max specified" do
      min_price = nil
      max_price = 5.55

      found_item = Item.find_by_price_range(min_price, max_price)
      expect(found_item).to eq(@item1)
    end
  end

end