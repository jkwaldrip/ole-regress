require 'rspec'
require 'spec_helper.rb'

describe 'The Circulation module' do

  include OLE_QA::RegressionTest::Assertions

  include_context 'Create a Marc Record'
  include_context 'Checkin'
  include_context 'Checkout'
  include_context 'New Patron'

  let(:main_menu)                         { OLE_QA::Framework::OLELS::Main_Menu.new(@ole) }
  let(:item_barcode)                      { @marc_record.item_info[:barcode] }
  
  before :all do
    @patron.borrower_type = 'UnderGrad'
  end

  it 'has a new record' do
    patron_lookup.open
    patron_lookup.create_new.when_present.click
    patron_page.wait_for_page_to_load
    patron_page.wait_for_page_to_load
    patron_page.barcode_field.when_present.set(@patron.barcode)
    patron_page.borrower_type_selector.select(@patron.borrower_type)
    patron_page.activation_date_field.set(today)
    patron_page.first_name_field.set(@patron.first)
    patron_page.last_name_field.set(@patron.last)
    patron_page.address_line.address_source_selector.when_present.select('Operator')
    patron_page.address_line.details_link.click
    patron_page.address_line.line_1_field.when_present.set(@patron.address)
    patron_page.address_line.city_field.set(@patron.city)
    patron_page.address_line.state_selector.select(@patron.state)
    patron_page.address_line.postal_code_field.set(@patron.postal_code)
    patron_page.address_line.country_selector.select('United States')
    patron_page.address_line.active_checkbox.set(true)
    patron_page.address_line.add_button.click
    patron_page.address_line.line_number = 2
    patron_page.address_line.line_1_field.wait_until_present
    patron_page.phone_line.phone_number_field.when_present.set(@patron.phone)
    patron_page.phone_line.country_selector.select('United States')
    patron_page.phone_line.active_checkbox.set(true)
    patron_page.phone_line.add_button.click
    patron_page.phone_line.line_number = 2
    patron_page.phone_line.phone_number_field.wait_until_present
    patron_page.email_line.email_address_field.when_present.set(@patron.email)
    patron_page.email_line.active_checkbox.set(true)
    patron_page.email_line.add_button.click
    patron_page.email_line.line_number = 2
    patron_page.email_line.email_address_field.wait_until_present
    patron_page.submit_button.click
    patron_page.wait_for_page_to_load
    patron_page.message.when_present.text.should =~ /success/
  end

  it 'starts with a Marc record' do
    bib_editor.open
    new_bib_record
    new_instance
    @ole.windows[-1].close
    @ole.windows[0].use
    new_item
    @ole.windows[-1].close
    @ole.windows[0].use
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
