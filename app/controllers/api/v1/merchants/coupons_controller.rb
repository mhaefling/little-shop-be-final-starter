class Api::V1::Merchants::CouponsController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    render json: CouponSerializer.new(Coupon.coupons_by_merchant(merchant))
  end
end