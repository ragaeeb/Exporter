#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include "InvokeHelper.h"
#include "LazySceneCover.h"
#include "Offloader.h"
#include "PaymentHelper.h"
#include "Persistance.h"

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
    PaymentHelper m_payment;
    InvokeHelper m_invoke;
    Offloader m_offloader;

    void initRoot(QString const& qml="main.qml");

Q_SIGNALS:
	void initialize();
	void accountsImported(QVariantList const& qvl);
	void messagesImported(QVariantList const& qvl);
	void conversationsImported(QVariantList const& qvl);
	void loadProgress(int current, int total, QString const& status);
	void lazyInitComplete();

private slots:
    void onExportCompleted(int success, int failed);
    void lazyInit();
    void invoked(bb::system::InvokeRequest const& request);
    void onMessageLoadProgress(int current, int total);

public:
    ApplicationUI(InvokeManager* i);
    ~ApplicationUI();

    Q_INVOKABLE void loadAccounts();
    Q_INVOKABLE void getMessagesFor(QString const& conversationKey, qint64 accountId);
    Q_INVOKABLE void getConversationsFor(qint64 accountId);
    Q_INVOKABLE void exportSMS(QStringList const& conversationIds, qint64 accountId, int outputFormat);
    Q_INVOKABLE void saveTextData(QString const& file, QString const& data);
    Q_INVOKABLE bool hasContactsAccess();
};

}

#endif /* ApplicationUI_HPP_ */
