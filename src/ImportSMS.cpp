#include "precompiled.h"

#include "ImportSMS.h"
#include "Logger.h"

using namespace bb::pim::account;
using namespace bb::pim::contacts;
using namespace bb::pim::message;

namespace {

bool lessThan(Conversation const& c1, Conversation const& c2) {
	return c1.timeStamp() > c2.timeStamp();
}

}

namespace exportui {

using namespace bb::system;

ImportSMS::ImportSMS(qint64 accountId) : m_accountId(accountId), m_active(true)
{
}

void ImportSMS::run()
{
	LOGGER("ImportSMS::run()");

    MessageService ms;
	QList<Conversation> conversations = ms.conversations( m_accountId, MessageFilter() );
	qSort( conversations.begin(), conversations.end(), lessThan );

	ContactService cs;
	QVariantList qvl;

	int total = conversations.size();
	QString status = tr("Loading...");

	for (int i = 0; i < total; i++)
	{
	    if (!m_active) {
	        LOGGER("Aborting!");
	        return;
	    }

		Conversation c = conversations[i];

		if ( !c.participants().isEmpty() )
		{
		    MessageContact mc = c.participants()[0];
			MessageContactKey key = mc.id();
			Contact contact = cs.contactDetails(key);

			QString name = contact.displayName().trimmed();

			if ( name.isEmpty() ) {
			    name = mc.displayableName().trimmed();
			}

			QVariantMap qvm;
			qvm.insert( "name", name );
			qvm.insert( "smallPhotoFilepath", contact.smallPhotoFilepath() );
			qvm.insert( "messageCount", c.messageCount() );
			qvm.insert( "number", mc.address() );
			qvm.insert( "conversationId", c.id() );

			qvl.append(qvm);
		}

		emit progress(i, total, status);
	}

	emit progress(total, total, status);

	LOGGER( "Elements generated:" << qvl.size() );
	emit importCompleted(qvl);
}


void ImportSMS::cancel() {
    LOGGER("Cancel!");
    m_active = false;
}

} /* namespace secret */
