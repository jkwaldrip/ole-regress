require 'rspec'
require 'spec_helper.rb'

describe 'The Circulation module' do

  include OLE_QA::RegressionTest::Assertions

  include_context 'Create a Marc Record'
  include_context 'Checkin'
  include_context 'Checkout'

  let(:main_menu)                         { OLE_QA::Framework::OLELS::Main_Menu.new(@ole) }
  let(:item_barcode)                      { @marc_record.item_info[:barcode] }
  
  before :all do
    @patron = OpenStruct.new( OLE_QA::Framework::Patron_Factory.select_patron )
  end

  it 'uses a patron record' do
    @patron.id.should       =~ /[0-9]+[A-Z]{1}/
    @patron.first.should    =~ /[A-Z]{1}[a-z]+/
    @patron.last.should     =~ /[A-Z]{1}[a-z]+/
    @patron.barcode.should  =~ /[0-9]+/
  end

  it 'starts with a Marc record' do
    bib_editor.open
    new_bib_record
    new_instance
    new_item
  end

  it 'uses the dev2 login' do
    main_menu.open
    main_menu.login('dev2').should be_true
  end

  it 'opens the loan screen' do
    loan_page.open
  end

  it 'uses a circulation desk' do
    select_desk(loan_page,'BL_EDUC')
  end

  it 'selects a patron by barcode' do
    loan_page.wait_for_page_to_load
    loan_page.patron_field.set("#{@patron.barcode}\n")
  end

  it 'checks out a resource by barcode' do
    loan_page.item_field.when_present.set("#{item_barcode}\n")
  end

  it 'dismisses any popups on loan' do
    loan_page.loan_button.when_present.click if verify { loan_page.loan_popup_box.present? }
  end

  it 'has the item barcode in current items' do
    loan_page.item_barcode_link(1).when_present.text.strip.include?(item_barcode).should be_true
  end

  it 'opens the return screen' do
    loan_page.return_button.when_present.click
    return_page.wait_for_page_to_load
  end

  it 'returns a resource' do
    return_resource(return_page, item_barcode) 
  end

  it 'ends the circulation session' do
    end_session(return_page)
  end
end
