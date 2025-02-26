class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name

  # # attribute :item_count, if: -> { options[:count] == true } do |object|
  # #   object.items.count 
  # end
end
