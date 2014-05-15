import bb.cascades 1.0
import bb.cascades.pickers 1.0

Page
{
    signal finished();
    property string data
    property string defaultName
    
    onDataChanged: {
        var tokens = data.split("\n");
        filePicker.defaultSaveFileNames = [ defaultName.length > 0 ? defaultName : tokens[0].substr(0, 40) + ".txt", "Document.txt" ];
        
        filePicker.open();
    }
    
    titleBar: ExporterTitleBar {}
    
    attachedObjects: [
        FilePicker
        {
            id: filePicker
            mode: FilePickerMode.Saver
            title : qsTr("Enter Name") + Retranslate.onLanguageChanged
            defaultType: FileType.Document
            allowOverwrite: true
            filter: ["*.txt"]
            directories: persist.getValueFor("output")
            
            onFileSelected : {
                var result = selectedFiles[0];
                app.saveTextData(result, data);
                
                persist.showBlockingToast( qsTr("Successfully saved file: %1").arg(result), qsTr("OK") );
                
                finished();
            }
            
            onCanceled: {
                finished();
            }
        }
    ]
}