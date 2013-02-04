#!/usr/bin/env ruby
#
require 'ostruct'
require 'ruport'

class User
  def initialize(success_rate)
    raise "success rate must be in (0..1)" unless success_rate > 0 and success_rate < 1
    @success_rate = success_rate
  end
  def play(session)
    @session = session
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

class Session
  attr_accessor :total_occurrences
  def initialize(wordfile)
    @allwords = []
    random_session(wordfile)
  end
  def print
    table = Table(%w[part noun Prob_word|user Prob_user|word*freq_word])
    @words.each do |w|
      table << [w.article, w.noun, w.formatted_prob, w.formatted_prob_user]
    end
    p table
  end
  def probs_given_user
    @words.map(&:prob_given_user)
  end
  def checksum
    sum = probs_given_user.inject(:+).to_f
    raise "checksum : #{sum}" unless (sum - 1).abs < 0.001
  end
  def initialize_probs(num_words)
    raise "#{num_words too large}" unless num_words <= @allwords.size
    @words = @allwords.shuffle.slice(0,num_words)
    initial_prob_user = 1.0 / @words.map{|w| w.frequency}.inject(:+).to_f
    @words.each{ |w| w.prob_user = initial_prob_user}
    checksum
  end
  def random_word

  end
  private
    def random_session(wordfile)
      File.read(wordfile).each_line do |l|                                                     
        article, noun = l.chomp.split                                                          
        @allwords << Word.new(article: article, noun: noun, frequency: (1..4).to_a.shuffle.first)   
      end                                                                                      
      puts "#{@allwords.size} words available in file source"
    end
end

session = Session.new File.join('../db', 'words.txt')
session.initialize_probs(6)
session.print

rate = 0.9
player = User.new rate 
puts "Player plays with rate #{rate}"
player.play(session)
session.print

