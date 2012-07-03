module GroceriesHelper
  # {edit_item}
  def edit_item_path(item)
    edit_grocery_line_item_path(item)
  end
  def item_path(item)
    grocery_line_item_path(item)
  end

  def amount_label(line)
    if line.unit_type == GroceryLineItem::TYPE_WEIGHT
      currency(line.amount) + ' (' + line.units.to_s + line.unit_type + ' @ ' + currency(line.price_per_unit) + '/' + line.unit_type + ')'
    else
      currency(line.amount) + ' (' + line.units.to_i.to_s + ' items. Each for ' + currency(line.price_per_unit) + ')'
    end
  end
end
