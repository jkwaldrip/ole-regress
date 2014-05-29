$:<< File.join(File.dirname(__FILE__),'..')

# Require regression testing code.
require 'lib/ole-regress.rb'

# Require shared contexts.
require 'spec/shared.rb'
Dir['spec/*/shared.rb'].sort.each {|file| require file}

RSpec.configure do |config|

  # Initiate a new OLE QA Framework Session before each spec.
  config.before(:all) do
    opts = OLE_QA::RegressionTest::Options
    @ole = OLE_QA::Framework::Session.new(opts)
  end

  config.after(:all) do
    # Close the browser session only if it is still alive after a test.
    # @note This will not close the Headless session.  Closing and reopening
    #   Headless between tests tends to result in errors reporting that
    #   XVFB is frozen.
    @ole.browser.close if @ole.browser.is_a?(Watir::Browser)
  end

  config.after(:suite) do
    # Close the OLE session if it is still active.
    # @note Calling @ole.quit tears down the Headless session and
    #   calls browser.close on Watir-Webdriver.
    @ole.quit if @ole.class == OLE_QA::Framework::Session
  end

  config.after(:each) do
    if ! example.exception.nil? && @ole.class == OLE_QA::Framework::Session
      time     = "#{Time.now.strftime("%Y\-%m\-%d \- %I-%M-%S %p %Z")}"
      filename = "#{time} - #{example.full_description.to_s}.png"
      @ole.browser.screenshot.save('screenshots/' + filename)
    end
  end

end
