#include <QApplication>
#include <QQmlApplicationEngine>
#include "fileio.h"
#include "clipboard.h"
#include <qqml.h>
#include <QResource>

int initializeGraphBlocks()
{
    Q_INIT_RESOURCE(graphblocks);
    //QResource::registerResource("qml.rcc");
    qmlRegisterType<FileIO, 1>("FileIO", 1, 0, "FileIO");
    qmlRegisterType<Clipboard, 1>("Clipboard", 1, 0, "Clipboard");
}
