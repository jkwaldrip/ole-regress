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

When /^I open the [Rr]equest (?:[Ll]ookup )?page$/ do
  @request_lookup = OLE_QA::Framework::OLELS::Request_Lookup.new(@ole)
  @request_lookup.open
end

When /^I click the \"?Create New Request\"? link$/ do
  @request_lookup.create_new.when_present.click
  @request_page = OLE_QA::Framework::OLELS::Request.new(@ole)
  @request_page.wait_for_page_to_load
end

When /^I select an operator type of \"?(\w+)\"?$/ do |operator_type|
  set_field(@request_page.user_type_selector,operator_type)
  @request_page.wait_for_page_to_load
end

When /^I select a request type of \"?([\w\/\s]+)\"?$/ do |request_type|
  @request_page.wait_for_page_to_load
  @request_page.request_type_selector.wait_until_present
  set_field(@request_page.request_type_selector,request_type)
end

When /^I enter the second patron's barcode$/ do
  @request_page.patron_barcode_field.wait_until_present
  set_field(@request_page.patron_barcode_field,"#{@second_patron[:barcode]}\n")
end

Then /^I wait for the patron's name to appear in the patron name field$/ do
  @request_page.wait_for_page_to_load
  patron_name = "#{@second_patron[:first_name]} #{@second_patron[:last_name]}"
  @request_page.patron_name_field.when_present.value.should eq(patron_name)
end

When /^I click the item search icon on the request page$/ do
  @request_page.item_search_icon.when_present.click
end

