require 'rails_helper'
require 'rspec_helper'

RSpec.describe Merchant, type: :model do

  before(:each) do
    Merchant.destroy_all
    @merchant1 = Merchant.create!(name: "Barbara")
    @merchant2 = Merchant.create!(name: "Mark")
    @merchant3 = Merchant.create!(name: "Jackson")
    @merchant4 = Merchant.create!(name: "Jason")
  end

  describe "relationships" do
    it { should have_many :items }
    it { should have_many :invoices }
  end

  describe ".sorted_by_age" do
    it "returns merchants ordered by most recently created" do
      expect(Merchant.sorted_by_age).to eq([@merchant4, @merchant3, @merchant2, @merchant1])
    end
  end

  describe ".has_returned_items" do
    it "returns merchants that have returned invoices" do
      customer1 = Customer.create!(first_name: "Sean", last_name: "Doe")
      customer2 = Customer.create!(first_name: "Big", last_name: "Riggz")
  
      invoice1 = @merchant1.invoices.create!(status: "returned", customer: customer1)
      invoice2 = @merchant2.invoices.create!(status: "completed", customer: customer2)
  
      expect(Merchant.has_returned_items).to eq([@merchant1])
    end
  end

  describe "item_count" do
    it "returns the count of items for a merchant" do
      @merchant1.items.create!(name: "Fancy Lamp", description: "Breakable", unit_price: 10)
      @merchant1.items.create!(name: "Coconut Candle", description: "Coconutty", unit_price: 5)

      expect(@merchant1.item_count).to eq(2)
    end
  end
end