require 'rails_helper'
require 'rspec_helper'

describe Merchant, type: :model do
  describe "relationships" do
    it { should have_many :items }
    it { should have_many :invoices }
  end

end