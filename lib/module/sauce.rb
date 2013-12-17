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
  # This module contains methods for handling SauceLabs sessions in regression testing.
  #
  # @usage
  #   OLE_QA::RegressionTest.start_browser('firefox'|'chrome'|'internet explorer'|'safari')
  #
  module Sauce   
    @options = YAML.load_file('config/sauce.yml')

    class << self

      # SauceLabs options hash.
      attr_reader :options

      # Start the specified browser in a SauceLabs session.
      #
      # @param [String] which Which browser to use.  ('firefox'|'chrome'|'internet explorer'|'safari')
      #
      def start_browser(which)
        which.gsub!(' ','_')
        @caps = Selenium::WebDriver::Remote::Capabilities.send(which.to_sym)
        case which
        when 'firefox','chrome','internet_explorer'
          os  = 'Windows ' + @options[:platforms][:windows]
        when 'safari'
          os = 'OS X ' + @options[:platforms][:os_x]
        end
        @caps.platform              = os
        @caps.version               = @options[:browsers][which.to_sym]
        time                        = Time.now.strftime('%Y-%m-%d %I:%M %p %Z')
        @caps[:name]                = "RegressionTest - #{time} - #{which} on #{os}"
        @caps['record-video']       = false
        @caps['sauce-advisor']      = false
        username        = @options[:username]
        api_key         = @options[:api_key]
        OLE_QA::RegressionTest::Options[:browser] = Watir::Browser.new(
          :remote,
          :url => "http://#{username}:#{api_key}@ondemand.saucelabs.com:80/wd/hub",
          :desired_capabilities => @caps
        )
      end


    end
  end
end
