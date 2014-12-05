#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include "LazySceneCover.h"
#include "PaymentHelper.h"
#include "Persistance.h"

#include <bb/system/InvokeManager>

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

    bb::system::InvokeManager m_invokeManager;
    Persistance m_persistance;
    LazySceneCover m_cover;
    PaymentHelper m_payment;
    QObject* m_root;
    bb::system::InvokeRequest m_request;

    ApplicationUI(bb::cascades::Application *app);
    void initRoot(QString const& qml="main.qml");

Q_SIGNALS:
	void initialize();
	void accountsImported(QVariantList const& qvl);
	void messagesImported(QVariantList const& qvl);
	void conversationsImported(QVariantList const& qvl);
	void loadProgress(int current, int total, QString const& status);
	void lazyInitComplete();

private slots:
    void onExportCompleted();
    void lazyInit();
    void invoked(bb::system::InvokeRequest const& request);
    void cardFinished();
    void onMessageLoadProgress(int current, int total);

public:
    static void create(bb::cascades::Application *app);
    ~ApplicationUI();

    Q_INVOKABLE void loadAccounts();
    Q_INVOKABLE void getMessagesFor(QString const& conversationKey, qint64 accountId);
    Q_INVOKABLE void getConversationsFor(qint64 accountId);
    Q_INVOKABLE void exportSMS(QStringList const& conversationIds, qint64 accountId, int outputFormat);
    Q_INVOKABLE void saveTextData(QString const& file, QString const& data);
};

}

#endif /* ApplicationUI_HPP_ */
