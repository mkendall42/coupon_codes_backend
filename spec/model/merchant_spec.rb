require 'rails_helper'

describe Merchant, type: :model do
  describe "relationships" do
    it { should have_many :items }
    it { should have_many :invoices }
  end

  describe "#index" do
    it "can retrieve all merchants" do
      
    end
    
  end

end