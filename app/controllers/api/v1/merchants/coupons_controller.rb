class Api::V1::Merchants::CouponsController < ApplicationController
  def index
    merchant = Merchant.find(params[:id])

    if params[:status].present? && params[:status] == 'active' || params[:status] == 'inactive'
      meta_data = {}
      meta_data[:meta] = { count: Coupon.coupons_by_status(merchant, params[:status]).count }
      render json: CouponSerializer.new(Coupon.coupons_by_status(merchant, params[:status]), meta_data), status: :ok

    else
      meta_data = {}
      meta_data[:meta] = { active_coupons: Coupon.coupons_by_status(merchant, 'active').count, inactive_coupons: Coupon.coupons_by_status(merchant, 'inactive').count }
      render json: CouponSerializer.new(Coupon.coupons_by_merchant(merchant), meta_data), status: :ok
    end
  end
end