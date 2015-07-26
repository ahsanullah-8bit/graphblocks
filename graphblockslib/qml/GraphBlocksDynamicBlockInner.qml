import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import "qrc:/qml/theme/";

Item {
    id: root
    property var input: []
    property var output: []
    property bool isDynamic: true
    Item {
        id: priv
        property var inputMap
        property var ouputMap
        property var ouputToChangedMethod
        Component.onCompleted: {
            if(typeof(inputMap) == "undefined") {
                inputMap = {};
            }
            if(typeof(ouputMap) == "undefined") {
                ouputMap = {};
            }
            if(typeof(ouputToChangedMethod) == "undefined") {
                ouputToChangedMethod = {};
            }
        }
    }

    function setBlockInput( propname, value ) {
        if(priv.inputMap[propname] !== value) {
            priv.inputMap[propname] = value;
            if(-1 == input.indexOf( propname )) {
                input.push( propname );
            }
        }
    }
    function setBlockOutput( propname, value ) {
        if(priv.ouputMap[propname] !== value) {
            priv.ouputMap[propname] = value;
            if(-1 == input.indexOf(propname)) {
                output.push( propname );
            }
            if(priv.ouputToChangedMethod[propname] === "undefined") {
                priv.ouputToChangedMethod[propname]( value );
            }
        }
    }
    function connectToChangedSignal(propname, fn) {
        var oldfn = ouputToChangedMethod[propname];
        if( typeof(oldfn) === "function") {
            ouputToChangedMethod[propname] = function( value ) { fn( value ); oldfn( value ); };
        } else {
            ouputToChangedMethod[propname] = fn;
        }
    }
}

