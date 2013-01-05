class ImportedLine
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :account
  belongs_to :line_item
  belongs_to :investment_line_item

  field :account_id
  field :imported_line
end
