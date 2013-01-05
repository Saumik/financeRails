module Importers
  class Scottrade
    HEADER_TRANSACTIONS = 'Symbol,Quantity,Price,ActionNameUS,TradeDate,SettledDate,Interest,Amount,Commission,Fees,CUSIP,Description,ActionId,TradeNumber,RecordType,TaxLotNumber'
    # accepts csv returns array of line items
    def import(data, file_name = nil)
      data = strip_non_ascii(data)
      require 'csv'
      CSV.new(data, :headers => :first_row).collect do |row|
        if data.starts_with?(HEADER_TRANSACTIONS)
          # For deposit - the amount (total deposit)
          # For purchase - the price (amount - last price) and number (quantity)
          action_name = row['ActionNameUS']
          next if action_name.blank?
          type = row['RecordType']
          symbol = row['Symbol']
          quantity = row['Quantity'].to_i
          event_date = Date.strptime(row['TradeDate'], '%m/%d/%Y')
          amount = row['Amount'].to_f
          price = row['Price'].to_f
          commission = row['Commission'].to_f

          line_item = InvestmentLineItem.new
          line_item.event_date = event_date

          if action_name == 'IRA Receipt' or action_name == 'Cash Adjustment'
            line_item.type = InvestmentLineItem::TYPE_DEPOSIT
            line_item.total_amount = line_item.amount = amount
          elsif action_name == 'Dividend'
            line_item.type = InvestmentLineItem::TYPE_DIVIDEND
            line_item.symbol = symbol
            line_item.total_amount = line_item.amount = amount
          elsif action_name == 'Credit Interest'
            line_item.type = InvestmentLineItem::TYPE_INTEREST
            line_item.total_amount = line_item.amount = amount
          else
            line_item.type = (action_name == 'Buy' ? InvestmentLineItem::TYPE_BUY : InvestmentLineItem::TYPE_SELL)
            line_item.symbol = symbol
            line_item.number = quantity.abs
            line_item.amount = price
            line_item.total_amount = amount.abs
            line_item.fee = commission.abs
          end

          line_item
        else
          symbol = row['Symbol']
          quantity = row['Qty'].to_i.abs
          event_date = Date.strptime(row['Event Date'], '%m/%d/%Y') if row['Event Date'].present?
          event_date = Date.strptime(file_name.split('.')[0].split('-')[1].strip.gsub(':', '/'), '%m/%d/%Y') if file_name.present?
          event_date ||=  Time.now
          last_price = strip_non_numbers(row['Last Price'])

          line_item = InvestmentLineItem.new
          line_item.type = InvestmentLineItem::TYPE_STATUS
          line_item.event_date = event_date
          line_item.symbol = symbol
          line_item.number = quantity
          line_item.amount = last_price
          line_item
        end
      end.compact.collect { |line_item| line_item.to_json_as_imported }
    end

    def strip_non_ascii(str)
      encoding_options = {
        :invalid           => :replace,  # Replace invalid byte sequences
        :undef             => :replace,  # Replace anything not defined in ASCII
        :replace           => '',        # Use a blank for those replacements
        :universal_newline => true       # Always break lines with \n
      }

      str.encode Encoding.find('ASCII'), encoding_options
    end

    def strip_non_numbers(str)
      str.scan(/[0-9.\-]+/).join.to_f
    end
  end
end