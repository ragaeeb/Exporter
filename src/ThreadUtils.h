#ifndef THREADUTILS_H_
#define THREADUTILS_H_

#include <QString>

namespace canadainc {
    class Report;
}

namespace exportui {

struct ThreadUtils
{
    static void compressFiles(canadainc::Report& r, QString const& zipPath, const char* password);
};

} /* namespace quran */

#endif /* THREADUTILS_H_ */
