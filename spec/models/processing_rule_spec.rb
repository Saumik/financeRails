require 'spec_helper'

describe ProcessingRule do
  let(:line_item) { FactoryGirl.create :line_item_2 }

  context 'payee processing rules' do
    let(:processing_rule_payee) { FactoryGirl.create :processing_rule_payee_1 }

    describe '#wildcard_match - matching that allows *' do
      it 'should work with *' do
        processing_rule_payee.wildcard_match('before*', 'before test').should be_true
      end
      it 'should return false for empty string' do
        processing_rule_payee.wildcard_match('before*', '').should be_false
      end
    end
    describe '#matches? - should match line item or string depending on the type' do
      it 'should match line item' do
        processing_rule_payee.matches?(line_item).should be_true
      end
    end

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

end