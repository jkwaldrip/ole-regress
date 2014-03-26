ole-regress
===========

OLE Regression Testing Suite
[Kuali OLE](http://www.kuali.org/ole)
---

This is a regression testing suite for the Kuali Open Library Environment (OLE) project.

### Code

To keep this testing suite adaptable and flexible, reusable code modules are currently being stored in [lib/module/](/lib/module/),
and basic namespacing and reusable constants are stored in [lib/ole_regress/](/lib/ole_regress/), loaded by lib/ole-regress.rb.

### RSpec

Currently, RSpec is being used to handle test execution and expectation building.  Each directory under [spec/](/spec/)
represents an OLE functional module, and each contains a shared.rb file for shared context definitions particular
to that module.  There is also a shared.rb in [spec/](/spec/shared.rb) for globally shared context definitions.
There is a [base specs](/spec/base/) folder for basic specs used to ensure that the regression suite can perform
basic tasks like starting an OLE QA Framework session.

### Installation

    git clone https://github.com/jkwaldrip/ole-regress.git
    cd ole-regress
    bundle install

### Usage

To run the full suite of regression tests, use:

    ./bin/regress

To run the full suite of regression tests across multiple browsers with a SauceLabs connection, edit config/sauce.yml
to enter your SauceLabs configuration information (e.g., username, API key, browser and OS versions to use), then run:

    ./bin/xregress

To rerun a failed spec against a single browser in SauceLabs, use:

    ./bin/xrerun path/to/spec.rb browser

To run the performance profiler, which performs a series of tests and records their run times in a CSV file, use:

    ./bin/profiler

