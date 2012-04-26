FactoryGirl.define do
  factory :processing_rule do
    type 'payee'

    factory :processing_rule_1 do
      expression 'Moshe*'
      replacement 'mb'
    end
  end

  factory :line_item do
    payee_name 'Moshe Bergman'
    factory :line_item_1 do
      type 0
      amount 100
    end
  end
end