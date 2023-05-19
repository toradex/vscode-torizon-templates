''' Docstring '''
# pylint: disable = unused-import
# pylint: disable = no-name-in-module

import sys

from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtGui import QGuiApplication
from PySide2.QtCore import QUrl

if __name__ == "__main__":
    print("Hello Torizon!")

    QURL_PATH = "src/mainwindow.qml"

    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    engine.load(QUrl(QURL_PATH))

    sys.exit(app.exec_())
