#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlEngine>
#include <QQmlContext>
#include <QtCore/QStandardPaths>
#include <QtCore/QStringList>


int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    const QUrl appPath(QUrl::fromLocalFile(app.applicationDirPath()));
    const QStringList picturesLocation = QStandardPaths::standardLocations(QStandardPaths::PicturesLocation);
    const QUrl imagePath = picturesLocation.isEmpty() ? appPath : QUrl::fromLocalFile(picturesLocation.first());
    engine.rootContext()->setContextProperty("imagePath", imagePath);

    engine.load(url);
    QMetaObject::invokeMethod(engine.rootObjects().first(), "init", Qt::QueuedConnection);

    return app.exec();
}
