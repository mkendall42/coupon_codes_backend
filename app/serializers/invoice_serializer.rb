class InvoiceSerializer
  include JSONAPI::Serializer
  attributes :customer_id, :merchant_id, :status

  attribute :coupon_id
  # attribute :coupon_id, if: Proc.new { |invoice, params| binding.pry; params[:coupon_id] != nil }
  # attribute :coupon_id, if: Proc.new { coupon_id != nil }
end
