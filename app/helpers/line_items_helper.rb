module LineItemsHelper
  def year_display(year)
    @active_year ||= nil
    if @active_year != year
      @active_year = year
      @active_year.to_s + ':'
    else
      ''
    end
  end
end
