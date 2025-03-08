FactoryBot.define do
  factory :invoice do
    status { "shipped" }    #Will want to override this / change it (maybe even randomly)


    #Not sure on the best way to give this association as OPTIONAL...
    association :coupon
    association :merchant
    association :customer   #Is this really needed?  Probably to avoid null constraint issue...
  end
end