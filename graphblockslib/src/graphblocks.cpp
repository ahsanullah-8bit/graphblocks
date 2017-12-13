#include <QApplication>
#include <QQmlApplicationEngine>
#include "fileio.h"
#include "clipboard.h"
#include "library.h"
#include <qqml.h>
#include <QResource>
#include <QQmlContext>
#include <QVariant>
#include <QDebug>

struct GraphblocksContext
{
    graphblocks::Library m_lib;
};

GraphblocksContext* initializeGraphBlocks()
{
    // Note: this is not 1 to 1 qmlContext <-> Library <-> gbContext! Use other mechanism with global object for qmlcontext. The gb is always connected with a specific qml context.
    Q_INIT_RESOURCE(graphblocks);
    //QResource::registerResource("qml.rcc");

    GraphblocksContext* ctx = new GraphblocksContext();

    qmlRegisterType<graphblocks::FileIO, 1>("FileIO", 1, 0, "FileIO");
    qmlRegisterSingletonType<graphblocks::Clipboard>("Clipboard", 1, 0, "Clipboard", &graphblocks::Clipboard::qmlInstance);
    qmlRegisterSingletonType<graphblocks::Library>("Library", 1, 0, "Library", &graphblocks::Library::qmlInstance);
    return new GraphblocksContext();
}


void addGraphBlocksLibrary(QQmlEngine *ctx, const QString &libname, const QString &folder)
{
    graphblocks::Library *lib = graphblocks::Library::getInstance( ctx );
    if( !lib ) {
        qDebug() << "Library manager not avaliable";
        return;
    }
    lib->addLibrary(libname, folder);
}


void shutdownGraphBlocks(GraphblocksContext *ctx)
{
    delete ctx;
}
