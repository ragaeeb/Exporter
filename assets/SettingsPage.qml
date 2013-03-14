import bb.cascades 1.0

BasePage {
    contentContainer: ScrollView
    {
	    Container
	    {
	        leftPadding: 20; topPadding: 20; rightPadding: 20; bottomPadding: 20
	        verticalAlignment: VerticalAlignment.Fill
	        
	        SettingPair {
	            topMargin: 20
	            title: qsTr("Animations")
	        	toggle.checked: app.getValueFor("animations") == 1
	    
	            toggle.onCheckedChanged: {
	        		app.saveValueFor("animations", checked ? 1 : 0)
	        		
	        		if (checked) {
	        		    infoText.text = qsTr("Controls will be animated whenever they are loaded.")
	        		} else {
	        		    infoText.text = qsTr("Controls will be snapped into position without animations.")
	        		}
	            }
	        }
	        
	        DropDown {
	            title: qsTr("Duplicate File Behaviour") + Retranslate.onLanguageChanged
	            horizontalAlignment: HorizontalAlignment.Fill
	
	            Option {
	                text: qsTr("Append") + Retranslate.onLanguageChanged
	                description: qsTr("If a file already exists, then export to the tail of the file.") + Retranslate.onLanguageChanged
	                selected: app.getValueFor("duplicateAction") == 0
	            }
	
	            Option {
	                text: qsTr("Overwrite") + Retranslate.onLanguageChanged
	                description: qsTr("If a file already exists, then overwrite it with the new information") + Retranslate.onLanguageChanged
	                selected: app.getValueFor("duplicateAction") == 1
	            }
	
	            onSelectedIndexChanged: {
	                app.saveValueFor("duplicateAction", selectedIndex);
	            }
	        }
	        
	        DropDown {
	            title: qsTr("Message Time Format") + Retranslate.onLanguageChanged
	            horizontalAlignment: HorizontalAlignment.Fill
	
	            Option {
	                text: qsTr("Date & Time") + Retranslate.onLanguageChanged
	                description: qsTr("ie: Jan 4/13 10:15:03") + Retranslate.onLocaleOrLanguageChanged
	                selected: app.getValueFor("timeFormat") == 0
	            }
	
	            Option {
	                text: qsTr("Time Only") + Retranslate.onLanguageChanged
	                description: qsTr("ie: 10:15:03") + Retranslate.onLocaleOrLanguageChanged
	                selected: app.getValueFor("timeFormat") == 1
	            }
	
	            Option {
	                text: qsTr("Off") + Retranslate.onLanguageChanged
	                description: qsTr("No date or time will be shown on messages.") + Retranslate.onLanguageChanged
	                selected: app.getValueFor("timeFormat") == 2
	            }
	
	            bottomMargin: 60
	
	            onSelectedIndexChanged: {
	                app.saveValueFor("timeFormat", selectedIndex);
	                
	                if (selectedIndex == 2) {
	                    infoText.text = qsTr("The time will not be appended to the messages.")
	                } else if (selectedIndex == 0) {
	                    infoText.text = qsTr("The time will will be appended in front of the messages with a format like Jan 4/13 10:15:03.")
	                } else {
	                    infoText.text = qsTr("The time will will be appended in front of the messages with a format like 10:15:03.")
	                }
	            }
	        }
	        
	        Label {
	            text: qsTr("Your name shows up as:");
	            textStyle.fontSize: FontSize.XSmall
	            textStyle.textAlign: TextAlign.Center
	        }
	        
	        TextField {
	            hintText: qsTr("The name that shows for messages you sent.") + Retranslate.onLanguageChanged
	
	            onTextChanged: {
	                app.saveValueFor("userName", text);
	                infoText.text = qsTr("In the output, messages you sent will be prefixed by: %1").arg(text)
	            }
	
	            text: app.getValueFor("userName")
	            
	            layoutProperties: StackLayoutProperties {
	                spaceQuota: 1
	            }
	            
	            verticalAlignment: VerticalAlignment.Fill
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