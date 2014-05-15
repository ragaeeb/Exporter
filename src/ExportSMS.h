#ifndef EXPORTSMS_H_
#define EXPORTSMS_H_

#include <QRunnable>
#include <QSettings>

#include "OutputFormat.h"

namespace exportui {

struct FormattedAttachment
{
    QByteArray data;
    QString name;
};

struct FormattedMessage
{
    QString sender;
    QString timestamp;
    QString body;
    QList<FormattedAttachment> attachments;
};

struct FormattedConversation
{
    QList<FormattedMessage> messages;
    QString fileName;
};

class ExportSMS : public QObject, public QRunnable
{
	Q_OBJECT

	qint64 m_accountId;
	QStringList m_keys;
	QSettings m_settings;
	OutputFormat::Type m_format;

	QList<FormattedConversation> formatConversations();

signals:
	void exportCompleted();

public:
	ExportSMS(QStringList const& keys, qint64 const& accountId);
	void setFormat(OutputFormat::Type format);
	void run();
};

} /* namespace exportui */
#endif /* EXPORTSMS_H_ */
