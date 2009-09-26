class RolesController < AdminController
  
  def admin_table_columns
    [ 'id', 'title', 'description' ]
  end
  
end
