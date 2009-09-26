class UsersController < AdminController
  before_filter :load_roles

  def admin_table_columns
    ['id', 'email', 'first_name', 'last_name', 'state', 'created_at', 'updated_at']
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      @user.set_roles(params[:roles])
      @user.register!
      @user.activate!
      flash[:message] = 'User was successfully created.'
      redirect_to(user_path(@user))
    else
      render_template_for_section 'new'
    end
  end

  def update
    @user = User.find(params[:id])
    @user.set_roles(params[:roles])

    if @user.update_attributes(params[:user])
      flash[:message] = 'User was successfully updated.'
      redirect_to(user_path(@user))
    else
      render_template_for_section 'edit'
    end
  end

  def search
    @admin_table_columns = admin_table_columns
    redirect_to :action => :index and return if params[:value].blank? 
    @users = User.all(:conditions => ['LOWER(email) LIKE ?', "%#{params[:value].downcase}%"])
    if @users.size == 0
      @users = User.all(:conditions => ['LOWER(CONCAT(first_name, \' \', last_name)) LIKE ?', "%#{params[:value].downcase}%"])
      if @users.size == 0
        flash[:message] = 'Your search yielded no results.'
        redirect_to :action => :index
      end
    end
  end
  
  protected
  def load_roles
    @roles = Role.all
  end

end
