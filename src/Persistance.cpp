#include "Persistance.h"
#include "Logger.h"

#include <bb/system/Clipboard>
#include <bb/system/SystemToast>

namespace canadainc {

using namespace bb::system;

Persistance::Persistance(QObject* parent) : QObject(parent), m_toast(NULL)
{
}

Persistance::~Persistance()
{
}


void Persistance::showToast(QString const& text, QString const& buttonLabel)
{
	if (m_toast == NULL) {
		m_toast = new SystemToast(this);
		connect( m_toast, SIGNAL( finished(bb::system::SystemUiResult::Type) ), this, SLOT( finished(bb::system::SystemUiResult::Type) ) );
	}

	if ( !buttonLabel.isNull() ) {
		m_toast->button()->setLabel( tr("OK") );
	}

	m_toast->setBody(text);
	m_toast->show();
}


void Persistance::copyToClipboard(QString const& text)
{
	Clipboard clipboard;
	clipboard.clear();

	clipboard.insert( "text/plain", text.toUtf8() );

	showToast( tr("Copied: %1 to clipboard").arg(text) );
}


void Persistance::finished(bb::system::SystemUiResult::Type value)
{
	LOGGER("Toast finished()");
	emit toastFinished(value == SystemUiResult::ButtonSelection);
}


QString Persistance::convertToUtf8(QString const& text) {
	return QString::fromUtf8( text.toUtf8().constData() );
}


QVariant Persistance::getValueFor(const QString &objectName)
{
    QVariant value( m_settings.value(objectName) );

    LOGGER("getValueFor: " << objectName << value);

    return value;
}


void Persistance::saveValueFor(const QString &objectName, const QVariant &inputValue)
{
	LOGGER("saveValueFor: " << objectName << inputValue);
	m_settings.setValue(objectName, inputValue);

	emit settingChanged(objectName);
}


} /* namespace canadainc */
