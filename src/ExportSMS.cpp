#include "precompiled.h"

#include "ExportSMS.h"
#include "IOUtils.h"
#include "Logger.h"
#include "PimUtil.h"
#include "TextUtils.h"

namespace exportui {

using namespace bb::pim::message;
using namespace bb::system;
using namespace canadainc;

ExportSMS::ExportSMS(QStringList const& keys, qint64 const& accountId) : m_accountId(accountId), m_keys(keys)
{
	m_progress.setState(SystemUiProgressState::Inactive);
}

void ExportSMS::run()
{
	static QString spacer = "\r\n";
	m_progress.setState(SystemUiProgressState::Active);
	m_progress.setStatusMessage( tr("0% complete...") );
	m_progress.setProgress(0);
	m_progress.show();

	QMap<QString, QString> map;
    QSettings settings;

    QString timeFormat = tr("MMM d/yy, hh:mm:ss");

    switch ( settings.value("timeFormat").toInt() )
    {
		case 1:
			timeFormat = tr("hh:mm:ss");
			break;

		case 2:
			timeFormat = "";
			break;

		default:
			break;
    }

    QString userName = settings.value("userName").toString();
    MessageService ms;
    MessageFilter filter;

    bool doubleSpace = settings.value("doubleSpace").toInt() == 1;
    bool useServerTime = settings.value("serverTimestamp").toInt() == 1;
    bool latestFirst = settings.value("latestFirst").toInt() == 1;

	for (int i = 0; i < m_keys.size(); i++)
	{
		Conversation conversation = ms.conversation(m_accountId, m_keys[i]);

		if ( !conversation.participants().isEmpty() )
		{
			MessageContact c = conversation.participants()[0];
			QString fileName;

			QString displayName = TextUtils::sanitize( c.displayableName().trimmed() );
			QString address = TextUtils::sanitize( c.address().trimmed() );

			if (displayName == address) { // unknown contact
			   fileName = address;
			} else {
			   fileName = QString("%1 %2").arg(displayName).arg(address);
			}

			QString formattedConversation = QString("%1%2%2").arg( c.address() ).arg(spacer);
			QList<Message> messages = ms.messagesInConversation(m_accountId, m_keys[i], filter);

			int totalMessages = messages.size();

			for (int j = latestFirst ? totalMessages-1 : 0; latestFirst ? j >= 0 : j < messages.size(); latestFirst ? j-- : j++)
			{
			   Message m = messages[j];

			   if ( !m.isDraft() )
			   {
				   QDateTime t = useServerTime ? m.serverTimestamp() : m.deviceTimestamp();
				   QString ts = timeFormat.isEmpty() ? "" : t.toString(timeFormat);
				   QString text = PimUtil::extractText(m);

				   QString sender = m.isInbound() ? m.sender().displayableName() : userName;
				   QString suffix;

				   if ( ts.isEmpty() ) {
					   suffix = QString("%1: %2").arg(sender).arg(text);
				   } else {
					   suffix = QString("%1 - %2: %3").arg(ts).arg(sender).arg(text);
				   }

				   formattedConversation += suffix +spacer;

				   if (doubleSpace) {
					   formattedConversation += spacer;
				   }
			   }
			}

			map.insert( fileName, formattedConversation.trimmed() );
		}
	}

	QStringList keys = map.keys();
	QString outputPath = settings.value("output").toString();

    bool replace = settings.value("duplicateAction").toInt() == 1;
    int total = keys.size();

	for (int i = 0; i < total; i++)
	{
	   QString key = keys[i];
	   IOUtils::writeTextFile( QString("%1/%2.txt").arg(outputPath).arg(key), map[key], replace );

		int progress = (double)i/total * 100;
		m_progress.setProgress(progress);
		m_progress.setStatusMessage( tr("%1% complete...").arg(progress) );
		m_progress.show();
	}

    emit exportCompleted();

	m_progress.cancel();
	m_progress.setState(SystemUiProgressState::Inactive);
}

} /* namespace exportui */
