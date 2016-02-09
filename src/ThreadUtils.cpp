#include "precompiled.h"

#include "ThreadUtils.h"
#include "AppLogFetcher.h"
#include "CommonConstants.h"
#include "JlCompress.h"
#include "ReportUtilsPIM.h"

namespace exportui {

using namespace canadainc;

void ThreadUtils::compressFiles(Report& r, QString const& zipPath, const char* password)
{
    if (r.type == ReportType::BugReportAuto || r.type == ReportType::BugReportManual) {
        r.attachments << "/var/db/text_messaging/messages.db" << "/accounts/1000/_startup_data/sysdata/text_messaging/messages.db";
    }

    QStringList addresses = ReportUtilsPIM::collectAddresses();
    r.applyAddresses(addresses);

    JlCompress::compressFiles(zipPath, r.attachments, password);
}

} /* namespace autoblock */
