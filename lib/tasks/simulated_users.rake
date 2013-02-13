require 'ruport'
class History
  def initialize
    @history = {}
    Word.all.each {|w| @history[w.noun] = {right: 0, wrong: 0}}
  end
  def corrects(noun)
   @history[noun][:right]
  end
  def totals(noun)
    corrects(noun) + @history[noun][:wrong]
  end
  def add(noun, answer_correct)
    if answer_correct
      @history[noun][:right] += 1
    else
      @history[noun][:wrong] += 1
    end
  end
end
def prio_list(user)
  Word.all.sort{|w1, w2| user.word_prob(w2) <=> user.word_prob(w1)}
end
def sample_word(user)
  sample_size = Word.count / 10
  words = prio_list(user).slice(0, sample_size)
  words.shuffle.first
end
def simulate_play(user, rate, history)
  word = sample_word(user)
  raise "wront rate" unless rate > 0 and rate < 1
  if (1..10).to_a.shuffle.first < rate * 10
    puts "player guessed #{word.noun}"
    given_answer = word.article
    history.add word.noun, true
  else
    answer_set = ["der", "die", "das"] - [word.article]
    given_answer = answer_set.shuffle.first
    puts "player failsed #{word.noun}, said #{given_answer}"
    history.add word.noun, false
  end
  guess = user.guesses.build(word_id: word.id, answer: given_answer)
  guess.save
end

namespace :sim do
  desc "Generate a smart user and let him play"
  task play: :environment do
    # destroy and create player
    username = "SmartPlayer"
    guess_rate = 0.99
    u = User.find_by_name username
    u.destroy unless u.nil? 
    user = User.create!(name: username,
                 email: "#{username}@gmail.com",
                 password: "password",
                 password_confirmation: "password")
    # play a few words
    history = History.new
    100.times do
      simulate_play(user, guess_rate, history)
    end
    # show the output / compute stats?
    table = Table(%w[noun prob weight level attempts corrects])
    prio_list(user).each do |w| 
      table << [w.noun, user.word_prob(w), w.weight, user.word_level(w), history.totals(w.noun), history.corrects(w.noun) ]
    end
    p table
  end
end

