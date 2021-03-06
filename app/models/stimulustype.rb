class Stimulustype < ActiveRecord::Base
  validates_presence_of :name
  validates_numericality_of :id, :allow_nil => true, :greater_than => 0, :only_integer => true

  belongs_to :institution
  has_many :stimuluslevels

  validates_associated :institution
end
