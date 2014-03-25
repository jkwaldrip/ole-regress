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
    def submit_requisition
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
