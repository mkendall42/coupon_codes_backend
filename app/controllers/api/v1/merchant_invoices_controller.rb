class Api::V1::MerchantInvoicesController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])

    if params[:status].present?
      if !["returned", "shipped", "packaged"].include?(params[:status])
        render json: ErrorSerializer.search_parameters_error("Only valid values for 'status' query are 'returned', 'shipped', or 'packaged'"), status: :unprocessable_entity
        return
      else
        invoices = merchant.invoices.filter_by_status(params[:status])
      end
    else
      invoices = merchant.invoices.all
    end

    binding.pry

    #For this project: serializer updated to add coupon_id if associated
    # render json: InvoiceSerializer.new(invoices)
    render json: InvoiceSerializer.new(invoices, { params: { coupon_id: true } })
  end
end