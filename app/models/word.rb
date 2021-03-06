# == Schema Information
#
# Table name: words
#
#  id         :integer          not null, primary key
#  noun       :string(255)
#  article    :string(255)
#  weight     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Word < ActiveRecord::Base
  attr_accessible :article, :noun, :weight, :definitions
  validates :noun, :presence => true
  #validates :definitions, :presence => true
  validates :weight, :numericality => { :only_integer => true }
  validates :article, :inclusion => { :in => %w(der die das),
    :message => "%{value} is not a valid german article" }

  has_many :guesses
  has_many :users, :through => :guesses

  def to_s
    self.article.to_s.capitalize + " " + self.noun.to_s
  end
  def to_error_s
    self.article.to_s.downcase + " " + self.noun.to_s
  end

end
