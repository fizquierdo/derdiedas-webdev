# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

wordfile = File.join Rails.root, 'db', 'words.txt'
words = []
File.read(wordfile).each_line do |l|
  article, noun = l.chomp.split
  words << {article: article, noun: noun, weight: 1}
end
puts "#{words.size} available"
words.shuffle.slice(0,100).each do |w|
  Word.create!({article: w[:article], noun: w[:noun], weight: 1})
end
