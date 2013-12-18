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
  # This module includes methods for location creation and location search.
  module Location
    
    # Create a new location in OLE.
    # @param [Object] page    The OLE QA Framework location page instance to use.
    # @param [Object] struct  A struct containing a location code, name, level, description, and optional parent location.
    # 
    # @note Returns an array containing a true or false value for success or failure, and the error message if any.
    #
    # @usage
    #   ostruct = OpenStruct.new(OLE_QA::Framework::Location_Factory.new_location)
    #   create_location(already_open_page, struct)
    #
    def create_location(page, struct)
      page.wait_for_page_to_load
      page.description_field.when_present.set(struct.description)
      page.location_code_field.set(struct.code)
      page.location_name_field.set(struct.name)
      page.location_level_field.set(struct.level)
      unless struct.parent.nil?
        page.parent_location_icon.when_present.click
        ole     = page.ole
        lookup  = OLE_QA::Framework::OLELS::Location_Lookup.new(ole)
        lookup.wait_for_page_to_load
        lookup.location_code_field.set(struct.parent)
        lookup.search_button.click
        Watir::Wait.until { lookup.text_in_results?(struct.parent) }
        lookup.return_by_text(struct.parent).click
        page.wait_for_page_to_load
      end
      results = [page.submit]
      results
    rescue => e
      results = [false]
      results << e.message
      results
    end

    # Find a location in OLE.
    # @param [Object] page    The OLE QA Framework location lookup page instance to use.
    # @param [Object] struct  A struct containing a location code, name, level, and option id.
    #
    # @note Returns an array containing a true or false value for success or failure, and the error message if any.
    #
    # @note For best results, use with an OpenStruct created with:
    #   ostruct = OpenStruct.new(OLE_QA::Framework::Location_Factory.new_location)
    #
    def find_location(page, struct)
      page.wait_for_page_to_load
      page.location_id_field.when_present.set(struct.id) unless struct.id.nil?
      page.location_code_field.when_present.set(struct.code)
      page.location_name_field.set(struct.name)
      page.location_level_field.set(struct.level)
      page.search_button.click
      page.wait_for_page_to_load
      if page.text_in_results?(struct.code) || page.text_in_results?(struct.id)
        results = [true]
      else
        results = [false]
        results << "#{struct.code} not found in search results."
      end
      results
    rescue => e
      results = [false]
      results << e.message
      results
    end
  end
end
