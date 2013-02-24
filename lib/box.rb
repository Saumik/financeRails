class Box
  def initialize
    @rows = []
    @row_by_hash = {}
  end

  def add_row(item)
    row = {columns: {}, totals: {}}
    @rows << row
    @row_by_hash[item] = row
  end

  def set_columns(columns, value_types)
    @rows.each do |row|
      columns.each do |col_value|
        column = row[:columns][col_value] = {}
        column[:values] = {}
        value_types.each do |type|
          column[:values][type] ||= 0
        end
      end
      value_types.each do |type|
        row[:totals][type] = 0
      end
    end
  end

  def set_value(row, col, type, value)

  end

  def add_to_value(row, col, type, value)
    return if row.nil?
    column = @row_by_hash[row][:columns][col]
    column[:values][type] += value
    @row_by_hash[row][:totals][type] += value
  end

  def column_amount
    @rows.first[:values].length
  end

  def rows
    @row_by_hash.keys
  end

  def row_column_values(row)
    @row_by_hash[row][:columns].collect { |col_value, col| [col_value, column_values(col)] }
  end

  def row_totals(row)
    @row_by_hash[row][:totals]
  end

  private
  def column_values(column)
    return 0 if column.blank?
    column[:values] || 0
  end
end