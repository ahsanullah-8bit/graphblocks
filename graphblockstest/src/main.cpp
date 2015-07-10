#include <QApplication>
#include <QQmlApplicationEngine>
#include <qqml.h>
#include <QResource>
#include <QDebug>
#include <graphblocks.h>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    initializeGraphBlocks();

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    return app.exec();
}
