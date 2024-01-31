@isTest
private class HolidayTCDCreationToInstScheduler_Test{
        
    @testSetup static void setUpMethod(){
    
        Test.StartTest();
            List<AcctSeed__Time_Card_Day__c>  tcd = TestClassUtil.createTestTimeCardDay();                
            List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment(); 
            
            List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='ProjectRT_HolidayTCDCreation', Value__c = 'FSI_Projects')};
            Insert sysVal;
            
            List<MTT_Location__c> location = TestClassUtil.createTestLocations();
            
            Date today = system.today();       
            Datetime dtime = datetime.newInstance(today.toStartofWeek(), Time.newInstance(0,0,0,0));
            String startOfWeek = dtime.format('EEE');  
            Date startDate;
            Date endDate;
                
            if(today.toStartofWeek() == today) {
                startDate = today.addDays(-1).toStartofWeek().addDays((startOfWeek == 'Sat') ? 2 : 1);
            }else {
                startDate = today.toStartofWeek().addDays((startOfWeek == 'Sat') ? 2 : 1);
            }   
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
               BusinessHours defaultBH = [Select Id From BusinessHours Where IsDefault = True];
                Holiday hol = new Holiday(Name = 'Test holiday', Activitydate = startDate);
                insert hol;
            }
            
        Test.StopTest();
        
        List<Events__c> events = TestClassUtil.createTestEvent();
        List<AcctSeed__Cost_Rates__c> costRates = TestClassUtil.createTestCostRates();
    }
    
    private static testMethod void myTest(){
        
        Account a = new Account(Name = 'PGLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> insCon = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName = 'Candidate' AND NAME LIKE '%Test%' LIMIT 2];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        User user = new User(alias = 'test123', email='test123@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p, country='United States',IsActive =true,
        ContactId = insCon[0].Id,
        timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        
        Id fsiRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('FSI_Projects').getRecordTypeId();
        Id lTPTRTId = Schema.SObjectType.AcctSeed__Project_Task__c .getRecordTypeInfosByDeveloperName().get('Language_Training').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date today = system.today();       
        Datetime dtime = datetime.newInstance(today.toStartofWeek(), Time.newInstance(0,0,0,0));
        String startOfWeek = dtime.format('EEE');  
        Date startDate;
        Date endDate;
            
        if(today.toStartofWeek() == today) {
            startDate = today.addDays(-1).toStartofWeek().addDays((startOfWeek == 'Sat') ? 2 : 1);
        }else {
            startDate = today.toStartofWeek().addDays((startOfWeek == 'Sat') ? 2 : 1);
        }        
        endDate = startDate.addDays(6); 
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Training_Location__c = loc.Id, AcctSeed__Account__c = a.Id, Name = 'Test Project 1',AcctSeed__Status__c = 'Active',RecordTypeId = fsiRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = startDate, End_Date__c = endDate);
        insert proj;
        
        AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Payroll_Item__c = 'RNB', RecordTypeId = ltPTRTId, Name = 'Fringe-Holiday',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Fringe', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 600);
        insert projTask;
        
        List<Schedule__c> schList = new List<Schedule__c> {
            new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c = endDate, Start_Date__c = startDate,Status__c= 'Active', Schedule_Type__c = 'Regular', Instructor__c = insCon[0].Id)
            
        };
        insert schList;
            
        Test.startTest(); 
                                   
            Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = proj.Id, Candidate_Name__c = insCon[0].Id, Start_Date__c = startDate, End_Date__c = endDate, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Instructor', Paper_Timesheet__c = false)
            };
            insert conAssignRecs;
            
            HolidayTCDCreationToInstScheduler_Batch  sch2 = new HolidayTCDCreationToInstScheduler_Batch(); 
            String sch = '0 19 9 22 3 ?'; 
            system.schedule('Holiday TCD Creation To Instructor Scheduler', sch, sch2); 

        Test.stopTest();
    }
}