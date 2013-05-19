#include <QFile>
#include <QSettings>
#include <QThreadPool>

#include <bb/cascades/AbstractPane>
#include <bb/cascades/Application>
#include <bb/cascades/Control>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/SceneCover>

#include <bb/pim/contacts/ContactService>

#include <bb/cascades/pickers/FilePicker>

#include <bb/pim/account/AccountService>
#include <bb/pim/message/MessageFilter>
#include <bb/pim/message/MessageService>

#include <bb/system/Clipboard>
#include <bb/system/SystemProgressDialog>
#include <bb/system/SystemToast>
