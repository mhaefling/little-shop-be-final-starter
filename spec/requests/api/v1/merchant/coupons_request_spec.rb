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
    @coupon7 = create(:coupon, name: 'The Word', code: 'NO', dollar_off: nil, percent_off: 50, status: 'active', merchant_id: @merchants[0].id)
    @coupon8 = create(:coupon, name: 'Coupon has', code: 'MORE', dollar_off: nil, percent_off: 10, status: 'active', merchant_id: @merchants[0].id)
    @coupon9 = create(:coupon, name: 'Lost all meaning', code: 'COUPONS', dollar_off: nil, percent_off: 50, status: 'active', merchant_id: @merchants[0].id)
    @coupon10 = create(:coupon, name: 'neverendingcoupons', code: 'THEYNEVEREND', dollar_off: nil, percent_off: 50, status: 'inactive', merchant_id: @merchants[0].id)
    @coupon11 = create(:coupon, name: 'we like all the coupons', code: 'COLLECTTHEMALL', dollar_off: nil, percent_off: 10, status: 'inactive', merchant_id: @merchants[0].id)
  end

  describe 'HAPPY PATH: GET /api/v1/merchants/:merchant_id/coupons' do
    it 'return all coupons for a given merchant ID' do
      get "/api/v1/merchants/#{@merchants[2].id}/coupons"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      coupons_data = JSON.parse(response.body, symbolize_names: true)[:data]
      coupons_meta = JSON.parse(response.body, symbolize_names: true)[:meta]


      expect(coupons_data).to be_a(Array)
      expect(coupons_data.count).to eq(2)
      expect(coupons_meta).to be_a(Hash)

      expect(coupons_data[0][:id]).to eq(@coupon5.id.to_s)
      expect(coupons_data[1][:id]).to eq(@coupon6.id.to_s)

      expect(coupons_meta[:active_coupons]).to eq(2)
      expect(coupons_meta[:inactive_coupons]).to eq(0)
    end

    it 'return filtered coupons for a given merchant id "active"' do
      get "/api/v1/merchants/#{@merchants[0].id}/coupons?status=active"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      coupons_data = JSON.parse(response.body, symbolize_names: true)[:data]
      coupons_meta = JSON.parse(response.body, symbolize_names: true)[:meta]

      expect(coupons_data).to be_a(Array)
      expect(coupons_data.count).to eq(5)
      expect(coupons_meta).to be_a(Hash)

      expect(coupons_data[0][:id]).to eq(@coupon1.id.to_s)
      expect(coupons_data[1][:id]).to eq(@coupon2.id.to_s)
      expect(coupons_data[2][:id]).to eq(@coupon7.id.to_s)
      expect(coupons_data[3][:id]).to eq(@coupon8.id.to_s)
      expect(coupons_data[4][:id]).to eq(@coupon9.id.to_s)

      expect(coupons_meta[:count]).to eq(5)
    end

    it 'returns filtered coupons for a given merchant "inactive"' do
      get "/api/v1/merchants/#{@merchants[0].id}/coupons?status=inactive"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      coupons_data = JSON.parse(response.body, symbolize_names: true)[:data]
      coupons_meta = JSON.parse(response.body, symbolize_names: true)[:meta]

      expect(coupons_data).to be_a(Array)
      expect(coupons_data.count).to eq(2)
      expect(coupons_meta).to be_a(Hash)

      expect(coupons_data[0][:id]).to eq(@coupon10.id.to_s)
      expect(coupons_data[1][:id]).to eq(@coupon11.id.to_s)

      expect(coupons_meta[:count]).to eq(2)
    end
  end

  describe 'SAD PATH: GET /api/v1/merchants/:merchant_id/coupons' do
    it "return 404 and error message when merchant is not found" do
      get "/api/v1/merchants/100000/coupons"
  
      JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to_not be_successful
      expect(response.status).to eq(404)
    end
  end
end