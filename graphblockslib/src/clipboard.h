#ifndef CLIPBOARD_H
#define CLIPBOARD_H

#include <QApplication>
#include <QClipboard>
#include <QMimeData>

class Clipboard : public QObject
{
    Q_OBJECT
public:
    Q_PROPERTY(QString text READ text WRITE setText)

    QString text() const
    {
        return QApplication::clipboard()->text();
    }

public slots:

    void setText(QString arg)
    {
        QApplication::clipboard()->setText( arg );
    }
};

#endif // FILEIO_H
