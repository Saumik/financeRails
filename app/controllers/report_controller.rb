class ReportController < ApplicationController
  before_filter :assign_section

  def from_date_select(params, key)
    Time.utc(params[key + "(1i)"].to_i, params[key + "(2i)"].to_i, params[key + "(3i)"].to_i)
  end

  def month_expenses
    Mongoid.logger = nil

    @filters = {}
    @filters[:support_spanned] = params[:hide_spanning].present? ? !(params[:hide_spanning] == 'true') : true
    @filters[:avg_from] = params[:avg_from].present? ? Date.parse(params[:avg_from]) : nil
    @filters[:avg_until] = params[:avg_until].present? ? Date.parse(params[:avg_until]) : nil

    @presenter = LineItemsReportPresenter.new(current_user, @filters, params[:year])
  end

  private

  def assign_section
    @override_section = 'line_items'
  end
end
