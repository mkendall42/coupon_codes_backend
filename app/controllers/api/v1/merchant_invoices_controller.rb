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

  def update

    # binding.pry

    #This is used here exclusively for extensions.  This is used to update invoices and assign it
    #a coupon if desired, etc.
    #When this is called, it must FIRST check the following and fail if so:
    #1) if coupon has exceeded the maximum number of usage times
    #2) if coupon is presently not active (status = false)

    #Find specified invoice (exception handling should take care of issues here)
    merchant = Merchant.find(params[:merchant_id])
    invoice = merchant.invoices.find(params[:id])

    #Query param of 'coupon_id=<number>' will attempt to assign it to a coupon
    if params[:coupon_id]
      #Is coupon_id even valid? (exception handling for this)
      specified_coupon = merchant.coupons.find(params[:coupon_id])

      if specified_coupon.times_used >= Coupon::MAX_TIMES_USABLE
        error_text = "Cannot use coupon 'id'=#{specified_coupon.id}, as it has been used the maximum number of times"
        # render json: ErrorSerializer.illegal_operation("Cannot use coupon 'id'=#{specified_coupon.id}, as it has been used the max number of times"), status: :unprocessable_entity
        # return
      elsif specified_coupon.status == false
        error_text = "Coupon with 'id'=#{specified_coupon.id} is presently inactive.  Must set to active before it is usable"
      else
        #We're good, update the invoice here and render JSON
        updated_invoice = Invoice.update!(params[:id], invoice_params_update)
        render json: InvoiceSerializer.new(updated_invoice)
        return
      end

      #Error, render it
      render json: ErrorSerializer.illegal_operation(error_text), status: :unprocessable_entity

    end
  end

  private

  def invoice_params_update
    #Changing merchant or customer would be equivalent to invaliding the invoice
    params.permit(:status, :coupon_id)
  end
end