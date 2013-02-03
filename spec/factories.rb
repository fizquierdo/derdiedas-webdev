FactoryGirl.define do
  factory :user do
    sequence(:name){|n| "Person #{n}"} 
    sequence(:email){|n| "person_#{n}@example.com"} 
    password "foobar"
    password_confirmation "foobar"
  end
  factory :word do
    article "das"
    noun    "Zimmer"
    weight  "1"
  end
end
