#ifndef IMPORTSMS_H_
#define IMPORTSMS_H_

#include <QRunnable>
#include <QVariantList>

#include <bb/system/SystemProgressToast>

namespace exportui {

class ImportSMS : public QObject, public QRunnable
{
	Q_OBJECT

	bb::system::SystemProgressToast m_progress;

signals:
	/**
	 * Emitted once all the SMS messages have been imported.
	 * @param qvl A list of QVariantMap objects. Each entry has a key for the conversation ID, and a name of the contact it is
	 * associated with.
	 */
	void importCompleted(qint64 accountId, QVariantList const& qvl);

public:
	ImportSMS();
	void run();
};

} /* namespace secret */
#endif /* IMPORTSMS_H_ */
