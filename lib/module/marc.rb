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
  # This module provides support for Marc and Marc XML records through the Ruby Marc gem.
  module Marc

    # Given an XML file in data/downloads/, return the contents of that
    #   file as an array of MARC XML format records.
    def get_marc_xml(filename)
      filename = ( filename =~ /.xml$/ ? filename : filename + '.xml')
      records = Array.new
      reader  = MARC::XMLReader.new("data/downloads/#{filename}")
      reader.each do |record|
        records << record
      end
      records
    end

  end
end