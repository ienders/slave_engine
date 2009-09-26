module SlaveEngine
  module AdminHelper

    def admin_table(collection, columns)
      render(
        :partial => 'shared/admin_table',
        :locals  => {
          :collection => collection,
          :columns    => columns
        }
      )
    end

    def admin_controls(name, options = {}, &block)      
      control_sets = {
        :index => [ :new ],
        :new   => [ :index ],
        :edit  => [ :index, :new, :show, :destroy ],
        :show  => [ :index, :new, :edit, :destroy ]
      }

      control_set = (options[:controls] ? options[:controls].clone : nil) || []
      control_set.unshift(control_sets[options[:for]]) if options[:for]

      render(
        :partial => 'shared/admin_controls',
        :locals => {
          :controller         => options[:controller] || name.to_s.tableize,
          :obj                => options[:object] || instance_variable_get("@#{name}") || nil,
          :control_set        => control_set,
          :additional_content => block_given? ? capture(&block) : ''
        }
      )
    end

  end
end