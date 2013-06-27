# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def get_words(filename)
    # Words from a file in db/
    wordfile = File.join Rails.root, 'db', filename
    raise "#{wordfile} not found" unless File.exist?(wordfile)
    words = []
    articles_short = {"f"=>"die", "m"=>"der", "n"=>"das"}
    file = IO.read(wordfile).force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
    lines = file.split("\n")
    lines.each do |l|
      begin
        id, noun, article, weight, definitions, count = l.chomp.split("\t")
        words << {article: articles_short[article], noun: noun, weight: weight.to_i}
        puts noun
      rescue Exception => e
        puts "Skipping line #{l}"
        puts e.message
        puts e.backtrace.inspect
        raise e
      end
      #raise "No valid article identifier for word id #{id}" unless articles_short.keys.include? article
    end
    puts "#{words.size} words available in file source"
    #puts w[:article]  + "\t"+w[:weight].to_s+"\t"+ w[:noun]
    words
end

# Create a default admin
admin = User.create!(name: "Fernando",
             email: "fer.izquierdo@gmail.com",
             password: "password",
             password_confirmation: "password")
admin.toggle!(:admin)

# Load the available words to the DB
get_words("de.freq.1000").each do |w|
  Word.create!({article: w[:article], noun: w[:noun], weight: w[:weight]})
end
