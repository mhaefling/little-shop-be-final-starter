class Api::V1::Merchants::CouponsController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    render json: CouponSerializer.new(Coupon.coupons_by_merchant(merchant))
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    if Coupon.active_coupon_count(merchant) >= 5
      render json: { error: "This merchant already has five active coupons" }, status: :forbidden
    else
      new_coupon = Coupon.create!(coupon_params)
      render json: CouponSerializer.new(new_coupon), status: :created
    end
  end
end

private

def coupon_params
  params.permit(:name, :code, :dollar_off, :percent_off, :status, :merchant_id)
end