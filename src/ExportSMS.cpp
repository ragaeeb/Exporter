#include "ExportSMS.h"
#include "Logger.h"

#include <QFile>
#include <QSettings>

#include <bb/pim/message/MessageFilter>
#include <bb/pim/message/MessageService>

namespace exportui {

using namespace bb::pim::message;

ExportSMS::ExportSMS(QStringList const& keys, qint64 const& accountId) : m_accountId(accountId), m_keys(keys)
{
}

void ExportSMS::run()
{
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
    }

    QString userName = settings.value("userName").toString();
    MessageService ms;
    MessageFilter filter;

	for (int i = 0; i < m_keys.size(); i++)
	{
		Conversation conversation = ms.conversation(m_accountId, m_keys[i]);

		if ( !conversation.participants().isEmpty() )
		{
			MessageContact c = conversation.participants()[0];
			QString fileName;

			QRegExp alphaNumericFilter = QRegExp( QString::fromUtf8("[-`~!@#$%^&*()_Ñ+=|:;<>ÇÈ,.?/{}\'\"\\\[\\\]\\\\]") );
			QString displayName = c.displayableName().trimmed().remove(alphaNumericFilter);
			QString address = c.address().trimmed().remove(alphaNumericFilter);

			if (displayName == address) { // unknown contact
			   fileName = address;
			} else {
			   fileName = QObject::tr("%1 %2").arg(displayName).arg(address);
			}

			QString formattedConversation = QObject::tr("%1\r\n\r\n").arg(fileName);
			QList<Message> messages = ms.messagesInConversation(m_accountId, m_keys[i], filter);

			for (int j = 0; j < messages.size(); j++)
			{
			   Message m = messages[j];

			   if ( !m.isDraft() && m.attachmentCount() > 0 && m.attachmentAt(0).mimeType() == "text/plain" )
			   {
				   QString ts = timeFormat.isEmpty() ? "" : m.serverTimestamp().toString(timeFormat);
				   QString text = QString::fromLocal8Bit( m.attachmentAt(0).data() );
				   QString sender = m.isInbound() ? m.sender().displayableName() : userName;
				   QString suffix;

				   if ( ts.isEmpty() ) {
					   suffix = QObject::tr("%1: %2").arg(sender).arg(text);
				   } else {
					   suffix = QObject::tr("%1 - %2: %3").arg(ts).arg(sender).arg(text);
				   }

				   formattedConversation += suffix +"\r\n";
			   }
			}

			map.insert( fileName, formattedConversation.trimmed() );
		}
	}

	QStringList keys = map.keys();
	QString outputPath = settings.value("output").toString();

    QIODevice::OpenMode om = QIODevice::WriteOnly | QIODevice::Append;

    int duplicateAction = settings.value("duplicateAction").toInt();
    if (duplicateAction == 1) {
    	om = QIODevice::WriteOnly;
    }

	for (int i = 0; i < keys.size(); i++)
	{
	   QString key = keys[i];
	   QFile outputFile( QObject::tr("%1/%2.txt").arg(outputPath).arg(key) );

	   bool alreadyExists = outputFile.exists() && duplicateAction != 1;
	   outputFile.open(om);

	   if ( outputFile.isOpen() )
	   {
		   QTextStream stream(&outputFile);

		   if (alreadyExists) {
			   stream << "\r\n\r\n";
		   }

		   stream << map[key];
		   outputFile.close();
	   } else {
		   LOGGER("Could not open " << key << "for writing!");
	   }
	}

    emit exportCompleted();
}

} /* namespace exportui */
