require 'rails_helper.rb'

RSpec.describe Coupon, type: :model do
  before(:each) do
    @merchant1 = Merchant.create!(name: "Midwest Tungsten Service")
    @merchant2 = Merchant.create!(name: "Schrodinger, Born, and Oppenheimer")

    @coupon1 = Coupon.create!(name: "Big % discount", code: "GET40OFF", status: true, discount_value: nil, discount_percentage: 40.0, merchant_id: @merchant1.id)
    @coupon2 = Coupon.create!(name: "Big % discount", code: "GET50OFF", status: true, discount_value: nil, discount_percentage: 50.0, merchant_id: @merchant1.id)
    @coupon3 = Coupon.create!(name: "Big % discount", code: "GET60OFF", status: false, discount_value: nil, discount_percentage: 60.0, merchant_id: @merchant1.id)
    @coupon4 = Coupon.create!(name: "Big % discount", code: "GET70OFF", status: true, discount_value: nil, discount_percentage: 70.0, merchant_id: @merchant1.id)
    @coupon5 = Coupon.create!(name: "Big % discount", code: "GET80OFF", status: false, discount_value: nil, discount_percentage: 80.0, merchant_id: @merchant1.id)

    @customer = Customer.create(first_name: "Todd", last_name: "Kobel")

    @invoice1 = @merchant1.invoices.create!(status: "returned", customer_id: @customer.id, coupon_id: @coupon2.id)
    @invoice2 = @merchant1.invoices.create!(status: "packaged", customer_id: @customer.id, coupon_id: @coupon2.id)
    @invoice3 = @merchant1.invoices.create!(status: "packaged", customer_id: @customer.id, coupon_id: @coupon2.id)
    @invoice4 = @merchant1.invoices.create!(status: "shipped", customer_id: @customer.id, coupon_id: @coupon4.id)
    @invoice5 = @merchant1.invoices.create!(status: "packaged", customer_id: @customer.id, coupon_id: @coupon4.id)
    @invoice6 = @merchant1.invoices.create!(status: "shipped", customer_id: @customer.id, coupon_id: @coupon5.id)
  end

  describe "relationships" do
    it { should have_many :invoices }     #Verify this is optional (i.e. if specific entry missing, test won't fail)
    it { should belong_to :merchant }
  end

  describe ".times_used" do
    it "determines correct number of times a specific coupon has been used (3 examples)" do
      expect(@coupon2.times_used).to eq(3)
      expect(@coupon4.times_used).to eq(2)
      expect(@coupon3.times_used).to eq(0)
    end
  end

  describe "#verify_unique_code" do
    it "confirms unique code given current coupon list" do
      new_code = "UNIQUE42"

      expect(Coupon.verify_unique_code(new_code)).to eq(true)
    end

    it "fails when given code is no longer unique" do
      new_code = "UNIQUE42"
      another_coupon = Coupon.create!(name: "another coupon", code: new_code, status: false, discount_value: 42.00, discount_percentage: nil, merchant_id: @merchant1.id)

      expect(Coupon.verify_unique_code(new_code)).to eq(false)
      expect(Coupon.verify_unique_code(@coupon1.code)).to eq(false)
    end
  end

  describe ".pending_invoices?" do
    it "check if any invoices are pending associated with coupon (3 examples)" do
      expect(@coupon2.pending_invoices?).to eq(true)
      expect(@coupon4.pending_invoices?).to eq(true)
      expect(@coupon5.pending_invoices?).to eq(false)
    end
  end

end