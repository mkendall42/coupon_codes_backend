require 'rails_helper.rb'

RSpec.describe "Coupons of specific merchant", type: :request do
  before(:each) do
    #Construct coupons here.  Perhaps use FactoryBot for this...
    @merchant1 = Merchant.create!(name: "Midwest Tungsten Service")
    @merchant2 = Merchant.create!(name: "Schrodinger, Born, and Oppenheimer")

    @coupon1 = Coupon.create!(name: "Basic discount", code: "GET10OFF", status: true, discount_value: 10.00, discount_percentage: nil, merchant_id: @merchant1.id)
    @coupon1 = Coupon.create!(name: "Big % discount", code: "GET30OFF", status: true, discount_value: nil, discount_percentage: 30.0, merchant_id: @merchant2.id)

    #Trying FactoryBot implementation:
    @merchants = create_list(:merchant, 2)

    @coupons = create_list(:coupon, 2)

    @invoices = create_list(:invoice, 4)

  end

  describe "#index tests" do
    it "returns all coupons associated with given merchant" do
      get "/api/v1/merchants/#{@merchant1.id}/coupons"
      coupons_data = JSON.parse(response.body, symbolize_names: true)
      
      binding.pry

      #Check JSON structure of each entry:
      #Need to pass appropriate array of merchants as well
      expect(response).to be_successful
      expect(coupons_data.length).to eq(1)
      expect(coupons_data[:data].length).to eq(@merchant1.coupons.length)
      coupons_data[:data].each do |coupon_data|
        # expect()
      end

    end

    it "returns empty array / JSON for no coupons" do

    end

    it "sad path: appropriate error for invalid merchant" do

    end

    #What about testing that if a merchant is deleted, so are all coupons?  Perhaps put in main merchant controller tests...

  end


end