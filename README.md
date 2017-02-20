# [Graph]-->[Blocks]
GraphBlocks provides an easy way to make program logic accessible and customizable to end users. It is easy to integrate for developers.

# Overview
Not everyone is a developer! When working together with artists or business people there sometimes is a need
to express sourcecode in a way everyone can understand or even work with. Enter GraphBlocks. It provides an easy-to-use
component to integrate into your Qt Qml application.
* **For the User** it opens a window with an graphical editor. Design program behavious with Drag & Drop.
* **For the application** there are two modes of operation
 * define your input and output. Using Qmls property bindings the output is recalculated whenever the input changes (or the user changes the graph) or
 * a simple function is returned. It can be called whenever the application desires to execute the usergenerated code.
 
 Whatever mode you choose, Blocks with custom (Javascript) applicationcode can be made available to the user easily.
 
## Features
* Save and load Graphs you created previously
* Import libraries of blocks the application provides.
* Easy block-interface for the application: A block can be a simple qml file.
* SuperBlocks: Define input and output of your graph and save it as a SuperBlock. It can then be used just like a normal block.
 Double-clicking it will take the user to the graph behind the SuperBlock.
* Input and outputs can be very flexible by using Qt/Qmls native mechanisms.
* Quick Access menu. Use space of right-click to open a list of blocks that can be used. Type the name of a block to filter.

## Usage of the Example

This repository comes with a small example next to the library itself. The example publishes mouse coordinates
to a GraphBlocks instance. It reads a coordiante to draw a red ball at that position.
Custom blocks are available which allow to draw rectangles. This is everything we need to create a small pong-game!


## Usage in your application

In your application code initialize GraphBlocks.

    GraphblocksContext* graphblockscontext = initializeGraphBlocks();

Load a library with custom blocks where "gblibs" is the name of a folder with qml files.

    QQmlApplicationEngine engine;
    addGraphBlocksLibrary( &engine, "userlibs", "gblibs" );

... at the end shutdown graph blocks

    shutdownGraphBlocks( graphblockscontext );

The following button will sho a GraphBlocks window when clicked

            Button {
                text: "[Graph]-->[Blocks]"
                GraphBlocksWindow {
                    id: gbw
                    control.input: ["mouseCoordX", "mouseCoordY"]
                    control.output: ["ballX", "ballY"]
                    control.sourceElement: gbw
                    control.manualMode: manualMode.checked
                    property real ballX: 0
                    property real ballY: 0
                    property real mouseCoordX: ma.mouseX
                    property real mouseCoordY: ma.mouseY
                    visible: false
                    width: 800
                    height: 500
                }
                onClicked: gbw.visible = !gbw.visible
            }

Libraries can also be added using qml:

            Component.onCompleted: {
                gbw.importLibrary("Draw", drawLib);
            }
            DrawingLibrary {
                id: drawLib
                canvas: drawingArea
            }
            
A block is a normal qml item with some special reserverd properties and a qml component, which has also reserved propertynames:

Properties of the Item:
* **displayName** Name of the type of block. This must be globally unique.
 It is used for serialization and must never clash. New versions of a block may also break the system
* **compo** The Qml Component which will be instantiated for each block instance.

**compo** is a n Item with the following reserver properties:
* **input** Array of strings with names of input properties. The name of the variables will be shown to the user on mouse over.
* **output** Array of strings with names of output properties.
* **execute** function that is executed 

For example, this is the code for the "less than" block, which is part of the basic block library:

    Item {
        id: blockLess
        property string displayName: "<"
        property string className: "lessThan"
        property var compo: Component {
            Item {
                property var input: ["op1", "op2"]
                property var output: ["result"]
                property real op1
                property real op2
                property real result: op1 < op2
            }
        }
    }


