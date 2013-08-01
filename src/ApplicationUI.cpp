#include "precompiled.h"

#include "applicationui.hpp"
#include "AccountImporter.h"
#include "ExportSMS.h"
#include "ImportSMS.h"
#include "IOUtils.h"
#include "MessageImporter.h"
#include "Logger.h"

namespace exportui {

using namespace bb::cascades;
using namespace bb::system;
using namespace bb::pim::message;
using namespace canadainc;

ApplicationUI::ApplicationUI(bb::cascades::Application *app) : QObject(app), m_cover("Cover.qml")
{
	INIT_SETTING( "userName", tr("You") );
	INIT_SETTING("timeFormat", 0);
	INIT_SETTING("duplicateAction", 0);
	INIT_SETTING("doubleSpace", 0);
	INIT_SETTING("latestFirst", 1);

	if ( m_persistance.getValueFor("output").isNull() ) { // first run
		QString sdDirectory("/accounts/1000/removable/sdcard/documents");

		if ( !QDir(sdDirectory).exists() ) {
			sdDirectory = "/accounts/1000/shared/documents";
		}

		m_persistance.saveValueFor("output", sdDirectory);
	}

    QmlDocument *qml = QmlDocument::create("asset:///main.qml").parent(this);
    qml->setContextProperty("app", this);
    qml->setContextProperty("persist", &m_persistance);

    AbstractPane* root = qml->createRootObject<AbstractPane>();
    app->setScene(root);
}


void ApplicationUI::create(bb::cascades::Application *app) {
	new ApplicationUI(app);
}


void ApplicationUI::getConversationsFor(qint64 accountId)
{
	ImportSMS* sms = new ImportSMS(accountId);
	connect( sms, SIGNAL( importCompleted(QVariantList const&) ), this, SIGNAL( conversationsImported(QVariantList const&) ) );
	connect( sms, SIGNAL( progress(int, int) ), this, SIGNAL( conversationLoadProgress(int, int) ) );
	IOUtils::startThread(sms);
}


void ApplicationUI::getMessagesFor(QString const& conversationKey, qint64 accountId)
{
	 MessageImporter* ai = new MessageImporter(accountId, false);
	 ai->setUserAlias( m_persistance.getValueFor("userName").toString() );
	 ai->setConversation(conversationKey);
	 ai->setLatestFirst( m_persistance.getValueFor("latestFirst") == 0 );

	 connect( ai, SIGNAL( importCompleted(QVariantList const&) ), this, SIGNAL( messagesImported(QVariantList const&) ) );
	 connect( ai, SIGNAL( progress(int, int) ), this, SIGNAL( loadProgress(int, int) ) );

	 IOUtils::startThread(ai);
}


void ApplicationUI::onExportCompleted() {
	m_persistance.showToast( tr("Export complete") );
}


void ApplicationUI::exportSMS(QStringList const& conversationIds, qint64 accountId)
{
	ExportSMS* sms = new ExportSMS(conversationIds, accountId);
	connect( sms, SIGNAL( exportCompleted() ), this, SLOT( onExportCompleted() ) );

	IOUtils::startThread(sms);
}


void ApplicationUI::loadAccounts()
{
	AccountImporter* ai = new AccountImporter();
	connect( ai, SIGNAL( importCompleted(QVariantList const&) ), this, SIGNAL( accountsImported(QVariantList const&) ) );
	IOUtils::startThread(ai);
}


ApplicationUI::~ApplicationUI()
{
}

}
