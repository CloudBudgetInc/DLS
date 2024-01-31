import { LightningElement , api } from 'lwc';
import approveOrRejectPDO from '@salesforce/apex/PDOCustomApproval_Ctrl.approveOrRejectPDO';
import { CloseActionScreenEvent } from 'lightning/actions';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PDOCustomApprovalCmp extends LightningElement 
{
    @api recordId;
    isApprove;
    approveOrReject;
    isDeleteEvents = false;
    comments;
    showSpinner = false;
    successMessage = '';

    handleComments(event){
        this.comments = event.target.value;
    }
    handleApproveClick(){
        this.isApprove = true;
        this.approveOrReject = 'Approve';
    }
    handleRejectClick(){
        this.isApprove = false;
        this.approveOrReject = 'Reject';
        const textAreaElement = this.template.querySelector('lightning-textarea');
        if(textAreaElement.value == undefined || textAreaElement.value == ''){
            textAreaElement.setCustomValidity('Rejection Comments is Required');
            textAreaElement.reportValidity();
        }
        else{
            textAreaElement.setCustomValidity('');
            textAreaElement.reportValidity();
            this.approvalProcessMethod();
        }
    }
    handleDeleteYes(){
        this.isDeleteEvents = true;
        this.approvalProcessMethod();
    }
    handleDeleteNo(){
        this.isDeleteEvents = false;
        this.approvalProcessMethod();
    }
    approvalProcessMethod(){
        this.showSpinner  = true;
        approveOrRejectPDO({recordId : this.recordId , approveOrReject : this.approveOrReject , isDeleteEvents : this.isDeleteEvents , comments : this.comments})
        .then(result=>{
            this.updateRecordView(this.recordId);
            this.successMessage = String(result);
            this.showSpinner = false;
            this.showToast('Success' , this.successMessage , 'success');
            this.dispatchEvent(new CloseActionScreenEvent());
        }).catch(error=>{
            this.showToast('Error' , error.body.message , 'error');
        })
    }
    updateRecordView(recordId) {
        updateRecord({fields: { Id: recordId }});
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