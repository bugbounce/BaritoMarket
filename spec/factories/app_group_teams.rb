FactoryBot.define do
  factory :app_group_team do
    association :app_group
    association :group
  end
end
