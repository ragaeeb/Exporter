#include "applicationui.hpp"
#include "ExportSMS.h"
#include "ImportSMS.h"
#include "Logger.h"

#include <QThreadPool>

#include <bb/cascades/AbstractPane>
#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>

#include <bb/pim/message/MessageFilter>
#include <bb/pim/message/MessageService>

#include <bb/system/SystemProgressDialog>

namespace exportui {

using namespace bb::cascades;
using namespace bb::system;
using namespace bb::pim::message;

ApplicationUI::ApplicationUI(bb::cascades::Application *app) : QObject(app), m_cover("Cover.qml"), m_progress(NULL), m_adm(this)
{
	INIT_SETTING("animations", 1);
	INIT_SETTING( "userName", tr("You") );
	INIT_SETTING("timeFormat", 0);
	INIT_SETTING("duplicateAction", 0);
	INIT_SETTING("separator", 1);
	INIT_SETTING("doubleSpace", 0);

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

	if ( m_persistance.getValueFor("arabicWarningShown").toInt() == 0 ) {
		m_persistance.showToast( tr("Note that currently there is a bug with the BB10 share framework where arabic texts cannot be shared. To get around this for now you can use the copy action instead of share. These conversations however can still be persisted to the file system using this app."), tr("OK") );
		m_persistance.saveValueFor("arabicWarningShown", 1);
	}
}


QVariantList ApplicationUI::getMessagesFor(QString const& conversationKey)
{
	MessageService messageService;
	QList<Message> messages = messageService.messagesInConversation( m_accountId, conversationKey, MessageFilter() );
	QVariantList variants;

	for (int i = 0; i < messages.size(); i++)
	{
		Message m = messages[i];

		if ( !m.isDraft() && m.attachmentCount() > 0 && m.attachmentAt(0).mimeType() == "text/plain" )
		{
			QVariantMap qvm;
			qvm.insert( "inbound", m.isInbound() );
			qvm.insert( "id", m.id() );
			qvm.insert( "text", QString::fromLocal8Bit( m.attachmentAt(0).data() ) );
			qvm.insert( "sender", m.sender().displayableName() );
			qvm.insert( "time", m.serverTimestamp() );
			variants << qvm;
		}
	}

	return variants;
}


void ApplicationUI::onExportCompleted()
{
	m_persistance.showToast( tr("Export complete") );
	m_progress->cancel();
}


void ApplicationUI::exportSMS(QStringList const& conversationIds)
{
	ExportSMS* sms = new ExportSMS(conversationIds, m_accountId);
	connect( sms, SIGNAL( exportCompleted() ), this, SLOT( onExportCompleted() ) );
	connect( sms, SIGNAL( progress(int) ), this, SLOT( onProgressChanged(int) ) );

	if (m_progress == NULL) {
		m_progress = new SystemProgressDialog(this);
		m_progress->setTitle( tr("Exporting...") );
	}

	m_progress->setProgress(0);
	m_progress->show();

	startThread(sms);
}


void ApplicationUI::onProgressChanged(int progress) {
	m_progress->setProgress(progress);
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
