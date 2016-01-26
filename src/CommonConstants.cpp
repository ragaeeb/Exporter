#include "CommonConstants.h"
#include "precompiled.h"

namespace exportui {

QString CommonConstants::getTimeFormat(int tf)
{
    QString timeFormat = QObject::tr("MMM d/yy hh:mm:ss");

    switch (tf)
    {
        case 1:
            timeFormat = QObject::tr("hh:mm:ss");
            break;

        case 2:
            timeFormat = "";
            break;

        default:
            break;
    }

    return timeFormat;
}

}
