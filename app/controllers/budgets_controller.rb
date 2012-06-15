class BudgetsController < ApplicationController
  def create
    @budget_item = BudgetItem.create(params[:budget_item])
    render :nothing => true
  end

  def index
    @budget_items = BudgetItem.all
    @categories = LineItem.category_names
  end

  def expense_summary
    puts params[:categories]
    @monthly_expenses = []
    months_between(5.months.ago.to_date, Date.today).each do |date|
      @monthly_expenses << {date: date, expense: LineItem.expense_in_month(date, JSON.parse(params[:categories]))}
    end

    render :layout => false
  end
end
