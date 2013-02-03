FactoryGirl.define do
  factory :user do
    sequence(:name){|n| "Person #{n}"} 
    sequence(:email){|n| "person_#{n}@example.com"} 
    password "foobar"
    password_confirmation "foobar"

    factory :admin do
      admin true
    end
  end

  factory :word do
    article "das"
    noun    "Zimmer"
    weight  "1"
  end

  factory :guess do
    sequence(:answer) {|n| ["das", "der", "die"].shuffle.first }
    user
    word
  end

  
end
