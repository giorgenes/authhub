require 'authhub/helper'

ActionController::Base.class_eval do
	include Authhub
end
