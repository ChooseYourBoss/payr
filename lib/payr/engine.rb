module Payr
  class Engine < ::Rails::Engine
  	engine_name "payr"

  	initializer "payr.add_payr_helpers" do
   	 	Payr.include_helpers(Payr)
    end
    
  end
end
