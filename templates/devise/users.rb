FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password "12345678"
    password_confirmation "12345678"
    confirmed_at { Time.now }
  end
end
