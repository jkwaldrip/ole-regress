require 'rspec'
require 'spec_helper.rb'

describe 'The PURAP Workflow' do
  include OLE_QA::RegressionTest::PURAP::Requisition

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

end
