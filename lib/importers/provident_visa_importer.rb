module Importers
  class ProvidentVisaImporter
    # accepts csv returns array of line items
    def import(data)
      require 'csv'
      CSV.new(data, :headers => :first_row).collect do |row|
        date = row['Trans Date']
        description = row['Description']
        reference_number = row['Reference Number']
        amount = row['Amount']

        amount_money = amount.scan(/[0-9.\-]+/).join.to_f

        next nil if amount_money == 0.0

        line_item = LineItem.new
        line_item.source = LineItem::SOURCE_IMPORT
        line_item.type = amount_money > 0 ? LineItem::EXPENSE : LineItem::INCOME
        line_item.amount = amount_money.abs
        line_item.comment = "Transaction #{reference_number}" if reference_number.present?
        line_item.payee_name = description
        line_item.event_date = Date.strptime(date, '%m/%d/%Y')
        line_item
      end.compact
    end
  end
end