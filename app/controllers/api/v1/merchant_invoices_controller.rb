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

    #Renders all invoices from merchant (including coupon_id == null), since example from project requirements showed this.
    render json: InvoiceSerializer.new(invoices, { params: { coupon_id: true } })
  end
end