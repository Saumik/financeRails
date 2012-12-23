module InvestmentHelper
  def as_table(investment_plan)
    table_data = []
    row = 0
    col = 0
    current_level = 0

    last_level_in_row = 0
    investment_plan.investment_allocation_plans.each do |allocation_plan|
      current_level = 1
      row, col, last_level_in_row = next_row_col_for_level(last_level_in_row, current_level, row, col) if row > 0

      table_data[row] ||= []
      table_data[row][col] = allocation_plan

      allocation_plan.investment_allocation_plans.each do |child_alloc_plan|
        current_level = 2
        row, col, last_level_in_row = next_row_col_for_level(last_level_in_row, current_level, row, col)

        table_data[row] ||= []
        table_data[row][col] = child_alloc_plan

        child_alloc_plan.investment_assets.each do |allocation_asset|
          current_level = 3
          row, col, last_level_in_row = next_row_col_for_level(last_level_in_row, current_level, row, col)

          table_data[row] ||= []
          table_data[row][col] = allocation_asset
        end
      end
    end

    puts table_data.inspect
    table_data
  end

  def next_row_col_for_level(last_level_in_row, current_level, row, col)
    puts "#{last_level_in_row} #{current_level}"
    if last_level_in_row >= current_level
      puts 'new row'
      [row+1, 0, current_level]
    else
      [row, col+1, current_level]
    end
  end
end
