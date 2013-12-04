require 'rspec'
require 'spec_helper.rb'

describe 'The PURAP Workflow' do
  include OLE_QA::RegressionTest::PURAP::Requisition
  include_context 'Create a Bib Record'

  let(:requisition)       { OLE_QA::Framework::OLEFS::Requisition.new(@ole) }
  let(:delivery)          { {:building => 'Wells Library', :room => '064'} }
  let(:vendor)            { 'YBP' }

  before :all do
    @struct = OpenStruct.new
  end

  it 'opens a new requisition' do
    requisition.open
  end

  it 'selects a delivery location' do
    results = set_delivery(requisition, delivery)
    results[:error].should be_nil
    results[:pass?].should be_true
  end

  it 'selects a vendor' do
    results = set_vendor(requisition, vendor)
    results[:error].should be_nil
    results[:pass?].should be_true
  end

  it 'selects a new bib record for a line item' do
    results = set_new_bib(requisition)
    results[:error].should be_nil
    results[:pass?].should be_true
  end
  
  it 'enters the new bib' do
    enter_bib_record
  end
end
