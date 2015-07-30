#include <QApplication>
#include <QQmlApplicationEngine>
#include <qqml.h>
#include <QResource>
#include <QDebug>
#include <graphblocks.h>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    GraphblocksContext* gbctx = initializeGraphBlocks();

    QQmlApplicationEngine engine;
    addGraphBlocksLibrary( &engine, "userlibs", "gblibs" );
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    int result = app.exec();
    shutdownGraphBlocks( gbctx );
    return result;
}
