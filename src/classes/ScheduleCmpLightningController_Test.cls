@isTest
private class ScheduleCmpLightningController_Test {
    
    @testsetup static void setup() {
    
        Test.startTest();
            List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment(); 
        Test.stopTest();  
        List<Schedule__c> schlist = TestClassUtil.createTestSchedule();        
    }
    
    private static testMethod void testMethod1() {
        
        List<AcctSeed__Project__c> proList = [SELECT Id,Name,DLS_Class__c,AcctSeed__Opportunity__c,RecordType.DeveloperName FROM AcctSeed__Project__c LIMIT 1];
        List<Opportunity> oppRec = [SELECT Id,DLS_Class__c,RecordType.DeveloperName FROM Opportunity LIMIT 1];
        ScheduleDomain.ParTypeSchRecWrapper schwrapper = new ScheduleDomain.ParTypeSchRecWrapper();  
        ScheduleCmpLightningController.getParentType(proList [0].Id,'All');
        
        Test.startTest();
            ScheduleCmpLightningController.getParentType(proList [0].Id,'Active');
            ScheduleCmpLightningController.getParentType(proList [0].AcctSeed__Opportunity__c,'Active');
            schwrapper  = ScheduleCmpLightningController.getParentType(oppRec[0].Id,'Active');
            System.assertEquals(schwrapper.parentType,'Opportunity');
        Test.stopTest();
    }
    
    private static testMethod void testMethod2() {
    
        List<AcctSeed__Project__c> proList = [SELECT Id,Name,DLS_Class__c,RecordType.DeveloperName FROM AcctSeed__Project__c  LIMIT 1];  
        List<Schedule__c> schlist = [SELECT Id,Name,Project__c,Project_Task__c,Opportunity__c, Total_Hours__c,End_Date__c,Start_Date__c,Status__c FROM Schedule__c LIMIT 2];
        string schmsg =  ScheduleCmpLightningController.scheduleActivate(schlist[0].Id);
        List<Schedule__c> schlst = [SELECT Id,Name,Project__c,Project_Task__c,Opportunity__c, Total_Hours__c,End_Date__c,Start_Date__c,Status__c FROM Schedule__c WHERE Id =: schlist[0].Id LIMIT 1];
       
        ScheduleCmpLightningController.getActiveAssignments(proList[0].Id,'Instructor');
        List<Contact_Assignments__c> caLst = ScheduleCmpLightningController.getActiveAssignments(proList[0].Id,'Student');
        System.assertEquals(schlst[0].Status__c,'Active');
        
        Test.startTest();
        
            schlist[1].Status__c = 'Drafted';
            update schlist;
            
            ScheduleCmpLightningController.deleteSchedule(JSON.serialize(schlist[0]),'Cancel');
            ScheduleCmpLightningController.deleteSchedule(JSON.serialize(schlist[1]),'Delete');
            ScheduleCmpLightningController.getLookupRecords('Test','Contact','Name','',new List<Id>{});
            System.assertEquals(schlist[0].Id,schlst[0].Id);
           
            Schedule__c sclst = ScheduleCmpLightningController.assignInstructorRec(schlist[0]);
            System.assertEquals(sclst.Status__c,'Drafted');
            ScheduleCmpLightningController.assignRoomRec(schlist[0]);
        Test.stopTest();
    }
   
    // - Method to check Hrs / Days related Product / Project Task exist
    private static testMethod void testMethod3() {
        
        List<AcctSeed__Project__c> proList = [SELECT Id,Name,DLS_Class__c,RecordType.DeveloperName FROM AcctSeed__Project__c WHERE RecordType.DeveloperName IN ('Admin_Projects','Language_Training_Projects')]; 
        List<Opportunity> oppRec = [SELECT Id,DLS_Class__c,RecordType.DeveloperName FROM Opportunity LIMIT 3];
        ScheduleCmpLightningController.checkProductOrPTExist(proList[0].Id,'AcctSeed__Project__c');
        ScheduleCmpLightningController.checkProductOrPTExist(proList[2].Id,'AcctSeed__Project__c');
        List<Product2> pd2 = [SELECT Id,Name,Unit_Type__c FROM Product2 LIMIT 1];
        pd2[0].Unit_Type__c = 'Hrs';
        update pd2;
        
        Test.startTest();
            Boolean pTExist = ScheduleCmpLightningController.checkProductOrPTExist(oppRec[2].Id,'Opportunity');
            System.assertEquals(pTExist,true);
        Test.stopTest();
        
    }
    
    private static testMethod void testMethod4() {
        
        List<AcctSeed__Project__c> proList = [SELECT Id,Name,DLS_Class__c,RecordType.DeveloperName FROM AcctSeed__Project__c WHERE RecordType.DeveloperName IN ('Admin_Projects','Language_Training_Projects')]; 
        List<Schedule__c> schlist = [SELECT Id,Name,Project__c,Parent_Schedule__c,Prior_Schedule__c,Project_Task__c,Opportunity__c, Total_Hours__c,End_Date__c,Start_Date__c,Status__c,Opportunity_Product_Id__c FROM Schedule__c  LIMIT 2]; 
        List<Opportunity> oppRec = [SELECT Id,DLS_Class__c,RecordType.DeveloperName FROM Opportunity LIMIT 3 ];
        List<Product2> pd2 = [SELECT Id,Name,Unit_Type__c FROM Product2 LIMIT 1];
        List<AcctSeed__GL_Account__c> glAcLst = [SELECT Id FROM AcctSeed__GL_Account__c LIMIT 1];
        String pTRecId = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Language_Training').getRecordTypeId();
        pd2[0].Unit_Type__c = 'Hrs';
        update pd2;
        String AdminRT = null;
        String notAdminRT = null;
        
        for(AcctSeed__Project__c plist : proList ){
            if(plist.RecordType.DeveloperName == 'Admin_Projects'){
               AdminRT = plist.Id; 
              }else{
               notAdminRT =  plist.Id;
            }
        }
        
        Test.startTest();
        
            List<AcctSeed__Project_Task__c> newPT = new List<AcctSeed__Project_Task__c>{ 
                new AcctSeed__Project_Task__c( RecordTypeId = pTRecId,Project_Task_Type__c = 'Preparation time',Name ='Language Training - Preparation' ,AcctSeed__Labor_GL_Account__c = glAcLst[0].Id,AcctSeed__Project__c = proList[0].Id)
            };
            
            insert newPT;
            
            List<Schedule__c>  newsch = new List<Schedule__c>{
                new Schedule__c(Parent_Schedule__c = schlist[0].Id ,Name = 'Test 34', Project__c = proList[0].Id, Project_Task__c = newPT[0].Id)
            };
            
            insert newsch;
            
            ScheduleCmpLightningController.getScheduleRelatedInformation(AdminRT,'AcctSeed__Project__c', schlist[0].Id,'Regular',null,newsch[0].Id);
            ScheduleCmpLightningController.getScheduleRelatedInformation(notAdminRT,'AcctSeed__Project__c',null,'Regular',null,newsch[0].Id);
            String schlstOpp =  ScheduleCmpLightningController.getScheduleRelatedInformation( oppRec[0].Id,'Opportunity', schlist[0].Id,'Regular',null,null);
            ScheduleDomain.SheduleDetailInfo  schRec = (ScheduleDomain.SheduleDetailInfo ) System.JSON.deserialize(schlstOpp , ScheduleDomain.SheduleDetailInfo.class);
            System.assertEquals(schRec.schDetail.scheduleId,schlist[0].Id);
        Test.stopTest();
    } 
    
    private static testMethod void testMethod5() {
        
        List<AcctSeed__Project__c> proList = [SELECT Id,Name,DLS_Class__c,RecordType.DeveloperName FROM AcctSeed__Project__c LIMIT 3 ]; 
        List<Contact> conlist = [SELECT Id From Contact LIMIT 2];
        List<Schedule__c> schlist = [SELECT Id,Name,Project__c,Instructor__c,Parent_Schedule__c,Prior_Schedule__c,Project_Task__c,Opportunity__c, Total_Hours__c,End_Date__c,Start_Date__c,Status__c,Opportunity_Product_Id__c FROM Schedule__c  LIMIT 2]; 
        List<Opportunity> oppRec = [SELECT Id,DLS_Class__c,RecordType.DeveloperName FROM Opportunity  LIMIT 3];
        
        List<Schedule__c> schlst = new List<Schedule__c>();
        schlst.add( schlist[0]);
        List<Schedule__c> schlsts = new List<Schedule__c>();
        ScheduleDomain.Days dayVal = new ScheduleDomain.Days();
        dayVal.sunday = false;
        dayVal.monday = false;
        dayVal.tuesday = false;
        dayVal.wednesday = false;
        dayVal.thursday = false;
        dayVal.friday = false;
        dayVal.saturday = false;
        ScheduleDomain.ScheduleDetail schRec = new ScheduleDomain.ScheduleDetail();
        schRec.isNew = true;
        schRec.variedTime = false;
        schRec.status = 'Active';
        schRec.scheduleType = 'Regular';
        schRec.projectId = proList[0].Id;
        schRec.projectTaskId = schlist[0].Project_Task__c;
        schRec.instructorId = conlist[0].Id;
        schRec.parentScheduleId = null;
        schRec.isTravelRequired = false;
        schRec.excludeFederalHoliday = false;
        schRec.variedDay = false;
        schRec.dayVal = dayVal;
        schRec.startDate = schlist[0].Start_Date__c;
        schRec.endDate = schlist[0].End_Date__c.addDays(10);
        schRec.biWeekly = true;
        schRec.createZoomMeetings = false;
        
        Test.startTest();
        
            ScheduleCmpLightningController.getScheduleConflicts(JSON.serialize(new List< ScheduleDomain.ScheduleDetail>{schRec}),JSON.serialize(schlst),schlist[0].Instructor__c,'AcctSeed__Project__c',proList[0].Id,proList[0].RecordType.DeveloperName,JSON.serialize(new List<Schedule__c>{}));
            ScheduleCmpLightningController.getScheduleConflicts(JSON.serialize(new List< ScheduleDomain.ScheduleDetail>{schRec}),JSON.serialize(new List<Schedule__c>{}),schlist[0].Instructor__c,'AcctSeed__Project__c',proList[0].Id,proList[0].RecordType.DeveloperName,JSON.serialize(new List<Schedule__c>{}));
            ScheduleCmpLightningController.createdRegularSchedule(JSON.serialize(new List< ScheduleDomain.ScheduleDetail>{schRec}),'Opportunity',oppRec[0].Id);
            ScheduleCmpLightningController.createdRegularSchedule(JSON.serialize(new List< ScheduleDomain.ScheduleDetail>{schRec}),'AcctSeed__Project__c',proList[0].Id);
        Test.stopTest();
    }
    
    //This test method Covered two ScheduleCmpLightningCtrl method 
    //method1 - createEventsForSubstituteSchEdit meyhod
    //method2 - createScheduleForOtherTypes
    private static testMethod void testMethod6() {
        
        List<Contact_Assignments__c> cAList = [SELECT Id,Name,Candidate_Name__c,RecordTypeId,Project__c,Status__c FROM Contact_Assignments__c  WHERE RecordType.DeveloperName = 'Instructor'];
        List<AcctSeed__Project__c> proList = [SELECT Id,Name,DLS_Class__c,Default_Cost_Rate_Rate_Type__c,RecordType.DeveloperName,AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 3]; 
        List<Schedule__c> schlist = [SELECT Id,Name,Project__c,Parent_Schedule__c,Prior_Schedule__c,Project_Task__c,Opportunity__c, Total_Hours__c,End_Date__c,Start_Date__c,Status__c,Schedule_Type__c,Opportunity_Product_Id__c FROM Schedule__c  WHERE Status__c = 'Drafted' LIMIT 1]; 
        List<Contact> conlist = [SELECT Id,RecordTypeId From Contact WHERE RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        List<Opportunity> oppRec = [SELECT Id,DLS_Class__c,Default_Cost_Rate_Rate_Type__c,RecordType.DeveloperName FROM Opportunity  LIMIT 1];
        
        //Qry schedule "scheduleWithoutEvent" named schedule to avoid name formation related issues
        List<Schedule__c> schUpdate = [SELECT Id,Name,Project__r.DLS_Class__c FROM Schedule__c WHERE Name = 'scheduleWithoutEvent'];
        schUpdate[0].Name = schUpdate[0].Project__r.DLS_Class__c+'-SH1';
        update schUpdate;
        
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Contact__c = conlist[0].Id, Annual_Salary_Cost__c = 5500, Salary_Cost_Per_Hour__c = 20, Pay_Type__c = 'Salary', Rate_Type__c = 'DLI-21 SCA LT', AcctSeed__Hourly_Cost__c = 22 , Status__c = 'Approved',Payroll_Item__c='ADM')
        };
        
        insert costrateList;
        
        schlist[0].Status__c = 'Active';
        update schlist;
        
        ScheduleDomain.Days dayVal = new ScheduleDomain.Days();
        dayVal.sunday = false;
        dayVal.monday = false;
        dayVal.tuesday = false;
        dayVal.wednesday = false;
        dayVal.thursday = false;
        dayVal.friday = false;
        dayVal.saturday = false;
        ScheduleDomain.ScheduleDetail schRec = new ScheduleDomain.ScheduleDetail();
        schRec.isNew = true;
        schRec.startDate = system.today().addDays(-10);
        schRec.variedTime = false;
        schRec.status = 'Active';
        schRec.scheduleType = 'Replace Instructor';
        schRec.projectId = proList[0].Id;
        schRec.projectTaskId = schlist[0].Project_Task__c;
        schRec.instructorId = conlist[0].Id;
        schRec.parentScheduleId = null;
        schRec.isTravelRequired = false;
        schRec.excludeFederalHoliday = false;
        schRec.variedDay = false;
        schRec.dayVal = dayVal;
        schRec.priorScheduleId = schlist[0].Id;
        schRec.startDate = schlist[0].Start_Date__c;
        schRec.endDate = schlist[0].End_Date__c.addDays(30);
        schRec.biWeekly = false;
        schRec.createZoomMeetings = false;
        
        Test.startTest();
        
        //insert event for existing schedule
        List<Events__c> eveList = new List<Events__c>{
            new Events__c(Name = schlist[0].Name+'-EV1',Date__c = schlist[0].Start_Date__c.addDays(2),Schedule__c = schlist[0].Id,Status__c = 'Scheduled',Project__c = schlist[0].Project__c,SequenceNo__c = 1)
        };
        insert eveList;
        
        List<String>  datelst = new List<String> {string.valueOf(eveList[0].Date__c)};
            
        String schmsg = ScheduleCmpLightningController.createScheduleForOtherTypes(JSON.serialize(schRec),'Replace Instructor',proList[0].Default_Cost_Rate_Rate_Type__c,'AcctSeed__Project__c',proList[0].Id, datelst, costrateList[0].Id, 'Approved CR');
        
        List<Schedule__c> substituteSchedule = [SELECT Id FROM Schedule__c WHERE Schedule_Type__c = 'Replace Instructor'];
        schRec.endDate = schlist[0].End_Date__c.addDays(20);        
        schRec.scheduleType = 'Substitute';        
        schRec.scheduleId = substituteSchedule[0].Id;
        
     
        ScheduleCmpLightningController.createScheduleForOtherTypes(JSON.serialize(schRec),'Substitute',proList[0].Default_Cost_Rate_Rate_Type__c,'AcctSeed__Project__c',proList[2].Id, datelst, costrateList[0].Id, 'Approved CR');
        Test.stopTest();

       // ScheduleCmpLightningController.createEventsForSubstituteSchEdit(JSON.serialize(schRec),datelst);
        
      
        
        schRec.scheduleId = null;
        schRec.oppId = proList[0].AcctSeed__Opportunity__c;
        ScheduleCmpLightningController.createScheduleForOtherTypes(JSON.serialize(schRec),'Replace Instructor',oppRec[0].Default_Cost_Rate_Rate_Type__c,'Opportunity',oppRec[0].Id,datelst, costrateList[0].Id, 'Draft CR');
        
        System.assertEquals(schmsg,'Schedule has been created succesfully and a Contact Assignment has been created and mapped to the Schedule.');
    }
    
    private static testMethod void SubstituteType_Test() {
        
        List<Contact_Assignments__c> cAList = [SELECT Id,Name,Candidate_Name__c,RecordTypeId,Project__c,Status__c FROM Contact_Assignments__c  WHERE RecordType.DeveloperName = 'Instructor'];
        List<AcctSeed__Project__c> proList = [SELECT Id,Name,DLS_Class__c,Default_Cost_Rate_Rate_Type__c,RecordType.DeveloperName,AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 3]; 
        List<Schedule__c> schlist = [SELECT Id,Name,Project__c,Parent_Schedule__c,Prior_Schedule__c,Project_Task__c,Opportunity__c, Total_Hours__c,End_Date__c,Start_Date__c,Status__c,Schedule_Type__c,Opportunity_Product_Id__c FROM Schedule__c  WHERE Status__c = 'Drafted' LIMIT 1]; 
        List<Contact> conlist = [SELECT Id,RecordTypeId From Contact WHERE RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        List<Opportunity> oppRec = [SELECT Id,DLS_Class__c,Default_Cost_Rate_Rate_Type__c,RecordType.DeveloperName FROM Opportunity  LIMIT 1];
        
        //Qry schedule "scheduleWithoutEvent" named schedule to avoid name formation related issues
        List<Schedule__c> schUpdate = [SELECT Id,Name,Project__r.DLS_Class__c FROM Schedule__c WHERE Name = 'scheduleWithoutEvent'];
        schUpdate[0].Name = schUpdate[0].Project__r.DLS_Class__c+'-SH1';
        update schUpdate;
        
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Contact__c = conlist[0].Id, Annual_Salary_Cost__c = 5500, Salary_Cost_Per_Hour__c = 20, Pay_Type__c = 'Salary', Rate_Type__c = 'DLI-21 SCA LT', AcctSeed__Hourly_Cost__c = 22 , Status__c = 'Approved',Payroll_Item__c='ADM')
        };
        
        insert costrateList;
        
        schlist[0].Status__c = 'Active';
        update schlist;
        
        ScheduleDomain.Days dayVal = new ScheduleDomain.Days();
        dayVal.sunday = false;
        dayVal.monday = false;
        dayVal.tuesday = false;
        dayVal.wednesday = false;
        dayVal.thursday = false;
        dayVal.friday = false;
        dayVal.saturday = false;
        ScheduleDomain.ScheduleDetail schRec = new ScheduleDomain.ScheduleDetail();
        schRec.isNew = true;
        schRec.startDate = system.today().addDays(-10);
        schRec.variedTime = false;
        schRec.status = 'Active';
        schRec.scheduleType = 'Substitute';
        schRec.projectId = proList[0].Id;
        schRec.projectTaskId = schlist[0].Project_Task__c;
        schRec.instructorId = conlist[0].Id;
        schRec.parentScheduleId = null;
        schRec.isTravelRequired = false;
        schRec.excludeFederalHoliday = false;
        schRec.variedDay = false;
        schRec.dayVal = dayVal;
        schRec.priorScheduleId = schlist[0].Id;
        schRec.startDate = schlist[0].Start_Date__c;
        schRec.endDate = schlist[0].End_Date__c.addDays(30);
        schRec.biWeekly = false;
        schRec.createZoomMeetings = false;
        
        Test.startTest();
        
        //insert event for existing schedule
        List<Events__c> eveList = new List<Events__c>{
            new Events__c(Name = schlist[0].Name+'-EV1',Date__c = schlist[0].Start_Date__c.addDays(2),Schedule__c = schlist[0].Id,Status__c = 'Scheduled',Project__c = schlist[0].Project__c,SequenceNo__c = 1)
        };
        insert eveList;
        
        List<String>  datelst = new List<String> {string.valueOf(eveList[0].Date__c)}; 
                         
        ScheduleCmpLightningController.createScheduleForOtherTypes(JSON.serialize(schRec),'Substitute',proList[0].Default_Cost_Rate_Rate_Type__c,'AcctSeed__Project__c',proList[2].Id, datelst, costrateList[0].Id, 'Approved CR');
        
        List<Schedule__c> substituteSchedule = [SELECT Id FROM Schedule__c WHERE Schedule_Type__c = 'Substitute'];
        schRec.endDate = schlist[0].End_Date__c.addDays(20);        
        schRec.scheduleType = 'Substitute';        
        schRec.scheduleId = substituteSchedule[0].Id;
        
        ScheduleCmpLightningController.createScheduleForOtherTypes(JSON.serialize(schRec),'Substitute',proList[0].Default_Cost_Rate_Rate_Type__c,'AcctSeed__Project__c',proList[2].Id, datelst, costrateList[0].Id, 'Approved CR');
        Test.stopTest();      
        
        ScheduleCmpLightningController.createEventsForSubstituteSchEdit(JSON.serialize(schRec),datelst);
        
    }
    
    private static testMethod void testMethod6a() {
        
        List<Contact_Assignments__c> cAList = [SELECT Id,Name,Candidate_Name__c,RecordTypeId,Project__c,Status__c FROM Contact_Assignments__c  WHERE RecordType.DeveloperName = 'Instructor'];
        List<AcctSeed__Project__c> proList = [SELECT Id,Name,DLS_Class__c,Default_Cost_Rate_Rate_Type__c,RecordType.DeveloperName,AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 3]; 
        List<Schedule__c> schlist = [SELECT Id,Name,Project__c,Parent_Schedule__c,Prior_Schedule__c,Project_Task__c,Opportunity__c, Total_Hours__c,End_Date__c,Start_Date__c,Status__c,Schedule_Type__c,Opportunity_Product_Id__c FROM Schedule__c  WHERE Status__c = 'Drafted' LIMIT 2]; 
        List<Contact> conlist = [SELECT Id,RecordTypeId From Contact WHERE RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        List<Opportunity> oppRec = [SELECT Id,DLS_Class__c,Default_Cost_Rate_Rate_Type__c,RecordType.DeveloperName FROM Opportunity  LIMIT 1];
        
        //Qry schedule "scheduleWithoutEvent" named schedule to avoid name formation related issues
        List<Schedule__c> schUpdate = [SELECT Id,Name,Project__r.DLS_Class__c FROM Schedule__c WHERE Name = 'scheduleWithoutEvent'];
        schUpdate[0].Name = schUpdate[0].Project__r.DLS_Class__c+'-SH1';
        update schUpdate;
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Contact__c = conlist[0].Id, Annual_Salary_Cost__c = 5500, Salary_Cost_Per_Hour__c = 20, Pay_Type__c = 'Salary', Rate_Type__c = 'DLI-21 SCA LT', AcctSeed__Hourly_Cost__c = 22 , Status__c = 'Approved',Payroll_Item__c='ADM')
        };
        
        insert costrateList;
        
        schlist[0].Status__c = 'Active';
        update schlist;
        
        ScheduleDomain.Days dayVal = new ScheduleDomain.Days();
        dayVal.sunday = false;
        dayVal.monday = false;
        dayVal.tuesday = false;
        dayVal.wednesday = false;
        dayVal.thursday = false;
        dayVal.friday = false;
        dayVal.saturday = false;
        ScheduleDomain.ScheduleDetail schRec = new ScheduleDomain.ScheduleDetail();
        schRec.isNew = true;
        schRec.startDate = system.today().addDays(-10);
        schRec.variedTime = false;
        schRec.status = 'Active';
        schRec.scheduleType = 'Replace Instructor';
        schRec.projectId = proList[0].Id;
        schRec.projectTaskId = schlist[0].Project_Task__c;
        schRec.instructorId = conlist[0].Id;
        schRec.parentScheduleId = null;
        schRec.isTravelRequired = false;
        schRec.excludeFederalHoliday = false;
        schRec.variedDay = false;
        schRec.dayVal = dayVal;
        schRec.priorScheduleId = schlist[1].Id;
        schRec.startDate = schlist[0].Start_Date__c;
        schRec.endDate = schlist[0].End_Date__c.addDays(30);
        schRec.biWeekly = true;
        schRec.createZoomMeetings = false;
        
        Test.startTest();
        
        //insert event for existing schedule
        List<Events__c> eveList = new List<Events__c>{
            new Events__c(Name = schlist[0].Name+'-EV1',Date__c = schlist[0].Start_Date__c.addDays(2),Schedule__c = schlist[0].Id,Status__c = 'Scheduled',Project__c = schlist[0].Project__c,SequenceNo__c = 1)
        };
        insert eveList;
        
        List<String>  datelst = new List<String> {string.valueOf(eveList[0].Date__c)};
                    
        ScheduleCmpLightningController.createScheduleForOtherTypes(JSON.serialize(schRec),'Replace Instructor',proList[0].Default_Cost_Rate_Rate_Type__c,'AcctSeed__Project__c',proList[2].Id, datelst, costrateList[0].Id, 'Approved CR');
         
    }
    
    private static testMethod void testMethod7() {
        
        List<Schedule__c> schlist = [SELECT Id,Name,Project__c,Parent_Schedule__c,Prior_Schedule__c,Project_Task__c,Opportunity__c, Total_Hours__c,End_Date__c,Start_Date__c,Status__c,Schedule_Type__c,Opportunity_Product_Id__c FROM Schedule__c  LIMIT 2]; 
        List<Contact> conlist = [SELECT Id,RecordTypeId From Contact LIMIT 2];
        List<String> statuslst =  new List<String> {'Scheduled','Completed'};  
      
        List<Events__c> evnts = new List<Events__c> {
            new Events__c(Name = '15-00687-SH1-EV89',Schedule__c = schlist[0].Id,SequenceNo__c = 1,Instructor__c = conList[1].Id,Date__c = system.today().addDays(-1),Project__c = schList[0].Project__c,Status__c = 'Completed'), 
            new Events__c(Name = '15-00687-SH1-EVt90',Schedule__c = schlist[0].Id,SequenceNo__c = 1,Instructor__c = conList[1].Id,Date__c = system.today().addDays(-1),Project__c = schList[0].Project__c,Status__c = 'Completed')
        };
        
        Test.startTest();
        
        insert evnts;
        
        String schevt = ScheduleCmpLightningController.getEventsFromSchedule(schlist[0].Id, String.valueOf(System.today().addDays(-10)),String.ValueOf(System.today()),statuslst);
        
        Map<String, Object> schevts = (Map<String, Object>)JSON.deserializeUntyped(schevt );
        System.assertEquals(schevts.containsKey('Completed'),true);
        Test.stopTest();
    }
   
    private static testMethod void testMethod8() {
        
        List<AcctSeed__Project__c> proList = [SELECT Id,Name,DLS_Class__c,AcctSeed__Opportunity__c,RecordType.DeveloperName FROM AcctSeed__Project__c LIMIT 3];
        List<AcctSeed__Project_Task__c> currentPT  = [SELECT Id,Name,Project_Task_Type__c,Parent_Project_Task__c FROM AcctSeed__Project_Task__c  LIMIT 2];
        List<AcctSeed__GL_Account__c> glAcLst = [SELECT Id FROM AcctSeed__GL_Account__c LIMIT 1];
        String pTRecId = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Language_Training').getRecordTypeId();
        List<AcctSeed__Project_Task__c> newPT = new List<AcctSeed__Project_Task__c>{ 
            new AcctSeed__Project_Task__c( RecordTypeId = pTRecId,Project_Task_Type__c = 'Preparation time',Name ='Language Training - Preparation' ,AcctSeed__Labor_GL_Account__c = glAcLst[0].Id,AcctSeed__Project__c = proList[0].Id,Parent_Project_Task__c = currentPT[0].Id)
        };
        
        insert newPT;
        
        Test.startTest();
        
            List<Schedule__c> schedules = [SELECT Id,Name,Status__c FROM Schedule__c WHERE Project_Task__c != null LIMIT 1];
            schedules[0].Status__c = 'Active';
            update schedules;
            
            String schJson = ScheduleCmpLightningController.getPTRelatedScheduleRecord(newPT[0].Id);
            List<Schedule__c> getSchlist = ( List<SObject>)JSON.deserialize(schJson, List<SObject>.class);
            String getPtSch = ScheduleCmpLightningController.getPTRelatedScheduleRecord(currentPT[0].Id);
            System.assertEquals(getSchlist[0].Project_Task__c,newPT[0].Parent_Project_Task__c);
            System.assertEquals(getPtSch,'Not Prep PT');
        Test.stopTest();
    }    
    
    private static testMethod void testMethod9() {
        
        List<Schedule__c> schlist = [SELECT Id,Name,Project__c,Parent_Schedule__c,Prior_Schedule__c,Project_Task__c,Opportunity__c, Total_Hours__c,End_Date__c,Start_Date__c,Status__c,Schedule_Type__c,Opportunity_Product_Id__c FROM Schedule__c  LIMIT 2]; 
        List<AcctSeed__Project_Task__c> currentPT = [SELECT Id,Name,Project_Task_Type__c,Parent_Project_Task__c FROM AcctSeed__Project_Task__c  LIMIT 3];
        
        Test.startTest();
            ScheduleCmpLightningController.createZoomMeetingUrl(schlist[0].Id,currentPT[0].Name);
        Test.stopTest();
    }    
    
    // To cover getCurrentUserProfileName() method
    private static testMethod void testMethod10() {
    
        ScheduleCmpLightningController.getCurrentUserProfileName();
    }
    
    // To cover checkContactAssignmentExist() method
    private static testMethod void testMethod11() {
    
        List<Contact_Assignments__c> cAList = [SELECT Id, Candidate_Name__c, Project__c FROM Contact_Assignments__c  WHERE RecordType.DeveloperName = 'Instructor'];
        
        Boolean temp = ScheduleCmpLightningController.checkContactAssignmentExist(cAList[0].Candidate_Name__c, cAList[0].Project__c);
        System.assertEquals(temp, TRUE);
    }
    
    // To cover checkContactAssignmentExist() method
    private static testMethod void testMethod12() {
    
        List<Contact_Assignments__c> cAList = [SELECT Id, Candidate_Name__c, Project__c FROM Contact_Assignments__c  WHERE RecordType.DeveloperName = 'Instructor'];
        
        List<Contact> con = [SELECT Id FROM Contact WHERE Id != :cAList[0].Candidate_Name__c];
        
        Boolean temp = ScheduleCmpLightningController.checkContactAssignmentExist(con[0].Id, cAList[0].Project__c);
        System.assertEquals(temp, false);
    }  
    
    // To cover checkContactAssignmentExist() method
    private static testMethod void testMethod13() {
                
        ScheduleDomain.TotalOffs totOff = new ScheduleDomain.TotalOffs('Test Name', System.Today(), 'Test Type', System.Today());
    }  
    
    // To cover sendMailtoNotifyFEOTeam() method
    private static testMethod void testMethod14() {
        List<AcctSeed__Project__c> proList = [SELECT Id,Name FROM AcctSeed__Project__c LIMIT 1];
        try{
            if(proList.size() > 0){
                ScheduleCmpLightningController.sendMailtoNotifyFEOTeam(proList[0].Id);
            }
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }  
      private static testMethod void testMethod15() {
        List<AcctSeed__Project__c> proList = [SELECT Id,Name FROM AcctSeed__Project__c LIMIT 1];
        try{
            if(proList.size() > 0){
                ScheduleCmpLightningController.getParentRecord('Project',proList[0].Id);
                
                Test.startTest();
                ScheduleCmpLightningController.getParentRecord('Opportunity',proList[0].Id);
                Test.stopTest();
            }
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }  
}