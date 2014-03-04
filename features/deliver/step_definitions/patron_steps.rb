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
  @patron = OLE_QA::Framework::Patron_Factory.new_patron
  @patron[:first_name]            = @patron[:first]
  @patron[:last_name]             = @patron[:last]
  @patron[:country]               = 'United States'
  @patron[:phone_number_country]  = 'United States'
  @patron[:email_address]         = @patron[:email]
  @patron[:phone_number]          = @patron[:phone]
  @patron[:address_type]          = 'Home'
end

Given /^I (?:open|visit|go to)? the patron editor$/ do
  @patron_editor = OLE_QA::Framework::OLELS::Patron.new(@ole)
  @patron_lookup = OLE_QA::Framework::OLELS::Patron_Lookup.new(@ole)
  @patron_lookup.open
  @patron_lookup.create_new.when_present.click
  @patron_editor.wait_for_page_to_load
end

When /^I set the patron(?:'s)? ((?:[\w]+ ?)*)\"?((?:[\w]+ ?)*)?\"?$/ do |field,value|
  field = field.split(' to ')[0]
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
      @patron_editor.address_line.add_button.when_present.click
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

When /^I click the patron(?:'s)? address details link$/ do
  @patron_editor.address_line.details_link.click
  @patron_editor.address_line.line_1_field.wait_until_present
end

When /^I (submit|save|cancel) the patron record$/ do |which|
  case which
    when /submit/
      @patron_editor.submit_button.click
      @patron_editor.wait_for_page_to_load
      @patron_editor.message.text.should =~ /success/
    when /save/
      @patron_editor.save_button.click
      @patron_editor.wait_for_page_to_load
      @patron_editor.message.text.should =~ /success/
    when /(cancel|close)/
      @patron_editor.close_button.click
  end
end

When /^I create a new patron record$/ do
  steps %{
    Given I have new patron information
    Given I open the patron editor
    When I set the patron's first name
    And I set the patron's last name
    And I set the patron's barcode
    And I set the patron's borrower type
    And I click the patron's address details link
    And I set the patron's address type
    And I set the patron's address
    And I set the patron's city
    And I set the patron's state
    And I set the patron's postal code
    And I set the patron's country
    And I add a patron address line
    And I set the patron's email address
    And I add the patron's email line
    And I set the patron's phone number
    And I add the patron's phone number line
    Then I submit the patron record
  }
end

When /^I (?:open|visit|use|am using) (?:the )?[Pp]atron [Ss]earch(?: [Pp]age|[Ss]creen)?$/ do
  @patron_lookup.open
end

When /^I enter (?:a|the) patron(?:'s)? (?:([\w ?]+){1,2})$/ do |field|
  value = @patron[keyify(field)]
  raise OLE_QA::RegressionTest::Error,"Patron record does not have #{value}" if value.nil?
  case field
    when 'first name'
      set_field(@patron_lookup.first_name_field,value)
    when 'last name'
      set_field(@patron_lookup.last_name_field,value)
    when 'barcode'
      set_field(@patron_lookup.barcode_field,value)
    when 'email address'
      set_field(@patron_lookup.email_address_field,value)
    when 'borrower type'
      set_field(@patron_lookup.borrower_type_selector,value)
  end
end

Then /^I see the (?:([\w ?]+){1,2}) in the patron search results$/ do |which|
  @patron_lookup.text_in_results?(@patron[keyify(which)]).should be_true
end

And /^I edit the patron record$/ do
  @patron_lookup.edit_by_text(@patron[:barcode]).when_present.click
  @patron_editor.wait_for_page_to_load
end

When /^I create a second new patron record$/ do
  @second_patron                          = OLE_QA::Framework::Patron_Factory.new_patron
  @second_patron[:first_name]             = @second_patron[:first]
  @second_patron[:last_name]              = @second_patron[:last]
  @second_patron[:country]                = 'United States'
  @second_patron[:phone_number_country]   = 'United States'
  @second_patron[:email_address]          = @second_patron[:email]
  @second_patron[:phone_number]           = @second_patron[:phone]
  @second_patron[:address_type]           = 'Home'
  steps %{
    Given I open the patron editor
    When I set the second patron's first name
    And I set the second patron's last name
    And I set the second patron's barcode
    And I set the second patron's borrower type
    And I click the patron's address details link
    And I set the second patron's address type
    And I set the second patron's address
    And I set the second patron's city
    And I set the second patron's state
    And I set the second patron's postal code
    And I set the second patron's country
    And I add a patron address line
    And I set the second patron's email address
    And I add the patron's email line
    And I set the second patron's phone number
    And I add the patron's phone number line
    Then I submit the patron record
        }
end

When /^I set the second patron(?:'s)? ((?:[\w]+ ?)*)\"?((?:[\w]+ ?)*)?\"?$/ do |field,value|
  field = field.split(' to ')[0]
  if value.empty? then
    value = @second_patron[keyify(field)]
  else
    @second_patron[keyify(field)] = value
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