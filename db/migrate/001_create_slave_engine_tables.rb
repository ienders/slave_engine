class CreateSlaveEngineTables < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.column :email,                     :string, :limit => 100
      t.column :first_name,                :string, :limit => 100
      t.column :last_name,                 :string, :limit => 100
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :remember_token,            :string, :limit => 40
      t.column :remember_token_expires_at, :datetime
      t.column :activation_code,           :string, :limit => 40
      t.column :activated_at,              :datetime
      t.column :state,                     :string, :null => :no, :default => 'passive'
      t.column :deleted_at,                :datetime
      t.timestamps
    end

    add_index :users, :email, :unique => true
    
    create_table :roles do |t|
      t.string   :title, :limit => 20
      t.string   :description
      t.timestamps
    end

    add_index :roles, :title, :unique => true
    
    create_table :role_privileges do |t|
      t.integer  :role_id
      t.string   :name
      t.boolean  :value, :default => false
      t.timestamps
    end

    add_index :role_privileges, [:role_id, :name], :unique => true
    
    create_table :user_roles do |t|
      t.integer :user_id
      t.integer :role_id
      t.timestamps
    end
    
    add_index :user_roles, [:user_id, :role_id], :unique => true
    add_index :user_roles, :role_id
    
    execute "INSERT INTO roles (title, description) VALUES ('admin', 'Admin')"
  end

  def self.down
    drop_table :user_roles
    drop_table :role_privileges
    drop_table :roles
    drop_table :users
  end
end
