class InvestmentController < ApplicationController
  def index
    if params[:create]
      create_plans
    end

    @new_item = InvestmentLineItem.new
    @investment_plan = current_user.investment_plan
    @items = current_user.investment_line_items.default_sort.to_a
  end

  def update_last_prices
    symbols = current_user.investment_assets.collect {|is| is.symbol.present? ? 'stock=' + is.symbol : nil }.compact.join('&')
    results = HTTParty.get('http://www.google.com/ig/api?' + symbols)


    results["xml_api_reply"]["finance"].each do |item|
      symbol = item["symbol"]["data"]
      amount = item["last"]["data"].to_f

      asset = current_user.investment_assets.to_a.find {|ia| ia.symbol == symbol}
      if asset.present?
        asset.last_price = amount
        asset.save
      else
        puts 'asset ' +  symbol + ' not found'
      end
    end

    redirect_to investment_path
  end

  private

  def create_plans
    InvestmentPlan.delete_all
    InvestmentAllocationPlan.delete_all
    InvestmentAsset.delete_all
    InvestmentLineItem.delete_all
    @investment_plan = InvestmentPlan.create(:user_id => current_user.id)
    risk_plan = @investment_plan.investment_allocation_plans.create(name: 'Risk', percent: 0.7)
    safe_plan = @investment_plan.investment_allocation_plans.create(name: 'Safe', percent: 0.3)

    developed = risk_plan.investment_allocation_plans.create(name: 'Developed Countries', percent: 0.25)
    developing = risk_plan.investment_allocation_plans.create(name: 'Developing Countries', percent: 0.25)
    metals = risk_plan.investment_allocation_plans.create(name: 'Precious Metals', percent: 0.25)
    locals = risk_plan.investment_allocation_plans.create(name: 'Locals', percent: 0.25)

    developed.investment_assets.create(name: 'Vanguard MSCI Europe', symbol: 'VGK', last_price: 47.2, number: 136, percent: 0.33)
    developed.investment_assets.create(name: 'TA100', symbol: 'TA100', last_price: 10.93, number: 384, currency: :ils, percent: 0.33)
    developed.investment_assets.create(name: 'iShares MSCI Japan Index', last_price: 9.325, number: 605, percent: 0.33)


    developing.investment_assets.create(name: 'iShares MSCI BRIC', symbol: 'BKF', last_price: 38.27, number: 147, percent: 0.5)
    developing.investment_assets.create(name: 'iShares MSCI South Africa Index', symbol: 'EZA', last_price: 64.68, number: 63, percent: 0.5)


    metals.investment_assets.create(name: 'PowerShares DB Precious Metals Fd', symbol: 'DBP', last_price: 59.45, number: 109, percent: 0.5)
    metals.investment_assets.create(name: 'Vanguard Energy ETF', symbol: 'VDE', last_price: 102.99, number: 65, percent: 0.5)

    locals.investment_assets.create(name: 'SNP500', symbol: 'ILSNMP', last_price: 55.42, number: 718, currency: :ils, percent: 0.5)
    locals.investment_assets.create(name: 'Vanguard REIT ETF', symbol: 'VNQ', last_price: 64.21, number: 48, percent: 0.5)

    bonds = safe_plan.investment_allocation_plans.create(name: 'Bond', percent: 1)
    bonds.investment_assets.create(name: 'Vanguard Short-Term Bond ETF', symbol: 'BSV', last_price: 81.43, number: 25 , percent: 1)

  end
end
