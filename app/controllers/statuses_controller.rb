class StatusesController < ApplicationController
  def success
    flash.keep(:success)
  end

  def error
    flash.keep(:error)
  end

  def error404
  end

  def error500
  end
end
