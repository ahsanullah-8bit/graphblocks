#ifndef CLIPBOARD_H
#define CLIPBOARD_H

#include <QApplication>
#include <QClipboard>
#include <QMimeData>
#include <QQmlEngine>

class Clipboard : public QObject
{
    Q_OBJECT
public:
    Q_PROPERTY(QString text READ text WRITE setText)

    QString text() const
    {
        return QApplication::clipboard()->text();
    }

    static QObject *qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
    {
        Q_UNUSED(engine);
        Q_UNUSED(scriptEngine);

        return new Clipboard;
    }
public slots:

    void setText(QString arg)
    {
        QApplication::clipboard()->setText( arg );
    }
};

#endif // FILEIO_H
