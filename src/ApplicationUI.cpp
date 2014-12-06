#include "precompiled.h"

#include "applicationui.hpp"
#include "AccountImporter.h"
#include "CardUtils.h"
#include "ExporterCollector.h"
#include "ExportSMS.h"
#include "ImportSMS.h"
#include "InvocationUtils.h"
#include "IOUtils.h"
#include "Logger.h"
#include "LogMonitor.h"
#include "MessageImporter.h"
#include "PimUtil.h"

#define CARD_KEY "logCard"

namespace exportui {

using namespace bb::cascades;
using namespace bb::system;
using namespace bb::pim::message;
using namespace canadainc;

ApplicationUI::ApplicationUI(bb::cascades::Application *app) :
        QObject(app), m_cover("Cover.qml"), m_payment(&m_persistance), m_root(NULL)
{
    INIT_SETTING(CARD_KEY, true);
    INIT_SETTING(UI_KEY, true);

    AppLogFetcher::create( &m_persistance, new ExporterCollector(), this );

	switch ( m_invokeManager.startupMode() )
	{
	case ApplicationStartupMode::InvokeCard:
	case ApplicationStartupMode::InvokeApplication:
	    LogMonitor::create(CARD_KEY, CARD_LOG_FILE, this);
		connect( &m_invokeManager, SIGNAL( invoked(bb::system::InvokeRequest const&) ), this, SLOT( invoked(bb::system::InvokeRequest const&) ) );
		break;

	default:
	    LogMonitor::create(UI_KEY, UI_LOG_FILE, this);
        initRoot();
	    break;
	}
}


void ApplicationUI::initRoot(QString const& qmlSource)
{
	qmlRegisterType<bb::cascades::pickers::FilePicker>("bb.cascades.pickers", 1, 0, "FilePicker");
	qmlRegisterUncreatableType<bb::cascades::pickers::FileType>("bb.cascades.pickers", 1, 0, "FileType", "Can't instantiate");
	qmlRegisterUncreatableType<bb::cascades::pickers::FilePickerMode>("bb.cascades.pickers", 1, 0, "FilePickerMode", "Can't instantiate");
	qmlRegisterUncreatableType<OutputFormat>("com.canadainc.data", 1, 0, "OutputFormat", "Can't instantiate");

    QMap<QString, QObject*> context;
    context.insert("payment", &m_payment);

    m_root = CardUtils::initAppropriate(qmlSource, context, this);
    emit initialize();
}


void ApplicationUI::invoked(bb::system::InvokeRequest const& request)
{
    QString target = request.target();
    LOGGER( request.action() << target << request.mimeType() << request.metadata() << request.uri().toString() << QString( request.data() ) );

    QMap<QString,QString> targetToQML;
    QString qml = targetToQML.value(target);

    if ( qml.isNull() ) {
        qml = "InvokedPage.qml";
    }

    initRoot(qml);

    m_request = request;
}


void ApplicationUI::cardFinished() {
	m_invokeManager.sendCardDone( CardDoneMessage() );
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

    QString target = m_request.target();

    if ( !target.isNull() )
    {
        QString text;
        QString uri = m_request.uri().toString();

        if ( uri.startsWith("pim") )
        {
            QStringList tokens = uri.split(":");
            LOGGER("INVOKED DATA" << tokens);

            if ( tokens.size() > 3 ) {
                qint64 accountId = tokens[2].toLongLong();
                qint64 messageId = tokens[3].toLongLong();

                Message m = MessageService().message(accountId, messageId);
                QString name = m.sender().displayableName().trimmed();
                m_root->setProperty( "defaultName", QString("%1.txt").arg(name) );

                QString timeFormat = ExportSMS::getTimeFormat( m_persistance.getValueFor("timeFormat").toInt() );
                QDateTime t = m_persistance.getValueFor("serverTimestamp").toInt() == 1 ? m.serverTimestamp() : m.deviceTimestamp();

                text = tr("%1\r\n\r\n%2: %3").arg( m.sender().address() ).arg( timeFormat.isEmpty() ? "" : t.toString(timeFormat) ).arg( PimUtil::extractText(m) );
            }
        } else {
            text = QString::fromUtf8( m_request.data().data() );
        }

        m_root->setProperty("data", text);

        connect( m_root, SIGNAL( finished() ), this, SLOT( cardFinished() ) );
    }

	emit lazyInitComplete();
}


void ApplicationUI::create(bb::cascades::Application *app) {
	new ApplicationUI(app);
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
	m_persistance.showToast( tr("Export complete"), "", "asset:///images/menu/ic_export.png" );
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
