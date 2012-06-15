class SpannedLineItem
  include Mongoid::Document

  field :months, :type => Integer

  belongs_to :master_line_item, :class_name => 'LineItem'
  has_many :line_items, :foreign_key => 'spanned_id'
end
