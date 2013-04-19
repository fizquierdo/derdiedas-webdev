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
  def balance
    all_totals = 0
    all_corrects = 0
    Word.all.each do |w| 
      all_totals += totals(w.noun) 
      all_corrects += corrects(w.noun)
    end
    "Historically guessed #{all_corrects} out of #{all_totals} (#{all_corrects.to_f / all_totals.to_f})"
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
  if (1..1000).to_a.shuffle.first < rate * 1000
    #puts "player guessed #{word.noun}"
    given_answer = word.article
    history.add word.noun, true
  else
    answer_set = ["der", "die", "das"] - [word.article]
    given_answer = answer_set.shuffle.first
    #puts "player failsed #{word.noun}, said #{given_answer}"
    history.add word.noun, false
  end
  guess = user.guesses.build(word_id: word.id, answer: given_answer)
  guess.save
end
def show_player_history(user, history, attempt, guess_rate)
  puts "User #{user.name} at attempt no #{attempt}, last guess rate #{guess_rate}"
  puts history.balance
  table = Table(%w[noun prob weight level attempts corrects])
  prio_list(user).each do |w| 
    table << [w.noun, user.word_prob(w), w.weight, user.word_level(w), history.totals(w.noun), history.corrects(w.noun) ]
  end
  p table
end
def new_guess_rate(total_guess, attempt_no)
  # this looks reasonable
  # guess_rate(t) = 1 - exp(-t)
  # guess_rate(0.4) = 0.33 
  # guess_rate(4.6) = 0.99 
  # we can map attempt to "time" range (0.4 - 4.6)
  t0 = (4.2 * attempt_no) / total_guess  # perfect learner reaches 4.2 in the last guess
  t = 0.4 + t0
  1 - Math.exp(-1 * t)
end

namespace :sim do
  desc "Generate a smart user and let him play"
  task play: :environment do
    players = [
      {username: "SmartPlayer",  guess_rate: 0.90},
      {username: "StupidPlayer", guess_rate: 0.33},
      {username: "LearningPlayer", guess_rate: 0.0},
    ]
    number_of_plays = 251
    showfreq = 50
    players.each do |player|
      # destroy and create player
      username = player[:username]
      guess_rate = player[:guess_rate]
      puts "##Creating #{username}"
      u = User.find_by_name username
      u.destroy unless u.nil? 
      user = User.create!(name: username,
                          email: "#{username}@gmail.com",
                          password: "password",
                          password_confirmation: "password")
      # play a few words
      history = History.new
      number_of_plays.times do |attempt|
        if username == "LearningPlayer"
          guess_rate = new_guess_rate(number_of_plays, attempt)
        end
        show_player_history(user, history, attempt, guess_rate) if attempt % showfreq == 0
        simulate_play(user, guess_rate, history)
      end
    end
  end
end

