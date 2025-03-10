require 'rails_helper.rb'

RSpec.describe "Coupons of specific merchant", type: :request do
  before(:each) do
    #Construct coupons here.  Perhaps use FactoryBot for this...
    @merchant1 = Merchant.create!(name: "Midwest Tungsten Service")
    @merchant2 = Merchant.create!(name: "Schrodinger, Born, and Oppenheimer")

    @coupon1 = Coupon.create!(name: "Basic discount", code: "GET10OFF", status: true, discount_value: 10.00, discount_percentage: nil, merchant_id: @merchant1.id)
    @coupon1 = Coupon.create!(name: "Big % discount", code: "GET30OFF", status: true, discount_value: nil, discount_percentage: 30.0, merchant_id: @merchant2.id)

    #Trying FactoryBot implementation:
    #NOTE: need to determine how to set up how things get associated
    #NOTE: it seems to be generating NEW marchants just to associate for coupons
    #May be able to manually pass associations in as args to override
    #TRY THIS OUT!
    # @merchants = create_list(:merchant, 2)

    # @coupons = create_list(:coupon, merchant: @merchants, 2)

    # @invoices = create_list(:invoice, 4)

    #Ok, let's take another shot at this:
    #2 merchants: A, B, C
    #3 coupons: 1A belongs to A, 1B and 2B belong to B, 1C belongs to C
    #4 invoices: 1 belongs to A and 1A, 1 belongs to B and 2B, 1 belongs to B (but no coupon), and 2 don't have a merchant or coupons -> fix this)
    #Well, this seems to work.  However, it can easily be a mess, especially since it's creating other merchants / things as needed to keep all associations safe...
    #ANOTHER THING: needs to correctly assign discounts (one must be nil), and unique codes...
    @merchants = create_list(:merchant, 4)
    @coupons = [
      create_list(:coupon, 1, merchant: @merchants[0]),
      create_list(:coupon, 2, merchant: @merchants[1]),
      create_list(:coupon, 1, merchant: @merchants[2]),
    ].flatten 
    @invoices = [
      create_list(:invoice, 1, coupon: @coupons[0], merchant: @merchants[0]),
      create_list(:invoice, 1, coupon: @coupons[2], merchant: @merchants[1]),
      create_list(:invoice, 1, merchant: @merchants[1]),
      create_list(:invoice, 2)
    ].flatten

    # merchant = create(:merchant)
    #   create_list(:item, 10, merchant_id: merchant.id)

  end

  describe "#index tests" do
    it "returns all coupons associated with given merchant" do
      get "/api/v1/merchants/#{@merchant1.id}/coupons"
      coupons_data = JSON.parse(response.body, symbolize_names: true)
      
      # binding.pry

      #Check JSON structure of each entry:
      #Need to pass appropriate array of merchants as well
      #Could zip 'em / something similar
      expect(response).to be_successful
      expect(coupons_data.length).to eq(1)
      expect(coupons_data[:data].length).to eq(@merchant1.coupons.length)
      coupons_data[:data].each do |coupon_data|

        # binding.pry

        expect(coupon_data.length).to eq(3)
        expect(coupon_data[:type]).to eq("coupon")
        expect(coupon_data[:attributes][:name]).to be_a(String)
        expect(coupon_data[:attributes][:code]).to be_a(String)
        expect([true, false]).to include(coupon_data[:attributes][:status])
        # expect(coupon_data[:attributes][:discount_value]).to be_a(Float)  #OR nil
        expect([Float, NilClass]).to include(coupon_data[:attributes][:discount_value].class)
        # expect(coupon_data[:attributes][:discount_percentage]).to be_a(Float)  #OR nil
        expect([Float, NilClass]).to include(coupon_data[:attributes][:discount_percentage].class)
      end

    end

    it "returns empty array / JSON for no coupons" do
      get "/api/v1/merchants/#{@merchants[3].id}/coupons"
      coupons_data = JSON.parse(response.body, symbolize_names: true)

      expected_response = { data: [] }
      expect(response).to be_successful
      expect(coupons_data).to eq(expected_response)

    end

    it "sad path: appropriate error for invalid merchant" do
      nonexistant_id = 100000
      get "/api/v1/merchants/#{nonexistant_id}/coupons"
      error_message = JSON.parse(response.body, symbolize_names: true)

      # binding.pry

      expected_response = {
        data: {
          message: "Merchant not found",
          errors: ["Couldn't find Merchant with 'id'=#{nonexistant_id}"]
        }
      }
      expect(response).to_not be_successful     #Maybe check exact code
      expect(error_message).to eq(expected_response)
    end

    #What about testing that if a merchant is deleted, so are all coupons?  Perhaps put in main merchant controller tests...

  end


end