class Api::V1::CouponsController < ApplicationController
  def show
    coupon = Coupon.find(params[:id])
    meta_data = {}
    meta_data[:meta] = { usage_count: Coupon.invoice_coupon_count(coupon) }
    render json: CouponSerializer.new(coupon, meta_data), status: :ok
  end

  def update
    coupon = Coupon.find(params[:id])
    if Coupon.coupons_with_packaged_invoices(coupon) > 0
      render json: { error: "Unable to Deactivate coupon with pending 'packaged' Invoices" }, status: :forbidden
    else
      coupon.update(coupon_params)
      coupon.save
      render json: CouponSerializer.new(coupon), status: :ok
    end
  end

  private

  def coupon_params
    params.permit(:name, :code, :dollar_off, :percent_off, :status, :merchant_id)
  end

end