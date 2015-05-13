class FeedbacksController < ApplicationController  
  before_filter :throttle_feedback, only: :submit_feedback
  
  def feedback
  end

  def submit_feedback
    name = params[:name][0..49]
    email = params[:email][0..49]
    message = params[:message][0..999]
    Delayed::Job.enqueue FeedbackJob.new(name, email, message)
    flash[:success] = "Thanks for the feedback, #{name}!"
    redirect_to root_url + 'success'
  end
end