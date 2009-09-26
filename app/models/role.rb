class Role < ActiveRecord::Base
  has_many :user_roles, :dependent => :destroy
  has_many :users, :through => :user_roles
  has_many :privileges, :class_name => "RolePrivilege"
  
  validates_presence_of :title
  validates_uniqueness_of :title
  validates_format_of :title, :with => /[a-z_0-9]/, :message => 'should only contain lowercase letters, numbers, and underscores'
  
  after_save :save_privileges
    
  UNIVERSAL_PRIVILEGES = %w{is_admin}
    
  def to_s
    "#{description}"
  end
  
  def master?
    title.to_sym == :admin
  end
  
  def admin?
    master? || with_privileges.is_admin?
  end
    
  def self.privilege_names
    UNIVERSAL_PRIVILEGES
  end
  
  def self.merge_privileges(*roles)
    privileges = roles.collect {|r| r.is_a?(Role) ? r.all_privileges : r }
    complete_privileges = PrivilegeSet.new
    privileges.compact.each do |privilege_set|
      privilege_set.each do |name, val|
        unless complete_privileges.has_key?(name) && complete_privileges[name] == true
          complete_privileges[name] = val 
        end
      end
    end
    complete_privileges
  end
  
  def all_privileges
    privs = PrivilegeSet.new
    privileges.each do |privilege|
      privs[privilege.name] = privilege.value
    end
    if master?
      privs[:master] = true 
      privs[:is_admin] = true
    end
    privs
  end
  alias :with_privileges :all_privileges

  def privileges=(new_privileges)
    raise ArgumentError unless new_privileges.is_a?(Hash)
    @privileges_to_save = new_privileges
  end
  
  def save_privileges
    return unless @privileges_to_save
    @privileges_to_save.each do |name, h|
      priv = privileges.find_by_name(name.to_s) || privileges.build(:name => name.to_s)
      priv.update_attributes(h)
    end
  end
  protected :save_privileges
    
end
