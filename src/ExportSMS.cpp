#include "precompiled.h"

#include "ExportSMS.h"
#include "IOUtils.h"
#include "Logger.h"
#include "PimUtil.h"
#include "TextUtils.h"

namespace {

QString getTimeFormat(int tf)
{
    QString timeFormat = QObject::tr("MMM d/yy hh:mm:ss");

    switch (tf)
    {
        case 1:
            timeFormat = QObject::tr("hh:mm:ss");
            break;

        case 2:
            timeFormat = "";
            break;

        default:
            break;
    }

    return timeFormat;
}

}

namespace exportui {

using namespace bb::pim::message;
using namespace canadainc;

ExportSMS::ExportSMS(QStringList const& keys, qint64 const& accountId) :
        m_accountId(accountId), m_keys(keys), m_format(OutputFormat::TXT)
{
}


QList<FormattedConversation> ExportSMS::formatConversations()
{
    QList<FormattedConversation> result;

    bool useServerTime = m_settings.value("serverTimestamp").toInt() == 1;
    QString userName = m_settings.value("userName").toString();
    QString timeFormat = getTimeFormat( m_settings.value("timeFormat").toInt() );
    bool supportMMS = m_settings.contains("exporter_mms");

    MessageService ms;

    for (int i = m_keys.size()-1; i >= 0; i--)
    {
        Conversation conversation = ms.conversation(m_accountId, m_keys[i]);
        QList<Message> messages = ms.messagesInConversation( m_accountId, m_keys[i], MessageFilter() );

        LOGGER("numMessages" << messages.size());

        if ( !conversation.participants().isEmpty() && !messages.isEmpty() )
        {
            MessageContact c = conversation.participants()[0];

            QString displayName = c.displayableName().trimmed();
            QString address = c.address().trimmed();

            FormattedConversation fc;
            fc.fileName = displayName == address ? address : QString("%1 %2").arg(displayName).arg(address);
            fc.fileName = TextUtils::sanitize(fc.fileName);

            for (int j = 0; j < messages.length(); j++)
            {
                Message m = messages[j];

                if ( !m.isDraft() && m.attachmentCount() > 0 )
                {
                    FormattedMessage fm;

                    QDateTime t = useServerTime ? m.serverTimestamp() : m.deviceTimestamp();
                    fm.timestamp = timeFormat.isEmpty() ? "" : t.toString(timeFormat);
                    fm.sender = m.isInbound() ? m.sender().displayableName() : userName;

                    QStringList totalBody;

                    for (int k = m.attachmentCount()-1; k >= 0; k--)
                    {
                        Attachment a = m.attachmentAt(k);

                        if ( a.mimeType() == "text/plain" ) {
                            totalBody << QString::fromLocal8Bit( a.data() );
                        } else if (supportMMS) {
                            FormattedAttachment fa;
                            fa.name = a.name();
                            fa.data = a.data();

                            totalBody << QString("[%1]").arg(fa.name);
                            fm.attachments << fa;
                        }
                    }

                    fm.body = totalBody.join(" ");
                    fc.messages << fm;
                }
            }

            result << fc;
        }
    }

    return result;
}


void ExportSMS::run()
{
    QString result;
    QList<FormattedConversation> conversations = formatConversations();
    bool latestFirst = m_settings.value("latestFirst").toInt() == 1;
    QString outputPath = m_settings.value("output").toString();
    bool replace = m_settings.value("duplicateAction").toInt() == 1;
    QString extension = m_format == OutputFormat::CSV ? "csv" : "txt";

    LOGGER("Total Conversations" << conversations.size());

    foreach (FormattedConversation fc, conversations)
    {
        QList<FormattedMessage> messages = fc.messages;
        LOGGER("Total messages" << messages.size());
        QStringList total;

        for (int i = latestFirst ? messages.length()-1 : 0; latestFirst ? i >= 0 : i < messages.length(); latestFirst ? i-- : i++)
        {
            FormattedMessage fm = messages[i];
            QList<FormattedAttachment> attachments = fm.attachments;
            LOGGER("Attachments" << attachments.size());

            for (int j = attachments.length()-1; j >= 0; j--)
            {
                FormattedAttachment fa = attachments[j];
                QString destination = QString("%1/%2").arg(outputPath).arg(fa.name);

                int k = 1;

                while ( QFile::exists(destination) ) {
                    destination = QString("%1/(%3)_%2").arg(outputPath).arg(fa.name).arg(k);
                    ++k;
                }

                IOUtils::writeFile(destination, fa.data);
            }

            if (m_format == OutputFormat::CSV) {
                total << QString("%1\t%2\t%3").arg(fm.timestamp).arg(fm.sender).arg(fm.body).trimmed();
            } else if (m_format == OutputFormat::TXT) {
                total << QString("%1 - %2: %3").arg(fm.timestamp).arg(fm.sender).arg(fm.body).trimmed();
            }
        }

        if ( !total.isEmpty() ) {
            IOUtils::writeTextFile( QString("%1/%2.%3").arg(outputPath).arg(fc.fileName).arg(extension), total.join(NEW_LINE), replace, false );
        }
    }
}


void ExportSMS::setFormat(OutputFormat::Type format) {
    m_format = format;
}

} /* namespace exportui */
