class AddNotificationTypeToNotifications < ActiveRecord::Migration[6.0]
  def change
    add_column :notifications, :notification_type, :integer
  end
end
