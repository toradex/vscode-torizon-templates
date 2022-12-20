import sys
import os
import PySide2
from PySide2.QtWidgets import QApplication
from PySide2.QtCore import QUrl, QObject
from PySide2.QtQuick import QQuickView

if __name__ == "__main__":
    print("Hello world!")

    qurlPath = ""
    if(os.path.exists(os.path.expanduser("~/app/mainwindow.qml"))):
        # Path of the qml source code file inside the debug container on the board, to debug the application remotelly on the board
        qurlPath = os.path.expanduser("~/app/mainwindow.qml")
    elif (os.path.exists("/app/mainwindow.qml")):
        # Path of the qml source code file inside the release container on the board, to run the release (production) application on the board
        qurlPath = "/app/mainwindow.qml"
    elif(os.path.exists("src/mainwindow.qml")):
        # Path of the qml source code file on host, to debug the application locally
        qurlPath = "src/mainwindow.qml"

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