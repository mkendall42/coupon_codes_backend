require 'rails_helper'

RSpec.describe Merchant, type: :model do

  before(:each) do
    Merchant.destroy_all
    @merchant1 = Merchant.create!(name: "Barbara")
    @merchant2 = Merchant.create!(name: "Mark")
    @merchant3 = Merchant.create!(name: "Jackson")
    @merchant4 = Merchant.create!(name: "Jason")

    #Hopefully these are safe up here...(all belong to merchant 4 for now)
    @coupon1 = Coupon.create!(name: "Big % discount", code: "GET40OFF", status: true, discount_value: nil, discount_percentage: 40.0, merchant_id: @merchant4.id)
    @coupon2 = Coupon.create!(name: "Big % discount", code: "GET50OFF", status: true, discount_value: nil, discount_percentage: 50.0, merchant_id: @merchant4.id)
    @coupon3 = Coupon.create!(name: "Big % discount", code: "GET60OFF", status: false, discount_value: nil, discount_percentage: 60.0, merchant_id: @merchant4.id)
    @coupon4 = Coupon.create!(name: "Big % discount", code: "GET70OFF", status: true, discount_value: nil, discount_percentage: 70.0, merchant_id: @merchant4.id)
    @coupon5 = Coupon.create!(name: "Big % discount", code: "GET80OFF", status: false, discount_value: nil, discount_percentage: 80.0, merchant_id: @merchant4.id)

  end

  describe "relationships" do
    it { should have_many :items }
    it { should have_many :invoices }
    it { should have_many :coupons }
    #I assume 'customers' not done here due to join / through: ?
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
      invoice2 = @merchant2.invoices.create!(status: "shipped", customer: customer2)
  
      expect(Merchant.has_returned_items).to eq([@merchant1])
      expect(@merchant1.invoices[0].status).to eq('returned')
    end
  end

  describe "item_count" do
    it "returns the count of items for a merchant" do
      @merchant1.items.create!(name: "Fancy Lamp", description: "Breakable", unit_price: 10)
      @merchant1.items.create!(name: "Coconut Candle", description: "Coconutty", unit_price: 5)

      expect(@merchant1.item_count).to eq(2)
    end
  end

  describe ".find_by_name_string" do
    it "correctly finds all merchants with name containing substring, sorted alphabetically by name" do
      search_string = "son"

      expect(Merchant.find_by_name_string(search_string)).to eq([@merchant3, @merchant4])
    end

    it "correctly works in case-insensitive manner" do
      search_string = "Ar"

      expect(Merchant.find_by_name_string(search_string)).to eq([@merchant1, @merchant2])
    end

    it "returns empty array for nonexistant substring in merchants" do
      search_string = "Batman"

      expect(Merchant.find_by_name_string(search_string)).to eq([])
    end
  end

  describe "coupon counting with .find_number_active_coupons and .coupons_count" do
    it "determines correct number of total coupons for merchant" do
      expect(@merchant4.coupons_count).to eq(5)

      Coupon.create!(name: "Surprise!", code: "100OFFWOW", status: false, discount_value: nil, discount_percentage: 100.0, merchant_id: @merchant4.id) 

      expect(@merchant4.coupons_count).to eq(6)
    end

    it "determines correct number of active coupons for merchant" do
      expect(@merchant4.find_number_active_coupons).to eq(3)
      expect(@merchant4.coupons_count - @merchant4.find_number_active_coupons).to eq(2)
    end
  end

  describe ".get_coupons_by_status" do
    it "correctly finds all inactive coupons" do
      #Wow - can convert to an array!  Wish I knew this earier...
      expect(@merchant4.get_coupons_by_status(false).to_a).to eq([@coupon3, @coupon5])
    end

    it "correctly finds all active coupons" do
      expect(@merchant4.get_coupons_by_status(true).to_a).to eq([@coupon1, @coupon2, @coupon4])
    end
  end

  describe ".invoice_coupon_count" do
    it "counts number of invoices utilizing a coupon of merchant" do
      #Need to create a few invoices for this scenario
      customer = Customer.create(first_name: "Todd", last_name: "Kobel")
      invoice1 = @merchant4.invoices.create!(status: "returned", customer_id: customer.id, coupon_id: @coupon2.id)
      invoice2 = @merchant4.invoices.create!(status: "shipped", customer_id: customer.id, coupon_id: @coupon3.id)
      invoice3 = @merchant4.invoices.create!(status: "packaged", customer_id: customer.id, coupon_id: @coupon4.id)
      invoice4 = @merchant4.invoices.create!(status: "shipped", customer_id: customer.id)

      expect(@merchant4.invoice_coupon_count).to eq(3)
    end
  end

end