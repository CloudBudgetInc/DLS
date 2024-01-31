import { LightningElement , track , wire ,api} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import UserNameFld from '@salesforce/schema/User.Name';
import UserEmailFld from '@salesforce/schema/User.Email';
import sendMail from '@salesforce/apex/CustomActivityTimelineController.sendMail';
import getOrgWideEmailAddresses from '@salesforce/apex/CustomActivityTimelineController.getOrgWideEmailAddresses';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NewEmailCmp extends LightningElement 
{
    //@track toEmailIds = new Set();
    @api recordId;
    @track toEmailIds;
    @track ccEmailIds = [];
    @track bccEmailIds = [];
    @track richText = '';
    emailId;
    attachFileModal = false;
    insertTemplateModal = false;
    @track filesInsideModal = [];
    @track filesOutsideModal = [];
    @track base64Files = [];
    @track filesUploaded = [];
    userName;
    userEmail;
    @track fromValue;
    @track body = '';
    @track subject = '';
    showSpinner = false;

    showWarning = false;
    isSubjectOrBodyEmpty = false;
    fromEmailAddresses = [];
    loggedInUserValue;

    connectedCallback(){
        this.showSpinner = true;
        this.getOrgWideEmailAddress();
    }
    getOrgWideEmailAddress(){
        getOrgWideEmailAddresses({}).then(result=>{
            
            var jsonResult = JSON.parse(JSON.stringify(result));
            this.fromEmailAddresses = result;
            this.loggedInUserValue = this.fromEmailAddresses[0].value;
            this.showSpinner = false;
        })
    }

    @wire(getRecord, { recordId: Id, fields: [UserNameFld ,  UserEmailFld]})
    userDetails({error, data}) {
        if (data) {
            this.userName = data.fields.Name.value;
            this.userEmail = data.fields.Email.value;
            this.fromValue = this.userName + '<' + this.userEmail + '>';
        } else if (error) {
            console.log(error);
        }
    }
    handleFromChange(event){
        this.fromValue = event.target.value;
    }
    
    handleOpenFileModal(event){
        this.attachFileModal = true;
    }
    handleOpenInsertTemplate(){
        this.insertTemplateModal = true;
    }
    handleFileModalClose(event){
        this.attachFileModal = false;
    }
    handleFilesChange (event){
        console.log(' Files: ',event.target.files);
        if (event.target.files.length > 0) {
            for(var i=0; i< event.target.files.length; i++){
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    let base64 = 'base64,';
                    let content = reader.result.indexOf(base64) + base64.length;
                    let fileContents = reader.result.substring(content);
                    this.filesInsideModal.push({'FileName' : file.name, 'Base64Data': fileContents});
                };
                reader.readAsDataURL(file);
            }
        }

        console.log('filesInsideModal : ',this.filesInsideModal);
    }
    uploadIconclick(event){
        this.template.querySelector('input[data-id="fileId"]').click();
    }
    handleAddContact(event){
        if(event.detail.fieldApiName == 'To' && event.detail.selectedRecord != undefined){
            this.toEmailIds = event.detail.selectedRecord;
            console.log('this.toEmailIds: ',this.toEmailIds);
        }
        if(event.detail.fieldApiName == 'Cc'){
            this.ccEmailIds = (event.detail.selectedRecord);
            console.log('this.ccEmailIds: ',this.ccEmailIds);
        }
        if(event.detail.fieldApiName == 'Bcc'){
            this.bccEmailIds = (event.detail.selectedRecord);
            console.log('this.bccEmailIds: ',this.bccEmailIds);
        }
    }
    handleAttachFile(){
        if(this.filesInsideModal.length == 0){
            this.showToast('Error' , 'There are no files to attach' , 'error');
        }
        else{
            var flag;
            if(this.filesOutsideModal.length == 0){
                this.filesOutsideModal = JSON.parse(JSON.stringify(this.filesInsideModal));
            }
            else{
                for( let i = 0 ; i < this.filesInsideModal.length ; i++){
                    flag = 0;
                    for( let j = 0 ; j < this.filesOutsideModal.length ; j++){
                        if(this.filesOutsideModal[j].Base64Data  == this.filesInsideModal[i].Base64Data){
                            flag = 1;
                        }
                    }
                    if(flag != 1){
                        this.filesOutsideModal.push(this.filesInsideModal[i]);
                    }
                }
            }
            this.attachFileModal = false;
            this.filesInsideModal = [];
        }
    }
    handleInsertTemplateClose(event){
        this.insertTemplateModal = false;
    }
    handleBodyChange(event){
        //this.body = this.richText + event.target.value;
        console.log('Body : ',event.target.value);
        this.richText = event.target.value;
    }
    handleSubjectChange(event){
        this.subject = event.target.value;
    }
    handleInsertSelectedTemplate(event){
        console.log('RichText: ',event.detail.richText);
        //this.richText = event.detail.richText;
        this.body = event.detail.richText;
        this.insertTemplateModal = false;
        this.showWarning = true;
    }
    handleCancelInsert(){
        this.showWarning = false;
        this.body = '';
    }
    handleInsertTemplate(){
        this.richText = this.body;
        this.showWarning = false;
    }
    handleCancel(){
        this.dispatchEvent(new CustomEvent('closefields',{detail : 
            {
                action : 'Cancel',
                object : 'Email'
            }
        }));
    }
    handleMailSend(){
        if(this.toEmailIds.length == 0){
            this.showToast('Error' , 'To Address is Empty' , 'error');
        }
        else if((this.subject == '' || this.subject == undefined) && (this.richText == '' || this.richText == undefined)){
            this.isSubjectOrBodyEmpty = true;
        }
        else{
            this.sendMail();
        }
    }
    sendMail(){
        this.showSpinner = true;
        sendMail({fromAddress : this.fromValue, toAddressListMap : this.toEmailIds , ccAddressListMap : this.ccEmailIds, bccAddressListMap : this.bccEmailIds, subject : this.subject, body : this.richText, filesJSON : this.filesOutsideModal , whatId : this.recordId})
            .then(result=>{
                if(result == true){
                    this.showSpinner = false;
                    this.showToast('Success' , 'Email Sent Successfully' , 'success');
                    this.dispatchEvent(new CustomEvent('closefields',{detail : 
                        {
                            action : 'Save',
                            object : 'Email'
                        }
                    }));
                }
            }).catch(error=>{
                console.log('error: ',error);
                this.showToast('Error' , error.body.message , 'error');
            })
    }
    handleCancelWarning(){
        this.isSubjectOrBodyEmpty = false;
    }
    handleYesWarning(){
        this.isSubjectOrBodyEmpty = false;
        this.sendMail();
    }
    get isFilesEmpty(){
        if(this.filesInsideModal != undefined){
            return (this.filesInsideModal.length > 0);
        }
    }
    get isFilesEmptyOutsideModal(){
        if(this.filesOutsideModal != undefined){
            return (this.filesOutsideModal.length > 0);
        }
    }
    handleFilesRemoveInside(event){
        this.filesInsideModal.splice( event.target.dataset.id , 1);
    }
    handleFilesRemoveOutside(event){
        this.filesOutsideModal.splice( event.target.dataset.id , 1);
    }
    showToast(title , message , variant){
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant : variant
        });
        this.dispatchEvent(event);
    }
}