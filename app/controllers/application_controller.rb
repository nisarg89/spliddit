class ApplicationController < ActionController::Base
  protect_from_forgery

  include Throttler
  include InstanceHelpers

  before_filter :throttle_requests


end