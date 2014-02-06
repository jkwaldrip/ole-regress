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

  let(:loan_page)    { OLE_QA::Framework::OLELS::Loan.new(@ole) }
  
  def select_desk(loan_page,desk)
    loan_page.circulation_desk_selector.when_present.select(desk)
    loan_page.circulation_desk_yes.click if loan_page.circulation_desk_yes.present?
    loan_page.loan_popup_box.wait_while_present if loan_page.loan_popup_box.present?
    loan_page.circulation_desk_selector.selected?('BL_EDUC').should be_true
  end
end

shared_context 'Checkin' do

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
 
  include OLE_QA::RegressionTest::Patron 
  
  let(:patron_lookup)       { OLE_QA::Framework::OLELS::Patron_Lookup.new(@ole) }
  let(:patron_page)         { OLE_QA::Framework::OLELS::Patron.new(@ole) }
  let(:today)               { Chronic.parse('today').strftime('%m/%d/%Y') }

  before :all do
    @patron = OpenStruct.new( OLE_QA::Framework::Patron_Factory.new_patron )
  end

  def new_patron(page, struct)
    results = create_patron(page, struct)  
    results[0].should be_true
    results[1].should be_nil
  end

end
