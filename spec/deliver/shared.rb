#  Copyright 2005-2013 The Kuali Foundation
#
#  Licensed under the Educational Community License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at:
#
#    http://www.opensource.org/licenses/ecl2.php
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

shared_context 'Checkout' do

  include OLE_QA::RegressionTest::Assertions

  let(:loan_page)                         { OLE_QA::Framework::OLELS::Loan.new(@ole) }
  let(:main_menu)                         { OLE_QA::Framework::OLELS::Main_Menu.new(@ole) }
  let(:item_barcode)                      { @marc_record.item_info[:barcode] }
    
  def select_desk(loan_page,desk)
    loan_page.circulation_desk_selector.when_present.select(desk)
    loan_page.circulation_desk_yes.click if loan_page.circulation_desk_yes.present?
    loan_page.loan_popup_box.wait_while_present if loan_page.loan_popup_box.present?
    desk_selected = loan_page.circulation_desk_selector.selected?(desk)
    expect(desk_selected).to be_true
  end

  context 'checks out a resource' do
    it 'with a new Marc record' do
      bib_editor.open
      new_bib_record
      new_instance
      new_item
      @ole.windows[-1].close
      @ole.windows[0].use
    end

    it 'using the dev2 login' do
      main_menu.open
      logged_in = main_menu.login('dev2')
      expect(logged_in).to be_true
    end

    it 'on the loan screen' do
      loan_page_loaded = loan_page.open
      expect(loan_page_loaded).to be_true
    end

    it 'uses a circulation desk' do
      select_desk(loan_page,'BL_EDUC')
    end

    it 'answers the confirmation dialogue' do
      loan_page.circulation_desk_yes.wait_until_present
      loan_page.circulation_desk_yes.click
    end

    it 'selects a patron by barcode' do
      loan_page.wait_for_page_to_load
      loan_page.patron_field.set("#{@patron[:barcode]}\n")
    end

    it 'checks out a resource by barcode' do
      loan_page.item_field.when_present.set("#{item_barcode}\n")
    end

    it 'dismisses any popups on loan' do
      loan_page.loan_button.when_present.click if verify { loan_page.loan_popup_box.present? }
    end

    it 'has the item barcode in current items' do
      barcode_shown = loan_page.item_barcode_link(1).when_present.text.strip.include?(item_barcode)
      expect(barcode_shown).to be_true
    end
  end
end

shared_context 'Checkin' do

  include OLE_QA::RegressionTest::Assertions

  let(:loan_page)                         { OLE_QA::Framework::OLELS::Loan.new(@ole) }
  let(:return_page)                       { OLE_QA::Framework::OLELS::Return.new(@ole) }
  let(:main_menu)                         { OLE_QA::Framework::OLELS::Main_Menu.new(@ole) }
  let(:item_barcode)                      { @marc_record.item_info[:barcode] }
  
  
  before :all do
    date            = Time.now.strftime("%m/%d/%Y") 
    time            = Time.now.strftime("%k:%M") 
    expected_str    = Time.now.strftime("%m/%d/%Y %I:%M %p")
    @checkin        = OpenStruct.new(:date => date, :time => time, :expected_str => expected_str)
  end

  def return_resource(return_page,barcode)
    return_page.item_field.wait_until_present
    return_page.checkin_date_field.set(@checkin.date)
    return_page.checkin_time_field.set(@checkin.time)
    return_page.item_field.set("#{barcode}\n")
    if verify {return_page.checkin_message_box.present?}
      return_page.return_button.click
      return_page.checkin_message_box.wait_while_present
    end
    return_page.items_returned_toggle.wait_until_present
    item_returned = return_page.item_barcode_link(1).text.include?(barcode)
    checkin_date_correct = return_page.item_checkin_date.text.include?(@checkin.expected_str)
    expect(item_returned).to be_true
    expect(checkin_date_correct).to be_true
  end

  def end_session(return_page)
    return_page.end_session_button.when_present.click
  end

  # @note This context assumes that you are already logged in as the appropriate user.
  #   If you are using this context without including the checkout context before it,
  #   you will need to include a login example from the main menu before using this context.
  #
  context 'returns a resource' do
    it 'on the return screen' do
      loan_page.open
      loan_page.return_button.when_present.click
      return_page.wait_for_page_to_load
    end

    it 'by_barcode' do
      return_resource(return_page, item_barcode) 
    end

    it 'and ends the circulation session' do
      end_session(return_page)
    end
  end

end

shared_context 'New Patron' do

  include OLE_QA::RegressionTest::Assertions
  include OLE_QA::RegressionTest::Patron 
  
  let(:patron_lookup)       { OLE_QA::Framework::OLELS::Patron_Lookup.new(@ole) }
  let(:patron_page)         { OLE_QA::Framework::OLELS::Patron.new(@ole) }
  let(:today)               { Chronic.parse('today').strftime('%m/%d/%Y') }

  before :all do
     @patron = OLE_QA::Framework::Patron_Factory.new_patron
     @patron[:new_borrower_type] = OLE_QA::Framework::Patron_Factory.borrower_types.sample
    # Ensure a unique value over the current borrower type.
    while @patron[:new_borrower_type] == @patron[:borrower_type]
      @patron[:new_borrower_type] = OLE_QA::Framework::Patron_Factory.borrower_types.sample
    end
  end

  context 'has a new record' do
    it 'with a barcode' do
      patron_lookup.open
      patron_lookup.create_new.when_present.click
      patron_page.wait_for_page_to_load
      patron_page.wait_for_page_to_load
      set_field(patron_page.barcode_field,@patron[:barcode])
    end

    it 'with a borrower type' do
      set_field(patron_page.borrower_type_selector,@patron[:borrower_type])
    end 

    it 'with a first name' do
      set_field(patron_page.first_name_field,@patron[:first])
    end

    it 'with a last name' do
      set_field(patron_page.last_name_field,@patron[:last])
    end

    it 'with an address source of Operator' do
      set_field(patron_page.address_line.address_source_selector,'Operator')
    end

    it 'with address details' do
      patron_page.address_line.details_link.click
      address_details_present = patron_page.address_line.line_1_field.wait_until_present
      expect(address_details_present).to be_true
    end

    it 'with an address type' do
      set_field(patron_page.address_line.address_type_selector,'Home')
    end

    it 'with an address' do
      set_field(patron_page.address_line.line_1_field,@patron[:address])
    end
   
    it 'with a city' do
      set_field(patron_page.address_line.city_field,@patron[:city])
    end

    it 'with a state' do
      set_field(patron_page.address_line.state_selector,@patron[:state])
    end
    
    it 'with a postal code' do
      set_field(patron_page.address_line.postal_code_field,@patron[:postal_code])
    end

    it 'with a country' do
      set_field(patron_page.address_line.country_selector,'United States')
      set_field(patron_page.phone_line.country_selector,'United States')
    end

    it 'with the address active' do
      set_field(patron_page.address_line.active_checkbox,true)
    end

    it 'with the address added' do
      patron_page.address_line.add_button.click
      patron_page.address_line.line_number = 2
      address_is_added = patron_page.address_line.line_1_field.wait_until_present
      expect(address_is_added).to be_true
    end

    it 'with an email address' do
      set_field(patron_page.email_line.email_address_field,@patron[:email])
    end

    it 'with the email address active' do
      set_field(patron_page.email_line.active_checkbox,true)
    end

    it 'with the email address added' do
      patron_page.email_line.add_button.click
      patron_page.email_line.line_number = 2
      email_is_added = patron_page.email_line.email_address_field.wait_until_present
      expect(email_is_added).to be_true
    end

    it 'with a phone number' do
      set_field(patron_page.phone_line.phone_number_field,@patron[:phone])
    end

    it 'with the phone number active' do
      set_field(patron_page.phone_line.active_checkbox,true)
    end

    it 'with the phone number added' do
      patron_page.phone_line.add_button.click
      patron_page.phone_line.line_number = 2
      phone_is_added = patron_page.phone_line.phone_number_field.wait_until_present
      expect(phone_is_added).to be_true
    end

    it 'successfully submitted' do
      patron_page.submit_button.click
      patron_page.wait_for_page_to_load
      message_given = patron_page.message.when_present.text
      expect(message_given).to match(/success/)
    end
  end
end
