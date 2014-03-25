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

module OLE_QA::Profiler
  # This module includes the tests to be run by the OLE QA Profiler app.
  #
  module Tests
    include OLE_QA::RegressionTest::Assertions
    include OLE_QA::RegressionTest::MarcEditor

    # Start at the rightmost OLE Portal Tab, "Admin," and click across
    #   all main portal tabs, one by one.
    #
    def tab_sprint
      @ole.open
      @ole.browser.link(:text => 'Admin').when_present.click
      @ole.browser.link(:text => 'Maintenance').when_present.click
      @ole.browser.link(:text => 'Select/Acquire').when_present.click
      @ole.browser.link(:text => 'Describe').when_present.click
      @ole.browser.link(:text => 'Deliver').when_present.click
    end 

    # Create a requisition with one line item and submit it, then wait
    #   until it becomes a purchase order.
    #
    def submit_req
      requisition = OLE_QA::Framework::OLEFS::Requisition.new(@ole)
      requisition.open
      # Set Delivery
      unless requisition.building_search_icon.present?
        requisition.delivery_tab_toggle.click
      end
      requisition.building_search_icon.wait_until_present
      requisition.building_search_icon.click
      lookup = OLE_QA::Framework::OLEFS::Building_Lookup.new(@ole)
      lookup.wait_for_page_to_load
      lookup.building_name_field.set('Wells Library')
      lookup.search_button.click
      lookup.wait_for_page_to_load
      lookup.return_result('Wells Library').when_present.click
      requisition.wait_for_page_to_load
      requisition.room_field.when_present.set('100')
      # Set Vendor
      unless requisition.vendor_search_icon.present?
        requisition.vendor_tab_toggle.click
      end
      requisition.vendor_search_icon.when_present.click
      lookup = OLE_QA::Framework::OLEFS::Vendor_Lookup.new(@ole)
      lookup.wait_for_page_to_load
      lookup.vendor_name_field.set('YBP')
      lookup.search_button.click
      lookup.return_result(/YBP/).when_present.click
      requisition.wait_for_page_to_load
      # Add new bib
      requisition.new_bib_option.when_present.set
      requisition.new_bib_button.when_present.click
      Watir::Wait.until { @ole.browser.windows.count > 1 }
      @ole.browser.windows[-1].use
      bib_ary = [{
          :tag    => '245',
          :ind_1  => '',
          :ind_2  => '',
          :value  => '|a' + OLE_QA::Framework::String_Factory.alphanumeric(12)
                 }]
      bib_editor = OLE_QA::Framework::OLELS::Bib_Editor.new(@ole)
      create_bib(bib_editor,bib_ary)
      @ole.browser.windows[-1].close
      @ole.browser.alert.ok if @ole.browser.alert.present?
      @ole.browser.windows[0].use
      requisition.wait_for_page_to_load
      requisition.list_price_field.when_present.set(OLE_QA::Framework::String_Factory.numeric(2))
      requisition.location_selector.when_present.select('B-EDUC/BED-STACKS')
      requisition.copies_field.when_present.set('1')
      requisition.add_button.when_present.click
      requisition.wait_for_page_to_load
      requisition.line_item.accounting_lines_toggle.click unless requisition.line_item.chart_selector.present?
      requisition.line_item.chart_selector.when_present.select('BL')
      account = OLE_QA::Framework::Account_Factory.select_account(:BL)[0]
      requisition.line_item.account_number_field.when_present.set(account)
      object = OLE_QA::Framework::Account_Factory.select_object(:BL)[0]
      requisition.line_item.object_field.when_present.set(object)
      requisition.line_item.percent_field.when_present.set('100.00')
      requisition.line_item.add_account_button.when_present.click
      requisition.wait_for_page_to_load
      requisition.submit_button.click
      requisition.wait_for_page_to_load
      requisition.generic_message.wait_until_present
      verify {requisition.document_id.present?}
      req_id  = requisition.document_id.text.strip
      req_url = requisition.lookup_url(req_id)
      page_assert(req_url,180) {requisition.wait_for_page_to_load
                                requisition.document_type_status.text.include?('Closed')}
      page_assert(req_url,180) {requisition.wait_for_page_to_load
                                requisition.view_related_tab_toggle.when_present.click unless requisition.view_related_po_link.present?
                                requisition.view_related_po_link.wait_until_present}
      purchase_order = OLE_QA::Framework::OLEFS::Purchase_Order.new(@ole)
      po_id   = requisition.view_related_po_link.text.strip
      po_url  = requisition.view_related_po_link.href
      @ole.browser.goto(po_url)
      page_assert(po_url,180)     {purchase_order.wait_for_page_to_load
                                   purchase_order.document_status.text.strip == 'FINAL' &&
                                   purchase_order.document_type_status.text.strip == 'Open'}
    end

    # Create an item and a patron, then loan the item to the patron,
    #   then return it.
    #
    def checkout_checkin
    end

    # Create a bib record and retrieve it through the 
    #   Search & Retrieval Unit API (SRU) with various
    #   search methods.
    #
    def sru_response
    end
  end
end
