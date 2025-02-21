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

  describe 'HAPPY PATH: GET /api/v1/coupons/:id' do
    it 'returns the requested coupon with a usage_count attribute' do
      get "/api/v1/coupons/#{@coupon6.id}"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      coupon_data = JSON.parse(response.body, symbolize_names: true)[:data]
      coupon_attribs = JSON.parse(response.body, symbolize_names: true)[:data][:attributes]
      coupon_meta = JSON.parse(response.body, symbolize_names: true)[:meta]

      expect(coupon_data[:id].to_i).to eq(@coupon6.id)
      expect(coupon_data[:type]).to eq('coupon')

      expect(coupon_attribs[:name]).to eq(@coupon6.name)
      expect(coupon_attribs[:code]).to eq(@coupon6.code)
      expect(coupon_attribs[:dollar_off]).to eq(@coupon6.dollar_off)
      expect(coupon_attribs[:percent_off]).to eq(@coupon6.percent_off)
      expect(coupon_attribs[:status]).to eq(@coupon6.status)
      expect(coupon_attribs[:merchant_id]).to eq(@coupon6.merchant_id)

      expect(coupon_meta[:usage_count]).to eq(4)

    end
  end

  describe 'SAD PATH: GET /api/v1/coupons/:id' do
    it 'RETURNS 404 not found when requested coupon_id doesnt exist' do
      get "/api/v1/coupons/133713371337"

      error = JSON.parse(response.body, symbolize_names: true)
      expect(response).to_not be_successful
      expect(response.status).to eq(404)

      expect(error[:message]).to eq('Your request could not be completed, please read the details below.')
      expect(error[:errors][0][:status]).to eq("404")
      expect(error[:errors][0][:detail]).to eq("Couldn't find Coupon with 'id'=133713371337")
    end
  end

  describe 'HAPPTY PATH: POST /api/v1/coupons' do
    it 'creates new coupons for a given Merchant' do
      name = "Testing Coupon1"
      code = "TESTING123"
      dollar_off = nil
      percent_off = 20
      status = 'active'

      body = {
        name: name,
        code: code,
        dollar_off: dollar_off,
        percent_off: percent_off,
        status: status,
        merchant_id: @merchants[2].id
      }

      post "/api/v1/coupons", params: body, as: :json
      new_coupon = JSON.parse(response.body, symbolize_names: true) [:data]


      expect(response).to be_successful
      expect(response.status).to eq(201)

      expect(new_coupon[:type]).to eq('coupon')
      expect(new_coupon[:attributes][:name]).to eq(name)
      expect(new_coupon[:attributes][:code]).to eq(code)
      expect(new_coupon[:attributes][:dollar_off]).to eq(dollar_off)
      expect(new_coupon[:attributes][:percent_off]).to eq(percent_off)
      expect(new_coupon[:attributes][:status]).to eq(status)
      expect(new_coupon[:attributes][:merchant_id]).to eq(@merchants[2].id)
    end
  end

  describe 'SAD PATH: POST /api/v1/coupons' do
    it 'return 403 when a Merchant already has 5 active coupons' do
      name = "To many coupons"
      code = "FAILEDCOUPON"
      dollar_off = nil
      percent_off = 20
      status = 'active'

      body = {
        name: name,
        code: code,
        dollar_off: dollar_off,
        percent_off: percent_off,
        status: status,
        merchant_id: @merchants[0].id
      }

      post "/api/v1/coupons", params: body, as: :json
      error = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(response.status).to eq(403)

      expect(error[:message]).to eq("This actiion is forbidden, please read the details below.")
      expect(error[:errors][0][:status]).to eq("403")
      expect(error[:errors][0][:detail]).to eq("Merchants can only have 5 active coupons, please deactivate one and try again.")
    end

    it 'returns 422 request invalid, if coupon with same name or code already exists in the db' do
      name = "15% off lentil tacos"
      code = "FAILEDCOUPON"
      dollar_off = nil
      percent_off = 20
      status = 'active'

      body = {
        name: name,
        code: code,
        dollar_off: dollar_off,
        percent_off: percent_off,
        status: status,
        merchant_id: @merchants[1].id
      }

      post "/api/v1/coupons", params: body, as: :json
      error = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(response.status).to eq(422)

      expect(error[:message]).to eq("Your request could not be completed, please read the details below.")
      expect(error[:errors][0][:status]).to eq("422")
      expect(error[:errors][0][:detail]).to eq("Validation failed: Name has already been taken")
    end

    it 'retruns error 422 if dollar_off or percent_off are both nill' do
      name = "To many coupons"
      code = "FAILEDCOUPON"
      dollar_off = nil
      percent_off = nil
      status = 'active'

      body = {
        name: name,
        code: code,
        dollar_off: dollar_off,
        percent_off: percent_off,
        status: status,
        merchant_id: @merchants[1].id
      }

      post "/api/v1/coupons", params: body, as: :json
      error = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(response.status).to eq(422)

      expect(error[:message]).to eq("Your request could not be completed, please read the details below.")
      expect(error[:errors][0][:status]).to eq("422")
      expect(error[:errors][0][:detail]).to eq("Validation failed: Either dollar_off or percent_off must have a value")
    end

    it 'retruns error 422 if dollar_off or percent_off both have a value' do
      name = "To many coupons"
      code = "FAILEDCOUPON"
      dollar_off = 2.0
      percent_off = 10
      status = 'active'

      body = {
        name: name,
        code: code,
        dollar_off: dollar_off,
        percent_off: percent_off,
        status: status,
        merchant_id: @merchants[1].id
      }

      post "/api/v1/coupons", params: body, as: :json
      error = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(response.status).to eq(422)

      expect(error[:message]).to eq("Your request could not be completed, please read the details below.")
      expect(error[:errors][0][:status]).to eq("422")
      expect(error[:errors][0][:detail]).to eq("Validation failed: Only dollar_off or percent_off can have a value")
    end
  end

  describe 'HAPPY PATH: PATCH /api/v1/coupons/:id' do
    it 'changes a coupons status from active to inactive' do

      status = 'inactive'
      body = {
        status: status
      }

      expect(@coupon1.status).to eq('active')

      patch "/api/v1/coupons/#{@coupon1.id}", params: body, as: :json

      coupon = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response).to be_successful
      expect(response.status).to eq(200)

      expect(coupon[:attributes][:status]).to eq('inactive')
    end

    it 'changes a coupons status from inactive to active' do
      status = 'active'
      body = {
        status: status
      }
      expect(@coupon4.status).to eq('inactive')

      patch "/api/v1/coupons/#{@coupon4.id}", params: body, as: :json

      coupon = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response).to be_successful
      expect(response.status).to eq(200)

      expect(coupon[:attributes][:status]).to eq('active')
    end
  end

  describe 'SAD PATH: PATH: PATCH /api/v1/coupons/:id' do
    it 'confirms coupons with pending "packaged" invoices can not be deactivated' do
      status = 'inactive'
      body = {
        status: status
      }

      expect(@coupon6.status).to eq('active')

      patch "/api/v1/coupons/#{@coupon6.id}", params: body, as: :json
      error = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(response.status).to eq(403)
      expect(@coupon6.status).to eq('active')

      expect(error[:message]).to eq("This actiion is forbidden, please read the details below.")
      expect(error[:errors][0][:status]).to eq("403")
      expect(error[:errors][0][:detail]).to eq("Unable to Deactivate coupon with pending 'packaged' Invoices")
    end

    it 'confirms existing coupons cannot change from inactive to active if their merchant already has 5 active coupons' do
      status = 'active'
      body = {
        status: status
      }
      expect(@coupon10.status).to eq('inactive')

      patch "/api/v1/coupons/#{@coupon10.id}", params: body, as: :json
      error = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(response.status).to eq(403)
      expect(@coupon10.status).to eq('inactive')

      expect(error[:message]).to eq("This actiion is forbidden, please read the details below.")
      expect(error[:errors][0][:status]).to eq("403")
      expect(error[:errors][0][:detail]).to eq("Merchants can only have 5 active coupons, please deactivate one and try again.")
    end

    it 'errors if status attribute is missing active/inactive' do
      status = ''
      body = {
        status: status
      }
      patch "/api/v1/coupons/#{@coupon10.id}", params: body, as: :json
      error = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(response.status).to eq(403)

      expect(error[:message]).to eq("This actiion is forbidden, please read the details below.")
      expect(error[:errors][0][:status]).to eq("403")
      expect(error[:errors][0][:detail]).to eq("Status must be 'active' or 'inactive', please correct and try again.")
    end
  end
end