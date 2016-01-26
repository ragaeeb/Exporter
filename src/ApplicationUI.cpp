#include "precompiled.h"

#include "applicationui.hpp"
#include "AccountImporter.h"
#include "CardUtils.h"
#include "ExportSMS.h"
#include "ImportSMS.h"
#include "InvocationUtils.h"
#include "IOUtils.h"
#include "Logger.h"
#include "MessageImporter.h"
#include "PimUtil.h"

#define CARD_KEY "logCard"

namespace exportui {

using namespace bb::cascades;
using namespace bb::system;
using namespace bb::pim::message;
using namespace canadainc;

ApplicationUI::ApplicationUI(InvokeManager* i) :
        m_persistance(i),
        m_cover( i->startupMode() != ApplicationStartupMode::InvokeCard, this ),
        m_payment(&m_persistance), m_invoke(i, &m_persistance)
{
    switch ( i->startupMode() )
    {
        case ApplicationStartupMode::LaunchApplication:
            initRoot();
            break;

        case ApplicationStartupMode::InvokeCard:
        case ApplicationStartupMode::InvokeApplication:
            connect( i, SIGNAL( invoked(bb::system::InvokeRequest const&) ), this, SLOT( invoked(bb::system::InvokeRequest const&) ) );
            break;

        default:
            break;
    }
}


void ApplicationUI::initRoot(QString const& qmlSource)
{
    QMap<QString, QObject*> context;
    context.insert("payment", &m_payment);

    m_invoke.init(qmlSource, context, this);

    emit initialize();
}


void ApplicationUI::invoked(bb::system::InvokeRequest const& request) {
    initRoot( m_invoke.invoked(request) );
}


void ApplicationUI::lazyInit()
{
	INIT_SETTING( "userName", tr("You") );
	INIT_SETTING("timeFormat", 0);
	INIT_SETTING("duplicateAction", 0);
	INIT_SETTING("doubleSpace", 0);
	INIT_SETTING("latestFirst", 1);
	INIT_SETTING("serverTimestamp", 1);

	if ( !m_persistance.contains("output") ) // first run
	{
	    QStringList availableFolders = QStringList() << "/accounts/1000/removable/sdcard/documents" << "/accounts/1000/shared/documents";

	    foreach (QString const& folder, availableFolders)
	    {
	        if ( QDir(folder).exists() ) {
	            m_persistance.saveValueFor("output", folder, false);
	            break;
	        }
	    }
	}

	m_invoke.lazyInit();

	emit lazyInitComplete();
}


void ApplicationUI::getConversationsFor(qint64 accountId)
{
	ImportSMS* sms = new ImportSMS(accountId);
	connect( sms, SIGNAL( importCompleted(QVariantList const&) ), this, SIGNAL( conversationsImported(QVariantList const&) ) );
	connect( sms, SIGNAL( progress(int, int, QString const&) ), this, SIGNAL( loadProgress(int, int, QString const&) ) );

	connect( bb::cascades::Application::instance(), SIGNAL( aboutToQuit() ), sms, SLOT( cancel() ) );

	IOUtils::startThread(sms);
}


void ApplicationUI::getMessagesFor(QString const& conversationKey, qint64 accountId)
{
	 MessageImporter* ai = new MessageImporter(accountId, false);
	 ai->setUserAlias( m_persistance.getValueFor("userName").toString() );
	 ai->setConversation(conversationKey);
	 ai->setLatestFirst( m_persistance.getValueFor("latestFirst") == 1 );
	 ai->setUseDeviceTime( m_persistance.getValueFor("serverTimestamp") != 1 );

	 connect( ai, SIGNAL( importCompleted(QVariantList const&) ), this, SIGNAL( messagesImported(QVariantList const&) ) );
	 connect( ai, SIGNAL( progress(int, int) ), this, SLOT( onMessageLoadProgress(int, int) ) );
	 connect( bb::cascades::Application::instance(), SIGNAL( aboutToQuit() ), ai, SLOT( cancel() ) );

	 IOUtils::startThread(ai);
}


void ApplicationUI::onMessageLoadProgress(int current, int total) {
    emit loadProgress( current, total, tr("Loading...") );
}


void ApplicationUI::onExportCompleted() {
	m_persistance.showToast( tr("Export complete"), "images/menu/ic_export.png" );
}


void ApplicationUI::exportSMS(QStringList const& conversationIds, qint64 accountId, int outputFormat)
{
    LOGGER(conversationIds << accountId << outputFormat);

	ExportSMS* sms = new ExportSMS(conversationIds, accountId);
	sms->setFormat( static_cast<OutputFormat::Type>(outputFormat) );
	connect( sms, SIGNAL( exportCompleted() ), this, SLOT( onExportCompleted() ) );
	connect( sms, SIGNAL( loadProgress(int, int, QString const&) ), this, SIGNAL( loadProgress(int, int, QString const&) ) );

	connect( bb::cascades::Application::instance(), SIGNAL( aboutToQuit() ), sms, SLOT( cancel() ) );

	IOUtils::startThread(sms);
}


void ApplicationUI::saveTextData(QString const& file, QString const& data) {
	IOUtils::writeTextFile( file, data, m_persistance.getValueFor("duplicateAction").toInt() == 1 );
}


void ApplicationUI::loadAccounts()
{
	AccountImporter* ai = new AccountImporter();
	connect( ai, SIGNAL( importCompleted(QVariantList const&) ), this, SIGNAL( accountsImported(QVariantList const&) ) );
	IOUtils::startThread(ai);
}


bool ApplicationUI::hasContactsAccess() {
    return PimUtil::hasContactsAccess();
}


ApplicationUI::~ApplicationUI()
{
}

}
