class MobileController < MobileApplicationController
  layout 'mobile_application'

  def index
  end

  def sync
    data_received = JSON.parse(params[:client_data])

    data_received.each do |item|
      if item['id'].blank?
        LineItem.create_from_mobile(item)
      end
    end


    respond_to do |format|
      format.json do
        @items = LineItem.in_month_of_date(Date.today).default_sort
      end
    end
  end
end
