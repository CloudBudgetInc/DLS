@isTest
private class sendFeedbackFormHelper_Test {
    @testSetup static void setup(){
        Test.startTest();
        List<Contact_Assignments__c> conAssignList = TestClassUtil.createTestContactAssignment();  
        Test.stopTest();   
    }
     
    // For sending Email
    private static testMethod void testMethod1() {
          
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, Candidate_Name__c FROM Contact_Assignments__c WHERE Project__c != null];
        Set<Id> proIds = new Set<Id>();
        
        if(conAssList.size() > 0) {
           
            for(Contact_Assignments__c ca : conAssList) {
                proIds.add(ca.Project__c);
            }
        
            if(proIds.size() > 0) {   
                List<AcctSeed__Project__c> proList = [SELECT Id, Name FROM AcctSeed__Project__c WHERE Id IN :proIds];
                
                if(proList.size() > 0) {
                    sendFeedbackFormHelper.sendEmail(proIds, proList);
                    sendFeedbackFormHelper.sendEmailAndUpdConAss(proIds,'weeklyGetfeedbackEmailTemplate', 'Weekly');
                }
            }
        }
    }
         
    // For sending Email When Project is Completed
    private static testMethod void testMethod2() {
          
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, Candidate_Name__c FROM Contact_Assignments__c WHERE Project__c != null];
        Set<Id> proIds = new Set<Id>();
        
        if(conAssList.size() > 0) {
            
            for(Contact_Assignments__c ca : conAssList) {
                proIds.add(ca.Project__c);
            }
        
            if(proIds.size() > 0) {   
                List<AcctSeed__Project__c> proList = [SELECT Id, Name FROM AcctSeed__Project__c WHERE Id IN :proIds];
                
                if(proList.size() > 0) {
                    sendFeedbackFormHelper.sendEmailForCompleted(proIds, proList);
                    sendFeedbackFormHelper.sendEmailAndUpdConAssFtr(proIds,'CourseEndGetfeedback', true);
                }
            }
        }
    } 
    
    //For Sending Monthly EMail
    private static testMethod void testMethod3() {
          
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, Candidate_Name__c FROM Contact_Assignments__c WHERE Project__c != null AND RecordType.DeveloperName = 'Student'];
        Set<Id> proIds = new Set<Id>();
        if(conAssList.size() > 0) {
            
            for(Contact_Assignments__c ca : conAssList) {
                proIds.add(ca.Project__c);
                ca.Status__c = 'Active';
            }
            update conAssList;
            
            if(proIds.size() > 0) {   
                List<AcctSeed__Project__c> proList = [SELECT Id, Name, Start_Date__c FROM AcctSeed__Project__c WHERE Id IN :proIds];
                List<RecordType> proRt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'DLI_W_LT_Projects' AND SobjectType = 'AcctSeed__Project__c'];
               
                if(proList.size() > 0 && proRt.size() > 0) {
                    
                    for(AcctSeed__Project__c pro : proList) {
                        pro.Start_Date__c = system.today().addDays(-45);
                        pro.RecordTypeId = proRt[0].Id;
                    }
                    update proList;
                    
                    List<System_Values__c> sysval = new List<System_Values__c> {
                        new System_Values__c(Name = 'Send FeedBack Monthly', Value__c = String.valueOf(System.today().addDays(-30)))
                    };
                    insert sysval;
                    
                    sendFeedbackFormHelper.sendMonthlyEmail(proIds, proList);
                    sendFeedbackFormHelper.sendEmailAndUpdConAss(proIds,'MonthlyGetfeedbackEmailTemplate', 'Monthly');
                }
            }
        }
    } 
    
    // For sending the Monthly Notification EMail
    private static testMethod void testMethod4() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Candidate_Name__r.Email, Candidate_Name__r.IsEmailBounced,Email__c, Do_not_send_feedback_One_time__c, Project__c, Project__r.Name, Project__r.Start_Date__c, Project__r.End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName != 'Testing_Projects'];
        Set<Id> proIds = new Set<Id>();
        
        if(conAssList.size() > 0) {
            
            for(Contact_Assignments__c ca : conAssList) {
                proIds.add(ca.Project__c);
                ca.Status__c = 'Active';
                ca.Weekly_Getfeedback_sent__c = null;
            }
            update conAssList;
            
            if(proIds.size() > 0) {   
                List<AcctSeed__Project__c> proList = [SELECT Id, Name, Start_Date__c, End_Date__c, AcctSeed__Status__c, RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id IN :proIds];
                List<RecordType> proRt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'DLI_W_LT_Projects' AND SobjectType = 'AcctSeed__Project__c'];

                if(proList.size() > 0 && proRt.size() > 0) {
                    for(AcctSeed__Project__c pro : proList) {
                        pro.Start_Date__c = system.today().addMonths(-2);
                        pro.AcctSeed__Status__c = 'Active';
                        pro.End_Date__c = system.today().addMonths(3);
                        pro.RecordTypeId = proRt[0].Id;
                    }
                    update proList;
                    
                    List<System_Values__c> sysval = new List<System_Values__c> {
                        new System_Values__c(Name = 'MonthlyFeedback', Value__c = String.valueOf(System.today())),
                        new System_Values__c(Name = 'GetFeedBack Notification Email', Value__c = 'test@notification.com')
                    };
                    insert sysval;
                    sendFeedbackFormHelper.sendNotificationEmailCheck(System.today().addDays(1), 'Monthly');
                }
            }
        }
   } 
   
   // For sending the Weekly Notification EMail
    private static testMethod void testMethod5() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Candidate_Name__r.Email, Candidate_Name__r.IsEmailBounced,Email__c, Do_not_send_feedback_One_time__c, Project__c, Project__r.Name, Project__r.Start_Date__c, Project__r.End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName != 'Testing_Projects'];
        Set<Id> proIds = new Set<Id>();
        
        if(conAssList.size() > 0) {
            
            for(Contact_Assignments__c ca : conAssList) {
                proIds.add(ca.Project__c);
                ca.Status__c = 'Active';
                ca.Weekly_Getfeedback_sent__c = null;
            }
            update conAssList;
            
            if(proIds.size() > 0) {   
                List<AcctSeed__Project__c> proList = [SELECT Id, Name, Start_Date__c, End_Date__c, AcctSeed__Status__c, RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id IN :proIds];
                List<RecordType> proRt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'DLI_W_LT_Projects' AND SobjectType = 'AcctSeed__Project__c'];

                if(proList.size() > 0 && proRt.size() > 0) {
                    for(AcctSeed__Project__c pro : proList) {
                        pro.Start_Date__c = system.today().addDays(-13);
                        pro.AcctSeed__Status__c = 'Active';
                        pro.RecordTypeId = proRt[0].Id;
                    }
                    update proList;
                    
                    List<System_Values__c> sysval = new List<System_Values__c> {
                        new System_Values__c(Name = 'TwoWeeksFeedback', Value__c = String.valueOf(System.today())),
                        new System_Values__c(Name = 'GetFeedBack Notification Email', Value__c = 'test@notification.com')
                    };
                    insert sysval;
 
                    for(AcctSeed__Project__c pro : proList) {
                        pro.Start_Date__c = system.today().addDays(-13);
                        pro.AcctSeed__Status__c = 'Active';
                        pro.End_Date__c = system.today().addMonths(3);
                        pro.RecordTypeId = proRt[0].Id;
                    }
                    sendFeedbackFormHelper.sendNotificationEmailCheck(System.today(), 'Weekly');
                }
            }
        }
    } 
   
    private static testMethod void sendInstructorCompletedFeedback_Test(){
        
        Contact newCon = new Contact(LastName = 'Test GF Con', Email = 'getfeedbackin@gmail.com');
        insert newCon;
        
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 1];
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> insCA = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Status__c = 'Active', Project__c = projList[0].Id, Candidate_Name__c = newCon.Id,Start_Date__c = system.today().addDays(-5), End_Date__c = System.today().addDays(90), Assignment_Position__c = 'Instructor')
        };
        insert insCA;
        
        Test.startTest();
        
            Contact_Assignments__History h = new Contact_Assignments__History(ParentId = insCA[0].Id, Field='Status__c');
            insert h;
            
            List<Contact_Assignments__c> conAssignRec = [SELECT Id, Status__c, End_Date__c FROM Contact_Assignments__c WHERE Id = :insCA[0].Id];
            conAssignRec[0].Status__c = 'Ended';
            conAssignRec[0].End_Date__c = Date.Today();
            update conAssignRec[0];
            
        Test.stopTest();
    }
}