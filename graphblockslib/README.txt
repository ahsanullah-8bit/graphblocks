* Add Tree View
* Add scalable Comment Block
* Type info in tooltip
* Highlight for connectible slots
* import files
* multi selection
* multi-slot (one new slot becomes appearent when previevs have been assigned)
* super-block
* input blocks / output blocks (not deletable, not editable)
* component to hook graph in application for values, functions, ...
* settings ?
* automatic blocks from class, without input/output info. Everything is input + output at the same time? (parse const, slots, readonly, notify, ...)

* compatible entity/component engine


/// API:
* cpp: call
    qmlRegisterType<FileIO, 1>("FileIO", 1, 0, "FileIO");
  to enable save/load from filesystem.
* instantiate GraphBlocksWindow (invisible?)
** configure inputs and outputs like this:
    Button {
        text: "[]--[]"
        GraphBlocksWindow {
            id: gbw
            control.input: ["mouseCoordX", "mouseCoordY"]
            control.output: ["ballX", "ballY"]
            control.sourceElement: gbw
            property real ballX
            property real ballY
            property real mouseCoordX: ma.mouseX
            property real mouseCoordY: ma.mouseY
            property real mouseCoordXRand: ma.mouseX + 100
            visible: false
            width: 800
            height: 500
        }
        onClicked: gbw.visible = !gbw.visible
    }
* use loadLibrary(qmlItem) to register children of "qmlItem" as blocks
** blocks must be of type Item with properties:
        property string displayName: "my display name"
        property string className: "myuniqueclassname"
        property var compo: Component {
            Item/TextField/... {
                property var output: ["val"]
                property var input: ["src"]
                property alias val: src
                property real src
                function serialize() {
                    return {src: blockRealText.src};
                }
            }
        }
* use loadGraph(json, x, y)
* use saveGraph() <- returns json
* additionally ui allows to save/load
* show/hide Window whenever needed
