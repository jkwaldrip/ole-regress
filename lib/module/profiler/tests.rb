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
    include OLE_QA::RegressionTest::SRU
    include OLE_QA::RegressionTest::Marc

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
      # Create new patron.
      patron        = OpenStruct.new(OLE_QA::Framework::Patron_Factory.new_patron)
      patron_lookup = OLE_QA::Framework::OLELS::Patron_Lookup.new(@ole)
      patron_page   = OLE_QA::Framework::OLELS::Patron.new(@ole)
      patron_lookup.open
      patron_lookup.create_new.when_present.click
      patron_page.wait_for_page_to_load
      patron_page.wait_for_page_to_load
      patron_page.barcode_field.when_present.set(patron.barcode)
      patron_page.borrower_type_selector.select(patron.borrower_type)
      patron_page.first_name_field.set(patron.first)
      patron_page.last_name_field.set(patron.last)
      patron_page.address_line.address_source_selector.when_present.select('Operator')
      patron_page.address_line.details_link.click
      patron_page.address_line.line_1_field.when_present.set(patron.address)
      patron_page.address_line.city_field.set(patron.city)
      patron_page.address_line.state_selector.select(patron.state)
      patron_page.address_line.postal_code_field.set(patron.postal_code)
      patron_page.address_line.country_selector.select('United States')
      patron_page.address_line.active_checkbox.set(true)
      patron_page.address_line.add_button.click
      patron_page.address_line.line_number = 2
      patron_page.address_line.line_1_field.wait_until_present
      patron_page.phone_line.phone_number_field.when_present.set(patron.phone)
      patron_page.phone_line.country_selector.select('United States')
      patron_page.phone_line.active_checkbox.set(true)
      patron_page.phone_line.add_button.click
      patron_page.phone_line.line_number = 2
      patron_page.phone_line.phone_number_field.wait_until_present
      patron_page.email_line.email_address_field.when_present.set(patron.email)
      patron_page.email_line.active_checkbox.set(true)
      patron_page.email_line.add_button.click
      patron_page.email_line.line_number = 2
      patron_page.email_line.email_address_field.wait_until_present
      patron_page.submit_button.click
      patron_page.wait_for_page_to_load
      verify {patron_page.message.when_present.text =~ /success/}

      # Create item record.
      bib_ary     = [{
                      :tag      => '245',
                      :ind_1    => '',
                      :ind_2    => '',
                      :value    => '|a' + OLE_QA::Framework::String_Factory.alphanumeric(12)
                     },
                    {
                      :tag      => '100',
                      :ind_1    => '',
                      :ind_2    => '',
                      :value    => '|a' + OLE_QA::Framework::String_Factory.alphanumeric(14)
                    }]
      bib_editor = OLE_QA::Framework::OLELS::Bib_Editor.new(@ole)
      bib_editor.open
      create_bib(bib_editor,bib_ary)
      instance  = {   :location         => 'B-EDUC/BED-STACKS',
                      :call_number      => OLE_QA::Framework::Bib_Factory.call_number,
                      :call_number_type => 'LCC'
                    }
      instance_editor = OLE_QA::Framework::OLELS::Instance_Editor.new(@ole)
      create_instance(instance_editor,instance)
      @ole.browser.windows[-1].close
      @ole.browser.windows[0].use
      item      = {   :item_type        => 'Book',
                      :item_status      => 'Available',
                      :barcode          => OLE_QA::Framework::Bib_Factory.barcode   
                  }
      item_editor = OLE_QA::Framework::OLELS::Item_Editor.new(@ole)
      create_item(item_editor,item)
      @ole.browser.windows[-1].close
      @ole.browser.windows[0].use

      # Login as dev2.
      page = OLE_QA::Framework::Page.new(@ole,@ole.url)
      page.open
      page.login('dev2')

      # Loan the item.
      loan_page = OLE_QA::Framework::OLELS::Loan.new(@ole)
      loan_page.open
      loan_page.circulation_desk_selector.when_present.select('BL_EDUC')
      loan_page.circulation_desk_yes.click if verify(5) {loan_page.circulation_desk_yes.present?}
      loan_page.loan_popup_box.wait_while_present if verify(5) {loan_page.loan_popup_box.present?}
      verify {loan_page.circulation_desk_selector.selected?('BL_EDUC')}
      loan_page.wait_for_page_to_load
      loan_page.patron_field.set("#{patron.barcode}\n")
      loan_page.item_field.when_present.set("#{item[:barcode]}\n")
      loan_page.loan_button.when_present.click if verify(10) {loan_page.loan_popup_box.present?}
      verify(10) {loan_page.item_barcode_link(1).when_present.text.strip.include?(item[:barcode])}

      # Return the item.
      return_page = OLE_QA::Framework::OLELS::Return.new(@ole)
      loan_page.return_button.when_present.click
      return_page.item_field.wait_until_present
      date            = Time.now.strftime("%m/%d/%Y")
      time            = Time.now.strftime("%k:%M")
      expected_str    = Time.now.strftime("%m/%d/%Y %I:%M %p")
      checkin        = OpenStruct.new(:date => date, :time => time, :expected_str => expected_str)
      return_page.checkin_date_field.set(checkin.date)
      return_page.checkin_time_field.set(checkin.time)
      return_page.item_field.set("#{item[:barcode]}\n")
      if verify(5) {return_page.checkin_message_box.present?}
        return_page.return_button.click
        return_page.checkin_message_box.wait_while_present
      end
      Watir::Wait.until {@ole.browser.windows.count > 1}
      @ole.browser.windows[-1].use
      @ole.browser.windows[0].close
      return_page.items_returned_toggle.wait_until_present
      verify(10) {return_page.item_barcode_link(1).text.include?(item[:barcode])}
      verify(10) {return_page.item_checkin_date.text.include?(checkin.expected_str)}
      return_page.end_session_button.when_present.click

      #Logout
      page.open
      page.logout
    end

    # Create a bib record and retrieve it through the 
    #   Search & Retrieval Unit API (SRU) with various
    #   search methods.
    #
    def sru_response
      # Create bib record.
      title_str   = OLE_QA::Framework::String_Factory.alphanumeric(12)
      author_str  = OLE_QA::Framework::String_Factory.alphanumeric(14)
      today       = Time.now.strftime('%Y%m%d-%H%M')
      bib_ary     = [{
                         :tag      => '245',
                         :ind_1    => '',
                         :ind_2    => '',
                         :value    => '|a' + title_str
                     },
                     {
                         :tag      => '100',
                         :ind_1    => '',
                         :ind_2    => '',
                         :value    => '|a' + author_str
                     }]
      bib_editor = OLE_QA::Framework::OLELS::Bib_Editor.new(@ole)
      bib_editor.open
      create_bib(bib_editor,bib_ary)
      query         = "title any #{title_str}"
      filename      = "sru_perf-#{today}.xml"
      get_sru_file(query,filename,@ole)
      records       = get_marc_xml(filename)
      verify(5) {File.zero?("data/downloads/#{filename}") == false}
      verify(5) {records.count == 1}
    end
  end
end
