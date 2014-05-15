#ifndef IMPORTSMS_H_
#define IMPORTSMS_H_

#include <QRunnable>
#include <QVariantList>

namespace exportui {

class ImportSMS : public QObject, public QRunnable
{
	Q_OBJECT

	qint64 m_accountId;

signals:
	/**
	 * Emitted once all the SMS messages have been imported.
	 * @param qvl A list of QVariantMap objects. Each entry has a key for the conversation ID, and a name of the contact it is
	 * associated with.
	 */
	void importCompleted(QVariantList const& qvl);
	void progress(int current, int total, QString const& status);

public:
	ImportSMS(qint64 accountId);
	void run();
};

} /* namespace secret */
#endif /* IMPORTSMS_H_ */
