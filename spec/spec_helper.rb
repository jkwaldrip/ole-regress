$:<< File.join(File.dirname(__FILE__),'..')

# Require regression testing code.
require 'lib/ole-regress.rb'

# Require shared contexts.
require 'spec/shared.rb'
Dir['spec/*/shared.rb'].sort.each {|file| require file}
