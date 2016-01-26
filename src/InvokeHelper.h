#ifndef INVOKEHELPER_H_
#define INVOKEHELPER_H_

#include "DeviceUtils.h"

#include <bb/system/InvokeRequest>

namespace bb {
    namespace system {
        class InvokeManager;
    }
}

namespace canadainc {
    class Persistance;
}

namespace exportui {

using namespace canadainc;
using namespace bb::system;

class InvokeHelper : public QObject
{
    Q_OBJECT

    bb::system::InvokeRequest m_request;
    QObject* m_root;
    InvokeManager* m_invokeManager;
    canadainc::DeviceUtils m_deviceUtils;
    Persistance* m_persist;

    void finishWithToast(QString const& message);

private slots:
    void cardFinished();
    void onChapterMatched();
    void onDataLoaded(QVariant id, QVariant data);
    void onDatabasePorted();
    void onPicked(int chapter, int verse);
    void onSearchPicked(int chapter, int verse);

public:
    InvokeHelper(InvokeManager* invokeManager, Persistance* p);
    virtual ~InvokeHelper();

    void init(QString const& qmlDoc, QMap<QString, QObject*> const& context, QObject* parent);
    QString invoked(bb::system::InvokeRequest const& request);
    void lazyInit();
    void process();
};

} /* namespace admin */

#endif /* INVOKEHELPER_H_ */
