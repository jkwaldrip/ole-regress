require 'rspec'
require 'spec_helper.rb'

describe 'The Circulation module' do

  include_context 'New Patron'
  include_context 'Create a Marc Record'
  include_context 'Checkout'
  include_context 'Checkin'

end
