class CouponSerializer
  include JSONAPI::Serializer
  attributes :name, :code, :status, :discount_value, :discount_percentage

  attribute :times_used, if: Proc.new { |coupon, params| params[:display_count] }
end
