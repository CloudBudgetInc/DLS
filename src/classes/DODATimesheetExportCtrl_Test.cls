@isTest
private class DODATimesheetExportCtrl_Test{

    @testSetup static void setupMethod(){
    
        List<AcctSeed__Time_Card_Day__c> days = TestClassUtil.createTestTimeCardDay();
        Test.startTest();
            List<Events__c> events = TestClassUtil.createTestEvent();
        Test.stopTest();
    }
        
    private static testMethod void myTest1(){
    
        Account testAccount = new Account();
        testAccount.Name='Test Account' ;
        insert testAccount;
        
        ApexPages.currentPage().getParameters().put('accountId', String.valueOf(testAccount.Id));
        ApexPages.currentPage().getParameters().put('dt1', String.valueOf(Date.Today()));
        ApexPages.currentPage().getParameters().put('dt2', String.valueOf(Date.Today()+1));
                
        List<Events__c> events = [SELECT Id FROM Events__c LIMIT 2];
        List<Contact> students = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Student'];
        
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
    
        Contact c = new Contact(LastName  = 'My Test Con', RecordTypeId = stdRTId);
        insert c;
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id FROM AcctSeed__Time_Card__c LIMIT 1];
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time'];
              
        List<AcctSeed__Project__c> projects = [SELECT Id,AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :projTask[0].AcctSeed__Project__c];
        projects[0].AcctSeed__Account__c = testAccount.Id;
        update projects[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = projTask[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
         
        Test.startTest();
           
            List<AcctSeed__Time_Card_Day__c> dayRecs = new List<AcctSeed__Time_Card_Day__c>{
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Status__c = 'Approved'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today()+1,Status__c = 'Approved')
            };
            insert dayRecs;
            
            List<AcctSeed__Time_Card_Day__c> days = [SELECT Id, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c FROM AcctSeed__Time_Card_Day__c WHERE Id IN : dayRecs];
            
            List<Attendance__c> attendanceRecs = new List<Attendance__c>{
                new Attendance__c(Event__c = events[0].Id, Student__c = students[0].Id, Time_Card_Day__c = days[0].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = days[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c, Comments__c = 'Test Comments'),
                new Attendance__c(Event__c = events[0].Id, Student__c = c.Id, Time_Card_Day__c = days[0].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = days[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c, Comments__c = 'Test Comments')
            };
            insert attendanceRecs;
        
            DODATimesheetExportCtrl tsExport = new DODATimesheetExportCtrl();
            
        Test.stopTest();
        
    }
    
    private static testMethod void myTest2(){
    
        Account testAccount = new Account();
        testAccount.Name='Test Account' ;
        insert testAccount;
        
        ApexPages.currentPage().getParameters().put('accountId', String.valueOf(testAccount.Id));
        ApexPages.currentPage().getParameters().put('dt1', String.valueOf(Date.Today()));
        ApexPages.currentPage().getParameters().put('dt2', String.valueOf(Date.Today()+1));
                
        List<Events__c> events = [SELECT Id FROM Events__c LIMIT 2];
        List<Contact> students = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Student'];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id FROM AcctSeed__Time_Card__c LIMIT 1];
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 1];
        projTask[0].Project_Task_Type__c = 'Preparation time';
        update projTask[0];
        
        List<AcctSeed__Project__c> projects = [SELECT Id,AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :projTask[0].AcctSeed__Project__c];
        projects[0].AcctSeed__Account__c = testAccount.Id;
        update projects[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = projTask[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
         
        Test.startTest();
           
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Status__c = 'Approved');
            insert day;
            
            List<AcctSeed__Time_Card_Day__c> days = [SELECT Id, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c FROM AcctSeed__Time_Card_Day__c WHERE Id = :day.Id];
            
            List<Attendance__c> attendanceRecs = new List<Attendance__c>{
                new Attendance__c(Event__c = events[0].Id, Student__c = students[0].Id, Time_Card_Day__c = days[0].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = days[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c, Comments__c = 'Test Comments'),
                new Attendance__c(Event__c = events[0].Id, Student__c = students[0].Id, Time_Card_Day__c = days[0].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = days[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c, Comments__c = 'Test Comments')
            };
            insert attendanceRecs;
        
            DODATimesheetExportCtrl tsExport = new DODATimesheetExportCtrl();
            
        Test.stopTest();
        
    }
    
    private static testMethod void myTest3(){
    
        Account testAccount = new Account();
        testAccount.Name='Test Account' ;
        insert testAccount;
        
        ApexPages.currentPage().getParameters().put('accountId', String.valueOf(testAccount.Id));
        ApexPages.currentPage().getParameters().put('dt1', String.valueOf(Date.Today()));
        ApexPages.currentPage().getParameters().put('dt2', String.valueOf(Date.Today()+1));
        
        DODATimesheetExportCtrl tsExport = new DODATimesheetExportCtrl();
        DODATimesheetExportCtrl.getInitialDate();
    }
    
    private static testMethod void myTest4(){
    
        Account testAccount = new Account();
        testAccount.Name='Test Account' ;
        insert testAccount;
        
        ApexPages.currentPage().getParameters().put('accountId', String.valueOf(testAccount.Id));
        ApexPages.currentPage().getParameters().put('dt1', String.valueOf(Date.Today()));
        ApexPages.currentPage().getParameters().put('dt2', String.valueOf(Date.Today()+1));
                
        List<Events__c> events = [SELECT Id FROM Events__c LIMIT 2];
        List<Contact> students = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Student'];
        
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
    
        Contact c = new Contact(LastName  = 'My Test Con', RecordTypeId = stdRTId);
        insert c;
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id FROM AcctSeed__Time_Card__c LIMIT 1];
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time'];
              
        List<AcctSeed__Project__c> projects = [SELECT Id,AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :projTask[0].AcctSeed__Project__c];
        projects[0].AcctSeed__Account__c = testAccount.Id;
        update projects[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = projTask[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
         
        Test.startTest();
           
            List<AcctSeed__Time_Card_Day__c> dayRecs = new List<AcctSeed__Time_Card_Day__c>{
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Status__c = 'Approved'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today()+1,Status__c = 'Approved')
            };
            insert dayRecs;
            
            List<AcctSeed__Time_Card_Day__c> days = [SELECT Id, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c FROM AcctSeed__Time_Card_Day__c WHERE Id IN : dayRecs];
            
            List<Attendance__c> attendanceRecs = new List<Attendance__c>{
                new Attendance__c(Event__c = events[0].Id, Student__c = students[0].Id, Time_Card_Day__c = days[0].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = days[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c, Comments__c = 'Test Comments'),
                new Attendance__c(Event__c = events[0].Id, Student__c = c.Id, Time_Card_Day__c = days[1].Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = days[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c, Comments__c = 'Test Comments')
            };
            insert attendanceRecs;
        
            DODATimesheetExportCtrl tsExport = new DODATimesheetExportCtrl();
            
        Test.stopTest();
        
    }
}