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

include OLE_QA::RegressionTest::Patron

Given /^I have new patron information$/ do
  @patron = OpenStruct.new(OLE_QA::Framework::Patron_Factory.new_patron)
  @patron[:country]               = 'United States'
  @patron[:phone_number_country]  = 'United States'
  @patron[:email_address]         = @patron[:email]
  @patron[:phone_number]          = @patron[:phone]
end

Given /^I (?:open|visit|go to)? the patron editor$/ do
  @patron_editor = OLE_QA::Framework::OLELS::Patron.new(@ole)
  @patron_lookup = OLE_QA::Framework::OLELS::Patron_Lookup.new(@ole)
  @patron_lookup.open
  @patron_lookup.create_new.when_present.click
  @patron_editor.wait_for_page_to_load
end

When /^I set the patron(?:'s)? ((?:[\w]+ ?)*)\"?((?:[\w]+ ?)*)?\"?$/ do |field,value|
  field = field.split(' to ').join
  value.gsub!('"','')
  if value.empty? then
    value = @patron[keyify(field)]
  else
    @patron[keyify(field)] = value
  end
  case field
    when 'first name'
      set_field(@patron_editor.first_name_field,value)
    when 'last name'
      set_field(@patron_editor.last_name_field,value)
    when 'barcode'
      set_field(@patron_editor.barcode_field,value)
    when 'borrower type'
      set_field(@patron_editor.borrower_type_selector,value)
    when 'address type'
      set_field(@patron_editor.address_line.address_type_selector,value)
    when 'address'
      set_field(@patron_editor.address_line.active_checkbox,true)
      set_field(@patron_editor.address_line.line_1_field,value)
    when 'city'
      set_field(@patron_editor.address_line.city_field,value)
    when 'state'
      set_field(@patron_editor.address_line.state_selector,value)
    when 'postal code'
      set_field(@patron_editor.address_line.postal_code_field,value)
    when 'country'
      set_field(@patron_editor.address_line.country_selector,value)
      set_field(@patron_editor.phone_line.country_selector,value)
    when 'email address'
      set_field(@patron_editor.email_line.email_address_field,value)
      set_field(@patron_editor.email_line.active_checkbox,true)
    when 'phone number'
      set_field(@patron_editor.phone_line.phone_number_field,value)
      set_field(@patron_editor.phone_line.active_checkbox,true)
    else
      raise OLE_QA::RegressionTest::Error,"Field does not exist on patron editor:  #{field}"
  end
end

When /^I add (?:a|the) patron(?:'s)? (?:([\w ]+){1,2}) line$/ do |which|
  case which
    when /address/
      # FIXME Patron address line add button ID is currently misnamed in OLE.
      # @patron.address_line.add_button.when_present.click
      @patron_editor.b.button(:id => 'addFee_add').when_present.click
      @patron_editor.address_line.line_number += 1
      @patron_editor.address_line.line_1_field.wait_until_present
    when /phone( number)?/
      @patron_editor.phone_line.add_button.when_present.click
      @patron_editor.phone_line.line_number += 1
      @patron_editor.phone_line.phone_number_field.wait_until_present
    when /email( address)?/
      @patron_editor.email_line.add_button.when_present.click
      @patron_editor.email_line.line_number += 1
      @patron_editor.email_line.email_address_field.wait_until_present
    else
      raise OLE_QA::RegressionTest::Error,"Line does not exist on patron editor:  #{which}"
  end
end

When /^I submit the patron record$/ do
  @patron_editor.submit_button.click
  @patron_editor.message.text.should =~ /success/
end