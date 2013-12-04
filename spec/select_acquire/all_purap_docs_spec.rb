require 'rspec'
require 'spec_helper.rb'

describe 'The PURAP Workflow' do
  include OLE_QA::RegressionTest::PURAP::Requisition
  include_context 'Create a Marc Record'

  let(:requisition)       { OLE_QA::Framework::OLEFS::Requisition.new(@ole) }
  let(:delivery)          { {:building => 'Wells Library', :room => '064'} }
  let(:vendor)            { 'YBP' }

  before :all do
    @struct               = OpenStruct.new
    
    # Generate account info.
    account_ary           = OLE_QA::Framework::Account_Factory.select_account(:BL)
    object_ary            = OLE_QA::Framework::Account_Factory.select_object(:BL)
    @struct.account       = { :chart   => 'BL',
                              :account => account_ary[0],
                              :object  => object_ary[0],
                              :percent => '100.00' }
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
    new_bib_record
    close_editor
  end
  
  it 'returns to the requisition' do
    @ole.browser.windows[0].use
    requisition.wait_for_page_to_load
  end
  
  it 'gives a list price' do
    requisition.list_price_field.when_present.set('42.00')
  end

  it 'gives a location' do
    requisition.location_selector.when_present.select('B-EDUC/BED-STACKS')
  end

  it 'sets the number of copies' do
    requisition.copies_field.when_present.set('1')
  end

  it 'adds the line item' do
    requisition.add_button.when_present.click
    requisition.wait_for_page_to_load
  end

  it 'has consistent data on a new line item' do
    requisition.line_item.line_number = 1
    requisition.line_item.list_price_field.when_present.value.should    eq('42.00')
    requisition.line_item.location_selector.when_present.value.should   eq('B-EDUC/BED-STACKS')
    requisition.line_item.copies_field.when_present.value.should        eq('1')
  end
  
  it 'adds an account to the new line' do
    results = set_acct(requisition, @struct.account)
    results[:error].should be_nil
    results[:pass?].should be_true
  end

  it 'has consistent data on a new accounting line' do
    requisition.line_item.accounting_line.chart_selector.selected?(@struct.account[:chart]).should  be_true
    requisition.line_item.accounting_line.account_number_field.value.should   eq(@struct.account[:account])
    requisition.line_item.accounting_line.object_field.value.should           eq(@struct.account[:object])
    requisition.line_item.accounting_line.percent_field.value.should          eq(@struct.account[:percent])
  end
end
