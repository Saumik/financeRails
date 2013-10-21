require 'csv'

module Importers
  class ChaseCC
    # accepts csv returns array of line items as json array
    def import(data, file_name = nil)
      CSV.new(data, :headers => :first_row).collect do |row|
        type = row['Type']
        date = row['Trans Date']
        description = row['Description']
        amount = row['Amount']

        amount_money = amount.scan(/[0-9.\-]+/).join.to_f

        line_item = LineItem.new
        line_item.source = LineItem::SOURCE_IMPORT
        line_item.type = amount_money < 0 ? LineItem::EXPENSE : LineItem::INCOME
        line_item.amount = amount_money.abs
        line_item.payee_name = description.strip
        line_item.event_date = Date.strptime(date, '%m/%d/%Y')
        line_item
      end.compact.collect { |line_item| line_item.to_json_as_imported }
    end
  end
end