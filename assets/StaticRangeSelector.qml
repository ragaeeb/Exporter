import bb.cascades 1.0

QtObject
{
    id: root
    
    property variant first
    property variant last
    property bool rangeSelect: false
    property ActionItem rangeSelectAction: ActionItem
    {
        title: qsTr("Range Select") + Retranslate.onLanguageChanged
        imageSource: "images/menu/ic_range.png"
        enabled: !root.rangeSelect

        onTriggered: {
            console.log("UserEvent: RangeSelectTriggered");
            
            tutorial.execCentered( "rangeInstructions", qsTr("This mode allows you to select a range of messages.\n\nTap the first message, then tap the last message and all of the ones in between will then be selected."), "images/menu/ic_range.png" );
            root.first = root.last = undefined;
            root.rangeSelect = true;
            
            reporter.record("RangeSelectTriggered");
        }
    }

    function onSelectionChanged()
    {
        if (rangeSelect)
        {
            if (!first) {
                first = parent.selected();
            } else if (!last) {
                last = parent.selectionList()[parent.selectionList().length - 1];
                
                for (var i = first[0] + 1; i < last[0]; i ++) {
                    parent.select([i], true);
                }
                
                rangeSelect = false;
            }
        }
    }
    
    onCreationCompleted: {
        parent.selectionChanged.connect(onSelectionChanged);
    }
}