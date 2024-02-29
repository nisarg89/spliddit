class Assignment < ActiveRecord::Base
  attr_accessible :price, :ownership, :order

  belongs_to :instance
  belongs_to :agent
  belongs_to :resource, optional: true

end
