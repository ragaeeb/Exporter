#include "applicationui.hpp"
#include "ExportSMS.h"
#include "ImportSMS.h"
#include "Logger.h"

#include <QThreadPool>

#include <bb/cascades/AbstractPane>
#include <bb/cascades/Application>
#include <bb/cascades/ArrayDataModel>
#include <bb/cascades/QmlDocument>

#include <bb/pim/message/MessageFilter>
#include <bb/pim/message/MessageService>

#include <bb/system/SystemProgressDialog>
#include <bb/system/SystemToast>

namespace exportui {

using namespace bb::cascades;
using namespace bb::system;
using namespace bb::pim::message;

ApplicationUI::ApplicationUI(bb::cascades::Application *app) :
		QObject(app), m_toast(NULL), m_progress(NULL)
{
	if ( getValueFor("animations").isNull() ) { // first run
		LOGGER("Exporter()::First run!");
		saveValueFor("animations", 1);
		saveValueFor("userName", tr("You") );
		saveValueFor("timeFormat", 0);
		saveValueFor("duplicateAction", 0);
		saveValueFor("output", "/accounts/1000/removable/sdcard/documents");
	}

    QmlDocument *qml = QmlDocument::create("asset:///main.qml").parent(this);
    qml->setContextProperty("app", this);

    m_root = qml->createRootObject<AbstractPane>();
    app->setScene(m_root);

	ImportSMS* sms = new ImportSMS();
	connect( sms, SIGNAL( importCompleted(qint64 const&, QVariantList const&) ), this, SLOT( onImportCompleted(qint64 const&, QVariantList const&) ) );
	startThread(sms);
}


void ApplicationUI::create(bb::cascades::Application *app) {
	new ApplicationUI(app);
}


void ApplicationUI::onImportCompleted(qint64 const& accountId, QVariantList const& qvl)
{
	m_accountId = accountId;

	ArrayDataModel* adm = m_root->findChild<ArrayDataModel*>("dataModel");
	adm->clear();
	adm->append(qvl);
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
	if (m_toast == NULL) {
		m_toast = new SystemToast(this);
	}

	m_toast->setBody( tr("Export complete") );
	m_progress->cancel();

	m_toast->show();
}


void ApplicationUI::exportSMS(QStringList const& conversationIds)
{
	ExportSMS* sms = new ExportSMS(conversationIds, m_accountId);
	connect( sms, SIGNAL( exportCompleted() ), this, SLOT( onExportCompleted() ) );
	connect( sms, SIGNAL( progress(int const&) ), this, SLOT( onProgressChanged(int const&) ) );

	if (m_progress == NULL) {
		m_progress = new SystemProgressDialog(this);
		m_progress->setTitle( tr("Exporting...") );
	}

	m_progress->setProgress(0);
	m_progress->show();

	startThread(sms);
}


void ApplicationUI::onProgressChanged(int const& progress) {
	m_progress->setProgress(progress);
}


void ApplicationUI::startThread(QRunnable* qr)
{
	qr->setAutoDelete(true);

	QThreadPool *threadPool = QThreadPool::globalInstance();
	threadPool->start(qr);
}


QVariant ApplicationUI::getValueFor(QString const &objectName)
{
    QVariant value( m_settings.value(objectName) );

	LOGGER("getValueFor()" << objectName << value);

    return value;
}


void ApplicationUI::saveValueFor(QString const& objectName, QVariant const& inputValue)
{
	LOGGER("saveValueFor()" << objectName << inputValue);
	m_settings.setValue(objectName, inputValue);
}

}
