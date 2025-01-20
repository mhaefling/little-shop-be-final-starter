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

    if Coupon.active_coupons(merchant).count >= 5
      new_coupon.destroy
      render json: { error: "This merchant already has five active coupons" }, status: :forbidden

    else
      new_coupon.save
      render json: CouponSerializer.new(new_coupon), status: :created
    end
  end

  def update
    coupon = Coupon.find(params[:id])

    case coupon_params[:status]
    when "inactive"
      if Coupon.coupons_with_packaged_invoices(coupon) > 0
        render json: { error: "Unable to Deactivate coupon with pending 'packaged' Invoices" }, status: :forbidden
      else
        coupon.update(coupon_params)
        coupon.save
        render json: CouponSerializer.new(coupon), status: :ok
      end
    when 'active'
      merchant = Merchant.find(coupon.merchant_id)
      if Coupon.active_coupons(merchant).count >= 5
        render json: { error: "This merchant already has five active coupons"}, status: :forbidden
      else 
        coupon.update(coupon_params)
        coupon.save
        render json: CouponSerializer.new(coupon), status: :ok
      end
    else
      render json: { error: "'status:' attribute must have value 'active' or 'inactive'" }, status: :bad_request
    end
  end

  private
  def coupon_params
    params.permit(:name, :code, :dollar_off, :percent_off, :status, :merchant_id)
  end
end