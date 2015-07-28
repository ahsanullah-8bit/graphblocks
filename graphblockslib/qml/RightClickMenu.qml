import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import "qrc:/qml/theme/";

Item {
    id: root
    property var options
    property var itemData
    property var settings // global settings
    onXChanged: reinit()
    onYChanged: reinit()
    onVisibleChanged: reinit()
    height: lv.height
    Rectangle {
        id: priv
        property bool noReinit
        property var shownOptions
        z: 800
        anchors.fill: parent
        border.width: 1
        border.color: ColorTheme.contextMenuBorder
        gradient: Gradient {
            GradientStop { position: 0.0; color: ColorTheme.contextMenu1}
            GradientStop { position: 1.0; color: ColorTheme.contextMenu2}
        }
    }
    function showOptions( data, opt, mx, my ) {
        priv.noReinit = true;
        if( mx && my ) {
            x = mx;
            y = my;
        }
        root.itemData = data;
        options = opt;
        visible = true;
        priv.noReinit = false;
        reinit();
    }
    function reinit() {
        if(priv.noReinit) return;

        if(visible) {
            lv.forceActiveFocus();
        }
        lv.model.clear();
        priv.shownOptions = [];
        for( var i in options) {
            if(options.hasOwnProperty(i)) {
                var opt = options[i];
                if(!opt.enabled || opt.enabled( itemData, settings)) {
                    lv.model.append( opt );
                    priv.shownOptions.push( opt );
                }
            }
        }
        if(lv.model.count === 0)
        {
            root.visible = false;
        }
    }
    ListView {
        property alias shownOptions: priv.shownOptions
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: 1
        anchors.leftMargin: 1
        anchors.topMargin: 1
        anchors.bottomMargin: 1
        height: model.count * 18 + 2
        id: lv
        z:900
        clip: true
        model: ListModel {}
        delegate: Text {
            verticalAlignment: Text.AlignVCenter
            height: 18
            text: name
            color: lv.currentIndex===index?Qt.darker("gray"):"gray"
            MouseArea {
                anchors.fill: parent
                id: lvMa
                z: 1
                hoverEnabled: true
                onEntered: {
                    lv.currentIndex = index;
                }
                onClicked: {
                    lv.shownOptions[ index ].action( root.itemData, root.settings );
                    root.visible = false;
                }
            }
        }
        highlight: Rectangle {
            anchors.left: if(parent) parent.left    //bug? parent is sometimes null
            anchors.right: if(parent) parent.right
            color: "lightGrey"
        }
    }
}
