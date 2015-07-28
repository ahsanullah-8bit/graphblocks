import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import "qrc:/qml/theme/";

Item {
    id: root
    property var controlManager
    property string displayName: "Super Block"
    property string className: "superBlock"
    property var compo: Component {
        GraphBlocksDynamicBlockInner {
            id: superblockInner
            width: 100
            height: 20
            property var json
            Component.onDestruction: {
                root.controlManager.removeSuperblockControl( superblockInner );
            }
            function initialize() {
                root.controlManager.createSuperblockControl( superblockInner );
            }
            function serialize() {
                return { json: controlManager.serializeSuperblock( superblockInner ) };
            }
            Rectangle {
                width: 100
                height: 20

                gradient: Gradient {
                    GradientStop { position: 0.0; color: ma.containsMouse?Qt.lighter(ColorTheme.superblock1):ColorTheme.superblock1 }
                    GradientStop { position: 1.0; color: ColorTheme.superblock2 }
                }
                radius: 20
                Text {
                    anchors.margins: 10
                    anchors.fill: parent
                    text: "[Grp]-[Blks]"
                    font.pixelSize: 10
                    color: "white"
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter
                }
                MouseArea {
                    id: ma
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true
                    propagateComposedEvents: false
                    onDoubleClicked: {
                        root.controlManager.showSuperBlockControl( superblockInner );
                    }
                }
            }
        }
    }
}
