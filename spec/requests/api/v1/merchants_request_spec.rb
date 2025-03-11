require "rails_helper"

RSpec.describe "Merchants endpoints", type: :request do
  before(:each) do
    # Merchant.destroy_all
    @merchant1 = Merchant.create!(name: "Barbara")
    @merchant2 = Merchant.create!(name: "Mark")
    @merchant3 = Merchant.create!(name: "Jackson")
    @merchant4 = Merchant.create!(name: "Jason")

    # Customer.destroy_all
    @customer1 = Customer.create!(first_name: "John J.", last_name: "Jingleheimerschmidt")
    @customer2 = Customer.create!(first_name: "Timmy", last_name: "Turner")
    @customer3 = Customer.create!(first_name: "Spongebob", last_name: "Squarepants")

    # Invoice.destroy_all
    @invoice1 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant1.id, status: "shipped")
    @invoice2 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant1.id, status: "returned")
    @invoice3 = Invoice.create!(customer_id: @customer2.id, merchant_id: @merchant2.id, status: "shipped")
    @invoice4 = Invoice.create!(customer_id: @customer3.id, merchant_id: @merchant2.id, status: "shipped")
  end

  describe "#index" do
    it "can retrieve all merchants" do

      get "/api/v1/merchants"

      expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants[:data].count).to eq(4)
      merchants[:data].each do |merchant|
        expect(merchant[:id].to_i).to be_a(Integer)
        expect(merchant[:type]).to eq("merchant")
        expect(merchant[:attributes]).to be_a(Hash)
        expect(merchant[:attributes][:name]).to be_a(String)
      end
    end

    it "can retrieve merchants sorted by creation, newest first" do

      get "/api/v1/merchants?sorted=age"

      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants[:data].first[:attributes][:name]).to eq("Jason")
    end

    it "can display item_count for a merchant when called for" do
      get "/api/v1/merchants?count=true"

      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants[:data].first[:attributes][:item_count]).to be_an(Integer)
    end

    it "coupon update: displays merchant coupon count and invoice count using coupons" do
      #Create more invoices to test here specifically (and not mess with main config)
      @coupon1 = Coupon.create!(name: "Basic discount", code: "GET10OFF", status: false, discount_value: 10.00, discount_percentage: nil, merchant_id: @merchant1.id)
      @coupon2 = Coupon.create!(name: "Big % discount", code: "GET30OFF", status: true, discount_value: nil, discount_percentage: 30.0, merchant_id: @merchant2.id)
      @coupon3 = Coupon.create!(name: "Malfunctioning Eddie's best deal", code: "GIVEAWAY80", status: true, discount_value: nil, discount_percentage: 80.0, merchant_id: @merchant2.id)
      @invoice5 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant1.id, status: "shipped", coupon_id: @coupon1.id)
      @invoice6 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant1.id, status: "shipped")
      @invoice7 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant2.id, status: "shipped", coupon_id: @coupon2.id)
      @invoice8 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant2.id, status: "shipped", coupon_id: @coupon3.id)
      @invoice9 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant3.id, status: "shipped")

      get "/api/v1/merchants?coupon_info=true"

      merchant_data = JSON.parse(response.body, symbolize_names: true)

      # binding.pry

      expect(response).to be_successful
      merchant_data[:data].each do |merchant|
        expect(merchant[:id].to_i).to be_a(Integer)
        expect(merchant[:type]).to eq("merchant")
        expect(merchant[:attributes]).to be_a(Hash)
        expect(merchant[:attributes][:name]).to be_a(String)
        expect(merchant[:attributes][:coupons_count]).to be_a(Integer)
        expect(merchant[:attributes][:invoice_coupon_count]).to be_a(Integer)
      end
      expect(merchant_data[:data][0][:attributes][:coupons_count]).to eq(1)
      expect(merchant_data[:data][0][:attributes][:invoice_coupon_count]).to eq(1)
      expect(merchant_data[:data][1][:attributes][:coupons_count]).to eq(2)
      expect(merchant_data[:data][1][:attributes][:invoice_coupon_count]).to eq(2)
      expect(merchant_data[:data][2][:attributes][:coupons_count]).to eq(0)
      expect(merchant_data[:data][2][:attributes][:invoice_coupon_count]).to eq(0)
      expect(merchant_data[:data][3][:attributes][:coupons_count]).to eq(0)
      expect(merchant_data[:data][3][:attributes][:invoice_coupon_count]).to eq(0)
    end
  end

  describe "#update (patch) tests" do
    it "can update a Merchant record with only name provided" do
      previous_merchant_name = @merchant1.name
      updated_merchant_attributes = { name: "Babs" }

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
    end

    it "correctly ignores attributes beyond name in updating" do
      previous_merchant = @merchant2
      updated_merchant_attributes = {
        name: "Marky Mark",
        created_at: Time.now,
        id: 10000,
        random_attr: "illegal value"
      }

      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/merchants/#{previous_merchant.id}", headers: headers, params: JSON.generate(updated_merchant_attributes)
      
      updated_merchant = Merchant.find_by(id: @merchant2.id)
      merchant_response_data = JSON.parse(response.body, symbolize_names: true)
      
      expect(response).to be_successful
      expect(updated_merchant.name).to eq(updated_merchant_attributes[:name])
      expect(updated_merchant.created_at).to_not eq(updated_merchant_attributes[:created_at])
    end

    it "handles empty body request properly" do
      previous_merchant = @merchant1
      updated_merchant_attributes = {}

      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/merchants/#{@merchant1.id}", headers: headers, params: JSON.generate(updated_merchant_attributes)

      updated_merchant = Merchant.find_by(id: @merchant1.id)
      
      expect(response).to_not be_successful
      expect(updated_merchant.id).to eq(previous_merchant.id)
      expect(updated_merchant.name).to eq(previous_merchant.name)
      expect(updated_merchant.created_at).to eq(previous_merchant.created_at)
      expect(updated_merchant.updated_at).to eq(previous_merchant.updated_at)
    end

    it "sad path: sends appropriate 400 level error when no id found" do
      nonexistant_id = 100000
      updated_merchant_attributes = { name: "J-son" }

      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/merchants/#{nonexistant_id}", headers: headers, params: JSON.generate(updated_merchant_attributes)
      
      error_message = JSON.parse(response.body, symbolize_names: true)
      updated_merchant = Merchant.find_by(id: nonexistant_id)

      expect(response).to_not be_successful
      expect(response.status).to eq(404)
      expect(error_message[:data][:message]).to eq("Merchant not found")
      expect(error_message[:data][:errors]).to eq(["Couldn't find Merchant with 'id'=#{nonexistant_id}"])
    end
  end

  describe 'can delete a merchant by id' do
    it 'can delete a merchant by a specific id' do
      merchant_to_delete = @merchant1.id
      expect(Merchant.count).to eq(4)
      delete "/api/v1/merchants/#{merchant_to_delete}"
      expect(response).to be_successful
      expect(Merchant.count).to eq(3)
      expect{ Merchant.find(merchant_to_delete) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "deletes all items associated with a deleted merchant" do
      merchant_to_delete = @merchant1.id
      expect(Merchant.count).to eq(4)
      expect(Item.count).to eq(@merchant1.items.count)
      delete "/api/v1/merchants/#{merchant_to_delete}"
      expect(response).to be_successful
      expect(Merchant.count).to eq(3)
      expect{ Merchant.find(merchant_to_delete) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Item.count).to eq(@merchant1.items.count - @merchant1.items.count)
      expect(Item.where(merchant_id: merchant_to_delete).count).to eq(0)
    end

    it 'sends appropriate 204 status code when merchant is deleted' do
      merchant_to_delete = @merchant1.id
      delete "/api/v1/merchants/#{merchant_to_delete}"
      expect(response).to be_successful
      expect(response.status).to eq(204)
      expect{ Merchant.find(merchant_to_delete) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#show tests" do
    it "should return specific merchant based on id given" do
      merchant = Merchant.create!(name: "Single Merchant")
      get "/api/v1/merchants/#{merchant.id}"

      expect(response).to be_successful
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:data][:id].to_i).to eq(merchant.id)
      expect(json[:data][:type]).to eq("merchant")
      expect(json[:data][:attributes]).to be_a(Hash)
      expect(json[:data][:attributes][:name]).to eq(merchant.name)
    end

    it "sad path: returns an error message when merchant does not exist" do
      get "/api/v1/merchants/1000" 

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:data][:message]).to eq("Merchant not found")
      expect(json[:data][:errors]).to be_a(Array)
      expect(json[:data][:errors][0]).to eq("Couldn't find Merchant with 'id'=1000")
    end
  end

  describe "#create merchant" do
    it "creates a new merchant when given json data" do
      body = { name: "New Merchant" }
      post "/api/v1/merchants", params: body, as: :json
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:created)
      expect(json[:data][:attributes][:name]).to eq("New Merchant")
      expect(json[:data][:type]).to eq("merchant")
    end
  end

  describe "sad path: create merchant failure" do
    it "should give sad path message when it does not work" do
      post "/api/v1/merchants", params: {}, headers: { "CONTENT_TYPE" => "application/json" }
      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:message]).to eq("Merchant was not created")
      expect(json[:errors]).to be_a(Array)
      expect(json[:errors][0]).to eq("param is missing or the value is empty: merchant")
    end
  end

  describe "can list customers related to a specific merchant" do
    it "can grab customers by merchant id" do
      get "/api/v1/merchants/#{@merchant2.id}/customers"
      customers = JSON.parse(response.body, symbolize_names: true)

      expect(customers[:data].first[:attributes][:first_name]).to eq("Timmy")
      expect(customers[:data].length).to eq(2)
    end
  end

  describe "can get list of invoices for a merchant based on status" do
    it "for shipped" do
      get "/api/v1/merchants/#{@merchant1.id}/invoices?status=shipped"
      invoices = JSON.parse(response.body, symbolize_names: true)

      expect(invoices[:data].first[:attributes][:status]).to eq("shipped")
    end

    it "for returned" do
      get "/api/v1/merchants/#{@merchant1.id}/invoices?status=returned"
      invoices = JSON.parse(response.body, symbolize_names: true)

      expect(invoices[:data].first[:attributes][:status]).to eq("returned")
    end

    it "returns all invoices if query other than 'status' is sent" do
      get "/api/v1/merchants/#{@merchant2.id}/invoices?customer_id=12345"
      invoices_data = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(invoices_data[:data].length).to eq(2)
      expect(invoices_data[:data][0][:attributes][:merchant_id]).to eq(@merchant2.id)
      expect(invoices_data[:data][1][:attributes][:merchant_id]).to eq(@merchant2.id)
    end

    it "sad path: error if query value other than 'returned/shipped/packaged' sent" do
      get "/api/v1/merchants/#{@merchant2.id}/invoices?status=indeterminate"
      expect(JSON.parse(response.body, symbolize_names: true)[:data][:errors]).to eq(["Only valid values for 'status' query are 'returned', 'shipped', or 'packaged'"])
    end
  end
end