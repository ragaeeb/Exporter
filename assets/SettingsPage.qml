import bb.cascades 1.0

Page
{
    titleBar: TitleBar {
        title: qsTr("Settings") + Retranslate.onLanguageChanged
    }
    
    function onTutorialFinished(key)
    {
        if (key == "useServerTS") {
            duplicateAction.expanded = true;
        }
    }
    
    
    function cleanUp() {
        tutorial.tutorialFinished.disconnect(onTutorialFinished);
    }
    
    onCreationCompleted: {
        tutorial.tutorialFinished.connect(onTutorialFinished);        
        tutorial.execBelowTitleBar("duplicateBehaviour", qsTr("You can control what Exporter does when it notices an existing conversation with the conversation that is being exported by setting the '%1' dropdown.").arg(duplicateAction.title) );
        tutorial.execActionBar( "settingsClose", qsTr("Tap here to close this page."), "b" );
        tutorial.exec( "yourName", qsTr("You can control how your name appears on all outgoing messages by modifying the '%1' text field.").arg(yourNameLabel.text), HorizontalAlignment.Center, VerticalAlignment.Top, 0, 0, tutorial.du(28), 0, undefined, "r" );
        tutorial.exec("doubleSpace", qsTr("If you require extra padding to be present between the messages in the plain-text document, enable the '%1' checkmark.").arg(doubleSpace.text), HorizontalAlignment.Right, VerticalAlignment.Top, 0, 0, tutorial.du(36), 0, "images/toast/double_space.png" );
        tutorial.exec("latestFirst", qsTr("Typically the app would display the most recent message at the top and the oldest message at the bottom. If you wish to reverse this and show the messages from most least recent to most recent, uncheck '%1'.").arg(latestFirst.text), HorizontalAlignment.Right, VerticalAlignment.Top, 0, 0, tutorial.du(44), 0, "images/toast/ic_clock.png" );
        tutorial.exec("useServerTS", qsTr("If your device was offline, or was turned off, it might have received the message at a later time than it was originally sent.\n\nAs a result, the '%1' checkbox ensures that the server timestamp is used for better accuracy. However there may be some scenarios when the server timestamp is not recorded at which point the device timestamp of the message will be used.").arg(serverTimestamp.text), HorizontalAlignment.Right, VerticalAlignment.Top, 0, 0, tutorial.du(52), 0, "images/toast/ic_calendar.png" );
    }
    
    ScrollView
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
	    Container
	    {
	        leftPadding: 10; topPadding: 10; rightPadding: 10; bottomPadding: 10
	        horizontalAlignment: HorizontalAlignment.Fill
	        verticalAlignment: VerticalAlignment.Fill
	        
            PersistDropDown
            {
                id: duplicateAction
	            title: qsTr("Duplicate File Behaviour") + Retranslate.onLanguageChanged
                key: "duplicateAction"
	
	            Option {
	                id: append
	                text: qsTr("Append") + Retranslate.onLanguageChanged
	                description: qsTr("If a file already exists, then export to the tail of the file.") + Retranslate.onLanguageChanged
                    imageSource: "images/dropdown/ic_append.png"
	                value: 0
	            }
	
	            Option {
	                id: overwrite
	                text: qsTr("Overwrite") + Retranslate.onLanguageChanged
	                description: qsTr("If a file already exists, then overwrite it with the new information") + Retranslate.onLanguageChanged
	                imageSource: "images/dropdown/ic_overwrite.png"
                    value: 1
	            }
                
                onValueChanged: {
                    console.log("UserEvent: DuplicateAction", selectedValue);
                    reporter.record( "DuplicateAction", selectedValue.toString() );
                }
                
                onExpandedChanged: {
                    if (expanded)
                    {
                        tutorial.execBelowTitleBar( "append", qsTr("To append to the existing file upon duplicate name encounter use the '%1' option.").arg(append.text), tutorial.du(8) );
                        tutorial.execBelowTitleBar( "overwrite", qsTr("To replace the file with the same name upon duplicate name encounter, use the '%1' option.").arg(overwrite.text), tutorial.du(16) );
                    }
                }
	        }
	        
	        Label {
	            id: yourNameLabel
	            text: qsTr("Your name shows up as:") + Retranslate.onLanguageChanged;
                textStyle.fontSize: FontSize.XSmall
	            textStyle.textAlign: TextAlign.Center
	        }
	        
	        TextField
	        {
	            hintText: qsTr("The name that shows for messages you sent.") + Retranslate.onLanguageChanged
                text: persist.getValueFor("userName")
                verticalAlignment: VerticalAlignment.Fill
	
	            onTextChanged: {
	                persist.saveValueFor("userName", text);

	                infoText.text = qsTr("In the output, messages you sent will be prefixed by: %1").arg(text) + Retranslate.onLanguageChanged
                    console.log("UserEvent: UserName", text);
                    reporter.record( "UserName", text );
                }
	        }
	        
	        PersistCheckBox
	        {
                id: doubleSpace
                topMargin: 20
                key: "doubleSpace"
                text: qsTr("Double-space") + Retranslate.onLanguageChanged

                onCheckedChanged: {
                    if (checked) {
                        infoText.text = qsTr("Each message will be double-spaced for better readability.") + Retranslate.onLanguageChanged
                    } else {
                        infoText.text = qsTr("Each message will be single-spaced.") + Retranslate.onLanguageChanged
                    }
                    
                    console.log("UserEvent: DoubleSpaceEnabled", checked);
                }
                
                onValueChanged: {
                    reporter.record( "DoubleSpaceEnabled", checked.toString() );
                }
            }

            PersistCheckBox
            {
                id: latestFirst
                topMargin: 20
                text: qsTr("Latest Message First") + Retranslate.onLanguageChanged;
                key: "latestFirst"

                onCheckedChanged: {
                    if (checked) {
                        infoText.text = qsTr("Messages will be ordered from most recent to least recent.");
                    } else {
                        infoText.text = qsTr("Messages will be ordered from oldest to newest .");
                    }
                    
                    console.log("UserEvent: LatestFirstEnabled", checked);
                }
                
                onValueChanged: {
                    reporter.record( "LatestFirstEnabled", checked.toString() );
                }
            }
            
            PersistCheckBox
            {
                id: serverTimestamp
                topMargin: 20
                text: qsTr("Use Server Timestamp") + Retranslate.onLanguageChanged;
                key: "serverTimestamp"
                
                onCheckedChanged: {
                    if (checked) {
                        infoText.text = qsTr("Message timestamps will reflect the time they were stored in the server.");
                    } else {
                        infoText.text = qsTr("Message timestamps will reflect the time they were created on the device.");
                    }
                    
                    console.log("UserEvent: UseServerTimestamp", checked);
                }
                
                onValueChanged: {
                    reporter.record( "UseServerTimestamp", checked.toString() );
                }
            }
            
            ImageView {
                topMargin: 40
                imageSource: "images/divider.png"
                horizontalAlignment: HorizontalAlignment.Center
            }

            Label {
	            id: infoText
	            multiline: true
	            textStyle.fontSize: FontSize.XXSmall
	            textStyle.textAlign: TextAlign.Center
	            verticalAlignment: VerticalAlignment.Bottom
	            horizontalAlignment: HorizontalAlignment.Center
	        }
	    }
    }
}

// ic calendar, ic clock, ic off