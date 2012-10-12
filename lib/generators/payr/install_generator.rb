module Payr
	
	class InstallGenerator < Rails::Generators::Base
		source_root File.expand_path("../../templates", __FILE__)

		desc "This generator creates an initializer file at config/initializers"
	  def init
	    copy_file "payr.rb", "config/initializers/payr.rb"
	  end
	end

end