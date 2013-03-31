module User::LineItemAggregateMethods
  def payees
    line_items.only(:payee_name).collect(&:payee_name).uniq.compact
  end

  def manual_payees
    line_items.where(source: LineItem::SOURCE_MANUAL).only(:payee_name).collect(&:payee_name).delete_if(&:nil?).uniq.sort
  end

  def valid_payees
    line_items.only(:payee_name).where(:original_payee_name.ne => nil).collect(&:payee_name).delete_if(&:nil?).uniq.sort
  end

  def categories
    line_items.only(:category_name).collect(&:category_name).uniq.compact.sort
  end

  def all_last_data_for_payee
    line_items.all.inject({}) do |result, item|
      result[item.payee_name.to_s] = { amount: item.amount.to_f, category_name: item.category_name }
      result
    end
  end
end