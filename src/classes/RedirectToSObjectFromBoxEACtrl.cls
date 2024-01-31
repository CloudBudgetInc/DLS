public class RedirectToSObjectFromBoxEACtrl {
    public String parentId{get; set;}
    public String sObjectId{get; set;}
    public Boolean showErrorMessage{get; set;}
    
    public RedirectToSObjectFromBoxEACtrl(){
        
        parentId = ApexPages.currentPage().getParameters().get('parentId'); 
        List<box__FRUP__c> frupRec = [SELECT Id, box__Record_ID__c, box__Folder_ID__c FROM box__FRUP__c WHERE box__Folder_ID__c = :parentId];
        if(frupRec.size() > 0){
            showErrorMessage = false;
            sObjectId = frupRec[0].box__Record_ID__c;
        }else{
            showErrorMessage = true;
        }        
    }    
}