#!/usr/bin/env ruby
#
require 'ostruct'
require 'ruport'
require 'vose'

class User
  attr_accessor :success_rate
  def initialize(success_rate = 0.5)
    raise "success rate must be in (0..1)" unless success_rate > 0 and success_rate < 1
    @success_rate = success_rate
  end
  def success?
    vose = Vose::AliasMethod.new [@success_rate, 1.0 - @success_rate]
    vose.next == 0
  end
  def play(session)
    session.play(self.success?)
  end
  def sample(num)
    results = []
    num.times do
      if success? 
        results << "G"
      else
        results << "B"
      end
    end
    results.join(' ')
  end
end

class Word < OpenStruct
  def to_s
     "#{article}\t#{noun}\t#{formatted_prob}\t(#{formatted_prob_user})" 
  end
  def formatted_prob_user
     '%.3f' % prob_user + ' * ' + frequency.to_s
  end
  def formatted_prob
     '%.3f' % prob_given_user 
  end
  def prob_given_user
    prob_user * frequency
  end
end

class History
  def initialize
    reset
  end
  def reset
    @history = []
  end
  def add(noun, guess)
    @history << {noun: noun, guess: guess}
  end
  def nouns
    @history.group_by{|p|p[:noun]}.map{|k,v| k}
  end
  def print_by_order
    table = Table(%w[noun guess])
    @history.each do |p|
      table << [p[:noun], p[:guess]]
    end
    p table
  end
  def print_by_result
    table = Table(%w[noun attempt correct wrong])
    @history.group_by{|p| p[:noun]}.each do |noun, history_entry|
      guesses = history_entry.map{|c| c[:guess]}
      raise "sum of guess wrong" unless guesses.count(true) + guesses.count(false) == guesses.count
      table << [noun, guesses.count, guesses.count(true), guesses.count(false)]
    end
    p table
  end
  def entries
    @history
  end
end

class Session
  attr_accessor :total_occurrences
  attr_accessor :traning_size
  def initialize(wordfile)
    @allwords = []
    @history = History.new
    random_session(wordfile)
  end
  def print
    table = Table(%w[part noun Prob_word|user Prob_user|word*freq_word attempts corrects])
    @words.each do |w|
      table << [w.article, w.noun, w.formatted_prob, w.formatted_prob_user, w.attempts, w.corrects]
    end
    p table
  end
  def checksum
    sum = cumulative_prob @words
    raise "checksum : #{sum}" unless (sum - 1).abs < 0.001
  end
  def initialize_probs(num_words, training_words)
    @training_size = training_words
    raise "#{num_words too large}" unless num_words <= @allwords.size
    @words = @allwords.shuffle.slice(0,num_words)
    initial_prob_user = 1.0 / @words.map{|w| w.frequency}.inject(:+).to_f
    @words.each{ |w| w.prob_user = initial_prob_user}
    puts "Loaded random #{num_words} initial words into session"
    shuffle
    checksum
  end
  def shuffle
    @training_set = @words.shuffle.slice(0, @training_size)
  end
  def play(guess)
    attempts = 100
    word = random_word_from_training_set(attempts)
    raise "No word found after #{attempts} attempts!" unless word
    @history.add(word.noun, guess)
    word.attempts += 1
    word.corrects += 1 if guess
  end
  def print_history
    @history.print_by_time
  end
  def print_history_by_result
    @history.print_by_result
  end
  def adjust_word_probabilities(factor = 2)
    # Compute initial cumulative probabilityes
    used_set_prob = cumulative_noun_prob @history.nouns
    unused_set_prob = cumulative_noun_prob unused_nouns
    if $DEBUG
      puts "cumulative probability of used words: " + "%.3f" % (used_set_prob)
      puts "cumulative probability of non-used words: " + "%.3f" % (unused_set_prob)
    end
    checksum

    # Update probabilities for the played words
    @history.entries.each do |entry|
      word = find_word entry[:noun]
      puts word.noun + " had \t" + word.formatted_prob_user if $DEBUG
      if entry[:guess]
        word.prob_user /= factor
       else
        word.prob_user *= factor
      end
    end

    # Compute absortion by unused words
    updated_used_set_prob = cumulative_noun_prob @history.nouns
    incr_unused = 1.0 - unused_set_prob - updated_used_set_prob
    num_unused = unused_nouns.count
    fraction = incr_unused / num_unused.to_f
    if $DEBUG
      puts "updated cumulative probability of used words: " + "%.3f" % (updated_used_set_prob)
      puts "#{num_unused} non-used words has to absorve #{incr_unused}, each #{fraction}" 
    end
    unused_nouns.each do |noun|
      word = find_word noun
      puts word.noun + " had \t" + word.formatted_prob_user if $DEBUG
      word.prob_user += (fraction / word.frequency)
    end
    checksum
    @history.reset
  end
  def unused_nouns
    @words.map{|w| w.noun} - @history.nouns
  end
  private
    def find_word(noun)
      @words.select{|w| w.noun == noun}.first
    end
    def probs_given_user(words)
      words.map(&:prob_given_user)
    end
    def cumulative_prob(words)
      probs_given_user(words).inject(:+).to_f
    end
    def words_with_noun_in (noun_list)
      @words.select{|w| noun_list.include?(w.noun)}
    end
    def cumulative_noun_prob(noun_list)
      cumulative_prob words_with_noun_in(noun_list)
    end
    def random_word
      vose = Vose::AliasMethod.new probs_given_user(@words)
      word = @words[vose.next]
    end
    def random_word_from_training_set(attempts)
      word = nil
      attempts.times do
        word = random_word 
        break if @training_set.include?(word)
      end
      word
    end
    def random_session(wordfile)
      File.read(wordfile).each_line do |l|                                                     
        article, noun = l.chomp.split                                                          
        @allwords << Word.new(article: article, 
                              noun: noun, 
                              frequency: (1..4).to_a.shuffle.first, 
                              attempts: 0,
                              corrects: 0)   
      end                                                                                      
      puts "#{@allwords.size} words available in file source" if $DEBUG
    end
end

# Initialize a random session 
num_words = 20
training_set = 5 
session = Session.new File.join('../db', 'words.txt')
session.initialize_probs(num_words, training_set)

# Set up a player
player = User.new  
puts "Player plays with success rate #{player.success_rate}"

# Let the player use these session words (assumes single user in session)
session.print
10.times do
  # player improves a bit (he learned from his mistakes)
  player.success_rate *= 1.01
  puts "Player plays with success rate #{player.success_rate}"
  # play 10 times with this training set
  6.times do
    player.play(session)
  end
  #session.print_history_by_result
  session.adjust_word_probabilities(1.5)
  # change the traning set from the num_words
  session.shuffle
end
session.print
