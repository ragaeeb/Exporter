import bb.cascades 1.0
import CustomComponent 1.0

NavigationPane
{
    id: navigationPane

    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]

    Menu.definition: MenuDefinition
    {
        settingsAction: SettingsActionItem
        {
    	    property variant settingsPage
            
            onTriggered:
            {
                if (!settingsPage) {
                    definition.source = "SettingsPage.qml"
                    settingsPage = definition.createObject()
                }
                
                navigationPane.push(settingsPage);
            }
        }

        helpAction: HelpActionItem
        {
    	    property variant helpPage
            
            onTriggered:
            {
                if (!helpPage) {
                    definition.source = "HelpPage.qml"
                    helpPage = definition.createObject();
                }

                navigationPane.push(helpPage);
            }
        }
    }

    onPopTransitionEnded: {
        page.destroy();
    }
    
    BasePage
    {
        actions: [
	        ActionItem {
	            imageSource: "images/selectAll.png"
	            ActionBar.placement: ActionBarPlacement.OnBar
	            title: qsTr("Select All") + Retranslate.onLanguageChanged
	            
	            onTriggered: {
	                listView.multiSelectHandler.active = true
	                listView.selectAll();
	            }
	        }
        ]
        
        contentContainer: Container
        {
	        leftPadding: 20
	        rightPadding: 20
	        topPadding: 20
	        horizontalAlignment: HorizontalAlignment.Fill
	        
	        Label {
	            text: qsTr("Tap on a conversation to open up its messages and share them. Press-and-hold on a conversation to export them to persistant storage.")
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
	        
	        Divider {
	            bottomMargin: 0; topMargin: 0;
	        }
	        
	        ListView {
	            id: listView
	            horizontalAlignment: HorizontalAlignment.Fill
	            verticalAlignment: VerticalAlignment.Fill
	            
	            function doExport(conversationIds)
	            {
	                filePicker.directories = [ persist.getValueFor("output"), "/accounts/1000/shared/documents"]
	                filePicker.conversationIds = conversationIds
	                filePicker.open()
	            }
	
	            listItemComponents:
	            [
	                ListItemComponent
	                {
	                    StandardListItem
	                    {
	                        id: control
	                        
    	                    contextActions: [
    	                        ActionSet {
    	                            title: ListItemData.name
    	                            subtitle: qsTr("%1 messages").arg(ListItemData.messageCount)
    	                            
						            ActionItem {
						                id: exportAction
						                title: qsTr("Export TXT")
						                imageSource: "file:///usr/share/icons/ic_forward.png"
						                
						                onTriggered: {
							                control.ListItem.view.doExport([ListItemData.conversationId])
						                }
						            }
    	                        }
    	                    ]
	                        
	                        title: ListItemData.name ? ListItemData.name : ListItemData.number
                            description: ListItemData.number
	                        status: ListItemData.messageCount
	                        imageSource: ListItemData.smallPhotoFilepath.length > 0 ? "file://"+ListItemData.smallPhotoFilepath : "file:///usr/share/icons/tmb_contact.png"
	                    }
	                }
	            ]
	            
                attachedObjects: [
					FilePicker {
	                    property variant conversationIds
					    
					    id: filePicker
					    mode: FilePickerMode.SaverMultiple
		                title : qsTr("Select Folder") + Retranslate.onLanguageChanged
		                filter: ["*.txt"]
		                
		                onFileSelected : {
					        var result = selectedFiles[0]
							persist.saveValueFor("output", result)
							
							app.exportSMS(conversationIds)
		                }
					}
                ]
	            
	            multiSelectAction: MultiSelectActionItem {}
                                
                multiSelectHandler {
                    actions: [
			            ActionItem {
			                id: multiExportAction
			                enabled: false
			                title: qsTr("Export TXT")
			                imageSource: "file:///usr/share/icons/ic_forward.png"
			                
			                onTriggered: {
				                var selectedIndices = listView.selectionList()
				                var result = []
				
				                for (var i = 0; i < selectedIndices.length; i++) {
				                    result.push( listView.dataModel.data(selectedIndices[i]).conversationId )
				                }
				                
				                listView.doExport(result)
			                }
			            }
                    ]
                    
                    onActiveChanged: {
                        if (!active) {
                            listView.clearSelection()
                        }
                    }
             
                    status: qsTr("None selected")
                }
	            
	            dataModel: app.getDataModel()
	            
	            layoutProperties: StackLayoutProperties {
	                spaceQuota: 1
	            }
	            
                onSelectionChanged: {
                    var n = selectionList().length
                    multiSelectHandler.status = qsTr("%1 conversations selected").arg(n)
                    multiExportAction.enabled = n > 0
                }
                
			    onTriggered: {
			        definition.source = "ConversationView.qml"
	                var page = definition.createObject()
	                page.contact = dataModel.data(indexPath)
	                navigationPane.push(page);
			    }
	        }
	    }
    }
}