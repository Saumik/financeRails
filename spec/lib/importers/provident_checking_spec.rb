require 'spec_helper'
require 'importers/provident_checking'

describe Importers::ProvidentCheckingImporter do
  describe '#import' do
    before :each do
      data = IO.read("#{Rails.root}/spec/lib/importers/provident_checking_example.csv")

      importer = Importers::ProvidentCheckingImporter.new
      @line_items = importer.import data
    end
    it 'should import the regular item' do
      @line_items.length.should == 2
    end
    it 'should import the check' do
      @line_items[1].comment.should == 'Check 1015'
      @line_items[1].amount.should == 2500
    end
  end
end
