import bb.cascades 1.0
import bb 1.0

BasePage
{
    attachedObjects: [
        ApplicationInfo {
            id: appInfo
        },

        PackageInfo {
            id: packageInfo
        }
    ]

    contentContainer: Container
    {
        leftPadding: 20; rightPadding: 20

        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Fill

        ScrollView {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Fill

            Label {
                multiline: true
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                textStyle.textAlign: TextAlign.Center
                textStyle.fontSize: FontSize.Small
                content.flags: TextContentFlag.ActiveText
                text: qsTr("(c) 2013 %1. All Rights Reserved.\n%2 %3\n\nPlease report all bugs to:\nsupport@canadainc.org\n\nBB10 lacks easy ways to forward or share multiple SMS conversations with others (or yourself). It also has no way of being able to persist these messages into the file system. This is where Exporter comes in.\n\nThis app makes it really easy to select which conversations you want to share and even allows you to select a subset of the messages that you want to share. You can also select these conversations to be archived into your SD card, a cloud storage account, or any other persistent storage. After selecting the conversations you are free to share it in whichever channel you wish (ie: Facebook, Remember, Email, BBM, SMS, etc.)").arg(packageInfo.author).arg(appInfo.title).arg(appInfo.version)
            }
        }
    }
}