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

dir = File.expand_path(File.dirname(__FILE__))
$:.unshift(dir) unless $:.include?(dir)

require 'rspec'
require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'
require 'lib/ole-regress.rb'

desc 'Print OLE Regression Test Suite version.'
task :version do
  puts "OLE Regression Test Version #{OLE_QA::RegressionTest::VERSION}"
end

desc 'Clean out the screenshots/ folder.'
task :scn_clean do
  files = Dir['screenshots/*.png']
  if files.empty?
    puts "No screenshots found."
  else
    files.each do |file|
      File.delete(file)
    end
    puts "#{files.count} screenshots deleted."
  end
end

desc 'Clean out the logs/ folder.'
task :log_clean do
  logs = Dir['logs/*.log']
  txts = Dir['logs/*.txt']
  logs.concat(txts)
  if logs.empty?
    puts 'No logfiles found.'
  else
    logs.each do |logfile|
      File.delete(logfile)
    end
    puts "#{logs.count} logfiles deleted."
  end
end

desc 'Clean temporary data folders.'
task :data_clean do
  downloads = Dir['data/downloads/*']
  uploads   = Dir['data/uploads/*']
  files     = downloads.concat(uploads)
  if files.empty?
    puts 'No data files found.'
  else
    files.each do |file|
      File.delete(file)
    end
    puts "#{files.count} data files deleted."
  end
end

desc 'Clean performance profile data.'
task :prof_clean do
  files = Dir['performance/*']
  if files.empty?
    puts 'No files found.'
  else
    files.each do |file|
      File.delete(file)
    end
    puts "#{files.count} performance profile files deleted."
  end
end

desc 'Clean all temporary data directories.'
task :all_clean do
  Rake::Task['log_clean'].invoke
  Rake::Task['scn_clean'].invoke
  Rake::Task['data_clean'].invoke
  Rake::Task['prof_clean'].invoke
end

desc 'Interactively configure config/options.yml'
task :configurator do
  config_file = File.open('config/options.yml','r')
  options     = YAML.load(config_file)
  config_file.close
  
  options.each do |k,v|
    puts "#{k.to_s.ljust(20)}:  #{v}"
    puts "... (k)eep or (c)hange? [k|c]"
    ans = STDIN.gets.chomp
    if ans =~ /[Cc]/
      puts "Enter new value:"
      new_val    = STDIN.gets.chomp
      if v.is_a?(TrueClass) || v.is_a?(FalseClass)
        new_val.match(/^[Tt]/) ? new_val = true : new_val = false
      else
       new_val = new_val.to_i unless new_val.to_i == 0
      end
      options[k] = new_val
      puts "#{k.to_s.ljust(20)} updated to:  #{new_val}"
    end
  end

  config_file = File.open('config/options.yml','w')
  YAML.dump(options,config_file)
  config_file.close
  
end

desc 'Show current options in config/options.yml'
task :show_config do
  config_file = File.open('config/options.yml','r')
  options     = YAML.load(config_file)
  config_file.close
  options.each do |k,v|
    puts "#{k.to_s.ljust(20)}:  #{v}"
  end
end

desc 'Run all specs with default configuration.'
RSpec::Core::RakeTask.new(:all_specs) do |task|
  task.rspec_opts = '-r spec_helper.rb'
end

desc 'Run only smoketest specs.'
RSpec::Core::RakeTask.new(:smoketest) do |task|
  task.pattern    = 'spec/smoketest/*_spec.rb'
  task.rspec_opts = '-r spec_helper.rb'
end

desc 'Run all Cucumber tests.'
Cucumber::Rake::Task.new(:cucumber) do |task|
  task.cucumber_opts = "features --format pretty"
end


desc 'Run all RSpec & Cucumber tests.'
task :regress do
  Rake::Task['all_specs'].invoke
  Rake::Task['cucumber'].invoke
end

desc 'Default:  Show version.'
task :default => :version

desc 'Show latest compatible OLE release version.'
task :works_with do
  puts OLE_QA::RegressionTest::OLE_VERSION
end
