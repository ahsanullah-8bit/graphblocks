#include "library.h"
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QTextStream>
#include <QDebug>
#include <QStringBuilder>

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
    if (!file.open(QFile::WriteOnly | QFile::Truncate))
        return false;

    QTextStream out(&file);
    out << data;

    file.close();

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
    }
}

QString Library::loadLibs()
{
    QString allLibs("{");
    foreach(QString libname, m_libToFolder) {
        allLibs += loadLib( libname );
        allLibs += ",";
    }
    allLibs.replace(allLibs.length() - 1, "}");
    return allLibs;
}

QString Library::loadLib(const QString &libname)
{
    QString libStr("{");
    QDir folder( m_libToFolder[ libname ] );
    foreach( QString f, folder.entryList( QStringList("*.blocks"), QDir::Files | QDir::Readable, QDir::Name))
    {
        QFile file( folder.absoluteFilePath(f) );
        QString fileContentStr("{name:");
        fileContentStr += "\"";
        fileContentStr += QFileInfo(f).baseName().replace("\"", "_"); //TODO: remove special chars
        fileContentStr += "\", graph:";
        if ( file.open(QIODevice::ReadOnly) ) {
            QString line;
            QTextStream t( &file );
            do {
                line = t.readLine();
                fileContentStr += line;
             } while (!line.isNull());

            file.close();
        } else {
            return QString();
        }
        libStr += fileContentStr;
        libStr += ",";
    }
    libStr.replace(libStr.length() - 1, "}");
    qDebug() << "the whole lib: " << libStr;
    return libStr;
}
