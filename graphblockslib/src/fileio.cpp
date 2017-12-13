#include "fileio.h"
#include <QFile>
#include <QTextStream>

namespace graphblocks {

FileIO::FileIO(QObject *parent) :
    QObject(parent)
{

}

QString FileIO::read()
{
    if (mSource.isEmpty()){
        emit error("source is empty");
        return QString();
    }
    if(mSource.startsWith("file:///")) {
        mSource = mSource.split("file:///")[1];
        if(mSource.at(1) != ':') {
            mSource = "/" + mSource;
        }
    }

    QFile file(mSource);
    QString fileContent;
    if ( file.open(QIODevice::ReadOnly) ) {
        QString line;
        QTextStream t( &file );
        do {
            line = t.readLine();
            fileContent += line;
         } while (!line.isNull());

        file.close();
    } else {
        emit error("Unable to open the file");
        return QString();
    }
    return fileContent;
}

bool FileIO::write(const QString& data)
{
    if (mSource.isEmpty())
        return false;
    if(mSource.startsWith("file:///")) {
        mSource = mSource.split("file:///")[1];
        if(mSource.at(1) != ':') {
            mSource = "/" + mSource;
        }
    }

    QFile file(mSource);
    if (!file.open(QFile::WriteOnly | QFile::Truncate))
        return false;

    QTextStream out(&file);
    out << data;

    file.close();

    return true;
}

}
