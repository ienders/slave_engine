class RolePrivilege < ActiveRecord::Base
  belongs_to :role
  
  validates_presence_of :role_id, :name
  validates_uniqueness_of :name, :scope => :role_id
end
