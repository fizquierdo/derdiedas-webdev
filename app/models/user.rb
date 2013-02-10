# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string(255)
#

class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation
  has_secure_password
  before_save{|user| user.email = email.downcase}
  before_save :create_remember_token
  
  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, 
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: {case_sensitive: false}
  validates :password, presence: true, length: {minimum: 6}
  validates :password_confirmation, presence: true

  has_many :guesses, :dependent => :destroy
  has_many :words, :through => :guesses

  def number_of_guesses
    self.guesses.size
  end
  def number_of_correct_guesses
    self.guesses.select{|guess| guess.correct?}.size
  end
  def success_ratio
    return "" unless number_of_guesses > 0
    '%.2f' % ((number_of_correct_guesses.to_f / number_of_guesses.to_f) * 100.0)
  end
  def guesses_by_words
    word_results = []
    self.guesses.group_by(&:word_id).each do |word_id, word_guesses|
      word_results << {correct: word_guesses.select{|guess| guess.correct?}.size, 
                       total: word_guesses.size, 
                       name: word_guesses.first.word.to_s 
      }
    end
    word_results 
  end
  def word_level(word)
    level = 5
    word_history(word).each do |guess|
      if guess.correct?
        level -= 1
        level = 1 if level < 1
      else
        level += 1
        level = 10 if level > 1
      end
    end
    level 
  end
  def word_prob(word)
    word.weight * word_level(word)
  end
  private
    def word_history(word)
      self.guesses.select{|g| g.word_id == word.id}.sort_by{|g| g.created_at}
    end
    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
end
