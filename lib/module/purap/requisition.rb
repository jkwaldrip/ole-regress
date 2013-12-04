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
    
    # Set the location, price, and copies (optional) on a new line item and add that line.
    # @param  [Object]      requisition           The OLE QA Framework requisition instance to use.
    # @param  [Hash]        line_info             The options to set on the line item before adding.
    # @option line_info     [String]    price     The line item list price value.
    # @option line_info     [String]    location  The location for the line item itself.
    # @option line_info     [String]    copies    The number of copies to set on the line item.
    #
    # Returns a hash with:
    # - :pass?              whether the test passed
    # - :error              the error message, if any error was raised
    # - :backtrace          the error backtrace, if any error was raised
    #
    def set_new_line(requisition, line_info)
      hsh_out = Hash.new

      requisition.wait_for_page_to_load
      requisition.list_price_field.when_present.set(line_info[:price])
      requisition.location_selector.when_present.select(line_info[:location])
      if line_info[:copies]
        requisition.copies_field.when_present.set(line_info[:copies])
      end
      requisition.add_button.click
      requisition.wait_for_page_to_load

      hsh_out[:pass?] = true      
      hsh_out

    rescue => e
      hsh_out[:pass?]       = false
      hsh_out[:error]       = e.message
      hsh_out[:backtrace]   = e.backtrace
      hsh_out
    end

    # Verify that the given information exists on a line item with a specific line-number.
    # @param    [Object]    requisition     The OLE QA Framework requisition instance to use.
    # @param    [Hash]      line_info       The information to verify on the line item.
    # @option   line_info   [Fixnum]    :line_num     The 1-based line item number to use.
    # @option   line_info   [String]    :price        The line item list price.
    # @option   line_info   [String]    :location     The line item location.
    # @option   line_info   [String]    :copies       The line item number of copies.
    #
    # Returns a hash with:
    # - :pass?              whether the test passed
    # - :error              the error message, if any error was raised
    # - :backtrace          the error backtrace, if any error was raised
    # - and one key for each given in line_info, e.g. :price?, with true/false outcome value
    #
    def check_line_item(requisition, line_info)
      hsh_out = Hash.new
      
      requisition.line_item.line_number = line_info[:line_num]
      
      if ( line_info[:price] &&\
          requisition.line_item.list_price_field.when_present.value.include?(line_info[:price]) )
          hsh_out[:price?] = true
      else
          hsh_out[:price?] = false
      end

      if ( line_info[:location] &&\
          requisition.line_item.location_selector.when_present.value.include?(line_info[:location]) )
        hsh_out[:location?] = true
      else
        hsh_out[:location?] = false
      end

      if ( line_info[:copies] &&\
          requisition.line_item.copies_field.when_present.value.include?(line_info[:copies]) )
        hsh_out[:copies?] = true
      else
        hsh_out[:copies?] = false
      end

      hsh_out[:pass?] = hsh_out.has_value?(false) ? false : true
      hsh_out

    rescue => e
      hsh_out[:pass?]       = false
      hsh_out[:error]       = e.message
      hsh_out[:backtrace]   = e.backtrace
      hsh_out
    end

  end
end
