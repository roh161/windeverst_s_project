require 'rails_helper'
RSpec.describe BxBlockNotifsettings::NotificationReminderSettingsController, type: :controller do
  let(:account) { FactoryBot.create(:account) }
  SUCCESS = "Returns success"
  ERROR = "Returns error"
  
  describe 'POST create' do
    before(:each) do
      role = create(:role)
      @account = create(:account, role: role) 
      @contact = create(:contact, account: @account)
      @token = BuilderJsonWebToken.encode(@account.id, {account_type: @account.type}, 1.year.from_now)
    end
    context "create with correct credentials" do
      it SUCCESS do
      post :create, params: {token: @token, data: {"notification_reminder_settings": {"first_reminder": "06:00 AM","second_reminder": "08:00 AM","morning_reminder": "02:00 AM"}} }
        expect(response).to have_http_status(201)
      end
    end

    context "create with incorrect credentials" do
      it ERROR do
      post :create, params: {token: nil, data: {"notification_reminder_settings": {"first_reminder": "06:00 AM","second_reminder": "08:00 AM","morning_reminder": "02:00 AM"}} }
        expect(response).to have_http_status(400)
      end
    end

    context "update with correct credentials" do
      it SUCCESS do
      post :create, params: {token: @token, data: {"notification_reminder_settings": {"first_reminder": "06:30 AM","second_reminder": "08:30 AM","morning_reminder": "03:00 AM"}} }
        expect(response).to have_http_status(201)
      end
    end

    context "update with incorrect credentials" do
      it ERROR do
      post :create, params: {token: nil, data: {"notification_reminder_settings": {"first_reminder": "06:30 AM","second_reminder": "08:30 AM","morning_reminder": "03:00 AM"}} }
        expect(response).to have_http_status(400)
      end
    end
  end

  describe 'Get index' do
    before(:each) do
      role = create(:role)
      @account = create(:account, role: role) 
      @token = BuilderJsonWebToken.encode(@account.id, {account_type: @account.type}, 1.year.from_now)
    end
    context "when given correct credentials" do
      it SUCCESS do
      get :index, params: {token: @token }
        expect(response).to have_http_status(200)
      end
    end
    context "when given incorrect credentials" do
      it ERROR do
      get :index, params: {token: nil }
        expect(response).to have_http_status(400)
      end
    end
  end
end
