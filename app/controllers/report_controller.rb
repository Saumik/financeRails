class ReportController < ApplicationController
  def from_date_select(params, key)
    Time.utc(params[key + "(1i)"].to_i, params[key + "(2i)"].to_i, params[key + "(3i)"].to_i)
  end

  def month_expenses

    @selected_month = Time.now.prev_month
    @selected_month = Time.at(params[:date].to_i) if params[:date]
    @selected_month = from_date_select(params[:report], 'month') if params[:report]

    line_items = LineItem.where(:event_date => {'$gte' => @selected_month.beginning_of_month,'$lte' => @selected_month.end_of_month.end_of_day})

    expenses, income = line_items.partition(&:expense?)

    # Getting each category and the sum of all amounts
    @expenses = Hash[expenses.group_by(&:category_name).collect {|key, value| [key, value.sum(&:amount)] }.sort]
    @income = Hash[income.group_by(&:category_name).collect {|key,value| [key, value.sum(&:amount)] }.sort]

    @total_income = @income.values.sum
    @total_expenses = @expenses.values.sum

  end

end
