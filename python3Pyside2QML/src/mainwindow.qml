import QtQuick 2.13
import QtQuick.Window 2.13

Window {
    id: mainWindow
    visible: true
    visibility: "FullScreen"
    width: 640
    height: 320
    title: qsTr("Title")

    OpacityAnimator
    {
        id: animator
        target: mainWindow.contentItem
        from: 0
        to: 1
        duration: 1000
        running: true
    }

    ScaleAnimator {
        target: mainWindow.contentItem
        from: 0
        to: 1
        duration: 5000
        running: true
        easing.type: "Bezier"
    }

    Scene {
        id: main
        anchors.fill: parent
    }
}
