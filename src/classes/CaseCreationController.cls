/**************************************************
used in the CaseCreationForm Lighnting Component
@newCase - case record for insertion from the Lighnting Component
***************************************************/
public Class CaseCreationController {
    
     //For invoking Case Assignment Rule
    public static Boolean isInvokeCaseAssign = FALSE;
    
    public class PicklistWrapper {
        public String label;
        public String value;
    }
    
    public class PicklistValues {
        public List<PicklistWrapper> typeValues;
        public List<PicklistWrapper> priorityValues;
    }
    
    @AuraEnabled
    public Static String getPickListValues(){
        List<String> typeFieldValues = ScheduleCmpLightningController.getPickListValues('Case','Type');
        List<String> priorityFieldValues = ScheduleCmpLightningController.getPickListValues('Case','Priority');
        List<PicklistWrapper> typeValues = new List<PicklistWrapper>();
        List<PicklistWrapper> priorityValues = new List<PicklistWrapper>();
        
        for(String str : typeFieldValues){
            PicklistWrapper wrap = new PicklistWrapper();
            wrap.label = str;
            wrap.value = str;
            
            typeValues.add(wrap);
        }
        
        for(String str : priorityFieldValues){
            PicklistWrapper wrap = new PicklistWrapper();
            wrap.label = str;
            wrap.value = str;
            
            priorityValues.add(wrap);
        }
        
        PicklistValues pickValue = new PicklistValues();
        pickValue.typeValues = typeValues;
        pickValue.priorityValues = priorityValues;
        
        return JSON.serialize(pickValue);
    }
    @AuraEnabled
    public Static String createCase(String fileType,String fileName,String base64Data,Boolean isfileUpload ,Case newCase) {
        
        System.debug('CONTROLLER=====');
        if(newCase != null) {
            
            isInvokeCaseAssign = TRUE;
            newCase.Environment__c = 'Internal';
            newCase.Origin = 'Web';
            
            Set<Id> userIds  = new Set<Id>{UserInfo.getUserId()};
                System.debug('UserIds====='+userIds);
            
            Map<Id, Id> userIdConId = PlannedDaysOffHandler.getUserRelatedContacts(userIds);
            if(userIdConId.containsKey(UserInfo.getUserId())) {
                
                newCase.ContactId = userIdConId.get(UserInfo.getUserId());
                System.debug('newCase.ContactId=='+newCase.ContactId);
            }
            
            /**Start of Code to initiate Case Assignment Rule
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            newCase.setOptions(dmo);
            End of Code to initiate Case Assignment Rule **/
            
           try {
                Insert newCase;
                
                if(isfileUpload){
                    base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
                    Attachment attach = new Attachment();
                    attach.parentId  = newcase.Id;
                    attach.Body = EncodingUtil.base64Decode(base64Data);
                    attach.Name = fileName;
                    attach.ContentType = fileType;
                    Insert attach;
                }
                
                return newcase.Id;
            }catch(Exception e){
                system.debug('::::::exception:::::::::'+e.getMessage());
                throw new AuraHandledException(e.getMessage());
            }
            
        }
        return null;
    }
}