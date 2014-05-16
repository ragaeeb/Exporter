#include "precompiled.h"

#include "ExporterCollector.h"
#include "JlCompress.h"

namespace exportui {

using namespace canadainc;

ExporterCollector::ExporterCollector()
{
}


QString ExporterCollector::appName() const {
    return "exporter";
}


QByteArray ExporterCollector::compressFiles()
{
    AppLogFetcher::dumpDeviceInfo();

    QStringList files;
    files << DEVICE_INFO_LOG;
    files << CARD_LOG_FILE;
    files << UI_LOG_FILE;
    files << QSettings().fileName();

    for (int i = files.size()-1; i >= 0; i--)
    {
        if ( !QFile::exists(files[i]) ) {
            files.removeAt(i);
        }
    }

    JlCompress::compressFiles(ZIP_FILE_PATH, files);

    QFile f(ZIP_FILE_PATH);
    f.open(QIODevice::ReadOnly);

    QByteArray qba = f.readAll();
    f.close();

    QFile::remove(UI_LOG_FILE);

    return qba;
}


ExporterCollector::~ExporterCollector()
{
}

} /* namespace autoblock */
