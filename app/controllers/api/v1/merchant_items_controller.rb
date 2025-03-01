#DEPRECATED - this was used while I was trying to get the 
#namespaced versions working.  Looks like it was slight typo in
#routes.rb.


# class Api::V1::MerchantItemsController < ApplicationController
#   def index
#     binding.pry

#     specified_merchant = Merchant.find(params[:id])

#     items_of_merchant = specified_merchant.items

#     render json: ItemSerializer.new(items_of_merchant)
#   end
# end