FactoryBot.define do
  factory :coupon do
    name {}
    code {}
    status {}
    discount_value {}         #Remember, exactly one of these must be not nil
    discount_percentage {}

    #Also define associations so they automatically connect
    association :merchant
  end
end