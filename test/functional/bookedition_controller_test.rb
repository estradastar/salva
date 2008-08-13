require 'salva_controller_test'
require 'bookedition_controller'

class BookeditionController; def rescue_action(e) raise e end; end

class  BookeditionControllerTest < SalvaControllerTest
   fixtures :countries, :booktypes, :books, :mediatypes, :editionstatuses, :bookeditions

  def initialize(*args)
   super
   @mycontroller =  BookeditionController.new
   @myfixtures = { :month => 12, :mediatype_id => 2, :edition => 'Second', :year => 2006, :pages => 340, :editionstatus_id => 1, :book_id => 3 }
   @mybadfixtures = {  :month => nil, :mediatype_id => nil, :edition => nil, :year => nil, :pages => nil, :editionstatus_id => nil, :book_id => nil }
   @model = Bookedition
  end
end
