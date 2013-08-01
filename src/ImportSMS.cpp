#include "precompiled.h"

#include "ImportSMS.h"
#include "Logger.h"

using namespace bb::pim::account;
using namespace bb::pim::contacts;
using namespace bb::pim::message;

namespace {

bool lessThan(const Conversation &c1, const Conversation &c2)
{
	QList<MessageContact> c1p = c1.participants();
	QList<MessageContact> c2p = c2.participants();

	if ( c1p.isEmpty() ) {
		return true;
	} else if ( c2p.isEmpty() ) {
		return false;
	}

	return c1p[0].displayableName().toLower() < c2p[0].displayableName().toLower();
}

}

namespace exportui {

using namespace bb::system;

ImportSMS::ImportSMS(qint64 accountId) : m_accountId(accountId)
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

	for (int i = 0; i < total; i++)
	{
		Conversation c = conversations[i];

		if ( !c.participants().isEmpty() )
		{
			MessageContactKey key = c.participants()[0].id();
			Contact contact = cs.contactDetails(key);

			QVariantMap qvm;
			qvm.insert( "name", contact.displayName() );
			qvm.insert( "smallPhotoFilepath", contact.smallPhotoFilepath() );
			qvm.insert( "messageCount", c.messageCount() );
			qvm.insert( "number", c.participants()[0].address() );
			qvm.insert( "conversationId", c.id() );

			qvl.append(qvm);
		}

		emit progress(i, total);
	}

	emit progress(total, total);

	LOGGER( "Elements generated:" << qvl.size() );
	emit importCompleted(qvl);
}

} /* namespace secret */
