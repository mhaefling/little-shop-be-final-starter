class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name

  attribute :item_count, if: Proc.new { |merchant, params|
    params && params[:count] == true
  } do |merchant|
    merchant.item_count
  end

  attribute :coupon_count, if: Proc.new { |merchant, params|
  params && params[:coupon] == false
} do |merchant|
  Coupon.coupons_by_merchant(merchant).count
  end

  attribute :invoice_coupon_count, if: Proc.new { |merchant, params|
  params && params[:coupon] == false
} do |merchant|
  Merchant.invoices_by_merchant_with_coupons(merchant)
  end

end
