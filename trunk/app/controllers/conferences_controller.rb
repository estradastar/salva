class ConferencesController < SalvaController
  def initialize
    super
    @model = Conference
    @create_msg = 'La información se ha guardado'
    @update_msg = 'La información ha sido actualizada'
    @purge_msg = 'La información se ha borrado'
    @per_pages = 10
    @order_by = 'id'
    @children = { 'conference_institution' => %w( institution_id ) }
  end
end
