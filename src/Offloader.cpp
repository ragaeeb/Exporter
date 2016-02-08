#include "precompiled.h"

#include "Offloader.h"
#include "Logger.h"
#include "Persistance.h"

namespace exportui {

using namespace canadainc;

Offloader::Offloader() :
        m_timeRender(bb::system::LocaleType::Region)
{
}


QString Offloader::renderStandardTime(QDateTime const& theTime)
{
    static QString format = bb::utility::i18n::dateTimeFormat(bb::utility::i18n::DateFormat::Medium);
    return m_timeRender.locale().toString(theTime, format);
}


void Offloader::lazyInit()
{
}


Offloader::~Offloader()
{
}

} /* namespace autoblock */
