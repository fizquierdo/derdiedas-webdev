#!/usr/bin/env ruby
#
require 'ostruct'
require 'ruport'
require 'vose'

class User
  def initialize(success_rate)
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
  def print
    table = Table(%w[noun guess])
    @history.each do |p|
      table << [p[:noun], p[:guess]]
    end
    p table
  end
  def print_grouped
    table = Table(%w[noun guess])
    @history.group_by{|p| p[:noun]}.each do |k, v|
      guesses = v.map{|c| c[:guess]}
      num_true_guess = guesses.select{|g| g == true}.size
      num_false_guess = guesses.select{|g| g == false}.size
      raise "sum of guess wrong" unless num_true_guess + num_false_guess == guesses.size
      table << [k, "#{guesses.size}; correct (#{num_true_guess}), wrong (#{num_false_guess})"]
    end
    p table
  end
end

class Session
  attr_accessor :total_occurrences
  def initialize(wordfile)
    @allwords = []
    @history = History.new
    random_session(wordfile)
  end
  def print
    table = Table(%w[part noun Prob_word|user Prob_user|word*freq_word])
    @words.each do |w|
      table << [w.article, w.noun, w.formatted_prob, w.formatted_prob_user]
    end
    p table
  end
  def checksum
    sum = cumulative_prob @words
    raise "checksum : #{sum}" unless (sum - 1).abs < 0.001
  end
  def initialize_probs(num_words)
    raise "#{num_words too large}" unless num_words <= @allwords.size
    @words = @allwords.shuffle.slice(0,num_words)
    initial_prob_user = 1.0 / @words.map{|w| w.frequency}.inject(:+).to_f
    @words.each{ |w| w.prob_user = initial_prob_user}
    checksum
  end
  def play(guess)
    @history.add(random_word.noun, guess)
  end
  def print_history
    @history.print
  end
  def print_history_grouped
    @history.print_grouped
  end
  def adjust_word_probabilities
    puts "cumulative probability of used words: " + "%.3f" % (cumulative_noun_prob @history.nouns)
    p @history.nouns
    puts
    puts "cumulative probability of non-used words: " + "%.3f" % (cumulative_noun_prob unused_nouns)
    p unused_nouns

    #TODO based on the history of success for each word, this should update the Prob_user|word
  end
  def unused_nouns
    @words.map{|w| w.noun} - @history.nouns
  end
  private
    def probs_given_user(words)
      words.map(&:prob_given_user)
    end
    def cumulative_noun_prob(noun_list)
      cumulative_prob @words.select{|w| noun_list.include?(w.noun)}
    end
    def cumulative_prob(words)
      probs_given_user(words).inject(:+).to_f
    end
    def random_word
      vose = Vose::AliasMethod.new probs_given_user(@words)
      @words[vose.next]
    end
    def random_session(wordfile)
      File.read(wordfile).each_line do |l|                                                     
        article, noun = l.chomp.split                                                          
        @allwords << Word.new(article: article, noun: noun, frequency: (1..4).to_a.shuffle.first)   
      end                                                                                      
      puts "#{@allwords.size} words available in file source"
    end
end

# Iinitialize a random session 
session = Session.new File.join('../db', 'words.txt')
session.initialize_probs(20)
session.print

# Set up a player
rate = 0.5
player = User.new rate 
puts "Player plays with success rate #{rate}"

# Let the player use these session words (assumes single user in session)
10.times do
  player.play(session)
end
session.print_history
session.print_history_grouped
session.adjust_word_probabilities

