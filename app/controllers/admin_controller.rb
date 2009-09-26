class AdminController < ApplicationController
  before_filter :login_required, :only => [:redirect_for_role]
  before_filter :admin_required, :except => [:redirect_for_role]
  
  helper_method :model_name, :instance, :model
  
  layout 'admin'
  
  def admin_table_columns
    raise Exception.new("Must implement admin_table_columns (have it return an array of column names to display)")
  end
  
  def index
    @admin_table_columns = admin_table_columns
    @model_collection = instance_variable_set(
      "@#{instance.pluralize}",
      model.paginate(:page => (params[:page] || 1), :per_page => (params[:per_page] || 25))
    )
    render_template_for_section 'index'
  end

  def show
    @m = instance_variable_set(instance, model.find(params[:id]))
    render_template_for_section 'show'
  end

  def new
    @m = instance_variable_set(instance, model.new)
    render_template_for_section 'new'
  end

  def create
    @m = instance_variable_set(instance, model.new(params[instance.to_sym]))
    if @m.save
      flash[:message] = '#{model_name.titleize} was successfully created.'
      redirect_to :action => 'show', :id => @m.id
    else
      render_template_for_section 'new'
    end
  end

  def edit
    @m = instance_variable_set(instance, model.find(params[:id]))
    render_template_for_section 'edit'
  end

  def update
    @m = instance_variable_set(instance, model.find(params[:id]))
    if @m.update_attributes(params[instance.to_sym])
      flash[:message] = '#{model_name.titleize} was successfully updated.'
      redirect_to :action => 'show', :id => params[:id]
    else
      render_template_for_section 'edit'
    end
  end

  def destroy
    @m = instance_variable_set(instance, model.find(params[:id]))
    @m.destroy
    flash[:message] = "#{model_name}.titleize was deleted"
    redirect_to :action => 'index'
  end

  def force_error
    raise "Im an error"
  end
  
  def redirect_for_role
    redirect_to :controller => 'users', :action => 'index' and return
  end
    
  protected
  def controller_name
    self.class.to_s.demodulize.gsub(/Controller/, '')
  end
  
  def model_name
    controller_name.singularize
  end
  
  def model
    Object.const_get(model_name.classify)
  end
  
  def instance
    model_name.underscore
  end

  def render_template_for_section(action)
    render(:template => template_exists?("#{controller_name}/#{action}") ? "#{controller_name}/#{action}" : "default/#{action}")
  end
  
  def template_exists?(template_name)
    begin
      self.view_paths.find_template(template_name, self.send(:default_template_format))
      true
    rescue ActionView::MissingTemplate
      false
    end
  end
  
end