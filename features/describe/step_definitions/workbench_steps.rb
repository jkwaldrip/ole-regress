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
      @workbench.doc_type_bib.when_present.set
    when 'instance','holdings'
      @workbench.doc_type_holdings.when_present.set
    when 'item'
      @workbench.doc_type_item.when_present.set
  end
  @workbench.wait_for_page_to_load
end

When /^I enter the ([A-Za-z\s]+) in the (first|second) search field$/ do |term,line|
  search_field = @workbench.send("search_field_#{numerize(line)}".to_sym)
  search_field.when_present.set(@resource[keyify(term)])
end

When /^I set the (first|second) search selector to (.*)$/ do |line,value|
  case line
    when 'first'
      selector = @workbench.search_field_selector_1
    when 'second'
      selector = @workbench.search_field_selector_2
  end
  value.strip!
  Watir::Wait.until {selector.include?(value)}
  selector.select(value)
end

When /^I click (?:the )?(search|clear)(?: button)?(?: on the )?([A-Za-z\s]+) page$/ do |button,page|
  page.gsub!(' page','')
  click_which(page,button)
end

Then /^I (?:should )?see the ([A-Za-z\s]+) in the workbench search results$/ do |term|
  @workbench.result_present?(@resource[keyify(term)]).should be_true
end