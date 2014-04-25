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
  # This module contains helper methods for spin asserts.
  module Assertions

    # The interval in seconds to wait between retrying an assertion.
    INTERVAL = 1

    # Set a given field element to a given value, then verify that that value was set properly.
    # e.g.
    #   set_field(@patron_editor.first_name_field,'Bob')
    def set_field(field,value)
      case field.class.name
        when /TextField/
          field.when_present.set(value)
          expect(field.value).to eq(value.chomp)
        when /Select/
          Watir::Wait.until {field.present? && field.include?(value)}
          field.select(value)
          expect(field.selected?(value)).to be_true
        when /CheckBox/
          field.when_present.set(value)
          expect(field.set?).to eq(value)
      end
    end
    alias_method(:set_selector,:set_field)

    # Repeat an assertion until success or timeout, and report true or false outcome.
    # @param [Fixnum] timeout     The timeout interval, in seconds.
    #
    # @note This assertion will not return any errors, only a value of false.
    #   This is necessary to ensure that assertions fail gracefully.  Be sure the
    #   assertion would normally evaluate to true while writing the lambda to use with this method.
    #
    # @usage 
    #   if assert { loan_page.loan_popup_box.present? }
    #     loan_page.loan_button.when_present.click
    #   end
    #
    def assert(timeout = OLE_QA::Framework.explicit_wait)
      timeout = Time.now + timeout
      begin
        return true if yield
        sleep INTERVAL
      rescue
      end while Time.now < timeout
      false
    end
    alias_method(:verify,:assert)

    # Reload a page, test an assertion, and if it fails, start over.
    # @param [String] page_url    The URL of the page to load.
    # @param [Fixnum] timeout     The timeout interval, in seconds.
    # @param [Object] ole_session The OLE QA Framework session to run the assertion in.
    #
    # @note This assertion will not return any errors, thanks to the rescue clause.
    #   This is necessary to ensure that assertions fail gracefully.  Be sure the assertion
    #   would normally evaluate to true while writing the lambda to pass to this method.
    #
    # @usage page_assert( requisition.lookup_url('4007') )
    #     { requisition.document_type_status.text.strip.include?('Closed') }
    #
    def page_assert(page_url, timeout = OLE_QA::Framework.doc_wait, ole_session = @ole)
      timeout = Time.now + timeout
      ole_session.browser.goto(page_url)
      begin
        return true if yield
        sleep INTERVAL
        ole_session.browser.refresh
        ole_session.browser.goto(page_url) unless ole_session.browser.url == page_url
      rescue
      end while Time.now < timeout
      false
    end
    alias_method(:assert_page,:page_assert)
    
  end
end
