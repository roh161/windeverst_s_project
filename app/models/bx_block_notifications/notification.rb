module BxBlockNotifications
  class Notification < ApplicationRecord
    self.table_name = :notifications
    belongs_to :account , class_name: 'AccountBlock::Account'

    enum notification_type: {"first_reminder" => 0, "second_reminder" => 1, "morning_reminder" => 3, "broadcast_message": 4, "gamification_reminder": 5 }

    validates :headings, :contents, :account_id, presence: true, allow_blank: false

    def self.create_data(paylaod)
    	Notification.create(paylaod) rescue nil
    end


    def self.save_push_notifications(accounts, device_tokens, paylaod, options = {})
    	begin
            notification_type = options[:notification_type]
    		accounts = AccountBlock::Account.where(device_token: device_tokens) unless accounts.present?
            paylaod = paylaod.with_indifferent_access
    		headings = paylaod[:notification][:title]
    		contents = paylaod[:notification][:body]
    		if accounts.present? && headings.present? && contents.present?
	    		notification_params = {
	    			created_by: nil,
	    			headings: headings,
	    			contents: contents,
	    			app_url: nil,
                    notification_type: notification_type
	    		}
		    	accounts.each do|account|
		    		Notification.create_data(notification_params.merge(account_id: account.id)) rescue nil
		    	end
		    end
	    rescue Exception =>e
	    	Rails.logger.info "Error in save_push_notifications. Error #{e.message}"
	    end
    end
  end
end
