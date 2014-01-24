#!/usr/bin/env ruby

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
dir = File.expand_path(File.dirname(__FILE__) + '/../')
$:<< dir unless $:.include?(dir)

require 'lib/ole-regress.rb'
require 'rspec'
require 'spec/spec_helper.rb'

# Parse command-line arguments.
if ARGV.count == 0 or ARGV[0] == 'help'
  puts 'Usage:'
  puts 'rerun spec_name browser_name'.rjust(25)
  exit
end

