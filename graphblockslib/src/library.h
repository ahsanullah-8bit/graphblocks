#ifndef LIBRARY_H
#define LIBRARY_H

#include <QObject>
#include <QQmlEngine>

class Library : public QObject
{
    Q_OBJECT

public:
    //Q_INVOKABLE bool setDefaultLibrary(const QString& libname);
    Q_INVOKABLE bool addLibrary(const QString& libname, const QString& folder);
    Q_INVOKABLE bool checkIfGraphExists(const QString &libname, const QString &name);
    Q_INVOKABLE bool addGraphToLib(const QString &libname, const QString &name, const QString &data);
    Q_INVOKABLE bool deleteGraphFromLib(const QString& libname, const QString& name);

    Q_INVOKABLE QString loadFolderAsLib(const QString &libname, const QString& folder);
    Q_INVOKABLE QString loadLibs();

    static Library *getInstance( QQmlEngine *engine ) {
        Library *instance = engine->property("_Library").value<Library*>();
        if( !instance )
        {
            instance = new Library;
            engine->setProperty("_Library", QVariant::fromValue(instance));
        }
        return instance;
    }

    static QObject *qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
    {
        Q_UNUSED(scriptEngine);

        return getInstance( engine );
    }

public slots:

signals:

private:
    QString loadLib( const QString &libname );
    QMap<QString, QString> m_folderToLib;
    QMap<QString, QString> m_libToFolder;
};

#endif // FILEIO_H
