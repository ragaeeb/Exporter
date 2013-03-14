#ifndef EXPORTSMS_H_
#define EXPORTSMS_H_

#include <QObject>
#include <QRunnable>
#include <QStringList>

namespace exportui {

class ExportSMS : public QObject, public QRunnable
{
	Q_OBJECT

	qint64 m_accountId;
	QStringList m_keys;

signals:
	void exportCompleted();
	void progress(int const& progress);

public:
	ExportSMS(QStringList const& keys, qint64 const& accountId);
	void run();
};

} /* namespace exportui */
#endif /* EXPORTSMS_H_ */
