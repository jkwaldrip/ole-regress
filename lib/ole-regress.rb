#!/usr/bin/sh ruby

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

$:<< File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__))

require 'ole-qa-framework'
require 'chronic'

require 'ostruct'
require 'yaml'
require 'timeout'

module OLE_QA
  module RegressionTest

    # Load all *.rb in lib/ole_regress/
    Dir['lib/ole_regress/*.rb'].sort.each do |file|
      require file
    end

    # Load classes in lib/ole_regress/*/
    Dir['lib/ole_regress/*/*.rb'].sort.each do |file|
      require file
    end
  
    # Load all helper modules.
    Dir['lib/module/*.rb'].sort.each do |file|
      require file
    end
    Dir['lib/module/*/*.rb'].sort.each do |file|
      require file
    end

    # Allow OLE_QA::RegressionTest::Error as a viable error class.
    class Error < StandardError
    end

  end
end
