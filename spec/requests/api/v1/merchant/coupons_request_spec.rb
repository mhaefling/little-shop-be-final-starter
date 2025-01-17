require "rails_helper"

RSpec.describe "Coupons endpoints", :type => :request do
  before(:each) do
    @merchants = create_list(:merchant, 3)

    @customers = create_list(:customer, 3)
    
    @coupon1 = create(:coupon, name: '50% Off Next Repair', code: '50PONRP', dollar_off: nil, percent_off: 50, status: 'active', merchant_id: @merchants[0].id)
    @coupon2 = create(:coupon, name: '10% Off Next Repair', code: '10PONRP', dollar_off: nil, percent_off: 10, status: 'active', merchant_id: @merchants[0].id)
    @coupon3 = create(:coupon, name: '15% off lentil tacos', code: '15PLT', dollar_off: nil, percent_off: 15, status: 'active', merchant_id: @merchants[1].id)
    @coupon4 = create(:coupon, name: '5 Dollars Off Sweet Tea', code: '5DOFF', dollar_off: 5.0, percent_off: nil, status: 'inactive', merchant_id: @merchants[1].id)
    @coupon5 = create(:coupon, name: '20% Off Second Necklace', code: '20P2NDNL', dollar_off: nil, percent_off: 20, status: 'active', merchant_id: @merchants[2].id)
    @coupon6 = create(:coupon, name: '10 Dollars Off Any Bracelet', code: '10DOB', dollar_off: 10, percent_off: nil, status: 'active', merchant_id: @merchants[2].id)
  end

  describe 'Coupons by Merchant ID' do
    it 'return all coupons for a given merchant' do
      get "/api/v1/merchants/#{@merchants[2].id}/coupons"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      coupons = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(coupons).to be_a(Array)
      expect(coupons.count).to eq(2)

      expect(coupons[0][:id]).to eq(@coupon5.id.to_s)
      expect(coupons[1][:id]).to eq(@coupon6.id.to_s)
    end
  end

  describe 'SAD PATH: GET /api/v1/merchants/:merchant_id/coupons' do
    it "should return 404 and error message when merchant is not found" do
      get "/api/v1/merchants/100000/coupons"
  
      json = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to_not be_successful
      expect(response.status).to eq(404)
    end
  end
end