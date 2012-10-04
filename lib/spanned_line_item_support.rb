module SpannedLineItemSupport
  def self.included(base)
    base.class_eval do
      field :spanned, :type => Boolean, default: false
      field :span_from, :type => Date
      field :span_until, :type => Date
    end
    base.extend(ClassMethods)
  end

  # Spanning Support
  def is_spanned
    spanned != nil
  end

  def spans_in?(month)
    span_from.beginning_of_month <= month && span_until.end_of_month >= month
  end

  def clone_for_date(date)
    item = clone_all
    item.event_date.change(month: date.month, year: date.year)
    item.amount = item.amount / (months_span + 1)
    item
  end

  def months_span
    12 * (span_until.year - span_from.year) + span_until.month - span_from.month
  end

  module ClassMethods
    # filters[:spanned] means we want to count spanned separately
    def add_spanning_filters(filter_chain, filters)
      return filter_chain unless !!filters[:support_spanned]
      filter_chain.where(:spanned => (filters[:spanned].present? ? filters[:spanned] : false))
    end

    def add_spanned_items(filters, items)
      return items unless !!filters[:support_spanned]
      all_spanned_items = get_filters(filters.merge(spanned: true, in_month_of_date: nil))
      all_spanned_items.inject(items) do |result, item|
        if filters[:in_month_of_date].present? and item.spans_in?(filters[:in_month_of_date])
          result << item.clone_for_date(filters[:in_month_of_date])
        end
        result
      end
    end

    def search_spanned_line_items_with_filters(filters)
      add_spanned_items(filters, [])
    end
  end
end