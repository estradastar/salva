class UserArticleController < SalvaController
  def initialize
    super
    @model = UserArticle
    @create_msg = 'La información se ha guardado'
    @update_msg = 'La información ha sido actualizada'
    @purge_msg = 'La información se ha borrado'
    @per_pages = 10
  end
end
