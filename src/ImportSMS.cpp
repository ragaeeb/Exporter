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

ImportSMS::ImportSMS() {
	m_progress.setState(SystemUiProgressState::Inactive);
}

void ImportSMS::run()
{
	LOGGER("ImportSMS::run()");

	m_progress.setState(SystemUiProgressState::Active);
	m_progress.setStatusMessage( tr("0% complete...") );
	m_progress.setProgress(0);
	m_progress.show();

    AccountService as;
    QList<Account> accounts = as.accounts(Service::Messages, "sms-mms");
    AccountKey accountKey = 0;

    if ( !accounts.isEmpty() ) {
    	accountKey = accounts[0].id();
    }

    MessageService ms;
	QList<Conversation> conversations = ms.conversations( accountKey, MessageFilter() );
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

		int progress = (double)i/total * 100;
		m_progress.setProgress(progress);
		m_progress.setStatusMessage( tr("%1% complete...").arg(progress) );
		m_progress.show();
	}

	LOGGER( "Elements generated:" << qvl.size() );
	emit importCompleted(accountKey, qvl);

	m_progress.cancel();
	m_progress.setState(SystemUiProgressState::Inactive);
}

} /* namespace secret */
