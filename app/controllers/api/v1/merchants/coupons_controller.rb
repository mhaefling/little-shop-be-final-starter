class Api::V1::Merchants::CouponsController < ApplicationController
  def index
    merchant = Merchant.find(params[:id])

    if params[:status].present?
      case params[:status]
      when "active"
        meta_data = {}
        meta_data[:meta] = { active_coupons: Coupon.active_coupons(merchant).count }
        render json: CouponSerializer.new(Coupon.active_coupons(merchant), meta_data), status: :ok
      
      when "inactive"
        meta_data = {}
        meta_data[:meta] = { inactive_coupons: Coupon.inactive_coupons(merchant).count }
        render json: CouponSerializer.new(Coupon.inactive_coupons(merchant), meta_data), status: :ok
      end

    else
      meta_data = {}
      meta_data[:meta] = { active_coupons: Coupon.active_coupons(merchant).count, inactive_coupons: Coupon.inactive_coupons(merchant).count }
      render json: CouponSerializer.new(Coupon.coupons_by_merchant(merchant), meta_data), status: :ok
    end
  end

  def create
    merchant = Merchant.find(params[:id])
    new_coupon = Coupon.new(coupon_params)

    if Coupon.active_coupons(merchant).count >= 5
      new_coupon.destroy
      render json: { error: "This merchant already has five active coupons" }, status: :forbidden

    elsif new_coupon.merchant_id.to_s != params[:id]
      new_coupon.destroy
      render json: { error: "Coupons merchant_id, doesn't match the provided merchant" }, status: :bad_request

    else
      new_coupon.save
      render json: CouponSerializer.new(new_coupon), status: :created
    end
  end

  private
  def coupon_params
    params.permit(:name, :code, :dollar_off, :percent_off, :status, :merchant_id)
  end
end