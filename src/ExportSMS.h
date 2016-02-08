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

struct ExportParams
{
    qint64 accountId;
    QStringList keys;
    OutputFormat::Type format;
    bool deviceTime;
    bool latestFirst;
    QString userName;
    bool supportMMS;
    QString outputPath;
    bool overwrite;

    ExportParams() : accountId(0), format(OutputFormat::TXT), deviceTime(false), latestFirst(true), supportMMS(false), overwrite(false) {}
};

class ExportSMS : public QObject, public QRunnable
{
	Q_OBJECT

	bool m_active;
	ExportParams m_params;

	QList<FormattedConversation> formatConversations();

signals:
	void exportCompleted(int success, int failed);
	void loadProgress(int current, int total, QString const& status);

public:
	ExportSMS(ExportParams params);
	void run();
	Q_SLOT void cancel();
};

} /* namespace exportui */
#endif /* EXPORTSMS_H_ */
