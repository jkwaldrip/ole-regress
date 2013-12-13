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

module OLE_QA::RegressionTest
  # This module includes methods related to patron creation.
  module Patron

    # Create a new patron record.
    # @param [Object]   page            The OLE QA Framework Patron page instance to use.
    # @param [Object]   patron_struct   The OpenStruct containing the patron info to use.
    #
    # @note The easiest way to get all the patron info necessary to create a new record is
    #   patron = OpenStruct.new( OLE_QA::Framework::Patron_Factory.new_patron )
    #   (See {OLE_QA::Framework::Patron_Factory#new_patron} for more information.)
    #
    # @note This method returns an array that may contain only true or false based on the outcome message,
    #   or may contain an error message, if the rescue clause is invoked.
    def create_patron(page,patron)
      page.wait_for_page_to_load
      page.barcode_field.when_present.set(patron.barcode)
      page.borrower_type_selector.select(patron.borrower_type)
      # FIXME - The ID for the activation date field causes spectacular failures ever since the Rice upgrade.
      # Use the   page.activation_date_field element once that ID problem is resolved.
      # Bug is OLE-5441.
      page.browser.text_field(:id => 'OlePatronDocument-OverviewSection_control').set(today)
      page.first_name_field.set(patron.first)
      page.last_name_field.set(patron.last)
      page.address_line.details_link.click
      page.address_line.line_1_field.when_present.set(patron.address)
      page.address_line.city_field.set(patron.city)
      page.address_line.state_selector.select(patron.state)
      page.address_line.postal_code_field.set(patron.postal_code)
      page.address_line.country_selector.select('United States')
      page.address_line.valid_from_date_field.set(today)
      page.address_line.active_checkbox.set(true)
      # FIXME - The ID for this element has changed.  The original line can be uncommented when the
      #   original ID is restored.
      #   page.address_line.add_button.click
      page.browser.button(:id => 'addFee_add').click
      page.address_line.line_number = 2
      page.address_line.line_1_field.wait_until_present
      page.phone_line.phone_number_field.when_present.set(patron.phone)
      page.phone_line.country_selector.select('United States')
      page.phone_line.active_checkbox.set(true)
      page.phone_line.add_button.click
      page.phone_line.line_number = 2
      page.phone_line.phone_number_field.wait_until_present
      page.email_line.email_address_field.when_present.set(patron.email)
      page.email_line.active_checkbox.set(true)
      page.email_line.add_button.click
      page.email_line.line_number = 2
      page.email_line.email_address_field.wait_until_present
      page.submit_button.click
      page.message.wait_until_present
      page.message.text =~ /success/ ? [true] : [false]
    rescue => e 
      ary_out = []
      ary_out << false
      ary_out << e.message
      out
    end
  end
end

