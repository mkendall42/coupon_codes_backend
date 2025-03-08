class CouponSerializer
  include JSONAPI::Serializer
  attributes :name, :code, :status, :discount_value, :discount_percentage
end
