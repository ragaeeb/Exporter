import bb.cascades 1.0

Page
{
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll

    titleBar: AboutTitleBar {
        id: atb
    }
    
    actions: [
        InvokeActionItem
        {
            title: qsTr("Our BBM Channel") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            query {
                invokeTargetId: atb.invokeTargetId
                uri: atb.channelUri
            }
        },
        
        InvokeActionItem
        {
            query {
                mimeType: "text/html"
                uri: "http://www.youtube.com/watch?v=AbHZLmWSKts"
                invokeActionId: "bb.action.OPEN"
            }
            
            imageSource: "images/menu/ic_tutorial.png"
            title: qsTr("Video Tutorial") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement.Signature : ActionBarPlacement.OnBar
        }
    ]

    Container
    {
        leftPadding: 10; rightPadding: 10

        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill

        ScrollView
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill

            Label {
                multiline: true
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                textStyle.textAlign: TextAlign.Center
                textStyle.fontSize: FontSize.Small
                content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
                text: qsTr("\n\nEver wanted to forward or share multiple SMS or Email conversations with others (or yourself)? Or ever wanted to persist these messages into the file system? This is where Exporter comes in.\n\nThis app makes it really easy to select which conversations you want to share and even allows you to select a subset of the messages that you want to share. You can also select these conversations to be archived into your SD card, a cloud storage account, or any other persistent storage. After selecting the conversations you are free to share it in whichever channel you wish (ie: Facebook, Remember, Email, BBM, SMS, etc.)\n\nThe great thing is that the app gives you access to nearly all your accounts to export messages from. This includes emails, SMS, PIN messages, etc. Exporter is also registered as in BB10's invocation framework and this means that any plain-text information can easily be saved to your file system when you use a Share action!\n\n") + Retranslate.onLanguageChanged
            }
        }
    }
}
