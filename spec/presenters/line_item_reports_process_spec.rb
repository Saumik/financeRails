require 'spec_helper'

describe LineItemReportProcess do
  let(:line_item_1) { FactoryGirl.create :line_item_1 }
  let(:line_item_transfer) { FactoryGirl.create :line_item_7 }
  describe '#perform_after' do
    it 'should ignore transfers' do
      LineItemReportProcess.new.perform_after([line_item_1, line_item_transfer]).should == [line_item_1]
    end
  end
end