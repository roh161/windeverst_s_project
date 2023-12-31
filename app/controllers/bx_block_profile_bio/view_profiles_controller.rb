# frozen_string_literal: true

module BxBlockProfileBio
  class ViewProfilesController < ApplicationController
    # before_action :load_basic_profile, only: %i[index]
    before_action :check_account_activated

    def index
      account = AccountBlock::Account.find_by(id: current_user.id)
      unless account.is_paid
        return render json: {message: "Only paid/premium users"},
          status: :unprocessable_entity
      end
      view_profiles = BxBlockProfileBio::ViewProfile.where(view_by_id: account.id)

      if view_profiles.present?
        if params[:filter_by].present?
          case params[:filter_by]
          when "newest_first"
            view_profiles = view_profiles.order("view_profiles.created_at desc")
          when "oldest_first"
            view_profiles = view_profiles.order("view_profiles.created_at asc")
          end
        end

        if params[:search_by_name].present?
          view_profiles = view_profiles.joins(:viewer).where(
            "accounts.first_name ILIKE ? or accounts.last_name ILIKE ?",
            "%#{params[:search_by_name]}%", "%#{params[:search_by_name]}%"
          ).distinct
        end

        BxBlockProfileBio::ViewProfile.mutual_friend(current_user.id, view_profiles)

        json_data = BxBlockProfileBio::ViewProfileSerializer.new(view_profiles).serializable_hash
        json_data[:total_viewed_count] = begin
          json_data[:data].count
        rescue
          0
        end
        render json: json_data,
          status: :ok
      else
        render json: {data: []},
          status: :ok
      end
    end

    def create
      view_profile = BxBlockProfileBio::ViewProfile.new(view_profile_params)
      view_profile.view_by_id = current_user.id

      if view_profile.save
        serializer = BxBlockProfileBio::ViewProfileSerializer.new(view_profile)
        render json: serializer.serializable_hash,
          status: :ok
      else
        render json: {errors: [{view_profile: view_profile.errors}]},
          status: :unprocessable_entity
      end
    end

    private

    def view_profile_params
      params.require(:data)[:attributes].permit \
        :account_id, :profile_bio_id
    end

    def load_basic_profile
      @profile = BxBlockProfileBio::ProfileBio.find_by(account_id: current_user.id)

      if @profile.nil?
        render json: {
          message: "Profile not found"
        }, status: :not_found
      end
    end
  end
end
