#include "precompiled.h"

#include "applicationui.hpp"
#include "Logger.h"

using namespace bb::cascades;
using namespace exportui;

namespace {

void redirectedMessageOutput(QtMsgType type, const char *msg) {
	Q_UNUSED(type);
	fprintf(stderr, "%s\n", msg);
}

}

Q_DECL_EXPORT int main(int argc, char **argv)
{
	qInstallMsgHandler(redirectedMessageOutput);

    Application app(argc, argv);
    ApplicationUI::create(&app);

    return Application::exec();
}
