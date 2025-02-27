class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name
  
  attribute :item_count, if: Proc.new { |merchant, params|
    params && params[:count] == "true" }
end
