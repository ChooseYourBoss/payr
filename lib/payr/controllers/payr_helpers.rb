module Payr
	module PayrHelpers
		def paybox_hidden_fields opts={}
			raise ArgumentError if opts.blank?
			opts.to_a.collect do |pair|
				hidden_field_tag pair[0].upcase, pair[1]
			end.join("").html_safe
		end

		def paybox_form submit_name, opts={}
			raise ArgumentError if opts.blank?
			("<form id='payrForm' action='#{Payr::Client.new.select_url}' method='POST'>" +
			paybox_hidden_fields(opts) +
			"<input type='submit' value='#{submit_name}'>" +
		  "</form>").html_safe
		end
	end
end