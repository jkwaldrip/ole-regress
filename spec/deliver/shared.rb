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

shared_context 'Checkin' do

  let(:loan_page)    { OLE_QA::Framework::OLELS::Loan.new(@ole) }
  
  def select_desk(loan_page,desk)
    loan_page.circulation_desk_selector.when_present.select(desk)
    loan_page.circulation_desk_yes.when_present.click
    loan_page.loan_popup_box.wait_while_present if loan_page.loan_popup_box.present?
    loan_page.circulation_desk_selector.selected?('BL_EDUC').should be_true
  end
end

shared_context 'Checkout' do

  let(:return_page) { OLE_QA::Framework::OLELS::Return.new(@ole) }
  
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
    @ole.windows[-1].close if @ole.windows.count > 1
    return_page.items_returned_toggle.wait_until_present
    return_page.item_barcode_link(1).text.include?(barcode).should            be_true
    return_page.item_checkin_date.text.include?(@checkin.expected_str).should be_true
  end

  def end_session(return_page)
    return_page.end_session_button.when_present.click
  end
end

shared_context 'New Patron' do
  
  let(:patron_lookup)       { OLE_QA::Framework::OLELS::Patron_Lookup.new(@ole) }
  let(:patron_page)         { OLE_QA::Framework::OLELS::Patron.new(@ole) }
  let(:today)               { Chronic.parse('today').strftime('%m/%d/%Y') }

  before :all do
    @patron = OpenStruct.new( OLE_QA::Framework::Patron_Factory.new_patron )
  end

  def new_patron(page, struct)
    page.wait_for_page_to_load
    page.barcode_field.when_present.set(@patron.barcode)
    page.borrower_type_selector.select(@patron.borrower_type)
    # FIXME - The ID for the activation date field causes spectacular failures ever since the Rice upgrade.
    # Use the page.activation_date_field element once that ID problem is resolved.
    # Bug is OLE-5441.
    page.browser.text_field(:id => 'OlePatronDocument-OverviewSection_control').set(today)
    page.first_name_field.set(@patron.first)
    page.last_name_field.set(@patron.last)
    page.address_line.details_link.click
    page.address_line.line_1_field.when_present.set(@patron.address)
    page.address_line.city_field.set(@patron.city)
    page.address_line.state_selector.select(@patron.state)
    page.address_line.postal_code_field.set(@patron.postal_code)
    page.address_line.country_selector.select('United States')
    page.address_line.valid_from_date_field.set(today)
    page.address_line.active_checkbox.set(true)
    # FIXME - The ID for this element has changed.  The original line can be uncommented when the
    #   original ID is restored.
    # page.address_line.add_button.click
    page.browser.button(:id => 'addFee_add').click
    page.address_line.line_number = 2
    page.address_line.line_1_field.wait_until_present
    page.phone_line.phone_number_field.when_present.set(@patron.phone)
    page.phone_line.country_selector.select('United States')
    page.phone_line.active_checkbox.set(true)
    page.phone_line.add_button.click
    page.phone_line.line_number = 2
    page.phone_line.phone_number_field.wait_until_present
    page.email_line.email_address_field.when_present.set(@patron.email)
    page.email_line.active_checkbox.set(true)
    page.email_line.add_button.click
    page.email_line.line_number = 2
    page.email_line.email_address_field.wait_until_present
    page.submit_button.click
    page.message.wait_until_present
    page.message.text.strip.should  =~ /successfully/
  end

end
