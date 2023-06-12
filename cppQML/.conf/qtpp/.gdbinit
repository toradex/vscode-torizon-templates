python

import sys, os.path
sys.path.insert(0, os.path.expanduser("/qtpp"))

from qt import register_qt_printers
register_qt_printers (None)

from kde import register_kde_printers
register_kde_printers (None)

end
