module BxBlockNotifsettings
  class NotificationReminderSettingsController < ApplicationController
    #before_action :get_noti_setting, only: [:show, :update, :destroy]

    def create
      notification_reminder_setting = current_user.notification_reminder_setting
      if notification_reminder_setting.present?
        update_record(notification_reminder_setting)
      else
        notification_reminder_setting = BxBlockNotifsettings::NotificationReminderSetting.new(notification_reminder_settings_params.merge(account_id: current_user.id))
        if notification_reminder_setting.save
          success_response(notification_reminder_setting)
        else
          formatted_error(notification_reminder_setting)
        end
      end
    end

    def index
      notification_reminder_setting = current_user.notification_reminder_setting
      render json: ::BxBlockNotifsettings::NotificationReminderSettingSerializer.new(notification_reminder_setting).serializable_hash, status: :ok
      
    end

    private

    def notification_reminder_settings_params
      params.require(:data).require(:notification_reminder_settings).permit(:first_reminder, :second_reminder, :morning_reminder, :actives)
    end

    def update_record(notification_reminder_setting)
      if notification_reminder_setting.update(notification_reminder_settings_params)
        success_response(notification_reminder_setting)
      else
        formatted_error(notification_reminder_setting)
      end
    end

    def success_response(notification_reminder_setting)
      render json: ::BxBlockNotifsettings::NotificationReminderSettingSerializer.new(notification_reminder_setting).serializable_hash, status: :created
    end

    def formatted_error(notifi_reminder_setting)
      render json: { errors: format_activerecord_errors(notifi_reminder_setting.errors) },
               status: :unprocessable_entity
    end
  end
end
