import QtQuick 2.12
import QtQuick.Window 2.12

Window {
    id: root
    visible: true
    color: "black"
    title: qsTr("test task")

    property int pixDens: Math.ceil(Screen.pixelDensity)
    property int itemWidth: 33 * pixDens
    property int itemHeight: 11 * pixDens
    property int windowWidth: Screen.desktopAvailableWidth
    property int windowHeight: Screen.desktopAvailableHeight
    property int scaledMargin: 2 * pixDens
    property int fontSize: 5 * pixDens
    property string imageFileName: ""


    MouseArea {
        id: rotationArea
        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
        property bool isActive: false
        property bool isFirstChange: true
        property var currentPosition: Qt.vector2d(0.0, 0.0)
        property var anchorPosition: Qt.vector2d(0.0, 0.0)

        onPressed: {
            isActive = true
            isFirstChange = true
        }

        onReleased: {
            isActive = false
        }

        onWheel: {
            shader.wheelPosition += wheel.angleDelta.y / 120
        }

        onPositionChanged: {
            if (isActive && isFirstChange)
            {
                anchorPosition = Qt.vector2d(mouseX/root.width, mouseY/root.height);
                isFirstChange = false
            }

            if (isActive  && !isFirstChange)
            {
                currentPosition.x += mouseX/root.width - anchorPosition.x
                currentPosition.y += mouseY/root.height - anchorPosition.y
                anchorPosition = Qt.vector2d(mouseX/root.width, mouseY/root.height);
                shader.currentPosition = currentPosition;
            }
        }
    }

    ShaderEffect {
        id: shader
        width: root.width; height: root.height

        property var resolution: Qt.vector2d(root.width, root.height)
        property var currentPosition: Qt.vector2d(0.0, 0.0)
        property int wheelPosition: 0
        property variant source: Image {
            source: root.imageFileName
        }

        fragmentShader: "qrc:/perspective_projection_equirectangular_shader.fsh"
    }


    Button {
        id: openImageButton
        text: "Open image"
        height: itemHeight
        width: itemWidth
        onClicked: openImageDialog()
    }


    FileBrowser {
        id: imageFileBrowser
        anchors.fill: parent
        Component.onCompleted: fileSelected.connect(openImage)
    }

    Component.onCompleted: init()

    function init() {
        if (Qt.platform.os === "linux" || Qt.platform.os === "windows" || Qt.platform.os === "osx" || Qt.platform.os === "unix") {
            if (Screen.desktopAvailableWidth > 1280) {
                windowWidth = 1280
            }
            if (Screen.desktopAvailableHeight > 720) {
                windowHeight = 720
            }
        }

        height = windowHeight
        width = windowWidth

        imageFileBrowser.folder = imagePath
    }

    function openImageDialog() {
        imageFileBrowser.show()
    }

    function openImage(path) {
        imageFileName = path
    }
}
