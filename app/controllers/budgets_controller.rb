class BudgetsController < ApplicationController
  MAIN_OBJECT = BudgetItem
  before_filter :assign_section

  def new
    @categories = current_user.categories - BudgetItem.existing_categories(current_user)
    @item = BudgetItem.new

    render layout: false
  end

  def create
    @item = current_user.budget_items.create(params[:budget_item])
    render :layout => false
  end

  def index
    @presenter = BudgetReportPresenter.new(current_user, params[:year])
  end

  def edit
    @item = current_user.budget_items.find(params[:id])
    @categories = current_user.categories - BudgetItem.existing_categories(current_user, @item.budget_year)

    render :layout => false
  end

  def update
    @item = current_user.budget_items.find(params[:id])
    @item.attributes = params[:budget_item]
    @item.save

    render :layout => false
  end

  def clone
    @categories = current_user.categories - BudgetItem.existing_categories(current_user)
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
    @item = current_user.budget_items.find(params[:id])
    @item.destroy
    render :json => {:refresh_page => 'true'}
  end

  private

  def assign_section
    @override_section = 'line_items'
  end
end
