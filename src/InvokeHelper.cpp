#include "precompiled.h"

#include "InvokeHelper.h"
#include "CardUtils.h"
#include "CommonConstants.h"
#include "DeviceUtils.h"
#include "Logger.h"
#include "OutputFormat.h"
#include "Persistance.h"
#include "PimUtil.h"

#define QML_SURAH_PAGE "SurahPage.qml"
#define TARGET_AYAT_PICKER "com.canadainc.Quran10.ayat.picker"

namespace exportui {

using namespace bb::cascades;
using namespace bb::pim::message;
using namespace bb::system;
using namespace canadainc;

InvokeHelper::InvokeHelper(InvokeManager* invokeManager, Persistance* p) :
        m_root(NULL), m_invokeManager(invokeManager), m_persist(p)
{
}


void InvokeHelper::init(QString const& qmlDoc, QMap<QString, QObject*> const& context, QObject* parent)
{
    DeviceUtils::registerTutorialTips(this);
    qmlRegisterUncreatableType<OutputFormat>("com.canadainc.data", 1, 0, "OutputFormat", "Can't instantiate");

    m_root = CardUtils::initAppropriate(qmlDoc, context, parent);
}


QString InvokeHelper::invoked(bb::system::InvokeRequest const& request)
{
    LOGGER( request.action() << request.target() << request.mimeType() << request.metadata() << request.uri().toString() << QString( request.data() ) );

    QMap<QString,QString> targetToQML;
    targetToQML[TARGET_AYAT_PICKER] = "InvokedPage.qml";

    QString target = request.target();
    QString qml = targetToQML.value(target);

    if ( qml.isNull() ) {
        qml = QML_SURAH_PAGE;
    }

    m_request = request;
    m_request.setTarget(target);

    return qml;
}


void InvokeHelper::lazyInit()
{
    QmlDocument* qml = QmlDocument::create("asset:///NotificationToast.qml").parent(this);
    QObject* toast = qml->createRootObject<QObject>();
    QmlDocument::defaultDeclarativeEngine()->rootContext()->setContextProperty("tutorialToast", toast);
}


void InvokeHelper::process()
{
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

                QDateTime t = m_persist->getValueFor("serverTimestamp").toInt() == 1 ? m.serverTimestamp() : m.deviceTimestamp();

                text = tr("%1\r\n\r\n%2: %3").arg( m.sender().address() ).arg( t.toString("MMM d/yy hh:mm:ss") ).arg( PimUtil::extractText(m) );
            }
        } else {
            text = QString::fromUtf8( m_request.data().data() );
        }

        m_root->setProperty("data", text);

        connect( m_root, SIGNAL( finished() ), this, SLOT( cardFinished() ) );
    }
}


void InvokeHelper::cardFinished() {
    m_invokeManager->sendCardDone( CardDoneMessage() );
}


void InvokeHelper::finishWithToast(QString const& message)
{
    Persistance::showBlockingDialog( tr("Exporter"), message, tr("OK"), "" );
    m_invokeManager->sendCardDone( CardDoneMessage() );
}


InvokeHelper::~InvokeHelper()
{
}

} /* namespace admin */
