#include "precompiled.h"

#include "applicationui.hpp"
#include "AccountImporter.h"
#include "ExportSMS.h"
#include "ImportSMS.h"
#include "InvocationUtils.h"
#include "IOUtils.h"
#include "Logger.h"
#include "MessageImporter.h"
#include "PimUtil.h"

namespace exportui {

using namespace bb::cascades;
using namespace bb::system;
using namespace bb::pim::message;
using namespace canadainc;

ApplicationUI::ApplicationUI(bb::cascades::Application *app) : QObject(app), m_cover("Cover.qml")
{
	switch ( m_invokeManager.startupMode() )
	{
	case ApplicationStartupMode::LaunchApplication:
		initRoot();
		break;

	case ApplicationStartupMode::InvokeCard:
		connect( &m_invokeManager, SIGNAL( invoked(bb::system::InvokeRequest const&) ), this, SLOT( invoked(bb::system::InvokeRequest const&) ) );
		break;

	default:
		exit(0);
		break;
	}
}


QObject* ApplicationUI::initRoot(QString const& qmlSource)
{
	qmlRegisterType<bb::cascades::pickers::FilePicker>("CustomComponent", 1, 0, "FilePicker");
	qmlRegisterUncreatableType<bb::cascades::pickers::FileType>("CustomComponent", 1, 0, "FileType", "Can't instantiate");
	qmlRegisterUncreatableType<bb::cascades::pickers::FilePickerMode>("CustomComponent", 1, 0, "FilePickerMode", "Can't instantiate");

    QmlDocument *qml = QmlDocument::create( QString("asset:///%1").arg(qmlSource) ).parent(this);
    qml->setContextProperty("app", this);
    qml->setContextProperty("persist", &m_persistance);

    AbstractPane* root = qml->createRootObject<AbstractPane>();
    Application::instance()->setScene(root);

	connect( this, SIGNAL( initialize() ), this, SLOT( init() ), Qt::QueuedConnection ); // async startup

	emit initialize();

	return root;
}


void ApplicationUI::invoked(bb::system::InvokeRequest const& request)
{
	QObject* root = initRoot("InvokedPage.qml");

	QString text = QString::fromUtf8( request.data().data() );
	root->setProperty("data", text);

	connect( root, SIGNAL( finished() ), this, SLOT( cardFinished() ) );
}


void ApplicationUI::cardFinished() {
	m_invokeManager.sendCardDone( CardDoneMessage() );
}


void ApplicationUI::init()
{
	INIT_SETTING( "userName", tr("You") );
	INIT_SETTING("timeFormat", 0);
	INIT_SETTING("duplicateAction", 0);
	INIT_SETTING("doubleSpace", 0);
	INIT_SETTING("latestFirst", 1);

	if ( m_persistance.getValueFor("output").isNull() ) // first run
	{
		QString sdDirectory("/accounts/1000/removable/sdcard/documents");

		if ( !QDir(sdDirectory).exists() ) {
			sdDirectory = "/accounts/1000/shared/documents";
		}

		m_persistance.saveValueFor("output", sdDirectory);
	}

	bool permissionOK = InvocationUtils::validateEmailSMSAccess( tr("Warning: It seems like the app does not have access to your Email/SMS messages Folder. This permission is needed for the app to access the SMS and email services it needs to render and process them so they can be saved. If you leave this permission off, some features may not work properly. Select OK to launch the Application Permissions screen where you can turn these settings on.") );

	if (permissionOK) {
		permissionOK = InvocationUtils::validateSharedFolderAccess( tr("Warning: It seems like the app does not have access to your Shared Folder. This permission is needed for the app to access the file system so that it can save the text messages as files. If you leave this permission off, some features may not work properly.") );

		if (permissionOK) {
			PimUtil::validateContactsAccess( tr("Warning: It seems like the app does not have access to your contacts. This permission is needed for the app to access your address book so we can properly display the names of the contacts in the output files. If you leave this permission off, some features may not work properly. Select OK to launch the Application Permissions screen where you can turn these settings on.") );
		}
	}
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


void ApplicationUI::saveTextData(QString const& file, QString const& data) {
	IOUtils::writeTextFile(file, data);
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
