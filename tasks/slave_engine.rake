namespace :slave_engine do
  
  desc "Create a new admin user by following prompts."
  task :create_admin => :environment do
    STDOUT.sync = true
    
    puts "\n"
    puts "----------------------------------------------------------------------------------------------"
    puts "** Creating Your Admin User. Please follow prompts..."
    puts "----------------------------------------------------------------------------------------------"
    
    user = User.new

    print "Enter your user's email: "
    user.email = $stdin.gets.chomp

    print "Enter your first name: "
    user.first_name = $stdin.gets.chomp

    print "Enter your last name: "
    user.last_name = $stdin.gets.chomp

    print "Enter your password: "
    user.password = user.password_confirmation = $stdin.gets.chomp

    user.set_roles ['admin']

    if user.save
      puts "Your user was saved."
      
      user.state = 'active'
      user.activated_at = Time.now.utc
      if user.save!
        puts "Your user was activated!"
      else
        puts "We were unable to activate your user."
      end
    else
      puts "We were unable to save your user:"
      user.errors.each{|attr,msg| puts "#{attr} - #{msg}" }
    end
    
    puts "Complete."
  end
  
end
