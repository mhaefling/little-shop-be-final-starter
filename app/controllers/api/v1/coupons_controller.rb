class Api::V1::CouponsController < ApplicationController
  def show
    coupon = Coupon.find(params[:id])
    meta_data = {}
    meta_data[:meta] = { usage_count: Coupon.coupon_invoice_count(coupon) }
    render json: CouponSerializer.new(coupon, meta_data), status: :ok
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    new_coupon = Coupon.new(coupon_params)

    if Coupon.coupons_by_status(merchant, 'active').count >= 5
      new_coupon.destroy
      raise ActionController::ActionControllerError, "Merchants can only have 5 active coupons, please deactivate one and try again."
    
    elsif new_coupon.save
      render json: CouponSerializer.new(new_coupon), status: :created

    else
      raise ActiveRecord::RecordInvalid.new(new_coupon)
    end
  end

  def update
    coupon = Coupon.find(params[:id])

    case coupon_params[:status]
    when "inactive"
      if Coupon.coupons_with_packaged_invoices(coupon) > 0
        raise ActionController::ActionControllerError, "Unable to Deactivate coupon with pending 'packaged' Invoices"

      else
        coupon.update(coupon_params)
        coupon.save
        render json: CouponSerializer.new(coupon), status: :ok
      end
    when 'active'
      merchant = Merchant.find(coupon.merchant_id)
      if Coupon.coupons_by_status(merchant, 'active').count >= 5
        raise ActionController::ActionControllerError, "Merchants can only have 5 active coupons, please deactivate one and try again."
      else 
        coupon.update(coupon_params)
        coupon.save
        render json: CouponSerializer.new(coupon), status: :ok
      end
    else
      raise ActionController::ActionControllerError, "Status must be 'active' or 'inactive', please correct and try again."
    end
  end

  private
  def coupon_params
    params.permit(:name, :code, :dollar_off, :percent_off, :status, :merchant_id)
  end
end