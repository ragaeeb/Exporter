import bb.cascades 1.0

ActiveTextHandler
{
    id: root
    
    property variant first
    property variant last
    property bool rangeSelect: false
    property alias rangeSelectAction: selectAction

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
    
    attachedObjects: [
        ActionItem {
            id: selectAction
            title: qsTr("Range Select") + Retranslate.onLanguageChanged
            imageSource: "images/ic_range.png"
            enabled: !root.rangeSelect
            onTriggered: {
                persist.showToast( qsTr("This mode allows you to select a range of messages.\n\nTap the first message, then tap the last message and all of the ones in between will then be selected."), qsTr("OK") );
                root.first = root.last = undefined;
                root.rangeSelect = true
            }
        }
    ]
}