require 'csv'

module Importers
  class ProvidentChecking
    # accepts csv returns array of line items as json array
    def import(data)
      CSV.new(data, :headers => :first_row).collect do |row|
        date = row['Date']
        description = row['Description']
        comments = row['Comments']
        check_number = row['Check Number']
        amount = row['Amount']
        balance = row['Balance']

        if description.ends_with? '(Pending)'
          next
        end

        amount_money = amount.scan(/[0-9.\-]+/).join.to_f

        line_item = LineItem.new
        line_item.source = LineItem::SOURCE_IMPORT
        line_item.type = amount.include?('(') ? LineItem::EXPENSE : LineItem::INCOME
        line_item.amount = amount_money.abs
        line_item.comment = "Check #{check_number}" if check_number.present?
        line_item.payee_name = description if check_number.blank?
        line_item.event_date = Date.strptime(date, '%m/%d/%Y')
        line_item
      end.compact.collect { |line_item| line_item.to_json_as_imported }
    end
  end
end