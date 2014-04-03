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
#  limitations under the License

Given /^I (?:am using|use) the (?:Describe )?Workbench$/ do
  @workbench = OLE_QA::Framework::OLELS::Describe_Workbench.new(@ole)
  @workbench.open
end

When /^I search for an? (bib|instance|holdings|item) record$/ do |type|
  @workbench.wait_for_page_to_load
  type.strip!
  case type
    when 'bib'
      set_field(@workbench.document_type_selector,'Bibliographic')
    when 'instance','holdings'
      set_field(@workbench.document_type_selector,'Holdings')
    when 'item'
      set_field(@workbench.document_type_selector,'Item')
  end
  @workbench.wait_for_page_to_load
  set_field(@workbench.search_type_selector,'Search')
end

When /^I enter the ([A-Za-z\s]+) in the search field$/ do |term|
  search_term   = @resource.send(keyify(term))
  set_field(@workbench.search_line.search_field,search_term)
end

When /^I set the search selector to (.*)$/ do |value|
  selector = @workbench.search_line.field_selector
  value.strip!
  Watir::Wait.until {selector.include?(value)}
  set_field(selector,value)
end

When /^I click (?:the )?(search|clear)(?: button)?(?: on the )?([A-Za-z\s]+) page$/ do |button,page|
  page.gsub!(' page','')
  click_which(page,button)
end

Then /^I (?:should )?see the ([A-Za-z\s]+) in the workbench search results$/ do |term|
  @workbench.wait_for_page_to_load
  if (term =~ /[Tt]itle/) then
    @workbench.title_in_results?(@resource.send(keyify(term))).should be_true
  else
    @workbench.text_in_results?(@resource.send(keyify(term))).should be_true
  end
end

When /^I add the workbench search line$/ do
  @workbench.search_line.add_button.when_present.click
  @workbench.wait_for_page_to_load
end
