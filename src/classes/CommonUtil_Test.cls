@isTest
public class CommonUtil_Test{
    
    private static testMethod void testgetPickListValues(){
        List<String> fieldAPINames = new List<String>{'Ask_simple_questions__c'};
        CommonUtil.getPickListValues('Assessment_Report__c', fieldAPINames );
    }
    
    private static testMethod void testgetAllPickListValuesByObject(){

        CommonUtil.getAllPickListValuesByObject('Assessment_Report__c');
    }
    
    private static testMethod void testgetAllPicklistValuesByObjectAndRecordTypeId(){
        Id recordTypeId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByName().get('DLI-W Progress').getRecordTypeId();
        try{
            CommonUtil.getAllPicklistValuesByObjectAndRecordTypeId('Assessment_Report__c',recordTypeId);
        }catch(Exception exe){
            
        }        
    }
    
    private static testMethod void fetchUserIdsOfPublicGroup(){
        
        Set<Id> groupIds = CommonUtil.fetchUserIdsOfPublicGroup('Registrar');
    }
}