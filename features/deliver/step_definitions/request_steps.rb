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
  @request_page.wait_for_page_to_load
  set_field(@request_page.user_type_selector,operator_type)
  @request_page.wait_for_page_to_load
end

Then /^I wait for the operator ID to appear in the operator ID field$/ do
  @request_page.wait_for_page_to_load
  @request_page.user_name.when_present.text.should eq('dev2')
end

When /^I select a request type of \"?([\w\/\s]+)\"?$/ do |request_type|
  @request_page.wait_for_page_to_load
  Watir::Wait.until {@request_page.request_type_selector.present? && @request_page.request_type_selector.include?(request_type)}
  @request_page.request_type_selector.select(request_type)
  @request_page.wait_for_page_to_load
  @request_page.item_barcode_field.wait_until_present
end

When /^I select the (second)? ?patron by barcode on the request page$/ do |which|
  @request_page.patron_barcode_field.wait_until_present
  if which.nil?
    set_field(@request_page.patron_barcode_field,"#{@patron[:barcode]}\n")
  else
    set_field(@request_page.patron_barcode_field,"#{@second_patron[:barcode]}\n")
  end
end

Then /^I wait for the (second)? ?patron's name to appear in the patron name field$/ do |which|
  @request_page.wait_for_page_to_load
  @request_page.loading_message.wait_while_present if @request_page.loading_message.present?
  if which.nil?
    patron_name = "#{@patron[:first_name]} #{@patron[:last_name]}"
  else
    patron_name = "#{@second_patron[:first_name]} #{@second_patron[:last_name]}"
  end
  @request_page.patron_name_field.when_present.value.should eq(patron_name)
end

When /^I click the item search icon on the request page$/ do
  @request_page.item_search_icon.when_present.click
  @request_page.loading_message.wait_while_present if @request_page.loading_message.present?
end

Then /^the item lookup screen will appear$/ do
  @item_lookup = OLE_QA::Framework::OLELS::Item_Lookup.new(@ole)
  @item_lookup.wait_for_page_to_load.should be_true
end

When /^I enter the item's barcode on the item lookup screen$/ do
  barcode = @resource.barcode
  set_field(@item_lookup.barcode_field,barcode)
end

When /^I click the ([\w\s]+) on the item lookup screen$/ do |what_to_click|
  @item_lookup.send(keyify(what_to_click.strip)).when_present.click
end

When /^I click the return link for the item(?:\'s)? ([\w\s]+)$/ do |what_value|
  value = @resource.send(keyify(what_value.strip))
  verify(30)  {@item_lookup.text_in_results?(value)}
  @item_lookup.return_by_text(value).click
end

Then /^I wait for the item's title to appear in the title field$/ do
  verify(30) {@request_page.item_title_field.value.should eq(@resource.title)}
end

When /^I enter a pickup location of \"?(\w+)\"?$/ do |pickup_location|
  @request_page.pickup_location_selector.wait_until_present
  set_field(@request_page.pickup_location_selector,pickup_location)
end

When /^I click the submit button on the request page$/ do
  @request_page.submit_button.when_present.click
end

Then /^I see a success message on the request page$/ do
  @request_page.wait_for_page_to_load
  verify(60) { @request_page.message.text.should =~ /success/ }.should be_true
end
