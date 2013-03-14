#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include <QSettings>

class QRunnable;

namespace bb {
	namespace cascades {
		class AbstractPane;
		class Application;
	}

	namespace system {
		class SystemProgressDialog;
		class SystemToast;
	}
}

namespace exportui {

using namespace bb::system;
using namespace bb::cascades;

class ApplicationUI : public QObject
{
    Q_OBJECT

    QSettings m_settings;
    AbstractPane* m_root;
    SystemToast* m_toast;
    SystemProgressDialog* m_progress;
    qint64 m_accountId;

    ApplicationUI(bb::cascades::Application *app);
    void startThread(QRunnable* qr);

private slots:
    void onExportCompleted();
    void onImportCompleted(qint64 const& accountId, QVariantList const& qvl);
    void onProgressChanged(int const& progress);

public:
    static void create(bb::cascades::Application *app);

    Q_INVOKABLE QVariantList getMessagesFor(QString const& conversationKey);
    Q_INVOKABLE void saveValueFor(QString const& objectName, QVariant const& inputValue);
    Q_INVOKABLE QVariant getValueFor(QString const& objectName);
    Q_INVOKABLE void exportSMS(QStringList const& conversationIds);
};

}

#endif /* ApplicationUI_HPP_ */
