#include "precompiled.h"

#include "Offloader.h"
#include "Logger.h"
#include "Persistance.h"

namespace exportui {

using namespace canadainc;

Offloader::Offloader() :
        m_timeRender(bb::system::LocaleType::Region),
        m_dateFormatter("MMMd")
{
}


QString Offloader::renderStandardTime(QDateTime const& theTime)
{
    if ( theTime.daysTo( QDateTime::currentDateTime() ) == 0 )
    {
        static QString format = bb::utility::i18n::timeFormat(bb::utility::i18n::DateFormat::Short);
        return m_timeRender.locale().toString(theTime, format);
    } else {
        return m_dateFormatter.format(theTime);
    }
}


void Offloader::lazyInit()
{
}


Offloader::~Offloader()
{
}

} /* namespace autoblock */
