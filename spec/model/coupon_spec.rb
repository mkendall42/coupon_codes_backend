require 'rails_helper.rb'

RSpec.describe Coupon, type: :model do

  describe "relationships" do
    it { should have_one :invoice }     #Verify this is optional (i.e. if specific entry missing, test won't fail)
  end

end