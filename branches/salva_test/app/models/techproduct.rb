class Techproduct < ActiveRecord::Base
validates_presence_of :title, :authors
validates_numericality_of :techproducttype_id
belongs_to :techproducttype
belongs_to :institution
end
