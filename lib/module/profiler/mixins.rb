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
  # This module contains mix-in methods to be used by the OLE QA Profiler app.
  module Mixins

    # Start an OLE Framework session.
    def ole_start
      @ole = OLE_QA::Framework::Session.new(OLE_QA::RegressionTest::Options)
    end

    # Stop the OLE Framework session.
    def ole_stop
      @ole.quit
    end

    # Format a test's runtime into a string.
    # @return [String] HH:MM:SS (seconds are rounded)
    def format_time(time_in_seconds)
      min, sec = time_in_seconds.divmod(60)
      hrs, min = min.divmod(60)
      "#{format("%02d",hrs)}:#{format("%02d",min)}:#{format("%02d",sec.round)}"
    end

    # Return a pre-formatted time string reflecting the current time.
    def current_time
      Time.now.strftime('%I:%M:%S %p')
    end

    def run_test(test_name,test)
      out = [test_name]

      5.times do
        ole_start
        begin
          time_now  = current_time
          test_time = format_time(Benchmark.realtime {self.send(test)})
          puts "#{test_name.ljust(45)} #{time_now.ljust(15)} #{test_time}"
          out << test_time
        rescue => e
          test_time = format_time(0)
          puts "#{test_name.ljust(45)} #{time_now.ljust(15)} ERROR"
          out << test_time
        end
        ole_stop
        sleep 15
      end
      out
    end
  end
end