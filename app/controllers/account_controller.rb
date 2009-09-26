class AccountController < ApplicationController
  before_filter :login_required, :except => [ :create, :lost_password, :reset_password ]

  # Abstract.  Please implement in your app if you need user creation, as this is fairly app specific.
  def create
    raise ActionController::RoutingError.new("Create not implemented, please override in your app.")
  end
  
  def lost_password
    return unless request.post?
    @user = User.find(:first, :conditions => { :email => params[:email] })
    flash(:warning) and return if !params[:email] || @user.nil?
    
    @user.generate_remote_key!
    UserMailer.deliver_reset_password(@user, reset_password_url(:key => @user.remote_key))
    flash(:message)
    redirect_to login_url
  end
  
  def reset_password
    if request.get?
      @user = User.find_by_remote_key(params[:key])
      if @user.nil?
        flash(:warning => [:account, :reset_password, :no_key])
        redirect_to login_url
      end
      self.current_user = @user #log in user
    elsif request.post?
      redirect_to :action => 'reset_password', :key => params[:key] and return if !logged_in?
      @user = current_user
      @user.crypted_password = ""
      
      if @user.update_attributes(params[:user])
        @user.generate_remote_key!
        flash(:message)
        redirect_to '/'
      else
        flash(:warning)
      end
    end
  end
  
end