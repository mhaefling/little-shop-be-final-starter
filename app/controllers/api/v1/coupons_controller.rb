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
      render json: { message: 'This merchant already has five active coupons', errors: [
        {
          status: '403',
          detail: 'Please deactivate an active coupon first.'
        }
      ]}, status: :forbidden
    
    elsif new_coupon.save == false
      render json: { message: new_coupon.errors.full_messages[0], errors: [
        { 
          status: '403',
          detail: 'Another coupon already exists with this name, or coupon code.'
        }
      ]}, status: :forbidden
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
      if Coupon.coupons_by_status(merchant, 'active').count >= 5
        render json: { message: 'This merchant already has five active coupons', errors: [
          {
            status: '403',
            detail: 'Please deactivate an active coupon first.'
          }
        ]}, status: :forbidden
      else 
        coupon.update(coupon_params)
        coupon.save
        render json: CouponSerializer.new(coupon), status: :ok
      end
    else
      render json: { message: "'status:' attribute must have value 'active' or 'inactive'", errors: [
        {
          status: '400',
          detail: 'Coupons can only be a status of active or inactive'
        }
      ]}, status: :bad_request
    end
  end

  private
  def coupon_params
    params.permit(:name, :code, :dollar_off, :percent_off, :status, :merchant_id)
  end
end