#include "precompiled.h"

#include "applicationui.hpp"
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

ApplicationUI::ApplicationUI(bb::cascades::Application *app) : QObject(app), m_cover("Cover.qml"), m_adm(this)
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

	ImportSMS* sms = new ImportSMS();
	connect( sms, SIGNAL( importCompleted(qint64, QVariantList const&) ), this, SLOT( onImportCompleted(qint64, QVariantList const&) ) );
	startThread(sms);
}


void ApplicationUI::create(bb::cascades::Application *app) {
	new ApplicationUI(app);
}


void ApplicationUI::onImportCompleted(qint64 accountId, QVariantList const& qvl)
{
	m_accountId = accountId;
	m_adm.append(qvl);
}


void ApplicationUI::getMessagesFor(QString const& conversationKey)
{
	 MessageImporter* ai = new MessageImporter(m_accountId, false);
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


void ApplicationUI::exportSMS(QStringList const& conversationIds)
{
	ExportSMS* sms = new ExportSMS(conversationIds, m_accountId);
	connect( sms, SIGNAL( exportCompleted() ), this, SLOT( onExportCompleted() ) );

	startThread(sms);
}


void ApplicationUI::startThread(QRunnable* qr)
{
	qr->setAutoDelete(true);

	QThreadPool *threadPool = QThreadPool::globalInstance();
	threadPool->start(qr);
}


QVariant ApplicationUI::getDataModel() {
	return QVariant::fromValue(&m_adm);
}


ApplicationUI::~ApplicationUI() {
	m_adm.setParent(NULL);
}

}
