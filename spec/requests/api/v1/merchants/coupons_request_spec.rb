require 'rails_helper.rb'

RSpec.describe "Coupons of specific merchant", type: :request do
  before(:each) do
    @merchant1 = Merchant.create!(name: "Midwest Tungsten Service")
    @merchant2 = Merchant.create!(name: "Schrodinger, Born, and Oppenheimer")

    @coupon1 = Coupon.create!(name: "Basic discount", code: "GET10OFF", status: false, discount_value: 10.00, discount_percentage: nil, merchant_id: @merchant1.id)
    @coupon2 = Coupon.create!(name: "Big % discount", code: "GET30OFF", status: true, discount_value: nil, discount_percentage: 30.0, merchant_id: @merchant2.id)

    #FactoryBot implementation below.
    #NOTE: for later tests, I resorted to the old fashioned way, due to:
    #1) difficulty tracking multiple relations simultaneously
    #2) needing correct initial values that can be tricky to randomize correctly (unique code, specifying ONLY one discount param, etc)
    #2 merchants: A, B, C
    #3 coupons: 1A belongs to A, 1B and 2B belong to B, 1C belongs to C, etc.
    @merchants = create_list(:merchant, 4)
    @coupons = [
      create_list(:coupon, 1, merchant: @merchants[0]),   #0
      create_list(:coupon, 2, merchant: @merchants[1]),   #1, 2
      create_list(:coupon, 1, merchant: @merchants[2])    #3
    ].flatten 
    @invoices = [
      create_list(:invoice, 1, coupon: @coupons[0], merchant: @merchants[0]),
      create_list(:invoice, 2, coupon: @coupons[2], merchant: @merchants[1]),
      create_list(:invoice, 1, merchant: @merchants[1]),
      create_list(:invoice, 2, merchant: @merchants[3])
    ].flatten
  end

  describe "#index tests" do
    it "returns all coupons associated with given merchant" do
      get "/api/v1/merchants/#{@merchant1.id}/coupons"
      coupons_data = JSON.parse(response.body, symbolize_names: true)
      
      expect(response).to be_successful
      expect(coupons_data.length).to eq(1)
      expect(coupons_data[:data].length).to eq(@merchant1.coupons.length)
      coupons_data[:data].each do |coupon_data|
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

      expected_response = {
        data: {
          message: "Coupon not found",
          errors: ["Couldn't find Merchant with 'id'=#{nonexistant_id}"]
        }
      }
      expect(response).to_not be_successful
      expect(error_message).to eq(expected_response)
    end

    it "filters list based on status (active/inactive)" do
      @coupon3 = Coupon.create!(name: "Big % discount", code: "GET40OFF", status: true, discount_value: nil, discount_percentage: 40.0, merchant_id: @merchant2.id)
      @coupon4 = Coupon.create!(name: "Big % discount", code: "GET50OFF", status: true, discount_value: nil, discount_percentage: 50.0, merchant_id: @merchant2.id)
      @coupon5 = Coupon.create!(name: "Big % discount", code: "GET60OFF", status: false, discount_value: nil, discount_percentage: 60.0, merchant_id: @merchant2.id)
      @coupon6 = Coupon.create!(name: "Big % discount", code: "GET70OFF", status: true, discount_value: nil, discount_percentage: 70.0, merchant_id: @merchant2.id)
      @coupon7 = Coupon.create!(name: "Big % discount", code: "GET80OFF", status: false, discount_value: nil, discount_percentage: 80.0, merchant_id: @merchant2.id)

      get "/api/v1/merchants/#{@merchant2.id}/coupons?filter_status=active"
      filtered_active_coupons_data = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(filtered_active_coupons_data[:data].length).to eq(4)
      expect(filtered_active_coupons_data[:data][0][:id].to_i).to eq(@coupon2.id)
      expect(filtered_active_coupons_data[:data][1][:id].to_i).to eq(@coupon3.id)
      expect(filtered_active_coupons_data[:data][2][:id].to_i).to eq(@coupon4.id)
      expect(filtered_active_coupons_data[:data][3][:id].to_i).to eq(@coupon6.id)

      get "/api/v1/merchants/#{@merchant2.id}/coupons?filter_status=inactive"
      filtered_active_coupons_data = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(filtered_active_coupons_data[:data].length).to eq(2)
      expect(filtered_active_coupons_data[:data][0][:id].to_i).to eq(@coupon5.id)
      expect(filtered_active_coupons_data[:data][1][:id].to_i).to eq(@coupon7.id)
    end
  end

  describe "#show tests" do
    it "locates and correctly renders single coupon info (2 examples)" do
      #First example
      #Somewhat hack-y fix:
      # @coupons[1][]
      get "/api/v1/merchants/#{@merchants[1].id}/coupons/#{@coupons[1].id}"
      coupons_data1 = JSON.parse(response.body, symbolize_names: true)

      # binding.pry

      expect(response).to be_successful
      #Just once, check JSON structuring (esp. since :times_used should be present)

      #Now check the data actually matches the record - iterate over the hash
      coupons_data1[:data][:attributes].each do |attribute, value|
        # expect(@coupons[1][attribute]).to eq(value)
        #NOTE: this is a very hack-y solution.  Don't know a better way for now, other than writing all lines out
        if attribute == :times_used
          expect(value).to eq(0)
        else
          expect(@coupons[1][attribute]).to eq(value)
        end
      end

      #Second example
      get "/api/v1/merchants/#{@merchants[2].id}/coupons/#{@coupons[3].id}"
      coupons_data2 = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      coupons_data2[:data][:attributes].each do |attribute, value|
        # expect(@coupons[3][attribute]).to eq(value)
        #NOTE: need updating the times_used, since this is currently failing
        if attribute == :times_used
          expect(value).to eq(0)
        else
          expect(@coupons[1][attribute]).to eq(value)
        end
      end
    end

    it "correctly renders a count of how many times coupon has been used" do
      #NOTE: what does it really mean for it to have been 'used'?
      #I assume this means all invoices that are beyond 'pending' status?

      #Complete an invoice a few times

      #Example 1 - first coupon (1 invoice uses it)
      get "/api/v1/merchants/#{@merchants[0].id}/coupons/#{@coupons[0].id}"
      coupon_data = JSON.parse(response.body, symbolize_names: true)
      
      expect(response).to be_successful
      expect(coupon_data[:data][:attributes][:times_used]).to eq(1)
      
      # binding.pry
      
      #Example 2 - check second coupon (2 invoices use it)
      get "/api/v1/merchants/#{@merchants[1].id}/coupons/#{@coupons[2].id}"
      coupon_data = JSON.parse(response.body, symbolize_names: true)
      

      expect(response).to be_successful
      expect(coupon_data[:data][:attributes][:times_used]).to eq(2)

      #Now add more invoices that use the coupon!
      create_list(:invoice, 5, coupon: @coupons[2], merchant: @merchants[1])
      get "/api/v1/merchants/#{@merchants[1].id}/coupons/#{@coupons[2].id}"
      coupon_data = JSON.parse(response.body, symbolize_names: true)

      expect(coupon_data[:data][:attributes][:times_used]).to eq(7)
    end

    it "sad path: appropriate error if invalid coupon or invalid merchant" do
      #NOTE: do I need to check merchant again?  Techncially a different route than for #index, so maybe???
      nonexistant_coupon_id = 100000
      get "/api/v1/merchants/#{@merchants[0].id}/coupons/#{nonexistant_coupon_id}"
      error_message = JSON.parse(response.body, symbolize_names: true)

      # binding.pry

      expected_response = {
        data: {
          message: "Coupon not found",
          errors: ["Couldn't find Coupon with 'id'=#{nonexistant_coupon_id}"]   #Weird; exception sends extra SQL info this time (WHERE "").  Why?  Can I filter that out?
        }
      }
      expect(response).to_not be_successful     #Maybe check exact response code
      expect(error_message[:data][:message]).to eq(expected_response[:data][:message])
    end
  end

  describe "#create tests" do
    it "can create a valid new coupon" do
      #Happy path here (don't set active, or have it below threshold)

      # binding.pry
      
      new_coupon_info = {
        name: "Huge discount - 40% off any item",
        code: "40OFFWOW",
        status: true,         #Set active - should work (no other coupons with this merchant)
        discount_value: nil,
        discount_percentage: 40.0
      }
      post "/api/v1/merchants/#{@merchants[3].id}/coupons", params: JSON.generate(new_coupon_info), headers: { "CONTENT_TYPE" => "application/json" }
      response_message = JSON.parse(response.body, symbolize_names: true)
    end

    it "creates new inactive coupon regardless of number of active coupons" do
      @coupons << create_list(:coupon, 5, status: true, merchant: @merchants[3])
      @coupons.flatten

      #First, check that there are exactly 5 active coupons present
      expect(@merchants[3].find_number_active_coupons).to eq(5)
      
      new_coupon_info = {
        name: "$10 off any item",
        code: "SAVE10YES",
        status: false,         #Set inactive
        discount_value: 10.0,
        discount_percentage: nil
      }
      post "/api/v1/merchants/#{@merchants[3].id}/coupons", params: JSON.generate(new_coupon_info), headers: { "CONTENT_TYPE" => "application/json" }
      response_message = JSON.parse(response.body, symbolize_names: true)
      
      # binding.pry

      expected_response = {
        data: {
          id: @merchants[3].coupons.last.id.to_s,
          type: "coupon",
          attributes: new_coupon_info
        }
      }
      expect(response).to be_successful   #Status 201 - set this
      expect(response_message).to eq(expected_response)
    end

    it "sad path: fails to create new active coupon if >= 5 active coupons already exist for merchant" do
      @coupons << create_list(:coupon, 5, status: true, merchant: @merchants[3])
      @coupons.flatten

      new_coupon_info = {
        name: "$10 off any item",
        code: "SAVE10YES",
        status: true,         #Now we cause trouble
        discount_value: 10.0,
        discount_percentage: nil
      }
      post "/api/v1/merchants/#{@merchants[3].id}/coupons", params: JSON.generate(new_coupon_info), headers: { "CONTENT_TYPE" => "application/json" }
      error_message = JSON.parse(response.body, symbolize_names: true)

      # binding.pry

      expect(response).to_not be_successful
      expect(error_message[:data][:errors]).to eq(["Operation failed; attempted to set > 5 active coupons for merchant 'id'=#{@merchants[3].id}"])    #Update later

    end

    it "sad path: fails to create if both discount_value and discount_percentage are supplied, or neither" do
      new_coupon_info = {
        name: "Is it $20 or 20%?  Who knows?",
        code: "SOMEDISCOUNTMAYBE",
        status: true,
        discount_value: 20.0,
        discount_percentage: 20.0
      }
      post "/api/v1/merchants/#{@merchants[3].id}/coupons", params: JSON.generate(new_coupon_info), headers: { "CONTENT_TYPE" => "application/json" }
      error_message = JSON.parse(response.body, symbolize_names: true)

      # binding.pry

      expect(response).to_not be_successful
      expect(error_message[:data][:errors]).to eq(["You must set either 'discount_value' or 'discount_percentage' (exclusive) to null"])

      second_coupon_info = {
        name: "No discout, I guess",
        code: "PROBABLYNOSAVE",
        status: true,         
        discount_value: nil,
        discount_percentage: nil
      }
      post "/api/v1/merchants/#{@merchants[3].id}/coupons", params: JSON.generate(second_coupon_info), headers: { "CONTENT_TYPE" => "application/json" }
      second_error_message = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(error_message[:data][:errors]).to eq(["You must set either 'discount_value' or 'discount_percentage' (exclusive) to null"])
    end

    it "sad path: fails to create if code is not unique" do
      identical_coupon_attributes = {
        name: "I'm a copy",
        code: "DUPLICATE12345",
        status: false,
        discount_value: 42.00,
        discount_percentage: nil
      }
      post "/api/v1/merchants/#{@merchants[3].id}/coupons", params: JSON.generate(identical_coupon_attributes), headers: { "CONTENT_TYPE" => "application/json" }
      # second_error_message = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful

      post "/api/v1/merchants/#{@merchants[3].id}/coupons", params: JSON.generate(identical_coupon_attributes), headers: { "CONTENT_TYPE" => "application/json" }
      error_message = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(error_message[:data][:errors]).to eq(["Code '#{identical_coupon_attributes[:code]}' already exists in database; you must create a unique code"])

      # binding.pry
      
    end

    it "sad path: fails to create if certain information is missing" do
      #Will alredy catch discount_ params, and code.  Also check name, maybe status (or default to false)?
      #Need to employ validation here...

    end

    #Do I need to check for nonexistant merchant AGAIN?

  end

  describe "#update tests (setting coupon active/inactive)" do
    it "can change status of coupon (inactive->active, and vice versa)" do
      #For here, just need basic coupon, invoice setup (nothing fancy)
      #Because factories aren't set up right yet, have these manually here:
      # @merchant1 = Merchant.create!(name: "Midwest Tungsten Service")
      # @merchant2 = Merchant.create!(name: "Schrodinger, Born, and Oppenheimer")
      # @coupon1 = Coupon.create!(name: "Basic discount", code: "GET10OFF", status: false, discount_value: 10.00, discount_percentage: nil, merchant_id: @merchant1.id)
      # @coupon2 = Coupon.create!(name: "Big % discount", code: "GET30OFF", status: true, discount_value: nil, discount_percentage: 30.0, merchant_id: @merchant2.id)
      @customer1 = Customer.create!(first_name: "Marcus", last_name: "Aurelius")
      @invoice1 = Invoice.create!(status: "shipped", coupon_id: @coupon1.id, merchant_id: @merchant1.id, customer_id: @customer1.id)
      @invoice2 = Invoice.create!(status: "returned", coupon_id: @coupon1.id, merchant_id: @merchant1.id, customer_id: @customer1.id)
      # @invoice3 = Invoice.create!(status: "shipped", coupon_id: @coupon2.id, merchant_id: @merchant2.id, customer_id: @customer1.id)

      # binding.pry

      headers = {"CONTENT_TYPE" => "application/json"}
      uri_request_activate = "/api/v1/merchants/#{@merchant1.id}/coupons/#{@coupon1.id}?status=active"
      uri_request_deactivate = "/api/v1/merchants/#{@merchant2.id}/coupons/#{@coupon2.id}?status=inactive"

      patch uri_request_activate, headers: headers
      response_message1 = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(response_message1[:data][:attributes][:status]).to eq(true)

      patch uri_request_deactivate, headers: headers
      response_message2 = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(response_message2[:data][:attributes][:status]).to eq(false)
    end

    it "sad path: cannot activate specified coupon if >= 5 already exist" do
      #Create exactly 5 pre-activated coupons in advance to test this
      @customer1 = Customer.create!(first_name: "Marcus", last_name: "Aurelius")
      @coupon3 = Coupon.create!(name: "Big % discount", code: "GET40OFF", status: true, discount_value: nil, discount_percentage: 40.0, merchant_id: @merchant2.id)
      @coupon4 = Coupon.create!(name: "Big % discount", code: "GET50OFF", status: true, discount_value: nil, discount_percentage: 50.0, merchant_id: @merchant2.id)
      @coupon5 = Coupon.create!(name: "Big % discount", code: "GET60OFF", status: false, discount_value: nil, discount_percentage: 60.0, merchant_id: @merchant2.id)
      @coupon6 = Coupon.create!(name: "Big % discount", code: "GET70OFF", status: true, discount_value: nil, discount_percentage: 70.0, merchant_id: @merchant2.id)
      @coupon7 = Coupon.create!(name: "Big % discount", code: "GET80OFF", status: true, discount_value: nil, discount_percentage: 80.0, merchant_id: @merchant2.id)
      
      headers = {"CONTENT_TYPE" => "application/json"}
      uri_request_activate = "/api/v1/merchants/#{@merchant2.id}/coupons/#{@coupon5.id}?status=active"
      patch uri_request_activate, headers: headers
      response_message = JSON.parse(response.body, symbolize_names: true)

      # binding.pry

      #WRITE THESE CORRECTLY
      # expect(response).to be_successful
      # expect(response_message).to eq({ data: "hi" })

    end

    it "sad path: cannot deactivate coupon until invoice has completed" do
      #Set up invoice(s) assigned
      @customer1 = Customer.create!(first_name: "Marcus", last_name: "Aurelius")
      @invoice1 = Invoice.create!(status: "shipped", coupon_id: @coupon2.id, merchant_id: @merchant2.id, customer_id: @customer1.id)
      @invoice2 = Invoice.create!(status: "packaged", coupon_id: @coupon2.id, merchant_id: @merchant2.id, customer_id: @customer1.id)

      #Verify cannot deactivate
      headers = {"CONTENT_TYPE" => "application/json"}
      uri_request_deactivate = "/api/v1/merchants/#{@merchant2.id}/coupons/#{@coupon2.id}?status=inactive"
      patch uri_request_deactivate, headers: headers
      response_message1 = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(response_message1[:data][:errors]).to eq(["Operation failed; attemped to deactivate coupon being used on unprocessed invoice.  Please wait until invoice is complete"])
      # binding.pry
      #Now process invoice, show can deactivate as normal
      #Not sure this is working correctly.  Further, this is a security risk to allow outside direct var manipulation...perhaps it's auto-protecting from this without notifying me?
      #Well, I think it's working now, but it's very hacky and again I'm worried about the security risk of direct access like that.
      #Is there a way to "seal off" these things?  At least a scope for set_status?
      @invoice2.set_status("shipped")
      @invoice2.save
      #VERY WEIRD: even inside controller scope, I can modify params e.g. status, and it
      #will show me the status is updated, but then when I query the DB, it's not there.
      #Is it not actually committing it to the DB?  Do I need to run update()?
      #This would also mean I need to write InvoiceController#update, argh!

      #CONCLUSION: this seems to all be sourcing from require(:coupon) in params.  Sometimes
      #it is pressent / works, sometimes it is not.  Perhaps due to nesting issue with Merchant,
      #or something else?  Could ask in OH I guess...
      # binding.pry
      
      patch uri_request_deactivate, headers: headers
      response_message2 = JSON.parse(response.body, symbolize_names: true)
      
      expect(response).to be_successful
      expect(response_message2[:data][:attributes][:status]).to eq(false)
      # binding.pry

    end

    #If allowed to change other attributes, add tests here

  end


end