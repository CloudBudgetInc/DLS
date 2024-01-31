// This class is for Client's student test report usage
// Create by Sukanya sep 30 2016


global without sharing class StudentTestResult_ReportPage_Controller {

    
    public class languageDetails {
        
        public List<Language_Testing__c> languageList;
        public List<Language__c> languageRecs;
    
    }
    
    @RemoteAction
    public  static languageDetails getReportData(String userType) {
        Boolean instructorCommunity;
        List<Language_Testing__c> LanguageTestingList = new List<Language_Testing__c>();
        String userId = UserInfo.getUserId();
        
        List<User> userList = SObjectQueryService.SObjectQuery('User', new Set<Id>{userId}, '');
        //List<User> userList = [SELECT Id,Name,UserType,AccountId,ContactId,Instructor_Access__c,Partner_Access__c,Student_Access__c,Client_Access__c FROM User WHERE Id =:UserInfo.getUserId()]; 
        if(userList[0].Instructor_Access__c) {
            instructorCommunity = true;
        }else {
            instructorCommunity = false;
        }
        
        system.debug(':::::::::::userList::::::::'+userList);
       
       if(userType == 'INSTRUCTOR') {
           
            Set<Id> oppIds = new Set<Id>();
           //List<Contact_Assignments__c> conAssList = ContactAssignmentService.getContactAssignmentByContIds(new Set<Id>{userList[0].contactId}, new Set<String>{'Instructor'}, ' AND Status__c = \'Active\'', ', Candidate_Name__r.Name');
           List<Contact_Assignments__c> conAssList = ContactAssignmentService.getContactassignmentByprojectId(' WHERE RecordType.DeveloperName = \'Instructor\' AND Status__c = \'Active\' AND Candidate_Name__c ','Candidate_Name__r.Name',new Set<Id>{userList[0].contactId},'');
           system.debug(':::::::conAssList:::::::'+conAssList);
           for(Contact_Assignments__c conAss :conAssList /*[SELECT Id,Name,Candidate_Name__c,Candidate_Name__r.Name,Opportunity_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Candidate_Name__c = :userList[0].contactId]*/) {
               if(conAss.Opportunity_Name__c != null)
                   oppIds.add(conAss.Opportunity_Name__c);
           }
           
           system.debug(':::::::oppIds:::::::'+oppIds);
           
           
           String parentFields = ',Agency_Contact__r.Name,Account_Name__r.Name,Project_Task__r.Name,Testee__r.Name,Testee__r.Alias__c,Opportunity__r.AccountId,Opportunity__r.Account.Name,Opportunity__r.L_Goal_Score_Applicable__c,Opportunity__r.R_Goal_Score_Applicable__c,Opportunity__r.S_Goal_Score_Applicable__c,Opportunity__r.W_Goal_Score_Applicable__c,Target_Language_LU__r.Name';
           if(oppIds != NULL && oppIds.size() >0)
           LanguageTestingList = LanguageTestingService.getLanguageTestingsByOppIds(oppIds, ' AND Opportunity__c != null AND Opportunity__r.AccountId != null', parentFields);
           /*LanguageTestingList = [SELECT Id,Agency_Contact__c,Agency_Contact__r.Name,Account_Name__c,Account_Name__r.Name,Name,Date_Time_Scheduled__c,L_Goal__c,L_Score__c,L_Score_vs_Goal__c,Overall_Score_vs_Goal__c,
                                       Project_Task__c,Project_Task__r.Name,R_Goal__c,R_Score__c,R_Score_vs_Goal__c,S_Goal__c,Source__c,S_Score__c,S_Score_vs_Goal__c,
                                       Stage__c,Target_Language__c,Testee__c,Testee__r.Name,Testee__r.Alias__c,Tester__c,Tester_Payment__c,Test_Format__c,Test_Type__c,Total_Hours_Used__c,
                                       W_Goal__c,W_Score__c ,W_Score_vs_Goal__c,Opportunity__c,Opportunity__r.AccountId,Opportunity__r.Account.Name,
                                       Opportunity__r.L_Goal_Score_Applicable__c,Opportunity__r.R_Goal_Score_Applicable__c,Opportunity__r.S_Goal_Score_Applicable__c,Opportunity__r.W_Goal_Score_Applicable__c,
                                       Goal_SLRW__c,SLRW_Goal_Vs_Score__c,Score_SLRW__c,Target_Language_LU__c,Target_Language_LU__r.Name,(SELECT Id,Name FROM Attachments ORDER By createdDate DESC LIMIT 1)
                                 FROM Language_Testing__c 
                                 WHERE Opportunity__c != null AND Opportunity__r.AccountId != null AND Opportunity__c IN :oppIds];*/
          
       }else if(userType == 'CLIENT') {
       
            String parentFields = ',Agency_Contact__r.Name,Account_Name__r.Name,Project_Task__r.Name,Testee__r.Name,Testee__r.Alias__c,Opportunity__r.AccountId,Opportunity__r.Account.Name,Opportunity__r.L_Goal_Score_Applicable__c,Opportunity__r.R_Goal_Score_Applicable__c,Opportunity__r.S_Goal_Score_Applicable__c,Opportunity__r.W_Goal_Score_Applicable__c,Target_Language_LU__r.Name';
            LanguageTestingList = LanguageTestingService.getLanguageTestingsByOppAccIds(new Set<Id>{userList[0].AccountId}, ' AND Opportunity__c != null AND Opportunity__r.AccountId != null', parentFields);
           
            /*LanguageTestingList = [SELECT Id,Name,Agency_Contact__c,Agency_Contact__r.Name,Account_Name__c,Account_Name__r.Name,Date_Time_Scheduled__c,L_Goal__c,L_Score__c,L_Score_vs_Goal__c,Overall_Score_vs_Goal__c,
                                       Project_Task__c,Project_Task__r.Name,R_Goal__c,R_Score__c,R_Score_vs_Goal__c,S_Goal__c,Source__c,S_Score__c,S_Score_vs_Goal__c,
                                       Stage__c,Target_Language__c,Testee__c,Testee__r.Name,Testee__r.Alias__c,Tester__c,Tester_Payment__c,Test_Format__c,Test_Type__c,Total_Hours_Used__c,
                                       W_Goal__c,W_Score__c ,W_Score_vs_Goal__c,Opportunity__c,Opportunity__r.AccountId,Opportunity__r.Account.Name,
                                       Opportunity__r.L_Goal_Score_Applicable__c,Opportunity__r.R_Goal_Score_Applicable__c,Opportunity__r.S_Goal_Score_Applicable__c,Opportunity__r.W_Goal_Score_Applicable__c,
                                       Goal_SLRW__c,SLRW_Goal_Vs_Score__c,Score_SLRW__c,Target_Language_LU__c,Target_Language_LU__r.Name,(SELECT Id,Name FROM Attachments ORDER By createdDate DESC LIMIT 1)
                                 FROM Language_Testing__c 
                                 WHERE Opportunity__c != null AND Opportunity__r.AccountId != null AND Opportunity__r.AccountId = :userList[0].AccountId];*/
       }else {
           
           String parentFields = ',Agency_Contact__r.Name,Account_Name__r.Name,Project_Task__r.Name,Testee__r.Name,Testee__r.Alias__c,Opportunity__r.AccountId,Opportunity__r.Account.Name,Opportunity__r.L_Goal_Score_Applicable__c,Opportunity__r.R_Goal_Score_Applicable__c,Opportunity__r.S_Goal_Score_Applicable__c,Opportunity__r.W_Goal_Score_Applicable__c,Target_Language_LU__r.Name';
           LanguageTestingList = LanguageTestingService.getLanguageTestingsByOppIds(new Set<Id>{}, ' Opportunity__c != null AND Opportunity__r.AccountId != null', parentFields);
           
           /*LanguageTestingList = [SELECT Id,Name,Agency_Contact__c,Agency_Contact__r.Name,Account_Name__c,Account_Name__r.Name,Date_Time_Scheduled__c,L_Goal__c,L_Score__c,L_Score_vs_Goal__c,Overall_Score_vs_Goal__c,
                                       Project_Task__c,Project_Task__r.Name,R_Goal__c,R_Score__c,R_Score_vs_Goal__c,S_Goal__c,Source__c,S_Score__c,S_Score_vs_Goal__c,
                                       Stage__c,Target_Language__c,Testee__c,Testee__r.Name,Testee__r.Alias__c,Tester__c,Tester_Payment__c,Test_Format__c,Test_Type__c,Total_Hours_Used__c,
                                       W_Goal__c,W_Score__c ,W_Score_vs_Goal__c,Opportunity__c,Opportunity__r.AccountId,Opportunity__r.Account.Name,
                                       Opportunity__r.L_Goal_Score_Applicable__c,Opportunity__r.R_Goal_Score_Applicable__c,Opportunity__r.S_Goal_Score_Applicable__c,Opportunity__r.W_Goal_Score_Applicable__c,
                                       Goal_SLRW__c,SLRW_Goal_Vs_Score__c,Score_SLRW__c,Target_Language_LU__c,Target_Language_LU__r.Name,(SELECT Id,Name FROM Attachments ORDER By createdDate DESC LIMIT 1)
                                 FROM Language_Testing__c 
                                 WHERE Opportunity__c != null AND Opportunity__r.AccountId != null];*/
                                 
      }
      
       system.debug('::::::::LanguageTestingList:::::::'+LanguageTestingList);
       
       //List<Language__c> languageDetailsList = [SELECT Id,Name FROM Language__c];
       List<Language__c> languageDetailsList = LanguageService.getLanguages('');
       
       languageDetails lang = new languageDetails();
       lang.languageList = LanguageTestingList;
       lang.languageRecs = languageDetailsList;
       
       system.debug(':::::::lang::::::'+lang);
       
       return lang;
    }  
    
    // To get pickList values
    
    @RemoteAction   
   global static List<String> PicklistValues(String ObjectApi_name,String Field_name) { 

        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
          lstPickvals.add(a.getValue());//add the value  to our final list
       }
    
      return lstPickvals;
    } 

}