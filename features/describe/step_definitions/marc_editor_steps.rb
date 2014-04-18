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

Given /^I have a (?:library )?resource$/ do
  @resource = OpenStruct.new(
      :title              => OLE_QA::Framework::Bib_Factory.title,
      :author             => OLE_QA::Framework::Bib_Factory.author,
      :price              => OLE_QA::Framework::String_Factory.price,
      :location           => 'B-EDUC/BED-STACKS',       # TODO Replace with randomly chosen existing location.
      :desk               => 'BL_EDUC',                 # TODO Replace with desk based on random extant location.
      :call_number        => OLE_QA::Framework::Bib_Factory.call_number,
      :call_number_type   => 'LCC',
      :item_type          => 'Book',
      :item_status        => 'Available',
      :barcode            => OLE_QA::Framework::Bib_Factory.barcode
  )
end

Given /^I (?:am using|use) the Marc Editor$/ do
  @bib_editor = OLE_QA::Framework::OLELS::Bib_Editor.new(@ole)
  @bib_editor.open
end

When /^I enter a title ?(?:of )?(.*)?$/ do |title|
  title.empty? ? title = "|a#{@resource.title}" : @resource.title = title.gsub('|a','')
  title = '|a' + title unless title =~ /^\|a/
  @bib_editor.data_line.tag_field.when_present.set('245')
  @bib_editor.data_line.data_field.when_present.set(title)
  @bib_editor.data_line.data_field.value.should =~ /#{@resource.title}/
end

When /^I enter an author ?(?:of )?(.*)?$/ do |author|
  author.empty? ? author = "|a#{@resource.author}" : @resource.author = author.gsub('|a','')
  author = '|a' + author unless author =~ /^\|a/
  @bib_editor.data_line.add_button.when_present.click
  @bib_editor.data_line.line_number += 1
  @bib_editor.data_line.tag_field.when_present.set('100')
  @bib_editor.data_line.data_field.when_present.set(author)
  @bib_editor.data_line.data_field.value.should =~ /#{@resource.author}/
end

Then /^I (?:can )?save the (bib|instance|item) record$/ do |which|
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
  @bib_editor.add_instance_button.when_present.click
  @instance_editor.wait_for_page_to_load
end

When /^I enter a location ?(?:of )?(.*)?$/ do |location|
  location.empty? ? location = @resource.location : @resource.location = location # TODO Randomize the location when it becomes possible.
  @instance_editor.location_field.when_present.set(location)
  @instance_editor.location_field.value.should eq(@resource.location)
end

When /^I enter a call number ?(?:of )?(.*)?$/ do |call_number|
  call_number.empty? ? call_number = @resource.call_number : @resource.call_number = call_number
  @instance_editor.call_number_field.when_present.set(call_number)
  @instance_editor.call_number_field.value.should eq(@resource.call_number)
end

When /^I select a call number type ?(?:of )?(.*)?$/ do |call_number_type|
  call_number_type.empty? ? call_number_type = 'LCC' : @resource.call_number_type = call_number_type
  @instance_editor.call_number_type_selector.when_present.select_value(call_number_type)
  @instance_editor.call_number_type_selector.selected?(/#{@resource.call_number_type}/).should be_true
end

When /^I create an instance record$/ do
  steps %{
    When I add an instance record
    And I enter a location
    And I enter a call number
    And I select a call number type
    Then I can save the instance record
    And I return to the bib editor window
  }
end

When /^I add an item record$/ do
  @item_editor = OLE_QA::Framework::OLELS::Item_Editor.new(@ole)
  @bib_editor.holdings_icon(1).when_present.click
  @bib_editor.item_link(1).when_present.click
  Watir::Wait.until {@ole.windows.count > 1}
  @ole.windows[-1].use
  @item_editor.wait_for_page_to_load
end

When /^I select an item type ?(?:of )?(.*)?$/ do |type|
  type.empty? ? type = @resource.item_type : @resource.item_type = type
  @item_editor.item_type_selector.when_present.select(type)
  @item_editor.item_type_selector.selected?(/#{@resource.item_type}/).should be_true
end

When /^I select an item status ?(?:of )?(.*)?$/ do |status|
  status.empty? ? status = @resource.item_status : @resource.item_status = status
  @item_editor.item_status_selector.when_present.select(status)
  @item_editor.item_status_selector.selected?(/#{@resource.item_status}/).should be_true
end

When /^I enter a barcode ?(?:of )?(.*)?$/ do |barcode|
  barcode.empty? ? barcode = @resource.barcode : @resource.barcode = barcode
  @item_editor.barcode_field.when_present.set(barcode)
  @item_editor.barcode_field.value.should eq(@resource.barcode)
end

When /^I create an item record$/ do
  steps %{
    When I add an item record
    And I select an item type
    And I select an item status
    And I enter a barcode
    Then I can save the item record
    And I return to the bib editor window
  }
end

When /^I exit the Marc Editor$/ do
  @ole.open(@ole.base_url)
end

When /^I return to the bib editor window$/ do
  if @ole.windows.count > 1
    @ole.windows[-1].close
    @ole.windows[0].use
  end
end

When /^I create a resource$/ do
  steps %{
    Given I have a resource
    Given I am using the Marc Editor
    When I create a bib record
    And I create an instance record
    Then I add an item record
    And I select an item type of Book
    And I select an item status of Available
    And I enter a barcode
    Then I can save the item record
    And I return to the bib editor window
    And I exit the Marc Editor
  }
end
