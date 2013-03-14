#include "ImportSMS.h"
#include "Logger.h"

#include <bb/pim/contacts/ContactService.hpp>

#include <bb/pim/account/AccountService>
#include <bb/pim/message/MessageFilter>
#include <bb/pim/message/MessageService>

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

void ImportSMS::run()
{
	LOGGER("ImportSMS::run()");

    AccountService as;
    QList<Account> accounts = as.accounts(Service::Messages, "sms-mms");
    AccountKey accountKey;

    if ( !accounts.isEmpty() ) {
    	accountKey = accounts[0].id();
    }

    MessageService ms;
	QList<Conversation> conversations = ms.conversations( accountKey, MessageFilter() );
	qSort( conversations.begin(), conversations.end(), lessThan );

	ContactService cs;
	QVariantList qvl;

	for (int i = 0; i < conversations.size(); i++)
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
	}

	LOGGER( "Elements generated:" << qvl.size() );
	emit importCompleted(accountKey, qvl);
}

} /* namespace secret */
