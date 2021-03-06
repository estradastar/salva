class UserTechproductsController < MultiSalvaController
  def initialize
    super
    @model = UserTechproduct
    @views = [ :techproduct, :user_techproduct, :institution ]
    @models = [ UserTechproduct, [ Techproduct, Institution ] ]
    @create_msg = 'La información se ha guardado'
    @update_msg = 'La información ha sido actualizada'
    @purge_msg = 'La información se ha borrado'
    @per_pages = 10
    @order_by = 'id'
  end
end
