#include "library.h"
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QTextStream>
#include <QDebug>
#include <QStringBuilder>

namespace graphblocks {

bool Library::addLibrary(const QString &libname, const QString &folder)
{
    qDebug() << "Adding library " << libname << " " << folder;
    QDir f(folder);
    if( m_libToFolder.contains( libname ) )
    {
        qDebug() << "Library: " << libname << " already added. ( pointing to " << m_libToFolder[ libname ] << ")";
        return false;
    }
    if( m_folderToLib.contains( f.absolutePath() ) )
    {
        qDebug() << "Folder: " << f.absolutePath() << " already added. ( as library " << m_folderToLib[ f.absolutePath() ] << ")";
        return false;
    }
    m_libToFolder[ libname ] = f.absolutePath();
    m_folderToLib[ f.absolutePath() ] = libname;
    return true;
}

bool Library::checkIfGraphExists(const QString &libname, const QString &name)
{
    if( m_libToFolder.contains( libname ))
    {
        qDebug() << "Unknown Library";
        return false;
    }
    QDir folder( m_libToFolder[ libname ] );
    QString filename = folder.absoluteFilePath( name + ".blocks" );
    if (filename.isEmpty())
        return false;
    if(filename.startsWith("file:///")) {
        filename = filename.split("file:///")[1];
        if(filename.at(1) != ':') {
            filename = "/" + filename;
        }
    }

    QFile file(filename);
    return file.exists();
}

bool Library::addGraphToLib(const QString &libname, const QString &name, const QString &data)
{
    QString ln = libname;
    if( m_libToFolder.contains( libname ) )
    {
        if( libname != "" ) return false;
        ln = m_libToFolder.firstKey();
        qDebug() << "Unknown Library while saving graph, using first lib: " + ln;
    }
    QDir folder( m_libToFolder[ ln ] );
    QString filename = folder.absoluteFilePath( name + ".blocks" );
    qDebug() << "fn " + filename;
    if (filename.isEmpty())
        return false;
    if(filename.startsWith("file:///")) {
        filename = filename.split("file:///")[1];
        if(filename.at(1) != ':') {
            filename = "/" + filename;
        }
    }

    QFile file(filename);
    if (!file.open(QFile::WriteOnly | QFile::Truncate))
        return false;

    qDebug() << "opened " + file.fileName();
    QTextStream out(&file);
    out << data;

    file.close();

    qDebug() << "done";
    return true;
}

bool Library::deleteGraphFromLib(const QString &libname, const QString &name)
{
    if( m_libToFolder.contains( libname ))
    {
        qDebug() << "Unknown Library while saving graph";
        return false;
    }
    QDir folder( m_libToFolder[ libname ] );
    QString filename = folder.absoluteFilePath( name + ".blocks" );
    if (filename.isEmpty())
        return false;
    if(filename.startsWith("file:///")) {
        filename = filename.split("file:///")[1];
        if(filename.at(1) != ':') {
            filename = "/" + filename;
        }
    }

    QFile file(filename);
    return file.remove();
}

QString Library::loadFolderAsLib(const QString &libname, const QString &folder)
{
    if( addLibrary(libname, folder) ) {
        return loadLib( libname );
    }
    //Note: when called a second time, this will load nothing
    return "";
}

QString Library::loadLibs()
{
    QString allLibs("[");
    bool oneOrMoreLoaded = false;
    foreach(QString libname, m_libToFolder.keys()) {
        QString loadedLib = loadLib( libname );
        allLibs += loadedLib;
        if(!loadedLib.isEmpty()) {
            allLibs += ",";
            oneOrMoreLoaded = true;
        }
    }
    if( oneOrMoreLoaded ) {
        allLibs[allLibs.length() - 1] = QChar(']');
    }
    else
    {
        allLibs += "]";
    }
    return allLibs;
}

QString Library::loadLib(const QString &libname)
{
    qDebug() << "Loading: " << libname << " folder: " << m_libToFolder[ libname ];
    QString libStr("{\"libname\":\"" + libname + "\", \"entries\":[");
    QDir folder( m_libToFolder[ libname ] );
    bool oneOrMoreLoaded = false;
    foreach( QString f, folder.entryList( QStringList("*.blocks"), QDir::Files | QDir::Readable, QDir::Name))
    {
        QFile file( folder.absoluteFilePath(f) );
        QString fileContentStr("{\"displayName\":");
        fileContentStr += "\"";
        fileContentStr += QFileInfo(f).baseName().replace("\"", "_"); //TODO: remove special chars
        fileContentStr += "\", \"graph\":";
        if ( file.open(QIODevice::ReadOnly) ) {
            QString line;
            QTextStream t( &file );
            do {
                line = t.readLine();
                fileContentStr += line;
             } while (!line.isNull());

            file.close();
            fileContentStr += "}";
        } else {
            fileContentStr = "";
        }
        libStr += fileContentStr;
        if(!fileContentStr.isEmpty()) {
            libStr += ",";
            oneOrMoreLoaded = true;
        }
    }
    if( oneOrMoreLoaded )
    {
        libStr[libStr.length() - 1] = QChar(']');
    }
    else
    {
        libStr += "]";
    }
    libStr += "}";
    return libStr;
}

}
