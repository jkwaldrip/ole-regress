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
