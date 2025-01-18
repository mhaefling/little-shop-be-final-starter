class Api::V1::CouponsController < ApplicationController
  def show
    coupon = Coupon.find(params[:id])
    meta_data = {}
    meta_data[:meta] = { usage_count: Coupon.invoice_coupon_count(coupon) }
    render json: CouponSerializer.new(coupon, meta_data), status: :ok
  end

  def update
    coupon = Coupon.find(params[:id])

    if params[:status].present?
      case params[:status]
      when "inactive"
        if Coupon.coupons_with_packaged_invoices(coupon) > 0
          render json: { error: "Unable to Deactivate coupon with pending 'packaged' Invoices" }, status: :forbidden
        else
          coupon.update(status: params[:status])
          coupon.save
          render json: CouponSerializer.new(coupon), status: :ok
        end
      when 'active'
        merchant = Merchant.find(coupon.merchant_id)
        if Coupon.active_coupon_count(merchant) >= 5
          render json: { error: "This merchant already has five active coupons"}, status: :forbidden
        else 
          coupon.update(status: params[:status])
          coupon.save
          render json: CouponSerializer.new(coupon), status: :ok
        end
      end
    else
        render json: { error: "Changing a coupons status requires status request active / inactive"}, status: :bad_request
    end
  end
end