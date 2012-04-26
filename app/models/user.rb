class User
  include Mongoid::Document

  field :last_date, :type => Date
end
