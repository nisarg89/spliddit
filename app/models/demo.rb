class Demo < ActiveRecord::Base
  attr_accessible :ip
  belongs_to :instance
end
