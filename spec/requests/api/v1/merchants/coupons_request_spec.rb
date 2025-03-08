require 'rails_helper.rb'

RSpec.describe "Coupons of specific merchant" type: :request do
  before(:each) do
    #Construct coupons here.  Perhaps use FactoryBot for this...

  end

  describe "#index tests" do
    it "returns all coupons associated with given merchant" do

    end

    it "returns empty array / JSON for no coupons" do

    end

    it "sad path: appropriate error for invalid merchant" do

    end

    #What about testing that if a merchant is deleted, so are all coupons?  Perhaps put in main merchant controller tests...

  end


end