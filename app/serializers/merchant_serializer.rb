class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name

  # attributes :coupons_count, :invoice_coupon_count      #These call relevant model methods
  
  attribute :item_count, if: Proc.new { |merchant, params|
    params && params[:count] == "true" }

  attributes :coupons_count, :invoice_coupon_count, if: Proc.new { |merchant, params|
    params && params[:coupon_info] == "true" }
end
