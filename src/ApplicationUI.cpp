#include "precompiled.h"

#include "applicationui.hpp"
#include "AccountImporter.h"
#include "AppLogFetcher.h"
#include "CardUtils.h"
#include "ExportSMS.h"
#include "ImportSMS.h"
#include "InvocationUtils.h"
#include "IOUtils.h"
#include "Logger.h"
#include "MessageImporter.h"
#include "PimUtil.h"
#include "SharedConstants.h"
#include "ThreadUtils.h"

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
            connect( i, SIGNAL( cardPooled(bb::system::CardDoneMessage const&) ), QCoreApplication::instance(), SLOT( quit() ) );
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
    context.insert("offloader", &m_offloader);

    m_invoke.init(qmlSource, context, this);

    emit initialize();
}


void ApplicationUI::invoked(bb::system::InvokeRequest const& request) {
    initRoot( m_invoke.invoked(request) );
}


void ApplicationUI::lazyInit()
{
	INIT_SETTING( "userName", tr("You") );
	INIT_SETTING("duplicateAction", 0);
	INIT_SETTING("doubleSpace", 0);
	INIT_SETTING("latestFirst", 1);
	INIT_SETTING("serverTimestamp", 1);

	if ( !m_persistance.containsFlag("output") ) // first run
	{
	    QStringList availableFolders = QStringList() << "/accounts/1000/removable/sdcard/documents" << "/accounts/1000/shared/documents";

	    foreach (QString const& folder, availableFolders)
	    {
	        if ( QDir(folder).exists() ) {
	            m_persistance.setFlag("output", folder);
	            break;
	        }
	    }
	}

	AppLogFetcher::create( &m_persistance, &ThreadUtils::compressFiles, this );
	m_invoke.lazyInit();
	m_invoke.process();

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


void ApplicationUI::onExportCompleted(int success, int failed)
{
    LOGGER( QString("%1; %2").arg(success).arg(failed) );

    if (success > 0 && failed == 0) { // no failures
        m_persistance.showToast( tr("Successfully exported %n conversations.", "", success), "images/toast/ic_exported.png" );
    } else if (success > 0 && failed > 0) {
        m_persistance.showToast( tr("%1 conversations exported, %2 conversations failed to export.").arg(success).arg(failed), "images/toast/ic_warning.png" );
    } else {
        m_persistance.showToast( tr("%n conversations failed to export.", "", failed), "images/toast/ic_warning.png" );
    }
}


void ApplicationUI::exportSMS(QStringList const& conversationIds, qint64 accountId, int outputFormat)
{
    LOGGER(conversationIds << accountId << outputFormat);

    ExportParams ep;
    ep.accountId = accountId;
    ep.keys = conversationIds;
    ep.deviceTime = m_persistance.getValueFor("serverTimestamp").toInt() != 1;
    ep.format = static_cast<OutputFormat::Type>(outputFormat);
    ep.latestFirst = m_persistance.getValueFor("latestFirst").toInt() == 1;
    ep.overwrite = m_persistance.getValueFor("duplicateAction").toInt() == 1;
    ep.userName = m_persistance.getValueFor("userName").toString();
    ep.supportMMS = m_persistance.contains("exporter_mms");
    ep.outputPath = m_persistance.getFlag("output").toString();

	ExportSMS* sms = new ExportSMS(ep);
	connect( sms, SIGNAL( exportCompleted(int, int) ), this, SLOT( onExportCompleted(int, int) ) );
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


bool ApplicationUI::noContactsAccess() {
    return NO_CONTACTS_ACCESS;
}


ApplicationUI::~ApplicationUI()
{
}

}
