class TechproductsController < SalvaController
  def initialize
    super
    @model = Techproduct
    @create_msg = 'La información se ha guardado'
    @update_msg = 'La información ha sido actualizada'
    @purge_msg = 'La información se ha borrado'
    @per_pages = 10
    @order_by = 'id'
  end
end
