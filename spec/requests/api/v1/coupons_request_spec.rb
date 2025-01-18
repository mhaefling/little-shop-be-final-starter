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
    @coupon7 = create(:coupon, name: '1000 Dollars off', code: '100kOFF', dollar_off: 1000, percent_off: nil, status: 'active', merchant_id: @merchants[0].id)
    @coupon8 = create(:coupon, name: '1 Penny Off', code: 'PENNYFORYOURTRUBLE', dollar_off: 0.1, percent_off: nil, status: 'active', merchant_id: @merchants[0].id)
    @coupon9 = create(:coupon, name: '2 dollar make you hollar', code: '2DHOLLA', dollar_off: 2.0, percent_off: nil, status: 'active', merchant_id: @merchants[0].id)
    @coupon10 = create(:coupon, name: '2 For 1', code: '2F1', dollar_off: 2.0, percent_off: nil, status: 'inactive', merchant_id: @merchants[0].id)



    @invoice1 = create(:invoice, customer_id: @customers[0].id, merchant_id: @merchants[0].id, status: 'shipped', coupon_id: @coupon1.id)
    @invoice2 = create(:invoice, customer_id: @customers[0].id, merchant_id: @merchants[0].id, status: 'shipped', coupon_id: @coupon2.id)
    @invoice3 = create(:invoice, customer_id: @customers[1].id, merchant_id: @merchants[1].id, status: 'shipped', coupon_id: @coupon3.id)
    @invoice4 = create(:invoice, customer_id: @customers[2].id, merchant_id: @merchants[2].id, status: 'shipped', coupon_id: @coupon6.id)
    @invoice5 = create(:invoice, customer_id: @customers[2].id, merchant_id: @merchants[2].id, status: 'shipped', coupon_id: @coupon6.id)
    @invoice6 = create(:invoice, customer_id: @customers[2].id, merchant_id: @merchants[2].id, status: 'shipped', coupon_id: @coupon6.id)
    @invoice7 = create(:invoice, customer_id: @customers[2].id, merchant_id: @merchants[2].id, status: 'packaged', coupon_id: @coupon6.id)
  end

  describe 'JSON Response Structure' do
    it 'Confirms the correct data types of a coupon' do
      get "/api/v1/coupons/#{@coupon6.id}"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      coupon = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(coupon[:id]).to be_a(String)
      expect(coupon[:type]).to be_a(String)
      expect(coupon[:type]).to eq('coupon')

      expect(coupon[:attributes][:name]).to be_a(String)
      expect(coupon[:attributes][:code]).to be_a(String)
      expect(coupon[:attributes][:dollar_off]).to be_a(Float).or eq(nil)
      expect(coupon[:attributes][:percent_off]).to be_a(Integer).or eq(nil)
      expect(coupon[:attributes][:status]).to be_a(String)
      expect(coupon[:attributes][:status]).to eq('active').or eq('inactive')
      expect(coupon[:attributes][:merchant_id]).to be_a(Integer)
    end
  end

  describe 'GET /api/v1/coupons/:id' do
    it 'Confirms correct coupon w/ usage_count attribute on JSON response.' do
      get "/api/v1/coupons/#{@coupon6.id}"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      coupon_data = JSON.parse(response.body, symbolize_names: true)[:data]
      coupon_meta = JSON.parse(response.body, symbolize_names: true)[:meta]

      expect(coupon_data[:id].to_i).to eq(@coupon6.id)
      expect(coupon_data[:type]).to eq('coupon')

      expect(coupon_data[:attributes][:name]).to eq(@coupon6.name)
      expect(coupon_data[:attributes][:code]).to eq(@coupon6.code)
      expect(coupon_data[:attributes][:dollar_off]).to eq(@coupon6.dollar_off)
      expect(coupon_data[:attributes][:percent_off]).to eq(@coupon6.percent_off)
      expect(coupon_data[:attributes][:status]).to eq(@coupon6.status)
      expect(coupon_data[:attributes][:merchant_id]).to eq(@coupon6.merchant_id)

      expect(coupon_meta[:usage_count]).to eq(4)

    end
  end

  describe 'SAD PATH: GET /api/v1/coupons/:id' do
    it 'Returns 404 Error when provided invalid coupon ID' do
      get "/api/v1/coupons/133713371337"

      expect(response).to_not be_successful
      expect(response.status).to eq(404)
    end
  end

  describe 'PATCH /api/v1/coupons/:id?status=' do
    it 'changes a coupons status from active to inactive' do

      expect(@coupon1.status).to eq('active')

      patch "/api/v1/coupons/#{@coupon1.id}?status=inactive"

      coupon = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response).to be_successful
      expect(response.status).to eq(200)

      expect(coupon[:attributes][:status]).to eq('inactive')
    end

    it 'changes a coupons status from inactive to active' do
      
      expect(@coupon4.status).to eq('inactive')

      patch "/api/v1/coupons/#{@coupon4.id}?status=active"

      coupon = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response).to be_successful
      expect(response.status).to eq(200)

      expect(coupon[:attributes][:status]).to eq('active')
    end
  end

  describe 'SAD PATH: PATCH /api/v1/coupons/:id?status=' do
    it 'confirms coupons with pending "packaged" invoices can not be deactivated' do

      expect(@coupon6.status).to eq('active')

      patch "/api/v1/coupons/#{@coupon6.id}?status=inactive"
      JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(response.status).to eq(403)
      expect(@coupon6.status).to eq('active')
    end

    it 'confirms existing coupons cannot change from inactive to active if their merchant already has 5 active coupons' do
      
      expect(@coupon10.status).to eq('inactive')

      patch "/api/v1/coupons/#{@coupon10.id}?status=active"
      JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(response.status).to eq(403)
    end

    it 'errors if no value is provided in the status param' do
      patch "/api/v1/coupons/#{@coupon10.id}?status="
      JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(response.status).to eq(400)
    end
  end
end