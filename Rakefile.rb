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

lib = File.expand_path(File.dirname(__FILE__))
$:.unshift(lib) unless $:.include?(lib)

require 'rspec/core/rake_task'
require 'lib/ole-regress.rb'

desc 'Print OLE Regression Test Suite version.'
task :version do
  puts OLE_QA::RegressionTest::VERSION
end

RSpec::Core::RakeTask.new(:spec)

desc 'Default:  Show version.'
task :default => :version
