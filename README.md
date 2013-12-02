ole-regress
===========

OLE Regression Testing Suite
[Kuali OLE](http://www.kuali.org/ole)
---

This is a regression testing suite for the Kuali Open Library Environment (OLE) project.

### Code

To keep this testing suite adaptable and flexible, reusable code modules are currently being stored in (/lib/module/),
and basic namespacing and reusable constants are stored in (/lib/ole_regress/), loaded by lib/ole-regress.rb

### RSpec

Currently, RSpec is being used to handle test execution and expectation building.  Each directory under (/spec/)
represents an OLE functional module, and each contains a shared.rb file for shared context definitions particular
to that module.  There is also a shared.rb in [spec/](/spec/shared.rb) for globally shared context definitions.
