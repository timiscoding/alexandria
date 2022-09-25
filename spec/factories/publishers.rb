FactoryBot.define do
  factory :publisher do
    name { "O'Reilly" }
  end

  factory :dev_media, class: Publisher do
    name { 'Dev media' }
  end

  factory :super_books, class: Publisher do
    name { 'Super books' }
  end
end
