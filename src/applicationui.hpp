#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include <bb/cascades/ArrayDataModel>

#include "LazySceneCover.h"
#include "Persistance.h"

class QRunnable;

namespace bb {
	namespace cascades {
		class Application;
	}
}

namespace exportui {

using namespace bb::system;
using namespace bb::cascades;
using namespace canadainc;

class ApplicationUI : public QObject
{
    Q_OBJECT

    Persistance m_persistance;
    LazySceneCover m_cover;
    qint64 m_accountId;
    ArrayDataModel m_adm;

    ApplicationUI(bb::cascades::Application *app);
    void startThread(QRunnable* qr);

private slots:
    void onExportCompleted();
    void onImportCompleted(qint64 accountId, QVariantList const& qvl);

public:
    static void create(bb::cascades::Application *app);
    ~ApplicationUI();

    Q_INVOKABLE QVariantList getMessagesFor(QString const& conversationKey);
    Q_INVOKABLE void exportSMS(QStringList const& conversationIds);
    Q_INVOKABLE QVariant getDataModel();
};

}

#endif /* ApplicationUI_HPP_ */
