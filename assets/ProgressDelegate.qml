import bb.cascades 1.0

ControlDelegate
{
    horizontalAlignment: HorizontalAlignment.Center
    delegateActive: false
    
    function onProgressChanged(current, total) {
        delegateActive = current != total;
        
        if (delegateActive) {
            control.value = current;
            control.toValue = total;
        }
    }
    
    sourceComponent: ComponentDefinition
    {
        ProgressIndicator {
            fromValue: 0
            horizontalAlignment: HorizontalAlignment.Center
            state: ProgressIndicatorState.Progress
        }
    }
}