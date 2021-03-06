
#  for the toy dataset words Words from a file in db/
def random_weight
  (1..10).to_a.shuffle.first
end
def get_random_words(number_of_words)
    wordfile = File.join Rails.root, 'db', 'words.txt'
    raise "#{wordfile} not found" unless File.exist?(wordfile)
    words = []
    File.read(wordfile).each_line do |l|
      article, noun = l.chomp.split
      words << {article: article, noun: noun, weight: random_weight}
    end
    puts "#{words.size} words available in file source"
    number_of_words = words.size if words.size < number_of_words
    words.shuffle.slice(0,number_of_words)
end


namespace :db do
  desc "Fill users database with sample data"
  task populate_sample: :environment do
    number_of_users = 5
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
    words = get_random_words(50)
    words.each do |w|
      Word.create!({article: w[:article], noun: w[:noun], weight: w[:weight]})
    end
    puts "#{Word.all.size} words added to the database"
  end
  #desc "Show words available in the database"
  #task words: :environment do
  #  get_words("de.frequency.1000").each do |w|
  #    puts w[:article]  + "\t"+w[:weight].to_s+"\t"+ w[:noun]
  #  end
  #end
end
