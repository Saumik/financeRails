class Money
  def import(data, file_name = nil)
    @imported_data = []

    balance = 0

    data.split('^').each do |transaction_string|

      amount = first_match(transaction_string.match(/^T([^\n]+)/))

      next if amount == nil

      amount = amount.delete(',').to_f

      category_full_name = first_match(transaction_string.match(/^L([^\n]+)/)) || ""
      date_parts = transaction_string.match(/D([0-9]+)\/([0-9]+)'([0-9]+)/)
      payee_name = first_match(transaction_string.match(/^P([^\n]+)/)) || ""
      comment = first_match(transaction_string.match(/^M([^\n]+)/)) || ""

      date_day = date_parts[1]
      date_month = date_parts[2]
      date_year = date_parts[3]

      # category can be of format [Saving] this means it's transfer
      transfer_name = first_match(category_full_name.match(/^\[(.+)\]/))

      if (transfer_name != nil)
        payee_name = category_full_name

        if (amount > 0)
          category_full_name = LineItem::TRANSFER_IN
        else
          category_full_name = LineItem::TRANSFER_OUT
        end
      end

      balance += amount

      line_item = LineItem.new
      line_item.type = amount > 0 ? LineItem::INCOME : LineItem::EXPENSE
      line_item.amount = amount.abs
      line_item.category_name = category_full_name.strip
      line_item.payee_name = payee_name.strip
      line_item.event_date = Date.new(date_year.to_i, date_month.to_i, date_day.to_i)
      line_item.comment = comment.strip
      line_item.balance = balance


      @imported_data << line_item

    end
  end
end