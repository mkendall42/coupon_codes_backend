FactoryBot.define do
  factory :merchant do
    name { Faker::Company.name }
    # created_at { Time.current }     #Isn't this done in SQL DB by default anyway???
  end
end