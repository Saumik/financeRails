class BudgetsController < ApplicationController
  MAIN_OBJECT = BudgetItem
  before_filter :assign_section

  def new
    @categories = current_user.categories - BudgetItem.existing_categories
    @item = BudgetItem.new

    render layout: false
  end

  def create
    @budget_item = BudgetItem.create(params[:budget_item])
    render :layout => false
  end

  def index
    @presenter = BudgetReportPresenter.new(current_user, params[:year])
  end

  def edit
    @categories = current_user.categories - BudgetItem.existing_categories
    @item = BudgetItem.find(params[:id])

    render :layout => false
  end

  def update
    @item = BudgetItem.find(params[:id])
    @item.attributes = params[:budget_item]
    @item.save

    render :layout => false
  end

  def clone
    @categories = current_user.categories - BudgetItem.existing_categories
    @item = BudgetItem.find(params[:id])
    render :layout => false
  end

  def expense_summary
    @monthly_expenses = []
    months_between(5.months.ago.to_date, Date.today).each do |date|
      @monthly_expenses << {date: date, expense: LineItem.sum_with_filters(current_user, :in_month_of_date => date, :categories => JSON.parse(params[:categories]))}
    end

    render :layout => false
  end

  def destroy
    @item = MAIN_OBJECT.find(params[:id])
    @item.destroy
    render :json => {:refresh_page => 'true'}
  end

  private

  def assign_section
    @override_section = 'line_items'
  end
end
