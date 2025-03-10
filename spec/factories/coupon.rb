FactoryBot.define do
  factory :coupon do
    name {}
    code {}
    status {}
    discount_value {}         #Remember, exactly one of these must be not nil
    discount_percentage {}

    #Also define associations so they automatically connect
    #NOTE: I may need to manually build merchants here to get access to them...
    association :merchant
  end
end