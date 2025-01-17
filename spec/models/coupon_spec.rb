require "rails_helper"

RSpec.describe Coupon, type: :model do
  describe "relationships" do
    it { should belong_to :merchant }
    it { should have_many :invoices }
  end

  describe "data validations" do
    it "Has valid attributes" do
      merchant = Merchant.create(name: "Matt's Taco World")
      new_coupon = Coupon.create(name: '10% Off Next Taco', code: '10PONRP', dollar_off: nil, percent_off: 10, status: 'active', merchant_id: merchant.id)

      expect(new_coupon).to be_valid
    end

    it "invalid when missing name attribute" do
      merchant = Merchant.create(name: "Matt's Taco World")
      new_coupon = Coupon.create(code: '10PONRP', dollar_off: nil, percent_off: 10, status: 'active', merchant_id: merchant.id)

      expect(new_coupon).to_not be_valid
    end

    it "invalid when missing code attribute" do
      merchant = Merchant.create(name: "Matt's Taco World")
      new_coupon = Coupon.create(name: '10% Off Next Taco', dollar_off: nil, percent_off: 10, status: 'active', merchant_id: merchant.id)
      
      expect(new_coupon).to_not be_valid
    end

    it "invalid if percent_off value not an integer" do
      merchant = Merchant.create(name: "Matt's Taco World")
      new_coupon = Coupon.create(name: '10% Off Next Taco', code: '10PONRP', dollar_off: nil, percent_off: 10.0, status: 'active', merchant_id: merchant.id)

      expect(new_coupon).to_not be_valid
    end

    it "valid when missing or nil percent_off attribute" do
      merchant = Merchant.create(name: "Matt's Taco World")
      new_coupon = Coupon.create(name: '10% Off Next Taco', code: '10PONRP', dollar_off: 10, status: 'active', merchant_id: merchant.id)
    
      expect(new_coupon).to be_valid
    end

    it "valid when missing or nil dollar_off attribute" do
      merchant = Merchant.create(name: "Matt's Taco World")
      new_coupon = Coupon.create(name: '10% Off Next Taco', code: '10PONRP', percent_off: 10, status: 'active', merchant_id: merchant.id)
      
      expect(new_coupon).to be_valid
    end

    it "confirms dollar_off value requires float datatype" do
      merchant = Merchant.create(name: "Matt's Taco World")
      new_coupon = Coupon.create(name: '10% Off Next Taco', code: '10PONRP', dollar_off: 10, percent_off: nil, status: 'active', merchant_id: merchant.id)

      expect(new_coupon).to be_valid
      expect(new_coupon[:dollar_off]).to be_a(Float)
    end

    it "invalid when missing status attribute" do
      merchant = Merchant.create(name: "Matt's Taco World")
      new_coupon = Coupon.create(name: '10% Off Next Taco', code: '10PONRP', dollar_off: 10, percent_off: nil, merchant_id: merchant.id)
    
      expect(new_coupon).to_not be_valid
    end

    it "invalid when status is not active or inactive" do
      merchant = Merchant.create(name: "Matt's Taco World")
      new_coupon = Coupon.create(name: '10% Off Next Taco', code: '10PONRP', dollar_off: 10, percent_off: nil, status: 'Deactive', merchant_id: merchant.id)
    
      expect(new_coupon).to_not be_valid
    end

    it "invalid when missing merchant_id attribute" do
      merchant = Merchant.create(name: "Matt's Taco World")
      new_coupon = Coupon.create(name: '10% Off Next Taco', code: '10PONRP', dollar_off: 10, percent_off: nil, status: 'active')
    
      expect(new_coupon).to_not be_valid
    end

    it "invalid if dollar_off and percent_off are missing values" do
      merchant = Merchant.create(name: "Matt's Taco World")
      new_coupon = Coupon.create(name: '10% Off Next Taco', code: '10PONRP', dollar_off: 10, percent_off: 10, status: 'active', merchant_id: merchant.id)
    
      expect(new_coupon).to_not be_valid
    end
  end

  describe "class methods" do
    it 'confirms the amount of invoices a coupon has been used on' do
      merchant = create(:merchant)
      customer = create(:customer)
      coupon = create(:coupon, name: '50% Off Next Repair', code: '50PONRP', dollar_off: nil, percent_off: 50, status: 'active', merchant_id: merchant.id)
      invoice1 = Invoice.create!(customer_id: customer.id, merchant_id: merchant.id, status: 'shipped', coupon_id: coupon.id)
      invoice2 = Invoice.create!(customer_id: customer.id, merchant_id: merchant.id, status: 'shipped', coupon_id: coupon.id)
      invoice3 = Invoice.create!(customer_id: customer.id, merchant_id: merchant.id, status: 'shipped', coupon_id: coupon.id)
      
      expect(Coupon.invoice_coupon_count(coupon)).to eq(3)
    end

    it 'finds coupons by merchant id' do
      merchants = create_list(:merchant, 2)

      coupon = create(:coupon, name: '50% Off Next Repair', code: '50PONRP', dollar_off: nil, percent_off: 50, status: 'active', merchant_id: merchants[0].id)
      coupon = create(:coupon, name: '10% Off Next Repair', code: '10PONRP', dollar_off: nil, percent_off: 10, status: 'inactive', merchant_id: merchants[0].id)
      coupon = create(:coupon, name: '10 Dollars Off', code: '10DO', dollar_off: 10.0, percent_off: nil, status: 'active', merchant_id: merchants[1].id)

      expect(Coupon.coupons_by_merchant(merchants[0]).count).to eq(2)
      expect(Coupon.coupons_by_merchant(merchants[1]).count).to eq(1)
    end
  end
end