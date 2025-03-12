class Api::V1::Merchants::CouponsController < ApplicationController
  #Handles coupon related queries belonging to a merchant (hence the namespace)
  rescue_from ActiveRecord::RecordNotFound, with: :coupon_not_found

  def index
    merchant = Merchant.find(params[:merchant_id])

    if params[:filter_status] == "active"
      merchant_coupons = merchant.get_coupons_by_status(true)
    elsif params[:filter_status] == "inactive"
      merchant_coupons = merchant.get_coupons_by_status(false)
    else
      merchant_coupons = merchant.coupons
    end

    render json: CouponSerializer.new(merchant_coupons)
  end

  def show
    specified_coupon = Merchant.find(params[:merchant_id]).coupons.find(params[:id])
    render json: CouponSerializer.new(specified_coupon, { params: { display_count: true } })
  end

  def create
    if !Coupon.verify_unique_code(params[:code]) || params[:code] == ""
      error_message = "Code '#{params[:code]}' already exists in database; you must create a unique code. Suggested code: '#{Coupon.generate_unique_code}'"
      render json: ErrorSerializer.illegal_operation(error_message), status: :unprocessable_entity
      return
    end

    if !params[:name] || params[:name] == ""
      render json: ErrorSerializer.search_parameters_error("You must provide a non-empty 'name' string"), status: :unprocessable_entity
      return
    end

    #Check that discount_value XOR discount_percentage is provided
    #This is my attempt at creating a proper XOR operator here (coerce values to boolean, then usual logical XOR)
    if !(!!params[:discount_value] ^ !!params[:discount_percentage])
      render json: ErrorSerializer.search_parameters_error("You must set either 'discount_value' or 'discount_percentage' (exclusive) to null"), status: :unprocessable_entity
      return
    end

    merchant = Merchant.find(params[:merchant_id])

    if params[:status] == true && merchant.find_number_active_coupons >= 5
      render json: ErrorSerializer.illegal_operation("Operation failed; attempted to set > 5 active coupons for merchant 'id'=#{merchant.id}"), status: :unprocessable_entity
    else
      #It is necessary to create the coupon via the merchant, or validation / other indirect errors occur (that was 'fun' to troubleshoot)
      new_coupon = Merchant.find(params[:merchant_id]).coupons.create!(coupon_params_create)

      render json: CouponSerializer.new(new_coupon), status: :created
    end
  end

  def update
    if params[:status]
      coupon = Coupon.find(params[:id])

      if params[:status] == "active" && coupon.status == false
        if coupon.merchant.find_number_active_coupons >= 5
          render json: ErrorSerializer.illegal_operation("Operation failed; attempted to set > 5 active coupons for merchant 'id'=#{coupon.merchant.id}"), status: :unprocessable_entity
        else
          #Activate it!
          params[:status] = true
          updated_coupon = Coupon.update!(params[:id], coupon_params_update)
          render json: CouponSerializer.new(updated_coupon)
        end
      elsif params[:status] == "inactive" && coupon.status == true
        if coupon.pending_invoices?
          render json: ErrorSerializer.illegal_operation("Operation failed; attemped to deactivate coupon being used on unprocessed invoice.  Please wait until invoice is complete"), status: :unprocessable_entity
        else
          #Deactivate it!
          params[:status] = false
          updated_coupon = Coupon.update!(params[:id], coupon_params_update)
          render json: CouponSerializer.new(updated_coupon)
        end
      else
        #Either nothing was changed, or got a bad input string here, generate an appropriate error
        render json: ErrorSerializer.search_parameters_error("Either parameter not specified correctly (status=active/inactive), or active status already set as requested"), status: :unprocessable_entity
      end
    end
  end

  private

  def coupon_params_create
    params.require(:coupon).permit(:name, :code, :status, :discount_value, :discount_percentage, :merchant_id)
  end
  
  def coupon_params_update
    #Only allow changing of 'status' and 'name' - I feel anything more changes the identity of the coupon (can't do a bait-and-switch, for example!)
    params.permit(:status, :name)
  end

  def coupon_not_found(exception)
    render json: ErrorSerializer.handle_exception(exception, "Coupon not found"), status: :not_found
  end

end