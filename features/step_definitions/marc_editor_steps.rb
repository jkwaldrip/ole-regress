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

When /^I enter a title$/ do
  title = '|a' + OLE_QA::Framework::String_Factory.alpha(8).capitalize
  @bib_editor.data_line.tag_field.when_present.set('245')
  @bib_editor.data_line.data_field.when_present.set(title)
end

When /^I enter an author$/ do
  author = '|a' + OLE_QA::Framework::String_Factory.alpha(4).capitalize
  author += ' ' + OLE_QA::Framework::String_Factory.alpha(8).capitalize
  @bib_editor.data_line.add_button.when_present.click
  @bib_editor.data_line.line_number += 1
  @bib_editor.data_line.tag_field.when_present.set('100')
  @bib_editor.data_line.data_field.when_present.set(author)
end

Then /^I can save the bib record$/ do
  save_msg = @bib_editor.save_record
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

When /^I enter a location (.*)$/ do |location|
  @instance_editor.location_field.when_present.set(location)
end

When /^I enter a call number$/ do
  call_number = OLE_QA::Framework::Bib_Factory.call_number
  @instance_editor.call_number_field.when_present.set(call_number)
end

When /^I select a call number type$/ do
  @instance_editor.call_number_type_selector.when_present.select_value('LCC')
end

Then /^I can save the instance record$/ do
  save_msg = @instance_editor.save_record
  save_msg.should =~ /success/
end
