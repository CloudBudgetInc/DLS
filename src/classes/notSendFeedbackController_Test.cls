/* Developed by Shalini on June 7 2017 for "notSendFeedbackController" */

@isTest
private class notSendFeedbackController_Test {
    @testSetup static void setup() {
        List<Contact_Assignments__c> getOppt = TestClassUtil.createTestContactAssignment();
    }
    static testmethod void test1() {
        Test.startTest();
            String monthlyDate = '2020-06-21', monthlyDate1 = '2017-06-30';
            String weeklyDate = '2020-06-07', weeklyDate1 = '2017-06-09';
          
            List<AcctSeed__Project__c> proList = [SELECT Id, Name, AcctSeed__Status__c, Start_Date__c, End_Date__c, RecordTypeId FROM AcctSeed__Project__c LIMIT 4];
            if(proList != Null && proList.size() > 0) {
                proList[0].Start_Date__c = Date.ValueOf(monthlyDate1).addDays(-20);
                proList[0].End_Date__c = Date.ValueOf(monthlyDate).addMonths(4);
                proList[0]. AcctSeed__Status__c = 'Active';
                proList[1].Start_Date__c = Date.ValueOf(weeklyDate).addDays(-13);
            }
            update proList;
           
            List<Contact_Assignments__c> assignments = [SELECT Id,Name,Candidate_Name__c,Opportunity_Name__c,Status__c,Weekly_Getfeedback_sent__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' LIMIT 3];
            List<Contact> contacts = [SELECT Id,Name FROM Contact LIMIT 1];
            assignments[0].Weekly_Getfeedback_sent__c = Date.ValueOf(monthlyDate1).addMonths(1).toStartOfMonth().addDays(-14);
            assignments[0].Project__c = proList[0].Id;
            assignments[1].Project__c = proList[1].Id;
            notSendFeedbackController.updateCAs(JSON.serialize(assignments),JSON.serialize(contacts));

            List<System_Values__c> sysVal = new List<System_Values__c>{
                                                new System_Values__c(Name = 'TwoWeeksFeedback', Value__c = 'https://www.getfeedback.com/r/sqybzLAc/672cbbe6-78bb-4380-b239-70ad7c008a3e'),
                                                new System_Values__c(Name = 'MonthlyFeedback', Value__c = 'https://www.getfeedback.com/r/PW3oCJut/7a10c4c7-cb79-4b08-a535-83f8d411f312'),
                                                new System_Values__c(Name = 'Send FeedBack Monthly', Value__c = '2018-05-01')
                                            };
            insert sysval;
            
            notSendFeedbackController.studentInfo stuInfo = new notSendFeedbackController.studentInfo();
            
            stuInfo = notSendFeedbackController.getStudents('2 Week',weeklyDate);   
            
            // The day of the date is an sunday , so Notification email will send to staff on date (weeklyDate)
            System.assertEquals(Date.valueOf(weeklyDate).addDays(-2), stuInfo.reviewdate); 
           
            stuInfo = notSendFeedbackController.getStudents('Monthly',monthlyDate);  
            
            // The day of the date an sunday , so Notification email will send to staff on date (monthlyDate)
            System.assertEquals(Date.valueOf(monthlyDate).addDays(9), stuInfo.reviewdate);
           
            stuInfo = notSendFeedbackController.getStudents('2 Week',weeklyDate1);  
            
            // The day of the date is not an sunday or saturday, so Notification email will send to staff on date (weeklyDate1)
            System.assertEquals(Date.valueOf(weeklyDate1), stuInfo.reviewdate);
           
            stuInfo = notSendFeedbackController.getStudents('Monthly',monthlyDate1); 
            
            // The day of the date is not an sunday or saturday, so Notification email will send to staff on date (monthlyDate1)
            System.assertEquals(Date.valueOf(monthlyDate1), stuInfo.reviewdate); 
                     
        Test.stopTest(); 
    }
}