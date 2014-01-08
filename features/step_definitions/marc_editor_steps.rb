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

Given /^I am using the Marc Editor$/ do
  @bib_editor = OLE_QA::Framework::OLELS::Bib_Editor.new(@ole)
  @bib_editor.open
end

When /^I enter a title ?(?:of )?(.*)?$/ do |title|
  title = '|a' + OLE_QA::Framework::String_Factory.alpha(8).capitalize if title.empty?
  @bib_editor.data_line.tag_field.when_present.set('245')
  @bib_editor.data_line.data_field.when_present.set(title)
  @bib_editor.data_line.data_field.value.should eq(title)
end

When /^I enter an author ?(?:of )?(.*)?$/ do |author|
  if author.empty?
    author = '|a' + OLE_QA::Framework::String_Factory.alpha(4).capitalize
    author += ' ' + OLE_QA::Framework::String_Factory.alpha(8).capitalize
  end
  @bib_editor.data_line.add_button.when_present.click
  @bib_editor.data_line.line_number += 1
  @bib_editor.data_line.tag_field.when_present.set('100')
  @bib_editor.data_line.data_field.when_present.set(author)
  @bib_editor.data_line.data_field.value.should eq(author)
end

Then /^I can save the (bib|instance|item) record$/ do |which|
  editor = instance_variable_get("@#{which}_editor".to_sym)
  save_msg = editor.save_record
  save_msg.should =~ /success/
end

When /^I create a bib record$/ do
  steps %{
    When I enter a title
    And I enter an author
    Then I can save the bib record
  }
end

When /^I add an instance record$/ do
  @instance_editor = OLE_QA::Framework::OLELS::Instance_Editor.new(@ole)
  @bib_editor.holdings_link(1).when_present.click
  @instance_editor.wait_for_page_to_load
end

When /^I enter a location ?(?:of )?(.*)?$/ do |location|
  location = 'B-EDUC/BED-STACKS' if location.empty? # TODO Randomize the location when it becomes possible.
  @instance_editor.location_field.when_present.set(location)
  @instance_editor.location_field.value.should eq(location)
end

When /^I enter a call number ?(?:of )?(.*)?$/ do |call_number|
  call_number = OLE_QA::Framework::Bib_Factory.call_number if call_number.empty?
  @instance_editor.call_number_field.when_present.set(call_number)
  @instance_editor.call_number_field.value.should eq(call_number)
end

When /^I select a call number type ?(?:of )?(.*)?$/ do |call_number_type|
  call_number_type = 'LCC' if call_number_type.empty?
  @instance_editor.call_number_type_selector.when_present.select_value(call_number_type)
  @instance_editor.call_number_type_selector.selected?(/#{call_number_type}/).should be_true
end

When /^I create an instance record$/ do
  steps %{
    When I add an instance record
    And I enter a location
    And I enter a call number
    And I select a call number type
    Then I can save the instance record
  }
end

When /^I add an item record$/ do
  @item_editor = OLE_QA::Framework::OLELS::Item_Editor.new(@ole)
  @instance_editor.holdings_icon(1).when_present.click
  @instance_editor.item_link(1).when_present.click
  @item_editor.wait_for_page_to_load
end

When /^I select an item type ?(?:of )?(.*)?$/ do |type|
  type = 'Book' if type.empty?
  @item_editor.item_type_selector.when_present.select(type)
  @item_editor.item_type_selector.selected?(/#{type}/).should be_true
end

When /^I select an item status ?(?:of )?(.*)?$/ do |status|
  status = 'Available' if status.empty?
  @item_editor.item_status_selector.when_present.select(status)
  @item_editor.item_status_selector.selected?(/#{status}/).should be_true
end

When /^I enter a barcode ?(?:of )?(.*)?$/ do |barcode|
  barcode = OLE_QA::Framework::Bib_Factory.barcode if barcode.empty?
  @item_editor.barcode_field.when_present.set(barcode)
  @item_editor.barcode_field.value.should eq(barcode)
end