class MailingListsController < ApplicationController

  before_filter :throttle_mailing_list, only: :mailing_list

  def mailing_list
    respond_to do |format| 
      format.js { }
    end
    return if @limited
    email = params[:email]
    if email && email.length > 0
      agent = Agent.new(name: "mailing list", email: email, mailing_list: true)
      agent.save!
    end
  end
end
