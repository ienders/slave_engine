require 'slave_engine/authenticated_system'
require 'slave_engine/admin_helper'

module SlaveEngine  
  module User
    def self.included(klass)            
      klass.module_eval do
        require 'digest/sha1'
        require 'restful_authentication/authorization/aasm_roles'
        
        include ::Authentication
        include ::Authentication::ByPassword
        include ::Authentication::ByCookieToken
        include ::Authorization::AasmRoles

        has_many :user_roles, :dependent => :destroy
        has_many :roles, :through => :user_roles

        validates_presence_of     :email
        validates_length_of       :email,       :within => 6..100
        validates_uniqueness_of   :email
        validates_format_of       :email,       :with => Authentication.email_regex, :message => Authentication.bad_email_message
        validates_format_of       :first_name,  :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
        validates_format_of       :last_name,   :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
        validates_length_of       :first_name,  :maximum => 100, :allow_nil => true
        validates_length_of       :last_name,   :maximum => 100, :allow_nil => true

        attr_accessible  :email, :first_name, :last_name, :password, :password_confirmation, :wants_email

        named_scope :non_guest, :conditions => ["state != 'guest'"]
      end
      
      klass.extend(ClassMethods)
    end
    
    module ClassMethods
      def authenticate(email, password)
        return nil if email.blank? || password.blank?
        u = find_in_state :first, :active, :conditions => {:email => email}
        u && u.authenticated?(password) ? u : nil
      end
    end
  
    def email=(value)
      write_attribute :email, (value ? value.downcase : nil)
    end

    def to_s; "#{email}"; end
    
    def full_name; "#{first_name} #{last_name}"; end

    def display_name
      first_name ? "#{first_name} #{last_name}" : email
    end

    def short_display_name
      first_name ? "#{first_name.split.collect{|p| p.first.upcase + '.'}.join} #{last_name}" : email
    end

    def has_role?(role_title)
      return false unless role_title
      role_title = role_title.to_s
      self.role_titles.include?(role_title)
    end

    def role_titles
      self.roles.collect {|r| r.title }
    end

    def set_roles(roles_to_set)
      self.roles.clear
      roles_to_set = roles_to_set.keys if roles_to_set.is_a?(Hash)
      roles_to_set.each do |role_title|
        role = Role.find_by_title(role_title.to_s)
        self.roles << role if role
      end if roles_to_set
    end

    def with_roles
      @privilege_set ||= Role.merge_privileges(*self.roles)
    end

    protected
    def make_activation_code
      self.deleted_at = nil
      self.activation_code = self.class.make_token
    end
  end
end

ActionView::Base.send(:include, SlaveEngine::AdminHelper)