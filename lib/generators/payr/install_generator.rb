module Payr
	
	class InstallGenerator < Rails::Generators::Base
		include Rails::Generators::Migration
		source_root File.expand_path("../../templates", __FILE__)
		desc "This generator creates an initializer file at config/initializers and adds migration file"

   	def self.next_migration_number(dirname)
     	if ActiveRecord::Base.timestamped_migrations
     		Time.new.utc.strftime("%Y%m%d%H%M%S")
     	else
      	"%.3d" % (current_migration_number(dirname) + 1)
     	end
   	end
   
   	def create_migration_file
      migration_template 'migration.rb', 'db/migrate/create_bills_table.rb'
   	end
   
	  def init
	    copy_file "payr.rb", "config/initializers/payr.rb"
	  end
	end

end