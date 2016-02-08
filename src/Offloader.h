#ifndef OFFLOADER_H_
#define OFFLOADER_H_

#include <bb/system/LocaleHandler>

namespace exportui {

using namespace bb::utility::i18n;

class Offloader : public QObject
{
    Q_OBJECT

    bb::system::LocaleHandler m_timeRender;

public:
    Offloader();
    virtual ~Offloader();

    Q_INVOKABLE QString renderStandardTime(QDateTime const& theTime);

    void lazyInit();
};

} /* namespace autoblock */

#endif /* OFFLOADER_H_ */
