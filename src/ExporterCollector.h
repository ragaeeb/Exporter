#ifndef EXPORTERCOLLECTOR_H_
#define EXPORTERCOLLECTOR_H_

#include "AppLogFetcher.h"

#define CARD_LOG_FILE QString("%1/logs/card.log").arg( QDir::currentPath() )

namespace exportui {

using namespace canadainc;

class ExporterCollector : public LogCollector
{
public:
    ExporterCollector();
    QString appName() const;
    QByteArray compressFiles();
    ~ExporterCollector();
};

} /* namespace quran */

#endif /* EXPORTERCOLLECTOR_H_ */
