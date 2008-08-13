class UserRoleingroupController < SalvaController
  def initialize
    super
    @model = UserRoleingroup
    @create_msg = 'La información se ha guardado'
    @update_msg = 'La información ha sido actualizada'
    @purge_msg = 'La información se ha borrado'
    @per_pages = 10
    @order_by = 'id'
  end

  def set_userid
    @edit.user_id = params[:edit][:user_id]
    @edit.moduser_id = session[:user] if @edit.has_attribute?('moduser_id')
  end
end
