class SplittingFareInstancesController < InstancesController
  def redirect(instance, password)
    redirect_to splitting_fare_instance_path(instance, p: password)
  end
end
