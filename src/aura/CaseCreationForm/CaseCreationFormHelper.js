({
    
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    
    uploadFileHelper: function(component, event) {
        
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileuploader").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            //var startPosition = 0;
            // calculate the end size or endPostion using Math.min() function which is return the min. value   
            //var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
            var fileUploadDetails = {};
            //var getchunk = fileContents.substring(startPosition,endPosition);
            
            fileUploadDetails['fileType'] = file.type;
            fileUploadDetails['fileName'] = file.name;
            fileUploadDetails['base64Data'] = encodeURIComponent(fileContents);
            fileUploadDetails['isfileUpload'] = true;
            component.set("v.fileUploadDetails",fileUploadDetails);
        });
        objFileReader.readAsDataURL(file);
    },
    uploadfileWithSaveCase : function(component,event) {
        
        var fileUploadDetails = component.get("v.fileUploadDetails"); 
        var isfileUpload =  (fileUploadDetails['isfileUpload'] ? true : false);
        var newExpense = component.get("v.newCase");
        var action = component.get("c.createCase");
        action.setParams({
            fileType : fileUploadDetails['fileType'],
            fileName : fileUploadDetails['fileName'],
            base64Data : fileUploadDetails['base64Data'],
            isfileUpload :isfileUpload,
            newCase : component.get("v.newCase")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(':::state:::'+state);
            if(state == "SUCCESS") {
                var caseId = response.getReturnValue();
                if(caseId){
                    window.open('/'+caseId,'_Self');
                }
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message :  response.getError()[0].message,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }         
        });
        $A.enqueueAction(action); 
    }
    
    
})