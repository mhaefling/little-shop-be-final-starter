class InvoiceSerializer
  include JSONAPI::Serializer
  attributes :customer_id, :merchant_id

  attribute :coupon_id do |invoice|
    invoice.coupon_id
  end

  attribute :status
end