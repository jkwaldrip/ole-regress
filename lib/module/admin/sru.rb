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
  # This module includes methods for testing the OLE Search/Retrieval Unit API.
  module SRU
    # Given a CQL Query string, return a URL-friendly version of that query.
    # @note See http://www.loc.gov/standards/sruBob/specs/cql.html for more info.
    def urlify(query_str)
      URI.encode(query_str).gsub('=','%3D')
    end

    # Given an OLE Framework session and an SRU query in CQL v1.2,
    #   return a suitable URL to retrieve that query from the SRU module.
    # @note See http://www.loc.gov/standards/sruBob/specs/cql.html for more info.
    def get_v12_url(ole_session,query_str)
      url = ole_session.docstore_url + 'sru?version=1.2&operation=searchRetrieve&query='
      url += urlify(query_str)
    end
    alias_method(:get_url,:get_v12_url)

    # Given an OLE Framework session and an SRU query in CQL v1.2,
    #   return a suitable URL to retrieve that query from the SRU module.
    # @note See http://www.loc.gov/standards/sruBob/specs/cql.html for more info.
    def get_v10_url(ole_session,query_str)
      url = ole_session.docstore_url + 'sru?version=1.0&operation=searchRetrieve&query='
      url += urlify(query_str)
    end

    # Given a suitable SRU query URL, open that URL and write the results
    #   to an XML file in data/downloads/ with the given filename.
    def write_sru(url,filename)
      filename = ( filename =~ /.xml$/ ? filename : filename + '.xml')
      File.open("data/downloads/#{filename}",'w') do |file|
        open(url).each_line do |line|
          file << line
        end
      end
    end


    def get_sru_file(query,filename,ole_session)
      url       = get_url(ole_session,query)
      write_sru(url,filename)
    end
  end
end