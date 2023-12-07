module BxBlockNotifications
  class DailyNotificationReminders

    def initialize(first_reminder_account_ids=[], secord_reminder_account_ids = [], morning_reminder_account_ids = [])
      @first_reminder_account_ids = first_reminder_account_ids
      @secord_reminder_account_ids = secord_reminder_account_ids
      @morning_reminder_account_ids = morning_reminder_account_ids
    end

    def call
      ::AccountBlock::Account.where.not(device_token: nil).find_each(batch_size: 10).each do|account|
        unless vacation_enabled?(account)
          notification_reminder_setting = account.notification_reminder_setting
          if reminder_enable(notification_reminder_setting&.first_reminder) && !reminder_sent(account, ::BxBlockNotifications::Notification.notification_types["first_reminder"])
            @first_reminder_account_ids << account.device_token
          elsif reminder_enable(notification_reminder_setting&.second_reminder) && !reminder_sent(account, ::BxBlockNotifications::Notification.notification_types["second_reminder"])
            @secord_reminder_account_ids << account.device_token
          elsif reminder_enable(notification_reminder_setting&.morning_reminder) && !reminder_sent(account, ::BxBlockNotifications::Notification.notification_types["morning_reminder"])
            @morning_reminder_account_ids << account.device_token
          end  
        end
      end

      send_notifications
    end

    private

    def send_notifications
      payload = payload_data
      payload[:notification][:body] = first_second_reminder_message
      payload[:data][:body] = first_second_reminder_message
      ::BxBlockPushNotifications::SendFcmNotification.new().send_notification_with_token(@first_reminder_account_ids, payload, {notification_type: ::BxBlockNotifications::Notification.notification_types["first_reminder"]}) if @first_reminder_account_ids.present?
      ::BxBlockPushNotifications::SendFcmNotification.new().send_notification_with_token(@secord_reminder_account_ids, payload, {notification_type: ::BxBlockNotifications::Notification.notification_types["second_reminder"]}) if @secord_reminder_account_ids.present?
      payload[:notification][:body] = morning_second_reminder_message
      payload[:data][:body] = morning_second_reminder_message
      ::BxBlockPushNotifications::SendFcmNotification.new().send_notification_with_token(@morning_reminder_account_ids, payload, {notification_type: ::BxBlockNotifications::Notification.notification_types["morning_reminder"]}) if @morning_reminder_account_ids.present?
    end

    def payload_data
      { notification: { title: 'windeverest', body: '' }, data: { title: 'windeverest', body: '' } }
    end

    def vacation_enabled?(account)
      vacation_mode_setting = account.vacation_mode_setting rescue nil
      vacation_begin = vacation_mode_setting.vacation_begin rescue nil
      vacation_end = vacation_mode_setting.vacation_end rescue nil
      vacation_mode = false
      if vacation_begin.present? && vacation_end.present?
        if (Time.now >= vacation_begin) && (Time.now <= vacation_end)
          return true
        end
      end
      vacation_mode
    end

    def reminder_enable(reminder_time)
      return false unless reminder_time.present?
      if reminder_time_enabled?(reminder_time)
        return true
      end
      false
    end

    def reminder_time_enabled?(reminder_time, current_time = Time.now.utc)
      current_time.utc.strftime( "%H%M" ) >= reminder_time.utc.strftime( "%H%M") &&
      current_time.utc.strftime( "%H%M" ) <= (reminder_time + 5.minutes).utc.strftime( "%H%M")
    end

    def reminder_sent(account, notification_type)
      ::BxBlockNotifications::Notification.where(account_id: account.id, notification_type: notification_type).where('created_at >= ?', Time.now.utc.beginning_of_day).present?
    end

    def first_second_reminder_message
      "Your car could contribute to a greener grid. Indicate your choice for tonight, either to 'decline' a charge, or to add a certain percent to your car's battery."
    end

    def morning_second_reminder_message
      "We received no indication of your choice to charge or decline a charge for last night. Please update your status before noon."
    end
  end
end
