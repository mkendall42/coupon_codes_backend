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

    #Will need a new serializer for this
    render json: CouponSerializer.new(merchant_coupons)

  end

  def show
    specified_coupon = Merchant.find(params[:merchant_id]).coupons.find(params[:id])
    render json: CouponSerializer.new(specified_coupon, { params: { display_count: true } })
  end

  def create
    if !Coupon.verify_unique_code(params[:code])
      render json: { data: "You must specify a unique code" }, status: :unprocessable_entity
      #Fancier: could return a suggestion for a unique code in the JSON response...
      return
    end

    #Check that discount_value XOR discount_percentage is provided
    #This is my attempt at creating a proper XOR operator here (coerce to boolean, then usual logical XOR)
    if !(!!params[:discount_value] ^ !!params[:discount_percentage])
      render json: { data: "Ya can't set neither nor both value and percentage at once, fool!"}, status: :unprocessable_entity
      return
    end

    merchant = Merchant.find(params[:merchant_id])

    if params[:status] == true && merchant.find_number_active_coupons >= 5
      render json: { data: "Houston, we have a problem" }, status: :unprocessable_entity
    else
      #Necessary to create the coupon via the merchant, or validation / other indirect errors occur (that was 'fun' to troubleshoot)
      new_coupon = Merchant.find(params[:merchant_id]).coupons.create!(coupon_params_create)

      render json: CouponSerializer.new(new_coupon), status: :created
    end
  end

  def update
    if params[:status]
      coupon = Coupon.find(params[:id])
      # coupon.set_status(params[:status])

      if params[:status] == "active" && coupon.status == false
        if coupon.merchant.find_number_active_coupons >= 5
          render json: { data: "too many active already yo" }, status: :unprocessable_entity
        else
          #Activate it!
          params[:status] = true
          updated_coupon = Coupon.update!(params[:id], coupon_params_update)
          render json: { data: "Coupon activated" }
        end
      elsif params[:status] == "inactive" && coupon.status == true
        if coupon.pending_invoices?
          render json: { data: "Ya can't deactivate it 'til it's processed, man!" }, status: :unprocessable_entity
        else
          #Deactivate it!
          params[:status] = false
          updated_coupon = Coupon.update!(params[:id], coupon_params_update)
          render json: { data: "Coupon deactivated" }
        end
      else
        #Either nothing was changed, or got a bad input string here, generate an appropriate error
        render json: { data: "uh oh, hit the else" }, status: 404
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

  #Later: refactor into main class (esp since this repeats MerchantController exactly)
  def coupon_not_found(exception)
    render json: ErrorSerializer.handle_exception(exception, "Coupon not found"), status: :not_found
  end

end