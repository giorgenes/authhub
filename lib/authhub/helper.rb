require 'net/http'
require 'json'

module Authhub
	def self.included(base)
		base.extend(ClassMethods)
	end

	module ClassMethods
		def authenticate_with_authhub(app, options = {})
			cattr_accessor :authhub_options
			self.authhub_options = {
				:server => "authhub.com",
				:authserver => "authhub.com",
				:app => app}
			self.authhub_options.merge!(options)
			send :include, InstanceMethods
			before_filter :auth_with_authhub
		end
	end

	module InstanceMethods
		def auth_with_authhub
			@authhub_user_id = session[:authhub_user_id]
			return unless @authhub_user_id.nil?
			opts = self.class.authhub_options
			user = nil
			token = params[:token]
			unless token.nil? or token.empty?
				if opts[:callback] then
					user = opts[:callback].call(opts[:app], token, opts[:secret])
				else
					u = "http://#{opts[:authserver]}/app/" +
						"#{opts[:app]}" +
						"/user.json?token=#{token}" +
						"&secret=#{opts[:secret]}"
					logger.debug "authhub: #{u}"
					uri = URI.parse(u)
					user = JSON.parse(Net::HTTP.get(uri))
				end
			end
			if user.nil? or user['user'].nil?
				redirect_to "http://#{self.class.authhub_options[:server]}" +
					"/users/token?app=#{self.class.authhub_options[:app]}"
			else
				@authhub_user_id = session[:authhub_user_id] = user['user']['id']
			end
		end
	end
end
