

def get_random_words(number_of_words)
    # Words from a file in db/
    wordfile = File.join Rails.root, 'db', 'words.txt'
    raise "#{wordfile} not found" unless File.exist?(wordfile)
    words = []
    File.read(wordfile).each_line do |l|
      article, noun = l.chomp.split
      words << {article: article, noun: noun, weight: 1}
    end
    puts "#{words.size} words available in file source"
    number_of_words = words.size if words.size < number_of_words
    words.shuffle.slice(0,number_of_words)
end




namespace :db do
  desc "Fill users database with sample data"
  task populate: :environment do
    number_of_users = 25
    number_of_words = 50
    # Users
    admin = User.create!(name: "Fernando",
                 email: "fer.izquierdo@gmail.com",
                 password: "password",
                 password_confirmation: "password")

    admin.toggle!(:admin)
    number_of_users.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@example.org"
      password  = "password"
      User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end
    puts "#{User.all.size} users created"

    # Words
    words = get_random_words(number_of_words)
    words.each do |w|
      Word.create!({article: w[:article], noun: w[:noun], weight: 1})
    end
    puts "#{Word.all.size} random words added to the database"

  end
end
