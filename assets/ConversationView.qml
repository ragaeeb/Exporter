import bb.cascades 1.0

BasePage
{
    property variant contact
    
    onContactChanged: {
        label.text = qsTr("Conversation with %1").arg(contact.name)
        var messages = app.getMessagesFor(contact.conversationId)
        theDataModel.clear()
        theDataModel.append(messages)
    }
    
    actions: [
        ActionItem {
            imageSource: "asset:///images/selectAll.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            title: qsTr("Select All") + Retranslate.onLanguageChanged
            
            onTriggered: {
                listView.selectAll();
            }
            
	        shortcuts: [
	            Shortcut {
	                key: qsTr("A") + Retranslate.onLanguageChanged
	            }
	        ]
        },
        
		InvokeActionItem {
		    id: iai
		    title: qsTr("Share")

            query {
                mimeType: "text/plain"
                invokeActionId: "bb.action.SHARE"
            }
            
            enabled: false
            
            onTriggered: {
                var selectedIndices = listView.selectionList()
                var result = ""

                for (var i = 0; i < selectedIndices.length; i++)
                {
                    result += listView.render( listView.dataModel.data(selectedIndices[i]) )
                    
                    if (i < selectedIndices.length-1) {
                        result += "\n"
                    }
                }

                iai.data = result
            }
            
	        shortcuts: [
	            SystemShortcut {
	                type: SystemShortcuts.Forward
	            }
	        ]
            
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
            bottomMargin: 65
            
	        animations: [
	            FadeTransition {
	                id: fadeInTransition
	                fromOpacity: 0
	                duration: 1000
	            }
	        ]
            
	        onCreationCompleted:
	        {
	            if ( app.getValueFor("animations") == 1 ) {
	                fadeInTransition.play()
	            }
	        }
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            preferredHeight: 1
            background: Color.LightGray
        }
        
		ListView {
	        id: listView
	        objectName: "listView"
	        property alias background: back
	        property variant application: app
	        
            attachedObjects: [
		        ImagePaintDefinition {
		            id: back
		            imageSource: "asset:///images/listitem.amd"
		        }
            ]
            
            onSelectionChanged: {
                exportAction.enabled = iai.enabled = selectionList().length > 0
            }
            
            function render(data)
            {
			    var timeFormat = "MMM d/yy, hh:mm:ss";
			    var timeSetting = app.getValueFor("timeFormat")
			    
			    if (timeSetting == 1) {
			        timeFormat = "hh:mm:ss"
			    } else if (timeSetting == 2) {
			        timeFormat = ""
			    }
                
                var time = Qt.formatDateTime(data.time, timeFormat)
                var name = data.inbound ? data.sender : app.getValueFor("userName")
                var text = data.text
                
                if (timeSetting == 2) {
                    return name+": "+text
                } else {
					return time+" - "+name+": "+text
                }
            }
            
            dataModel: ArrayDataModel {
                id: theDataModel
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
		                    text: {
							    listItemRoot.ListItem.view.render(ListItemData)
		                    }
		                    multiline: true
		                    verticalAlignment: VerticalAlignment.Center
		                }
		            }
		        }
		    ]
		    
		    onTriggered: {
		        toggleSelection(indexPath)
		    }
		
		    horizontalAlignment: HorizontalAlignment.Fill
		    verticalAlignment: VerticalAlignment.Fill
		
		    layoutProperties: StackLayoutProperties {
		        spaceQuota: 1
		    }
		}
    }
}