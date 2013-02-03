class Guess < ActiveRecord::Base
  attr_accessible :answer, :user_id, :word_id
  validates :user_id, presence: true
  validates :word_id, presence: true
  validates :answer, :inclusion => { :in => %w(der die das),
                                      :message => "%{value} is not a valid german article" }
  belongs_to :user
  belongs_to :word

  default_scope order: 'guesses.created_at DESC'

  def correct?
    answer == self.word.article
  end

end
