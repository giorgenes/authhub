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
			u = "http://#{self.class.authhub_options[:authserver]}/app/" +
				"#{self.class.authhub_options[:app]}" +
				"/user.json?token=#{params[:token]}" +
				"&secret=#{self.class.authhub_options[:secret]}"
			logger.debug "authhub: #{u}"
			uri = URI.parse(u)
			user = JSON.parse(Net::HTTP.get(uri))
			if user['user'].nil?
				redirect_to "http://#{self.class.authhub_options[:server]}" +
					"/apps/users/token?app=#{self.class.authhub_options[:app]}"
			else
				@authhub_user_id = session[:authhub_user_id] = user['user']['id']
			end
		end
	end
end
