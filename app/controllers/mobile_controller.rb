class MobileController < MobileApplicationController
  layout 'mobile_application'

  def index
  end

  def sync
    data_received = JSON.parse(params[:client_data])

    current_account = User.first.default_account
    data_received.each do |item|
      if item['id'].blank?
        current_account.create_from_mobile(item)
      end
    end
    current_account.reset_balance

    respond_to do |format|
      format.json do
        @items = LineItem.in_month_of_date(Date.today).default_sort
      end
    end
  end
end
