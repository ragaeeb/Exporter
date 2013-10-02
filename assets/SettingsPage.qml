import bb.cascades 1.0

BasePage
{
    contentContainer: ScrollView
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
	    Container
	    {
	        leftPadding: 20; topPadding: 20; rightPadding: 20; bottomPadding: 20
	        verticalAlignment: VerticalAlignment.Fill
	        
            PersistDropDown
            {
	            title: qsTr("Duplicate File Behaviour") + Retranslate.onLanguageChanged
                key: "duplicateAction"
	
	            Option {
	                text: qsTr("Append") + Retranslate.onLanguageChanged
	                description: qsTr("If a file already exists, then export to the tail of the file.") + Retranslate.onLanguageChanged
                    imageSource: "images/ic_append.png"
	                value: 0
	            }
	
	            Option {
	                text: qsTr("Overwrite") + Retranslate.onLanguageChanged
	                description: qsTr("If a file already exists, then overwrite it with the new information") + Retranslate.onLanguageChanged
	                imageSource: "images/ic_overwrite.png"
                    value: 1
	            }
	        }
	        
	        PersistDropDown
	        {
	            title: qsTr("Message Time Format") + Retranslate.onLanguageChanged
	            key: "timeFormat"
	
	            Option {
	                text: qsTr("Date & Time") + Retranslate.onLanguageChanged
	                description: qsTr("ie: Jan 4/13 10:15:03") + Retranslate.onLocaleOrLanguageChanged
	                imageSource: "images/ic_calendar.png"
	                value: 0
	            }
	
	            Option {
	                text: qsTr("Time Only") + Retranslate.onLanguageChanged
	                description: qsTr("ie: 10:15:03") + Retranslate.onLocaleOrLanguageChanged
	                imageSource: "images/ic_clock.png"
                    value: 1
	            }
	
	            Option {
	                text: qsTr("Off") + Retranslate.onLanguageChanged
	                description: qsTr("No date or time will be shown on messages.") + Retranslate.onLanguageChanged
	                imageSource: "images/ic_off.png"
                    value: 2
	            }
	
	            bottomMargin: 60
	
	            onSelectedIndexChanged: {
	                if (selectedIndex == 2) {
	                    infoText.text = qsTr("The time will not be appended to the messages.") + Retranslate.onLanguageChanged;
                    } else if (selectedIndex == 0) {
	                    infoText.text = qsTr("The time will will be appended in front of the messages with a format like Jan 4/13 10:15:03.") + Retranslate.onLanguageChanged;
                    } else {
	                    infoText.text = qsTr("The time will will be appended in front of the messages with a format like 10:15:03.") + Retranslate.onLanguageChanged;
                    }
	            }
	        }
	        
	        Label {
	            text: qsTr("Your name shows up as:") + Retranslate.onLanguageChanged;
                textStyle.fontSize: FontSize.XSmall
	            textStyle.textAlign: TextAlign.Center
	        }
	        
	        TextField {
	            hintText: qsTr("The name that shows for messages you sent.") + Retranslate.onLanguageChanged
	
	            onTextChanged: {
	                persist.saveValueFor("userName", text);
	                infoText.text = qsTr("In the output, messages you sent will be prefixed by: %1").arg(text) + Retranslate.onLanguageChanged
                }
	
	            text: persist.getValueFor("userName")
	            
	            verticalAlignment: VerticalAlignment.Fill
	        }
	        
	        SettingPair
	        {
	            topPadding: 20
                key: "doubleSpace"
                title: qsTr("Double-space") + Retranslate.onLanguageChanged

                toggle.onCheckedChanged: {
                    if (checked) {
                        infoText.text = qsTr("Each message will be double-spaced for better readability.") + Retranslate.onLanguageChanged
                    } else {
                        infoText.text = qsTr("Each message will be single-spaced.") + Retranslate.onLanguageChanged
                    }
                }
            }

            SettingPair {
                topPadding: 20

                title: qsTr("Latest Message First") + Retranslate.onLanguageChanged;
                key: "latestFirst"

                toggle.onCheckedChanged: {
                    if (checked) {
                        infoText.text = qsTr("Messages will be ordered from most recent to least recent.");
                    } else {
                        infoText.text = qsTr("Messages will be ordered from oldest to newest .");
                    }
                }
            }
            
            SettingPair {
                topPadding: 20
                
                title: qsTr("Use Server Timestamp") + Retranslate.onLanguageChanged;
                key: "serverTimestamp"
                
                toggle.onCheckedChanged: {
                    if (checked) {
                        infoText.text = qsTr("Message timestamps will reflect the time they were stored in the server.");
                    } else {
                        infoText.text = qsTr("Message timestamps will reflect the time they were created on the device.");
                    }
                }
            }

            Label {
	            topMargin: 40
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