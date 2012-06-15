module SpannedLineItemSupport
  def self.included(base)
    base.class_eval do
      belongs_to :spanned, :class_name => 'SpannedLineItem'
      field :virtual, :type => Boolean
      field :master, :type => Boolean

      scope :regular, where(:master.ne => true)
    end
  end

    # Spanning Support

  def span(months)
    spanned_line_item = SpannedLineItem.create(:master_line_item => self , :months => months)

    self.master = true
    self.spanned = spanned_line_item
    save

    monthly_amount = self.amount / months

    (1..months).collect do |month_num|
      virtual_line_item = clone_all
      virtual_line_item.amount = monthly_amount
      virtual_line_item.master = nil
      virtual_line_item.virtual = true
      virtual_line_item.event_date = event_date >> (month_num-1)
      virtual_line_item.spanned = spanned_line_item
      virtual_line_item.save
      virtual_line_item
    end

  end

  def is_spanned
    spanned != nil
  end

  def spanned_months
    spanned.months unless spanned.nil?
  end
end