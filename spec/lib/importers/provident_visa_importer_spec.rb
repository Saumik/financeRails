require 'spec_helper'
require 'importers/provident_visa'

describe Importers::ProvidentVisa do
  describe '#import' do
    before :each do
      data = IO.read("#{Rails.root}/spec/lib/importers/provident_visa_example.csv")

      importer = Importers::ProvidentVisa.new
      @line_items = importer.import(data).collect {|item| JSON.parse(item) }
    end
    it 'should import the regular item' do
      @line_items.length.should == 3
      @line_items[0]['amount'].should == '6.05'
      @line_items[0]['payee_name'].should == "LEE'S DELI - 615 M SAN FRANCISCO CA"
      @line_items[0]['comment'].should == "Transaction 2422443JD2YZWFQHY"
    end
    it 'should import interest' do
      @line_items[2]['amount'].should == '1.0'
    end
  end
end
