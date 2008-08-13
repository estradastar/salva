class UserPrizeController < MultiSalvaController
  def initialize
    super
    @model = UserPrize
    @views = [:prize, :user_prize, :institution]
    @models = [ UserPrize, [Prize, Institution] ]
    @create_msg = 'La información se ha guardado'
    @update_msg = 'La información ha sido actualizada'
    @purge_msg = 'La información se ha borrado'
    @per_pages = 10
    @order_by = 'id'
  end
end
