# performs post processing of items
class LineItemReportProcess
  def perform_after(line_items)
    process_line = [:ignore_transfers, :ignore_exclude_from_reports]
    line_items.collect do |line_item|
      process_line.each do |process|
        line_item = self.send(process, line_item)
        break if line_item.blank?
      end
      line_item
    end.compact
  end

  def ignore_transfers(line_item)
    (line_item.category_name.present? and line_item.category_name.downcase.include?('transfer')) ? nil : line_item
  end

  def ignore_exclude_from_reports(line_item)
    line_item.tags.include?(LineItem::TAG_EXCLUDE_FROM_REPORTS) ? nil : line_item
  end

  def self.ignore_transfers(line_item)
    (line_item.category_name.present? and line_item.category_name.downcase.include?('transfer'))
  end

  def self.ignore_exclude_from_reports(line_item)
    line_item.tags.include?(LineItem::TAG_EXCLUDE_FROM_REPORTS)
  end

  def self.should_ignore?(line_item)
    ignore_transfers(line_item) || ignore_exclude_from_reports(line_item)
  end
end