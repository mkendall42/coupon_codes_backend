require "rails_helper"

RSpec.describe "MerchantInvoices endpoints", type: :request do
  before(:each) do
    @merchant1 = Merchant.create!(name: "Midwest Tungsten Service")
    @merchant2 = Merchant.create!(name: "Schrodinger, Born, and Oppenheimer")

    @coupon1 = Coupon.create!(name: "Basic discount", code: "GET10OFF", status: false, discount_value: 10.00, discount_percentage: nil, merchant_id: @merchant1.id)
    @coupon2 = Coupon.create!(name: "Big % discount", code: "GET30OFF", status: true, discount_value: nil, discount_percentage: 30.0, merchant_id: @merchant1.id)
    @coupon3 = Coupon.create!(name: "Second merchant big discount", code: "BIGGER40", status: true, discount_value: 40.00, discount_percentage: nil, merchant_id: @merchant2.id)

    @customer1 = Customer.create!(first_name: "Spongebob", last_name: "Squarepants")

    @invoice1 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant1.id, status: "shipped", coupon_id: @coupon1.id)
    @invoice2 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant1.id, status: "shipped", coupon_id: @coupon2.id)
    @invoice3 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant1.id, status: "shipped")
    @invoice4 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant2.id, status: "shipped")
  end

  describe "#index" do
    it "lists all invoices associated with a merchant, including coupon_id if one is used" do
      get "/api/v1/merchants/#{@merchant1.id}/invoices"
      invoices_data = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(invoices_data[:data].length).to eq(3)
      expect(invoices_data[:data][0][:id].to_i).to eq(@invoice1.id)
      expect(invoices_data[:data][0][:type]).to eq("invoice")
      expect(invoices_data[:data][0][:attributes][:merchant_id].to_i).to eq(@invoice1.merchant_id)
      expect(invoices_data[:data][0][:attributes][:coupon_id].to_i).to eq(@invoice1.coupon_id)
      expect(invoices_data[:data][1][:attributes][:merchant_id].to_i).to eq(@invoice2.merchant_id)
      expect(invoices_data[:data][1][:attributes][:coupon_id].to_i).to eq(@invoice2.coupon_id)
      expect(invoices_data[:data][2][:attributes][:merchant_id].to_i).to eq(@invoice3.merchant_id)
      expect(invoices_data[:data][2][:attributes][:coupon_id].to_i).to eq(0)    #nil.to_i = 0...I suppose that makes sense
    end
  end

  describe "#update" do
    it "updates an invoice with provided information" do
      updated_invoice_attributes = {
        coupon_id: @coupon3.id      #Already with @merchant2, so it's consistent
      }

      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/merchants/#{@merchant2.id}/invoices/#{@invoice4.id}", headers: headers, params: JSON.generate(updated_invoice_attributes)
      response_message = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(response_message[:data][:attributes][:coupon_id]).to eq(@coupon3.id)
    end

    it "sad path: cannot attach coupon if coupon has been used too many times" do
      invoice5 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant2.id, status: "shipped", coupon_id: @coupon3.id)
      invoice6 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant2.id, status: "shipped", coupon_id: @coupon3.id)
      invoice7 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant2.id, status: "packaged", coupon_id: @coupon3.id)

      updated_invoice_attributes = {
        coupon_id: @coupon3.id
      }

      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/merchants/#{@merchant2.id}/invoices/#{@invoice4.id}", headers: headers, params: JSON.generate(updated_invoice_attributes)
      error_message = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(error_message[:data][:errors]).to eq(["Cannot use coupon 'id'=#{@coupon3.id}, as it has been used the maximum number of times"])
    end

    it "sad path: cannot attach coupon if coupon inactive" do
      coupon4 = Coupon.create!(name: "So much discount, it must be a shady meme crypto!", code: "WOWZA95OFFWTF", status: false, discount_value: nil, discount_percentage: 95.0, merchant_id: @merchant2.id)

      updated_invoice_attributes = {
        coupon_id: coupon4.id
      }

      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/merchants/#{@merchant2.id}/invoices/#{@invoice4.id}", headers: headers, params: JSON.generate(updated_invoice_attributes)
      error_message = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(error_message[:data][:errors]).to eq(["Coupon with 'id'=#{coupon4.id} is presently inactive.  Must set to active before it is usable"])
    end
  end
end