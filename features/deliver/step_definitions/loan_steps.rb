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

include OLE_QA::RegressionTest::Assertions

When /^I log in as \"?([\w]+)\"?$/ do |as_who|
  @ole.open
  page = OLE_QA::Framework::Page.new(@ole,@ole.url)
  page.wait_for_page_to_load
  page.login(as_who).should be_true
end

When /^I open the loan page$/ do
  @loan_page = OLE_QA::Framework::OLELS::Loan.new(@ole)
  @loan_page.open
end


When /^I select a [Cc]irculation [Dd]esk of \"?([\w\_]+)\"?$/ do |desk|
  set_field(@loan_page.circulation_desk_selector,desk)
end

When /^I wait for the confirmation dialogue to appear$/ do
  @loan_page.circulation_desk_yes.wait_until_present
end

When /^I click the "(yes|no)" button$/ do |which|
  case which
    when 'yes'
      @loan_page.circulation_desk_yes.click
    when 'no'
      @loan_page.circulation_desk_no.click
  end
end

Then /^the loan screen will appear$/ do
  @loan_page.wait_for_page_to_load
end

When /^I select a patron by (\w+)$/ do |which|
  case which
    when 'barcode'
      @loan_page.patron_field.set("#{@patron[:barcode]}\n")
  end
end

Then /^the (\w+) field appears$/ do |which|
  case which
    when 'item'
      @loan_page.item_field.wait_until_present
  end
end

When /^I select the item by (\w+)$/ do |which|
  case which
    when 'barcode'
      @loan_page.item_field.set("#{@resource.barcode}\n")
  end
  # Click the "loan" button on a popup if any popup appears in the next thirty seconds.
  @loan_page.loan_button.when_present.click if verify(30) {@loan_page.loan_popup_box.present?}
  @loan_page.wait_for_page_to_load
end

Then /^I see the item (\w+) in current items$/ do |which|
  case which
    when 'barcode'
      @loan_page.item_barcode_link(1).when_present.text.strip.should =~ /#{@resource.barcode}/
  end
end