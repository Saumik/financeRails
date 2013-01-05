module Importers
  class ProvidentVisa
    # accepts csv returns array of line items
    def import(data, file_name = nil)
      require 'csv'
      CSV.new(data, :headers => :first_row).collect do |row|
        date = row['Trans Date'] || row['TRANSACTION DATE']
        description = row['Description']  || row['DESCRIPTION']
        reference_number = row['Reference Number'] || row['REFERENCE']
        amount = row['Amount'] || row['AMOUNT']

        amount_money = amount.scan(/[0-9.\-]+/).join.to_f

        next nil if amount_money == 0.0

        line_item = LineItem.new
        line_item.source = LineItem::SOURCE_IMPORT
        line_item.type = amount_money > 0 ? LineItem::EXPENSE : LineItem::INCOME
        line_item.amount = amount_money.abs
        line_item.comment = "Transaction #{reference_number}" if reference_number.present?
        line_item.payee_name = description.strip
        line_item.event_date = date.length == 8 ? Date.strptime(date, '%m/%d/%y') : Date.strptime(date, '%m/%d/%Y')
        line_item
      end.compact.collect { |line_item| line_item.to_json_as_imported }
    end
  end
end