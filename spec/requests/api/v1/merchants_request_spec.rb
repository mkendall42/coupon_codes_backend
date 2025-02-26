require "rails_helper"

RSpec.describe "Merchants endpoints", type: :request do
  
  describe "#index" do
    it "can retrieve all merchants" do
      Merchant.destroy_all
      Merchant.create!(name: "Barbara", item_count: 20)
      Merchant.create!(name: "Mark", item_count: 30)
      Merchant.create!(name: "Jackson", item_count: 40)
      Merchant.create!(name: "Jason", item_count:10)

      get "/api/v1/merchants"

      expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants[:data].count).to eq(4)
    end

    it "can retrieve merchants sorted by creation, newest first" do
      Merchant.destroy_all
      Merchant.create!(name: "Barbara")
      Merchant.create!(name: "Mark")
      Merchant.create!(name: "Jackson")
      Merchant.create!(name: "Jason")

      get "/api/v1/merchants?sorted=age"

      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants[:data].first[:attributes][:name]).to eq("Jason")
    end

    it "can "
  end
end