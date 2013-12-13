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

module OLE_QA::RegressionTest::PURAP
  # This mix-in module contains helper methods for OLE Financial System requisitions.
  module Requisition
    
    # Set delivery building and room number.
    # @param  [Object] requisition   The OLE QA Framework requisition document instance.
    # @param  [Hash]   delivery_info A hash containing delivery information.
    # @option delivery_info [String] :building The name of the building to use.
    # @option delivery_info [String] :room     The room number to use.
    # Returns a hash with:
    # - :pass?              whether the test passed
    # - :error              the error message, if any error was raised
    # - :backtrace          the error backtrace, if any error was raised
    def set_delivery(requisition, delivery_info)
      hsh_out = Hash.new
      
      requisition.wait_for_page_to_load

      unless requisition.building_search_icon.present?
        requisition.delivery_tab_toggle.click
      end
      requisition.building_search_icon.wait_until_present
      requisition.building_search_icon.click
      
      ole = requisition.ole
      lookup = OLE_QA::Framework::OLEFS::Building_Lookup.new(ole)
      lookup.wait_for_page_to_load
      lookup.building_name_field.set(delivery_info[:building])
      lookup.search_button.click
      lookup.wait_for_page_to_load
      lookup.return_result(delivery_info[:building]).when_present.click
      
      requisition.wait_for_page_to_load
      requisition.room_field.when_present.set(delivery_info[:room])
      
      if ( requisition.closed_building_field.text.include?(delivery_info[:building]) &&\
            requisition.room_field.value.include?(delivery_info[:room]) )
        hsh_out[:pass?] = true
      else
        hsh_out[:pass?] = false
      end
      hsh_out

    rescue => e
      hsh_out[:pass?]       = false
      hsh_out[:error]       = e.message
      hsh_out[:backtrace]   = e.backtrace
      hsh_out
    end
    
    # Select a vendor.
    # @param [Object]   requisition   The OLE QA Framework requisition instance to use.
    # @param [String]   vendor        The vendor to select.  (Using vendor alias works best!)
    #
    # Returns a hash with:
    # - :pass?              whether the test passed
    # - :error              the error message, if any error was raised
    # - :backtrace          the error backtrace, if any error was raised
    #
    def set_vendor(requisition, vendor)
      hsh_out = Hash.new

      requisition.wait_for_page_to_load
      unless requisition.vendor_search_icon.present?
        requisition.vendor_tab_toggle.click
      end
      requisition.vendor_search_icon.when_present.click

      ole = requisition.ole
      lookup = OLE_QA::Framework::OLEFS::Vendor_Lookup.new(ole)
      lookup.wait_for_page_to_load
      lookup.vendor_name_field.set(vendor)
      lookup.search_button.click
      lookup.return_result(/#{vendor}/).when_present.click

      requisition.wait_for_page_to_load
      if requisition.closed_vendor_name_field.text.include?(vendor)
        requisition.vendor_tab_toggle.click
        hsh_out[:pass?] = true
      else
        hsh_out[:pass?] = false
      end
      hsh_out

    rescue => e
      hsh_out[:pass?]       = false
      hsh_out[:error]       = e.message
      hsh_out[:backtrace]   = e.backtrace
      hsh_out
    end

    # Set a new line item to use a new bibliographic record, then open the Marc editor.
    # @param [Object] requisition     The OLE QA Framework requisition instance to use.
    #
    # Returns a hash with:
    # - :pass?              whether the test passed
    # - :error              the error message, if any error was raised
    # - :backtrace          the error backtrace, if any error was raised
    #
    def set_new_bib(requisition)
      hsh_out = Hash.new

      requisition.new_bib_option.when_present.set
      requisition.new_bib_button.when_present.click
      ole = requisition.ole
      Watir::Wait.until { ole.browser.windows.count > 1 }
      ole.browser.windows[-1].use
      
      hsh_out[:pass?] = true
      hsh_out

    rescue => e
      hsh_out[:pass?]       = false
      hsh_out[:error]       = e.message
      hsh_out[:backtrace]   = e.backtrace
      hsh_out
    end

    # Set the accounting line on a line item.
    # @param  [Object]  requisition   The OLE QA Framework requisition instance to use.
    # @param  [Hash]    account_info  The options hash to use for accounting information.
    # @option account_info  [Fixnum]  :line_number  The line item number to set the new account line on.
    # @option account_info  [String]  :chart        The chart code to use.
    # @option account_info  [String]  :account      The account number to use.
    # @option account_info  [String]  :object       The object code to use.
    # @option account_info  [String]  :dollar       The dollar amount to set, if any.  (Precedence is given to percentages.)
    # @option account_info  [String]  :percent      The percentage to set, if any.  (Default is 100%.)
    # 
    # Returns a hash with:
    # - :pass?              whether the test passed
    # - :error              the error message, if any error was raised
    # - :backtrace          the error backtrace, if any error was raised
    #
    def set_acct(requisition, account_info)
      hsh_out = Hash.new

      requisition.line_item.line_number = account_info.has_key?(:line_number) ? account_info[:line_number] : 1
      requisition.line_item.accounting_lines_toggle.click unless requisition.line_item.chart_selector.present?
      requisition.line_item.chart_selector.when_present.select(account_info[:chart])
      requisition.line_item.account_number_field.set(account_info[:account])
      requisition.line_item.object_field.set(account_info[:object])
      if account_info.has_key?(:percent) 
        requisition.line_item.percent_field.set(account_info[:percent])
      elsif account_info.has_key?(:dollar)
        requisition.line_item.dollar_field.set(account_info[:dollar])
      else
        requisition.line_item.percent_field.set('100.00')
      end
      requisition.line_item.add_account_button.when_present.click

      hsh_out[:pass?] = true
      hsh_out

    rescue => e
      hsh_out[:pass?]       = false
      hsh_out[:error]       = e.message
      hsh_out[:backtrace]   = e.backtrace
      hsh_out
    end
  end
end
