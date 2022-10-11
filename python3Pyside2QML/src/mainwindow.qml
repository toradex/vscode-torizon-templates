import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle {
    width: 200
    height: 200
    color: "green"

    Text {
        id: mytext
        objectName: "mytext"
        text: "Hello World"
        anchors.centerIn: parent
    }

    Button {
        id: mybutton
        objectName: "mybutton"
        text: "Hello"
    }
}
