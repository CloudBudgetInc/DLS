/***********************************************
 - Batch class to update the Contact Assignment records status to Active based on Project Status
 - If the project is activated before actual start date
 - Batch size = 1
 - Created by NS on April 23 2018
************************************************/
global class CAStatusUpdation_FromProject_Batch implements Database.batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext info){  
    
        // Query modified By HL on Nov 19 2020
        // Work Item : W-006041 - Updating the Status for DODA Partner School Projects
        // Before this batch update the status of all recordtype of projects but now it updates only DODA projects
        //String proQry = 'SELECT Id,Name,Start_Date__c,End_Date__c,Oral_Exam_Date_Time__c,AcctSeed__Status__c,Project_Manager__c FROM AcctSeed__Project__c WHERE (Oral_Exam_Date_Time__c = TOMORROW OR Oral_Exam_Date_Time__c = TODAY OR Start_Date__c = TOMORROW) AND (AcctSeed__Status__c = \'Order\' OR AcctSeed__Status__c = \'Active\')';
        String proQry = 'SELECT Id,Name,Start_Date__c,AcctSeed__Status__c,Project_Manager__c FROM AcctSeed__Project__c WHERE Start_Date__c = TOMORROW AND AcctSeed__Status__c = \'Order\' AND RecordType.DeveloperName = \'DODA_Projects\' AND QB_Classification__c = \'OF0MTT0PS\'';
        return Database.getQueryLocator(proQry);
    }
    
    global void execute(Database.BatchableContext info, List<AcctSeed__Project__c> projectList){
    
        //Map<Id,String> proIdstatusMap = new Map<Id,String>();
        //List<Contact_Assignments__c> CAUpdateList = new List<Contact_Assignments__c>();
        List<AcctSeed__Project__c> proUpdateList = new List<AcctSeed__Project__c>();
        
        // To send Email to corresponding Project Manager regarding the status update - Added by NS on July 20 2018
        List<Messaging.SingleEmailMessage> EmailToProjectManagerList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate pmTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Status_update_remainder_to_PM'];
        
        for(AcctSeed__Project__c pro : projectList){
            /*
            if(pro.AcctSeed__Status__c == 'Active' && pro.Start_Date__c == System.Today().addDays(1)) {
                
                if(!proIdstatusMap.containsKey(pro.Id))
                    proIdstatusMap.put(pro.Id,pro.AcctSeed__Status__c);
            } 
            */
            if(pro.AcctSeed__Status__c == 'Order' && pro.Start_Date__c == System.Today().addDays(1)){
            
                proUpdateList.add(pro);
                if(pmTemplate != null) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(pro.Project_Manager__c);
                    mail.setWhatId(pro.Id);
                    mail.setTemplateID(pmTemplate.Id);
                    mail.setSaveAsActivity(false);
                    EmailToProjectManagerList.add(mail);
                }
            }
        }
        
        try {
            if(proUpdateList.size() > 0){
                Boolean isSuccess = OpportunityTrigger_Handler.projectStatusUpdate(proUpdateList);
                
                // Send Email to PM based on the project status update success
                if(isSuccess && EmailToProjectManagerList != null && EmailToProjectManagerList.size() > 0 ) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(EmailToProjectManagerList);
                }
            }
            /*
            if(proIdstatusMap.size() > 0){
                OpportunityTrigger_Handler.contactAssignmentStatusUpdate(proIdstatusMap);
            }
            */
        }catch(Exception e){
            ErrorHandler errHandler = new ErrorHandler();
            errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Project Status & Contact Assignment Status Updation');  
        }
    }
    
    global void finish(Database.BatchableContext info){ 
         
    }
}