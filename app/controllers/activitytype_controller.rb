class ActivitytypeController < SalvaController
  def initialize
    super
    @model = Activitytype
    @create_msg = 'La información se ha guardado'
    @update_msg = 'La información ha sido actualizada'
    @purge_msg = 'La información se ha borrado'
    @per_pages = 10
    @order_by = 'id'
#    @list = { :include => [:activities], :conditions => "activitytypes.name = 'Otras actividades' AND activities.activitytype_id = activitytypes.id" }
  end
end
