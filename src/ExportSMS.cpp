#include "precompiled.h"

#include "ExportSMS.h"
#include "CommonConstants.h"
#include "IOUtils.h"
#include "Logger.h"
#include "PimUtil.h"
#include "TextUtils.h"

using namespace bb::pim::message;

namespace {

bool latestFirst = true;
bool deviceTime = false;

bool messageComparator(Message const& c1, Message const& c2)
{
    if (deviceTime) {
        return !latestFirst ? c1.deviceTimestamp() < c2.deviceTimestamp() : c1.deviceTimestamp() > c2.deviceTimestamp();
    } else {
        return !latestFirst ? c1.serverTimestamp() < c2.serverTimestamp() : c1.serverTimestamp() > c2.serverTimestamp();
    }
}

}

namespace exportui {

using namespace canadainc;

ExportSMS::ExportSMS(ExportParams params) :
        m_active(true), m_params(params)
{
}


QList<FormattedConversation> ExportSMS::formatConversations()
{
    QList<FormattedConversation> result;
    LOGGER( m_params.accountId << m_params.keys << m_params.deviceTime << m_params.outputPath << m_params.format << m_params.userName << m_params.latestFirst );

    deviceTime = m_params.deviceTime;
    latestFirst = m_params.latestFirst;
    QString status = tr("Preparing...");

    MessageService ms;
    MessageFilter mf;

    int total = m_params.keys.size();

    for (int i = 0; i < total; i++)
    {
        Conversation conversation = ms.conversation(m_params.accountId, m_params.keys[i]);
        LOGGER( conversation.messageCount() );

        if (!m_active) {
            return QList<FormattedConversation>();
        }

        if ( !conversation.participants().isEmpty() && conversation.messageCount() > 0 )
        {
            QList<Message> messages = ms.messagesInConversation( m_params.accountId, m_params.keys[i], mf );
            qSort( messages.begin(), messages.end(), messageComparator );
            MessageContact c = conversation.participants()[0];

            LOGGER("Total messages fetched" << messages.size());

            if (!m_active) {
                LOGGER("Aborting!");
                return QList<FormattedConversation>();
            }

            QString displayName = c.displayableName().trimmed();
            QString address = c.address().trimmed();

            FormattedConversation fc;
            fc.fileName = displayName == address ? address : QString("%1 %2").arg(displayName).arg(address);
            fc.fileName = TextUtils::sanitize(fc.fileName);

            LOGGER("Current" << displayName << address);

            for (int j = 0; j < messages.size(); j++)
            {
                Message m = messages[j];
                bool isSpecial = m.mimeType() == "message/rfc822" || m.mimeType() == "application/vnd.blackberry.pin";

                if ( !m.isDraft() && ( m.attachmentCount() > 0 || isSpecial ) )
                {
                    FormattedMessage fm;

                    QDateTime t = deviceTime ? m.deviceTimestamp() : m.serverTimestamp();
                    fm.timestamp = t.toString("MMM d/yy hh:mm:ss");
                    fm.sender = m.isInbound() ? m.sender().displayableName() : m_params.userName;

                    QStringList totalBody;

                    if (isSpecial) {
                        QString body = m.body(MessageBody::PlainText).plainText();

                        if ( body.isEmpty() ) {
                            body = m.body(MessageBody::Html).plainText();
                        }

                        totalBody << body;
                    }

                    LOGGER("total" << isSpecial << totalBody);

                    for (int k = m.attachmentCount()-1; k >= 0; k--)
                    {
                        Attachment a = m.attachmentAt(k);

                        if ( a.mimeType() == "text/plain" ) {
                            totalBody << QString::fromLocal8Bit( a.data() );
                        } else if (m_params.supportMMS) {
                            FormattedAttachment fa;
                            fa.name = a.name();
                            fa.data = a.data();

                            totalBody << QString("[%1]").arg(fa.name);
                            fm.attachments << fa;
                        }
                    }

                    fm.body = totalBody.join(" ");
                    fc.messages << fm;

                    LOGGER("FormattedMessage" << totalBody.size() << fm.attachments.size());
                }
            }

            LOGGER("FormattedConversation" << fc.messages.size());

            result << fc;
        }

        emit loadProgress(i, total, status);
    }

    return result;
}


void ExportSMS::run()
{
    LOGGER(m_params.accountId << m_params.keys << m_params.format);

    QString result;
    QList<FormattedConversation> conversations = formatConversations();
    QString extension = m_params.format == OutputFormat::CSV ? "csv" : "txt";

    LOGGER("Total Conversations" << conversations.size());

    int n = conversations.size();
    QString status = tr("Writing...");
    int failed = 0;
    int success = 0;

    for (int x = 0; x < n; x++)
    {
        if (!m_active) {
            LOGGER("Aborting!");
            return;
        }

        FormattedConversation fc = conversations[x];

        QList<FormattedMessage> messages = fc.messages;
        LOGGER("Total messages" << messages.size());
        QStringList total;

        for (int i = 0; i < messages.length(); i++)
        {
            FormattedMessage fm = messages[i];
            QList<FormattedAttachment> attachments = fm.attachments;
            LOGGER("Attachments" << attachments.size());

            for (int j = attachments.length()-1; j >= 0; j--)
            {
                FormattedAttachment fa = attachments[j];
                QString destination = QString("%1/%2").arg(m_params.outputPath).arg(fa.name);

                int k = 1;

                while ( QFile::exists(destination) ) {
                    LOGGER(destination << "already exists");
                    destination = QString("%1/(%3)_%2").arg(m_params.outputPath).arg(fa.name).arg(k);
                    ++k;
                }

                IOUtils::writeFile(destination, fa.data);
            }

            switch (m_params.format)
            {
                case OutputFormat::CSV:
                    total << QString("%1\t%2\t%3").arg(fm.timestamp).arg(fm.sender).arg(fm.body).trimmed();
                    break;
                case OutputFormat::TXT:
                    total << QString("%1 - %2: %3").arg(fm.timestamp).arg(fm.sender).arg(fm.body).trimmed();
                    break;
                default:
                    break;
            }
        }

        LOGGER("Total lines" << total.size());

        if ( !total.isEmpty() )
        {
            bool written = IOUtils::writeTextFile( QString("%1/%2.%3").arg(m_params.outputPath).arg(fc.fileName).arg(extension), total.join(NEW_LINE), m_params.overwrite, false );

            if (written) {
                ++success;
            } else {
                ++failed;
            }
        } else {
            LOGGER("Total was empty...");
            ++failed;
        }

        emit loadProgress(x, n, status);
    }

    emit loadProgress(n,n,status);
    emit exportCompleted(success, failed);
}


void ExportSMS::cancel() {
    m_active = false;
}

} /* namespace exportui */
