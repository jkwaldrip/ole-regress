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

module OLE_QA
  # This module is for mix-in methods common to all Cucumber step definitions.
  module Cukes

    # Given a string containing an English-language ordinal, return an integer.
    def numerize(str)
      Chronic::Numerizer.numerize(str).to_i
    end

    # Given a string from user-generated Gherkin input, return it as a suitable hash key.
    def keyify(str)
      str.downcase.gsub(' ','_').to_sym
    end

    # Click the given named button on a page instance, if it exists.
    # e.g.
    #   click_which('Patron Search','search')
    def click_which(page_name,button)
      page = instance_variable_get("@#{keyify(page_name)}")
      raise OLE_QA::RegressionTest::Error,"Page not instantiated:  @#{page_name}" if page.nil?
      raise OLE_QA::RegressionTest::Error,"@#{page} does not have a #{button} button." unless page.elements.include?("#{button}_button".to_sym)
      page.send("#{button}_button".to_sym).click
      page.wait_for_page_to_load
    end

    # Set a given field element to a given value, then verify that that value was set properly.
    # e.g.
    #   set_field(@patron_editor.first_name_field,'Bob')
    def set_field(field,value)
      case field.class.name
        when /TextField/
          field.when_present.set(value)
          field.value.should eq(value)
        when /Select/
          Watir::Wait.until {field.present? || field.include?(value)}
          field.select(value)
          field.selected?(value).should be_true
        when /CheckBox/
          field.set(value)
          field.set?.should eq(value)
      end
    end
    alias_method(:set_selector,:set_field)
  end
end