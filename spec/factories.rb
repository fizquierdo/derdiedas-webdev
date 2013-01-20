FactoryGirl.define do
  factory :user do
    name     "fer"
    email    "fer.izquierdo@gmail.com"
    password "foobar"
    password_confirmation "foobar"
  end
  factory :word do
    article "das"
    noun    "Zimmer"
    weight  1 
  end
end
