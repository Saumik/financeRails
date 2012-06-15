module BudgetsHelper
  def short_month(date)
    Date::ABBR_MONTHNAMES[date.month].to_s + ' ' + date.year.to_s
  end
end
