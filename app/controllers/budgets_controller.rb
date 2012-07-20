class BudgetsController < ApplicationController
  before_filter :assign_section
  def create
    @budget_item = BudgetItem.create(params[:budget_item])
    render :nothing => true
  end

  def index
    @budget_items = BudgetItem.all
    @categories = LineItem.categories

    @presenter = BudgetReportPresenter.new
  end

  def expense_summary
    @monthly_expenses = []
    months_between(5.months.ago.to_date, Date.today).each do |date|
      @monthly_expenses << {date: date, expense: LineItem.sum_with_filters(:in_month_of_date => date, :categories => JSON.parse(params[:categories]))}
    end

    render :layout => false
  end

  private

  def assign_section
    @override_section = 'line_items'
  end
end
