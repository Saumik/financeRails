require 'spec_helper'
require 'importers/chase_cc'

describe Importers::ChaseCC do
  describe '#import' do
    before :each do
      data = IO.read("#{Rails.root}/spec/lib/importers/chase_cc_example.csv")

      importer = Importers::ChaseCC.new
      @line_items = importer.import(data).collect {|item| JSON.parse(item) }
    end
    it 'should import the regular item' do
      @line_items.length.should == 2
    end
    it 'should import the check' do
      @line_items[1]['payee_name'].should == 'FANDANGO.COM'
      @line_items[1]['amount'].should == '26.5'
      @line_items[1]['type'].should == LineItem::EXPENSE
    end
  end
end
