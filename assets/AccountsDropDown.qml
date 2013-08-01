import bb.cascades 1.0

DropDown
{
    id: accountChoice
    title: qsTr("Account") + Retranslate.onLanguageChanged
    property variant selectedAccountId
    signal accountsLoaded(int numAccounts);
    horizontalAlignment: HorizontalAlignment.Fill
    
    function onAccountsImported(results)
    {
        for (var i = results.length-1; i >= 0; i--)
        {
            var current = results[i];
            var option = optionDefinition.createObject();
            option.text = current.name;
            option.description = current.address;
            option.value = current.accountId;
            
            if (current.accountId == selectedAccountId) {
                option.selected = true;
            }
            
            add(option);
        }
        
        accountsLoaded(results.length);
        if (results.length > 0) {
            divider.visible = true;
        } else {
            instructions.text = qsTr("Did not find any accounts. Maybe the app does not have the permissions it needs...") + Retranslate.onLanguageChanged
            divider.visible = false;
        }
    }
    
    onCreationCompleted: {
        app.accountsImported.connect(onAccountsImported);
        app.loadAccounts();
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: optionDefinition
            
            Option {
                imageSource: "images/ic_account.png"
            }
        }
    ]
}