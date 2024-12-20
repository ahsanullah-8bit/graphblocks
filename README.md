# [Graph]-->[Blocks]
GraphBlocks provides an easy way to make program logic accessible and customizable to end users. It is easy to integrate for developers.
![alt text](https://github.com/dabulla/graphblocks/raw/master/doc/example_overview.png "Overview")

# Overview
Not everyone is a developer! When working together with artists or business people there sometimes is a need
to express sourcecode in a way everyone can understand or even work with. Enter GraphBlocks. It provides an easy-to-use
component to integrate easily into your Qt Qml application.
* **For the User** it opens a window with an graphical editor. Design program behavious with Drag & Drop.
* **For the application** there are two modes of operation
 * define your input and output. Using Qmls property bindings. The output is recalculated whenever the input changes (or the user changes the graph) or
 * a simple function/callback is provided to the application, that was designed by the user. It can be called whenever the application desires to execute the usergenerated code.
 
 Whatever mode you choose, Blocks with custom (Javascript) applicationcode can be made available to the user easily.
 
## Building
Building guide is the same for all platforms, except installing the Qt.
### Linux
* Go to [Qt for Open Souce developement](https://www.qt.io/download-open-source) and download the Qt Online Installer binaries at the bottom. In the installer, log in, do the license stuff until you get to the components.
* Check the `Archives` and click `Filter` on the right, older versions of Qt will be listed as well now.
* Check on the `Qt 5.15` and select other options you want, and download. Make sure Qt Creator is also downloaded.
* Clone this repo, open it in Qt Creator and hit run.
```
> git clone --recursive https://github.com/ahsanullah-8bit/graphblocks.git
```

### Windows
Same as the linux setup...

## Features
* Design code using visual programming, drag & drop.
* Save and load graphs of blocks
* Import libraries of blocks the application provides.
* Easy block-interface for the application: A block can be a simple qml file.
* Rename Blocks as you like
* Copy/Paste of blocks. Use shortcuts.
* SuperBlocks: Define input and output of your graph and save it as a SuperBlock. It can then be used just like a normal block.
 Double-clicking it will take the user to the graph behind the SuperBlock.
* Input and outputs can be very flexible by using Qt/Qmls native mechanisms.
* Quick Access menu. Use space of right-click to open a list of blocks that can be used. Type the name of a block to filter.

The quick access menu let's you filter an search all available block types
![alt text](https://github.com/dabulla/graphblocks/raw/master/doc/example2.png "Quick Access menu")

## Usage of the Example

This repository comes with a small example next to the library itself. The example publishes mouse coordinates
to a GraphBlocks instance. It reads a coordiante to draw a red ball at that position.
Custom blocks are available which allow to draw rectangles. This is everything we need to create a small pong-game!

The Example defines input (blue) and output (red).

![alt text](https://github.com/dabulla/graphblocks/raw/master/doc/example5.png "blank sample application")

You can drag and drop blocks from the left into the graph area. For example the SinusValue block looks like this

![alt text](https://github.com/dabulla/graphblocks/raw/master/doc/example3.png "blank sample application")

Drag a line from the black output splot from a block and connect it to the input of another block to create program logic.

### Superblocks

Drag and drop a Superblock from the library (left) into the grapharea, then double-click it's green button. A new empty grapharea apears.

Create input for the Superblock by dragging a block from the library into the emtpy area, e.g. a real value. To mark this block as input, simply right-click it and choose "convert to public input".

![alt text](https://github.com/dabulla/graphblocks/raw/master/doc/example_input.png "Superblock input")

Do the same for output by selection "convert to public output".

![alt text](https://github.com/dabulla/graphblocks/raw/master/doc/example_output.png "Superblock output")

When you are finished, click the "back" button at the top left.

You can safe your work to the library by right-clicking the superblock an select "Save Block to Library"

![alt text](https://github.com/dabulla/graphblocks/raw/master/doc/example_superblock_save.png "Super Blocks")


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


