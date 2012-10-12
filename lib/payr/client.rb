require "openssl"
require "base64"

module Payr
	class Client

		def get_paybox_params_from params
			raise ArgumentError if params[:command_id].nil? || params[:buyer_email].nil? || params[:total_price].nil?
			command_timestamp = Time.now.utc.iso8601
			returned_hash = { pbx_site: Payr.site_id, 
												pbx_rang: Payr.rang,
												pbx_identifiant: Payr.paybox_id,
												pbx_total: params[:total_price],
												pbx_devise: convert_currency,
												pbx_cmd: params[:command_id],
												pbx_porteur: params[:buyer_email],
												pbx_retour: build_return_variables(Payr.callback_values),
												pbx_hash: Payr.hash.upcase,
												pbx_time: command_timestamp }


			# optionnal parameters
			returned_hash.merge!(pbx_typepaiement: Payr.typepaiement, 
													 pbx_typepcarte: Payr.typecard) unless Payr.typepaiement.nil? || Payr.typecard.nil?
			returned_hash.merge!(pbx_effectue: Payr.callback_route,
													 pbx_refuse: 	 Payr.callback_refused_route,
													 pbx_annule: 	 Payr.callback_cancelled_route) unless Payr.callback_route.nil?

			base_params = self.to_base_params(returned_hash)			
			returned_hash.merge(pbx_hmac: self.generate_hmac(base_params))
		end


		def check_response params
			query = re_build_query params
			signature = get_signature params
			public_key = OpenSSL::PKey::RSA.new(File.read(File.expand_path(File.dirname(__FILE__) + '/keys/pubkey.pem')))
			check_response_verify query, Base64.decode64(Rack::Utils.unescape(signature)), public_key
		end

  	protected
  	def get_signature params
  		 params[params.index("&signature=")+"&signature=".length..params.length]
  	end
  	def re_build_query params
			params[params.index("?")+1..params.index("&signature")-1]
  	end
  	def check_response_verify params, signature, pub_key
  		digest = OpenSSL::Digest::SHA1.new
			pub_key.verify digest, signature, params
		end

  	def generate_hmac base_params
			binary_key = [Payr.secret_key].pack("H*")
			OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new(Payr.hash.to_s), binary_key, base_params).upcase
		end

  	def to_base_params params={}  
  		params.to_a.collect do |pair|
  			"#{pair[0].upcase}=#{pair[1]}"
  		end.join("&")
  	end

	  def build_return_variables variables
  		variables.to_a.collect do |pair|
  			"#{pair[0]}:#{pair[1].capitalize}"
  		end.join(";")
		end
	 	def convert_currency
			case Payr.currency
		 	when :euro
		 		978
		 	when :us_dollars
		 		840
		 	else
		 		978
		 	end 
		end
	end

end