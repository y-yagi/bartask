3.times do |i|
  User.create!(email: "user_#{i}@example.com")
end
