import sys
import os
import PySide2
from PySide2.QtWidgets import QApplication
from PySide2.QtCore import QUrl, QObject
from PySide2.QtQuick import QQuickView

if __name__ == "__main__":
    print("Hello Torizon!")

    qurlPath = qurlPath = "src/mainwindow.qml"

    app = QApplication(sys.argv)

    view = QQuickView()

    qml = QUrl(qurlPath)

    view.setSource(qml)
    view.show()
    root = view.rootObject()

    text = root.findChild(QObject, "mytext")
    button = root.findChild(QObject, "mybutton")

    button.clicked.connect(
        lambda: text.setProperty("text", "Hello Qt World!"))

    sys.exit(app.exec_())