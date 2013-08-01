import bb.cascades 1.0

BasePage
{
    property variant contact
    property int timeSetting
    property string userName
    
    onContactChanged:
    {
        userName = persist.getValueFor("userName");
        timeSetting = persist.getValueFor("timeFormat");

        app.getMessagesFor(contact.conversationId);
    }
    
    function onSettingChanged(key)
    {
        if (key == "latestFirst" || key == "timeFormat" || key == "userName") {
            contactChanged(contact);
        }
    }
    
    function onMessagesImported(results)
    {
        theDataModel.clear();
        
        if (results.length > 0) {
            theDataModel.append(results);
            label.text = qsTr("Conversation with %1").arg(contact.name);
        } else {
            label.text = qsTr("There are no messages detected for this conversation...are you sure you gave the app the permissions it needs?") + Retranslate.onLanguageChanged
        }
    }
    
    onCreationCompleted: {
        persist.settingChanged.connect(onSettingChanged);
        addAction(rangeSelector.rangeSelectAction);
        
        app.messagesImported.connect(onMessagesImported);
    }
    
    function concatenate()
    {
        var selectedIndices = listView.selectionList()
        var result = ""
        var doubleSpace = persist.getValueFor("doubleSpace") == 1

        for (var i = 0; i < selectedIndices.length; i ++) {
            result += listView.render(listView.dataModel.data(selectedIndices[i]))

            if (i < selectedIndices.length - 1) {
                result += "\n"
                
                if (doubleSpace) {
                    result += "\n"
                }
            }
        }
        
        return result
    }
    
    actions: [
        ActionItem {
            imageSource: "images/selectAll.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            title: qsTr("Select All") + Retranslate.onLanguageChanged
            
            onTriggered: {
                listView.selectAll();
            }
        },

        ActionItem {
            id: copyAction
            title: qsTr("Copy") + Retranslate.onLanguageChanged
            imageSource: "images/ic_copy.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            enabled: false

            onTriggered: {
                var result = concatenate();
                persist.copyToClipboard(result);
            }
        },

        InvokeActionItem {
		    id: iai
		    title: qsTr("Share") + Retranslate.onLanguageChanged

            query {
                mimeType: "text/plain"
                invokeActionId: "bb.action.SHARE"
            }
            
            enabled: false
            
            onTriggered: {
                persist.showBlockingToast( qsTr("Note that BBM has a maximum limit for the length of text that can be inputted into the message field. So if your conversation is too big it may not paste properly.\n\nUse the Range Selector if the message gets truncated."), qsTr("OK") );
                iai.data = persist.convertToUtf8( concatenate() );
            }
            
            ActionBar.placement: ActionBarPlacement.OnBar
        }
    ]
    
    contentContainer: Container
    {
        leftPadding: 20
        rightPadding: 20
        topPadding: 20
        
        Label {
            id: label
            textStyle.fontSize: FontSize.XSmall
            multiline: true
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            textStyle.textAlign: TextAlign.Center
            
	        animations: [
	            FadeTransition {
	                id: fadeInTransition
	                fromOpacity: 0
	                duration: 1000
	            }
	        ]
            
	        onCreationCompleted: {
                fadeInTransition.play();
	        }
        }
        
        ProgressDelegate
        {
            onCreationCompleted: {
                app.loadProgress.connect(onProgressChanged);
            }
        }
        
        Divider {
            bottomMargin: 0; topMargin: 0;
        }
        
		ListView {
            property alias background: back

            id: listView
	        objectName: "listView"

            attachedObjects: [
		        ImagePaintDefinition {
		            id: back
		            imageSource: "images/listitem.amd"
		        },
		        
		        StaticRangeSelector {
		            id: rangeSelector
              	}
            ]
            
            function copyToClipboard(data) {
                persist.copyToClipboard( render(data) )
            }
            
            function render(data)
            {
			    var timeFormat = "MMM d/yy, hh:mm:ss";
			    
			    if (timeSetting == 1) {
			        timeFormat = "hh:mm:ss"
			    } else if (timeSetting == 2) {
			        timeFormat = ""
			    }
                
                var time = Qt.formatDateTime(data.time, timeFormat);
                var name = data.inbound ? data.sender : userName;
                var text = data.text;
                
                if (timeSetting == 2) {
                    return name+": "+text
                } else {
					return time+" - "+name+": "+text
                }
            }
            
            dataModel: ArrayDataModel {
                id: theDataModel
            }
            
            onSelectionChanged: {
                copyAction.enabled = iai.enabled = selectionList().length > 0
            }
		
		    listItemComponents: [
		        ListItemComponent {
		            Container {
		                id: listItemRoot
		                property bool active: ListItem.active
		                property bool selected: ListItem.selected
		                opacity: 0.5
		                
		                onSelectedChanged: {
		                    opacity = selected ? 1 : 0.5
		                }
		                
		                leftPadding: 40; bottomPadding: 30; topPadding: 20
		                
		                background: ListItem.view.background.imagePaint
		                horizontalAlignment: HorizontalAlignment.Fill
		                preferredWidth: 1280
		                
		                Label {
		                    id: messageLabel
                            text: listItemRoot.ListItem.view.render(ListItemData)
		                    multiline: true
		                    verticalAlignment: VerticalAlignment.Center
		                }
		                
		                contextActions: [
		                    ActionSet {
		                        ActionItem {
		                            title: qsTr("Copy") + Retranslate.onLanguageChanged
                                    imageSource: "images/ic_copy.png"
                                    
                                    onTriggered: {
                                        listItemRoot.ListItem.view.copyToClipboard(ListItemData)
                                    }
                                }
		                    }
		                ]
		            }
		        }
		    ]
		    
		    onTriggered: {
		        toggleSelection(indexPath);
		    }
		
		    horizontalAlignment: HorizontalAlignment.Fill
		    verticalAlignment: VerticalAlignment.Fill
		
		    layoutProperties: StackLayoutProperties {
		        spaceQuota: 1
		    }
		}
    }
}