module Importers
  class ProvidentCheckingImporter
    # accepts csv returns array of line items
    def import(data)
      require 'csv'
      CSV.new(data, :headers => :first_row).collect do |row|
        date = row['Date']
        description = row['Description']
        comments = row['Comments']
        check_number = row['Check Number']
        amount = row['Amount']
        balance = row['Balance']

        amount_money = amount.scan(/[0-9.\-]+/).join.to_f

        line_item = LineItem.new
        line_item.source = LineItem::SOURCE_IMPORT
        line_item.type = amount.include?('(') ? LineItem::EXPENSE : LineItem::INCOME
        line_item.amount = amount_money.abs
        line_item.comment = "Check #{check_number}" if check_number.present?
        line_item.payee_name = description if check_number.blank?
        line_item.event_date = Date.strptime(date, '%m/%d/%Y')
        line_item
      end
    end
  end
end