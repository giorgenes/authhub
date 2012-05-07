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
			prepend_before_filter :auth_with_authhub
		end
	end

   module InstanceMethods
     def auth_with_authhub
       @authhub_user = session[:authhub_user]
       return unless @authhub_user.nil?
       opts = self.class.authhub_options
       if opts[:test]
         @authhub_user = { 'id' => 1, 'email' => 'test@test.com'}
         return
       end

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
       logger.debug user
       if user.nil?
         redirect_to "http://#{self.class.authhub_options[:server]}" +
         "/user/token?app=#{self.class.authhub_options[:app]}"
       else
         @authhub_user = session[:authhub_user] = user
       end
     end
   end
end
