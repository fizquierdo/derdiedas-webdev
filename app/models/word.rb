class Word < ActiveRecord::Base
  attr_accessible :article, :noun, :weight
  validates :noun, :presence => true
  validates :weight, :numericality => { :only_integer => true }
  validates :article, :inclusion => { :in => %w(der die das),
    :message => "%{value} is not a valid german article" }

  def to_s
    self.article.to_s.capitalize + " " + self.noun.to_s
  end

end
