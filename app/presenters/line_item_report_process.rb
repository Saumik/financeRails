# performs post processing of items
class LineItemReportProcess
  def perform_after(line_items)
    process_line = [:ignore_transfers]
    line_items.collect do |line_item|
      process_line.each do |process|
        line_item = self.send(process, line_item)
        break if line_item.blank?
      end
      line_item
    end.compact
  end

  def ignore_transfers(line_item)
    line_item.category_name.downcase.include?('transfer') ? nil : line_item
  end
end