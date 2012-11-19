module BudgetsHelper
  def short_month(date)
    Date::ABBR_MONTHNAMES[date.month].to_s + ' ' + date.year.to_s
  end

  def categories_popover(budget_item)
    controller.render_to_string(partial: 'categories_popover', locals: {budget_item: budget_item})
  end
end
