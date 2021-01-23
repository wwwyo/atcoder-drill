class Question < ApplicationRecord
  # validation
  validates :name, presence: true
  validates :url,  presence: true, uniqueness: true
  validates :is_checked, inclusion: {in: [true, false]}

  def scraping_factory
    itelate_hash_lists(fetch_data)
  end

  def fetch_data
    Scraping.new.execute
  end

  def itelate_hash_lists(hash_lists)
    hash_lists.each do |hash|
      Question.find_or_create_by(hash)
    end
  end

  def self.select_new_question
    Question.where(is_checked: false).sample
  end

  def self.add_check(id)
    question = Question.find(id)
    question.update(is_checked: true)
  end
end
