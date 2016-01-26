APP_NAME = Exporter

INCLUDEPATH += ../../canadainc/src/
INCLUDEPATH += ../../quazip/src/
CONFIG += qt warn_on cascades10
LIBS += -lbbpim -lbbsystem -lbb -lbbplatform -lbbdevice
QT += network

CONFIG(release, debug|release) {
    DESTDIR = o.le-v7
    LIBS += -L../../canadainc/arm/o.le-v7 -lcanadainc -Bdynamic
    LIBS += -Bstatic -L../../quazip/arm/o.le-v7 -lquazip -Bdynamic
}

CONFIG(debug, debug|release) {
    DESTDIR = o.le-v7-g
    LIBS += -L../../canadainc/arm/o.le-v7-g -lcanadainc -Bdynamic
    LIBS += -Bstatic -L../../quazip/arm/o.le-v7-g -lquazip -Bdynamic
}

simulator {

CONFIG(debug, debug|release) {
    DESTDIR = o-g
    LIBS += -Bstatic -L../../canadainc/x86/o-g/ -lcanadainc -Bdynamic
    LIBS += -Bstatic -L../../quazip/x86/o-g -lquazip -Bdynamic
}

}

include(config.pri)
