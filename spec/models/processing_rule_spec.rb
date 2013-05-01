require 'spec_helper'

describe ProcessingRule do
  let(:user) { FactoryGirl.create :user_with_account }
  let(:line_item) { FactoryGirl.create :line_item_6 }

  context 'payee processing rules' do
    let(:processing_rule_payee) { FactoryGirl.create(:processing_rule_payee_1, user: user) }

    describe '#perform - should apply the processing rule to line item' do
      let!(:original_name) {line_item.payee_name}
      before :each do
        processing_rule_payee.perform(line_item)
      end
      it 'should add itself to the line item' do
        line_item.processing_rules.include?(processing_rule_payee).should == true
      end
      it 'should rename the payee for a payee type processing rule' do
        line_item.payee_name.should == processing_rule_payee.replacement
      end
      it 'should save the original name' do
        line_item.original_payee_name.should == original_name
      end
      it "should not run itself twice" do
        processing_rule_payee.perform(line_item)
        line_item.original_payee_name.should == original_name
      end
    end

    describe "#self.all_matching" do
      it "should return all matching items" do
        ProcessingRule.all_matching([processing_rule_payee], line_item).should == [processing_rule_payee]
      end
    end

    describe "#perform_all" do
      let!(:original_name) {line_item.payee_name}
      it "should process all line items" do
        processing_rule_payee.perform_all
        line_item.reload
        line_item.original_payee_name.should == original_name
      end
    end
  end

  context 'category processing rules' do
    let(:processing_rule_category) { FactoryGirl.create :processing_rule_category_1 }

    describe '#perform - should apply the processing rule to line item' do
      before :each do
        processing_rule_category.perform(line_item)
      end
      it 'should add itself to the line item' do
        line_item.processing_rules.include?(processing_rule_category).should == true
      end
      it 'should rename the payee for a payee type processing rule' do
        line_item.category_name.should == processing_rule_category.replacement
      end
    end
  end

  describe '#create_category_rename_rule' do
    it "should not create the item if a rule already exists"
    it 'should create the rename otherwise'
  end

  describe '#create_rename_and_assign_rule_if_not_exists' do
    it "should not create the item if a rule already exists" do
      category_processing_rules = []
      payee_rules = []
      ProcessingRule.create_rename_and_assign_rule_if_not_exists(user, category_processing_rules, payee_rules, line_item.payee_name, 'Safeway', 'Shopping')
      category_processing_rules.length.should == 1
      payee_rules.length.should == 1
      ProcessingRule.create_rename_and_assign_rule_if_not_exists(user, category_processing_rules, payee_rules, line_item.payee_name, 'Safeway', 'Shopping')
      category_processing_rules.length.should == 1
      payee_rules.length.should == 1

      created_rules = ProcessingRule.all
      created_rules.length.should == 2

      created_rules.each { |rule| rule.perform(line_item) }

      line_item.payee_name.should == 'Safeway'
      line_item.category_name.should == 'Shopping'
      line_item.original_payee_name.should == 'Safeway SF Caus'
    end
  end

  describe '#perform_all_matching' do
    it 'should perform all rules available on the line item' do
      FactoryGirl.create :processing_rule_payee_1, user: user
      FactoryGirl.create :processing_rule_category_1, user: user

      ProcessingRule.perform_all_matching(ProcessingRule.get_payee_rules(user), line_item)
      ProcessingRule.perform_all_matching(ProcessingRule.get_category_name_rules(user), line_item)
      line_item.payee_name.should == 'Safeway'
      line_item.category_name.should == 'Groceries'
      line_item.original_payee_name.should == 'Safeway SF Caus'
    end
  end
end