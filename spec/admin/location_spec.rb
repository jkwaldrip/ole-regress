require 'rspec'
require 'spec_helper.rb'

describe 'A location' do
  include_context 'Create Location'

  context 'with level 1' do
    it 'is created by admin' do
      login('admin').should be_true
      new_location(@location)
    end

    it 'is searchable' do
      verify_location(@location)
    end

    it 'has an id' do
      @location.id = location_lookup.id_by_text(@location.code).text.strip
      @location.id.should_not be_empty
      @location.id.should =~ /\d/
    end
  end

  context 'with level 2' do
    it 'is created by admin' do
      login('admin').should be_true
      new_location(@child_loc)
    end

    it 'is searchable' do
      verify_location(@child_loc)
    end

    it 'has a parent location' do
      @child_loc.parent_id = location_lookup.parent_id_by_text(@child_loc.code).text.strip
      @child_loc.parent_id.should_not be_empty
      @child_loc.parent_id.should eq(@location.id)
    end
  end

end
