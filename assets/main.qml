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

    Menu.definition: CanadaIncMenu {
        projectName: "exporter10"
    }

    onPopTransitionEnded: {
        page.destroy();
    }
    
    BasePage
    {
        id: rootPage
        
        actions: [
	        ActionItem {
	            id: selectAllAction
	            imageSource: "images/selectAll.png"
	            ActionBar.placement: ActionBarPlacement.OnBar
	            title: qsTr("Select All") + Retranslate.onLanguageChanged
	            enabled: false
	            
	            onTriggered: {
	                listView.multiSelectHandler.active = true;
	                listView.selectAll();
	            }
	        }
        ]
        
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        contentContainer: Container
        {
	        leftPadding: 20
	        rightPadding: 20
	        topPadding: 20
	        horizontalAlignment: HorizontalAlignment.Fill
	        
            ProgressDelegate
            {
                onCreationCompleted: {
                    app.conversationLoadProgress.connect(onProgressChanged);
                }
            }
	        
	        Label {
	            id: instructions
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
	            
	            leadingVisual: AccountsDropDown
	            {
	                id: accountsDropDown
	                selectedAccountId: 23
	                
	                onAccountsLoaded: {
	                    if (numAccounts == 0) {
                            instructions.text = qsTr("No accounts found. Are you sure you gave the app the permissions it needs?");
	                    } else {
                            divider.visible = false;
	                    }
                    }
	                
	                onSelectedValueChanged: {
                        app.getConversationsFor(selectedValue);
                    }
                }
	            
	            function doExport(conversationIds)
	            {
	                filePicker.directories = [ persist.getValueFor("output"), "/accounts/1000/shared/documents"]
	                filePicker.conversationIds = conversationIds;
	                filePicker.open();
	            }
	            
	            function onConversationsImported(conversations)
	            {
	                adm.clear();
	                adm.append(conversations);
	                
                    selectAllAction.enabled = conversations.length > 0;

                    scrollToPosition(0, ScrollAnimation.None);
                    scroll(-100, ScrollAnimation.Smooth);
	            }
	            
	            onCreationCompleted: {
                    app.conversationsImported.connect(onConversationsImported);
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
						                imageSource: "images/ic_export.png"
						                
						                onTriggered: {
							                control.ListItem.view.doExport([ListItemData.conversationId])
						                }
						            }
    	                        }
    	                    ]
	                        
	                        title: ListItemData.name ? ListItemData.name : ListItemData.number
                            description: ListItemData.number
	                        status: ListItemData.messageCount
	                        imageSource: ListItemData.smallPhotoFilepath.length > 0 ? "file://"+ListItemData.smallPhotoFilepath : "images/ic_user.png"
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
					        var result = selectedFiles[0];
							persist.saveValueFor("output", result);
							
                            app.exportSMS(conversationIds, accountsDropDown.selectedValue);
		                }
					}
                ]
	            
	            multiSelectAction: MultiSelectActionItem {}
                                
                multiSelectHandler {
                    actions: [
			            ActionItem {
			                id: multiExportAction
			                enabled: false
			                title: qsTr("Export TXT") + Retranslate.onLanguageChanged
			                imageSource: "images/ic_export.png"
			                
			                onTriggered: {
				                var selectedIndices = listView.selectionList();
				                var result = [];
				
				                for (var i = 0; i < selectedIndices.length; i++) {
				                    result.push( listView.dataModel.data(selectedIndices[i]).conversationId );
				                }
				                
				                listView.doExport(result);
			                }
			            }
                    ]
                    
                    onActiveChanged: {
                        if (!active) {
                            listView.clearSelection();
                        }
                    }
             
                    status: qsTr("None selected") + Retranslate.onLanguageChanged
                }

	            dataModel: ArrayDataModel {
	                id: adm
                }

	            layoutProperties: StackLayoutProperties {
	                spaceQuota: 1
	            }

                onSelectionChanged: {
                    var n = selectionList().length;
                    multiSelectHandler.status = qsTr("%1 conversations selected").arg(n);
                    multiExportAction.enabled = n > 0;
                }

			    onTriggered: {
			        definition.source = "ConversationView.qml"
	                var page = definition.createObject();
                    page.accountId = accountsDropDown.selectedValue;
	                page.contact = dataModel.data(indexPath);
	                navigationPane.push(page);
			    }
	        }
	    }
    }
}