require 'rails_helper'
RSpec.describe BxBlockGamification::Badge, type: :model do
  it { should have_one_attached :unlocked_image }
  it { should have_one_attached :locked_image }
end