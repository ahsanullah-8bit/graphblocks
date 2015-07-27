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
            width: 100
            height: 20
            Text {
                text: "[Graph]-->[Blocks]"
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true
                    propagateComposedEvents: false
                    onDoubleClicked: {
                        console.log("clicked double");
                    }
                }
            }
        }
    }
}
