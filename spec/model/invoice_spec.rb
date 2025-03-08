require 'rails_helper'

describe Invoice, type: :model do
  describe "relationships" do
    it { should belong_to :merchant }
    it { should belong_to :customer }
    it { should have_many :invoice_items }
    it { should have_many :transactions }
    it { should belong_to :coupon }
  end

  describe "filter by status(status)" do
    before(:each) do
      
      @merchant1 = Merchant.create!(name: "Barbara")
      @merchant2 = Merchant.create!(name: "Mark")
      @merchant3 = Merchant.create!(name: "Jackson")
      @merchant4 = Merchant.create!(name: "Jason")
  
     
      @customer1 = Customer.create!(first_name: "John J.", last_name: "Jingleheimerschmidt")
      @customer2 = Customer.create!(first_name: "Timmy", last_name: "Turner")
      @customer3 = Customer.create!(first_name: "Spongebob", last_name: "Squarepants")
  
      
      @invoice1 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant1.id, status: "shipped")
      @invoice2 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant1.id, status: "returned")
      @invoice3 = Invoice.create!(customer_id: @customer2.id, merchant_id: @merchant2.id, status: "shipped")
      @invoice4 = Invoice.create!(customer_id: @customer3.id, merchant_id: @merchant2.id, status: "shipped")
    end

    describe "can filter by a given shipping status" do
      it "for shipped" do
        invoices = [@invoice1, @invoice2, @invoice3, @invoice4]

        expect(Invoice.filter_by_status("shipped").count).to eq(3)
      end
  
      it "for returned" do
        invoices = [@invoice1, @invoice2, @invoice3, @invoice4]

        expect(Invoice.filter_by_status("returned").count).to eq(1)
      end
    end
  end
end