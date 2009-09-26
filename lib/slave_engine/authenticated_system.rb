module SlaveEngine
  module AuthenticatedSystem
    def self.included(klass)            
      klass.module_eval do        
        protect_from_forgery
        filter_parameter_logging :password

        helper_method :logged_in_with_privilege?, :logged_in_as_admin?
      end
    end
    
    def admin_required
      (logged_in_as_admin? && current_user.with_roles.can_access(controller_name)) || access_denied
    end

    def logged_in_with_privilege?(privilege_name)
      logged_in? && current_user.with_roles[privilege_name]
    end

    def logged_in_as_admin?
      logged_in_with_privilege?(:is_admin)
    end
    
    protected
    def logged_in?
      !!current_user
    end

    def current_user
      @current_user ||= (login_from_session || login_from_basic_auth || login_from_cookie) unless @current_user == false
    end

    def current_user=(new_user)
      session[:user_id] = new_user ? new_user.id : nil
      @current_user = new_user || false
    end

    def authorized?(action = action_name, resource = nil)
      logged_in?
    end

    def login_required
      authorized? || access_denied
    end

    def access_denied
      respond_to do |format|
        format.html do
          store_location
          redirect_to new_session_path
        end
        format.any(:json, :xml) do
          request_http_basic_authentication 'Web Password'
        end
      end
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(params[:r] || session[:return_to] || default)
      session[:return_to] = nil
    end

    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?, :authorized? if base.respond_to? :helper_method
    end

    def login_from_session
      self.current_user = ::User.find_by_id(session[:user_id]) if session[:user_id]
    end

    def login_from_basic_auth
      authenticate_with_http_basic do |email, password|
        self.current_user = ::User.authenticate(email, password)
      end
    end

    def login_from_cookie
      user = cookies[:auth_token] && ::User.find_by_remember_token(cookies[:auth_token])
      if user && user.remember_token?
        self.current_user = user
        handle_remember_cookie! false
        self.current_user
      end
    end

    def logout_keeping_session!
      # Kill server-side auth cookie
      @current_user.forget_me if @current_user.is_a? ::User
      @current_user = false
      kill_remember_cookie!
      session[:user_id] = nil
    end

    def logout_killing_session!
      logout_keeping_session!
      reset_session
    end

    def valid_remember_cookie?
      return nil unless @current_user
      (@current_user.remember_token?) && 
        (cookies[:auth_token] == @current_user.remember_token)
    end

    def handle_remember_cookie!(new_cookie_flag)
      return unless @current_user
      case
      when valid_remember_cookie? then @current_user.refresh_token
      when new_cookie_flag        then @current_user.remember_me 
      else                             @current_user.forget_me
      end
      send_remember_cookie!
    end

    def kill_remember_cookie!
      cookies.delete :auth_token
    end

    def send_remember_cookie!
      cookies[:auth_token] = {
        :value   => @current_user.remember_token,
        :expires => @current_user.remember_token_expires_at }
    end
  end
end