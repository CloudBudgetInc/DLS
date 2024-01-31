/**********************************************************************
    Created by Sukanya on Feb 28, 2017: Service class used for Qualification object     
***********************************************************************/
public with sharing class QualificationService {
    
     /**********************************************************************
        Created by Sukanya on Feb 28, 2017: This method return list of Qualification 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        return - list of Qualification records
    ***********************************************************************/ 
    
    public static List<Qualification__c> getQualificationrecords(String filterQry, String parentFields) {
    
        List<Qualification__c> qualificationList =  new List<Qualification__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Qualification__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM Qualification__c';
        
        if(parentFields != null && parentFields != ''){
            defalutQry = 'SELECT '+ fieldName +parentFields + ' FROM Qualification__c';
        }
       
        System.debug(':QualificationService:;;:defalutQry:::::::;;::'+defalutQry);
        qualificationList =  Database.query(defalutQry);   
        return qualificationList;
    }
    
     /**********************************************************************
        Created by Sukanya on Feb 28, 2017: This method return newly created list of Qualification records 
        @materialRequestList - List of materialRequest records
        return - list of materialRequest records
    ***********************************************************************/ 
    public static List<Qualification__c> qualificationCreation(List<Qualification__c> qualificationList) {
    
        if(qualificationList != null && qualificationList.size() > 0){
            insert qualificationList;            
        }
        return qualificationList;    
    } 
}