import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import "qrc:/qml/theme/";

Item {
    property string displayName: "Super Block"
    property string className: "superBlock"
    property var compo: Component {
        GraphBlocksDynamicBlockInner {
            id: superblockInner
            width: 100
            height: 20
            property var input: ["inp1", "inp2"]
            property var output: ["outp1", "outp2"]
            property var inp1
            property var inp2
            property var outp1
            property var outp2
            Text {
                text: "[Graph]-->[Blocks]"
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true
                    propagateComposedEvents: false
                    onDoubleClicked: {
                        gbw.visible = !gbw.visible;
                    }
                    GraphBlocksWindow {
                        id: gbw
                        control.input: ["inp1", "inp2"]
                        control.output: ["outp1", "outp2"]
                        control.sourceElement: superblockInner
                        visible: false
                        width: 800
                        height: 500
                        isEditingSuperblock: true
                    }
                }
            }
        }
    }
}
