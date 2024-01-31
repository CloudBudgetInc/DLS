import { LightningElement , track , api} from 'lwc';
import uploadFiles from '@salesforce/apex/LessonPlanBoxUtil.uploadFile';
import createFolder from '@salesforce/apex/LessonPlanBoxUtil.createFolder';
import uploadFilesAsync from '@salesforce/apex/LessonPlanBoxUtil.uploadFilesAsync';

const MAX_FILE_SIZE = 1572864;

export default class LessonPlanFileUploadCmp extends LightningElement {

    @track filesDetails = [];
    @track toastMsg = {show: false};
    lessonPlanRecord;
    showSpinner = false;
    boxSharedId  = '';
    folderId = '';
    boxSharedURL = '';
    showDeleteModal = false;
    
    @api 
    get lessonPlan(){
        return JSON.stringify(this.lessonPlanRecord);
    }

    set lessonPlan(value){
        this.lessonPlanRecord = JSON.parse(value);
        if(this.lessonPlanRecord.Box_Folder_Id__c != undefined){
            let temp = JSON.parse(value);
            this.folderId = temp.Box_Folder_Id__c;
            this.boxSharedId = this.splitUrl(temp.Box_File_Shared_URL__c);
        }
    }
    
    splitUrl(url){
        var split = url.split('/');
        return split[(split.length - 1)];
    }

    handleFilesChange(event){
        var selectedFilesSize = 0;
        for(let i=0; i< event.target.files.length; i++){
            selectedFilesSize += event.target.files[i].size;
        }
        if(selectedFilesSize > MAX_FILE_SIZE){
            this.showToast('Size of files should not exceed 1.5 MB' , 'Error');   
        }
        else {
            for(let i=0; i< event.target.files.length; i++){
                const file = event.target.files[i];
                let reader = new FileReader();
                let flag = 0;
                let totalFilesSize = 0;
                if(file.size > MAX_FILE_SIZE){
                    this.showToast('Size of files should not exceed 1.5 MB' , 'Error');
                    flag = 2;
                }
                reader.onload = () => {
                        let base64 = reader.result.split(',')[1];
                    for( let j = 0 ; j < this.filesDetails.length ; j++){
                        totalFilesSize+=this.filesDetails[j].size;
                        if(this.filesDetails[j].fileName == file.name){
                            flag = 1;
                            this.showToast('File with the same name already exists . Please choose another file' , 'Error');
                        }
                    }
                    if(totalFilesSize +  file.size > MAX_FILE_SIZE){
                        this.showToast('Size of files should not exceed 1.5 MB' , 'Error');
                        flag = 2;
                    }
                    if(flag == 0){
                        this.filesDetails.push({'fileName': file.name,
                        'base64': base64,
                        'size' : file.size});   
                        }
                    
                };
                reader.readAsDataURL(file);
            }
        }
    }
    handleUpload(){
        if(this.filesDetails == undefined || this.filesDetails.length== 0){
            this.showToast('There are no files to upload' , 'Error');
        }
        else{
            this.dispatchEvent(new CustomEvent('showspinner'));
            if(this.lessonPlanRecord.Box_Folder_Id__c == undefined && this.boxSharedId == ''){
                this.folderCreation(this.lessonPlanRecord.Name);
            }
            else{
                this.fileUpload(this.folderId);
            }
        }
    }
    folderCreation(folderName){
        createFolder({folderName : folderName , lessonPlanRecordId : this.lessonPlanRecord.Id }).then(result=>{
            console.log('result: ',result);
            var boxWrapper = JSON.parse(result);
            this.boxSharedId = this.splitUrl(boxWrapper.boxSharedURL);
            this.folderId = boxWrapper.boxFolderId;
            this.fileUpload(this.folderId);
        }).catch(error=>{
            console.log('error: ',error);
            if(error.body.message == 'Error while creating folder 409'){
                this.filesDetails = [];
                this.showToast('Folder already exists or another operation is in progress' , 'Error');
                this.dispatchEvent(new CustomEvent('refresh'));
            }
            else{
                this.filesDetails = [];
                this.showToast(error.body.message , 'Error');
                this.dispatchEvent(new CustomEvent('hidespinner'));
            }
        })
    }
    fileUpload(folderId){
        if(this.filesDetails.length > 2){
            uploadFilesAsync({ filesDetails : JSON.stringify(this.filesDetails) , folderId : folderId }).then(result=>{
                this.filesDetails = [];
                this.showToast('Files are being uploaded' , 'Success');
                this.dispatchEvent(new CustomEvent('refresh',{detail : 
                    {
                        sharedLinkId : this.boxSharedId
                    },
                }));
            }).catch(error=>{
                this.filesDetails = [];
                this.showToast(error.body.message , 'Error');
                this.dispatchEvent(new CustomEvent('hidespinner'));
            });
        }
        else{
            for( let i = 0 ; i < this.filesDetails.length ; i++){
                uploadFiles({base64 : this.filesDetails[i].base64 , fileName : this.filesDetails[i].fileName , folderId : folderId}).then(result=>{
                    console.log('result : ',result);
                    this.filesDetails = [];
                    this.showToast('File(s) Uploaded Successfully' , 'Success');
                    this.dispatchEvent(new CustomEvent('refresh',{detail : 
                        {
                            sharedLinkId : this.boxSharedId
                        },
                    }));
                }).catch(error=>{
                    console.log('error: ',error);
                    if(error.body.message == 'Error while creating folder 409'){
                        this.filesDetails = [];
                        this.showToast('File already exists or there is no space' , 'Error');
                        this.dispatchEvent(new CustomEvent('hidespinner'));
                    }
                    else{
                        this.filesDetails = [];
                        this.showToast(error.body.message , 'Error');
                        this.dispatchEvent(new CustomEvent('hidespinner'));
                    }
                })
            }
        }
    }
    handleFilesRemoveInside(event){
        this.filesDetails.splice( event.target.dataset.id , 1);
    }
    get isFilesEmpty(){
        if(this.filesDetails != undefined && this.filesDetails.length > 0){
            return true;
        }
    }
    showToast(message, header) {
        this.toastMsg.show = true;
        this.toastMsg.message = message;
        this.toastMsg.header = header;
    }
    closeToastMsg(){
        this.toastMsg.show = false;
    }
    handleDeleteModal(){
       this.showDeleteModal = true;
    }
    handleShowSpinner(){
        this.dispatchEvent(new CustomEvent('showspinner'));
    }
    handleHideSpinner(){
        this.dispatchEvent(new CustomEvent('hidespinner'));
    }
    handleCloseDeleteModal(){
        this.showDeleteModal = false;
    }
    handleRefresh(){
        this.showToast('File(s) Deleted Successfully' , 'Success');
        this.dispatchEvent(new CustomEvent('refresh'));
    }
    get showDeleteButton(){
        if(this.boxSharedId != ''){
            return true;
        }
        else if(this.boxSharedId == ''){
            return false;
        }
    }
}