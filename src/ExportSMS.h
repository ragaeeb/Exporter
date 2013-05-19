#ifndef EXPORTSMS_H_
#define EXPORTSMS_H_

#include <QRunnable>
#include <QStringList>

#include <bb/system/SystemProgressToast>

namespace exportui {

class ExportSMS : public QObject, public QRunnable
{
	Q_OBJECT

	qint64 m_accountId;
	QStringList m_keys;
	bb::system::SystemProgressToast m_progress;

signals:
	void exportCompleted();

public:
	ExportSMS(QStringList const& keys, qint64 const& accountId);
	void run();
};

} /* namespace exportui */
#endif /* EXPORTSMS_H_ */
