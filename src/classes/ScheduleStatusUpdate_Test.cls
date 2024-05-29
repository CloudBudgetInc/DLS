@isTest
private class ScheduleStatusUpdate_Test{

    @testSetup static void setupMethod(){
    
        List<Events__c> events = TestClassUtil.createTestEvent();
    }
    
    private static testMethod void myTest1(){
    
        List<Events__c> eveRec = [SELECT Id, Schedule__c, Status__c FROM Events__c WHERE Schedule__c != NULL];
        
        List<Schedule__c> schRecs = [SELECT Id, Start_Date__c, End_Date__c, Status__c, Schedule_Type__c 
            FROM Schedule__c 
            WHERE Id = :eveRec[0].Schedule__c];
                    
        List<Events__c> eveRecs = [SELECT Id, Schedule__c, Status__c FROM Events__c WHERE Schedule__c =:schRecs[0].Id];
        List<Events__c> updateEveRecs = new List<Events__c>();
        
        if(eveRecs != NULL && eveRecs.size() > 0){            
            
            for(Events__c eve : eveRecs){
            
                eve.Status__c = 'Completed';
                updateEveRecs.add(eve);
            }
        }
        
        if(updateEveRecs != NULL && updateEveRecs.size() > 0){
            update updateEveRecs;
        }
        
        schRecs[0].End_Date__c = Date.Today().addDays(-1);
        schRecs[0].Status__c = 'Active';
        schRecs[0].Schedule_Type__c = 'Substitute';
        update schRecs[0];
        
        Test.startTest();
        
            ScheduleStatusUpdate updateScheduleRec = new ScheduleStatusUpdate();
            String sch = '0 0 5 * * ? *'; //schedule interval time
            system.schedule('One Time Pro', sch, updateScheduleRec); //system method to schedule apex class
            
        Test.stopTest();
        
        List<Schedule__c> updatedSchRecs = [SELECT Id, Status__c FROM Schedule__c WHERE Id = :schRecs[0].Id];
    }
    
    private static testMethod void myTest2(){
    
        List<Events__c> eveRec = [SELECT Id, Schedule__c, Status__c FROM Events__c WHERE Schedule__c != NULL];
        
        List<Schedule__c> schRecs = [SELECT Id, Start_Date__c, End_Date__c, Status__c, Schedule_Type__c 
            FROM Schedule__c 
            WHERE Id = :eveRec[0].Schedule__c];
                    
        List<Events__c> eveRecs = [SELECT Id, Schedule__c, Status__c FROM Events__c WHERE Schedule__c =:schRecs[0].Id];
        List<Events__c> updateEveRecs = new List<Events__c>();
        
        if(eveRecs != NULL && eveRecs.size() > 0){            
            
            for(Events__c eve : eveRecs){
            
                eve.Status__c = 'Scheduled';
                updateEveRecs.add(eve);
            }
        }
        
        if(updateEveRecs != NULL && updateEveRecs.size() > 0){
            update updateEveRecs;
        }
        
        schRecs[0].End_Date__c = Date.Today().addDays(-1);
        schRecs[0].Status__c = 'Active';
        schRecs[0].Schedule_Type__c = 'Substitute';
        update schRecs[0];
        
        Test.startTest();
        
            ScheduleStatusUpdate updateScheduleRec = new ScheduleStatusUpdate();
            String sch = '0 0 5 * * ? *'; //schedule interval time
            system.schedule('One Time Pro', sch, updateScheduleRec); //system method to schedule apex class
            
        Test.stopTest();
        
        List<Schedule__c> updatedSchRecs = [SELECT Id, Status__c FROM Schedule__c WHERE Id = :schRecs[0].Id];
    }
    
    private static testMethod void myTest3(){
    
        Contact c = new Contact(LastName = 'ScheduleStatusUpdateCon');
        insert c;
        
        List<Events__c> eveRec = [SELECT Id, Schedule__c, Status__c FROM Events__c WHERE Schedule__c != NULL];
        
        List<Schedule__c> schRecs = [SELECT Id, Start_Date__c, End_Date__c, Status__c, Schedule_Type__c, Project__c 
            FROM Schedule__c 
            WHERE Id = :eveRec[0].Schedule__c];
       
        List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Paper Timesheet Value', Value__c = 'True')};
        Insert sysVal;
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        Contact_Assignments__c insCA = new Contact_Assignments__c(RecordTypeId = insRTId, Candidate_Name__c = c.Id, Start_Date__c = schRecs[0].Start_Date__c, End_Date__c = schRecs[0].End_Date__c, Project__c = schRecs[0].Project__c, Assignment_Position__c = 'Instructor', Status__c = 'Active');
        insert insCA;
         
        Test.startTest();
        
            List<Events__c> eveRecs = [SELECT Id, Schedule__c, Status__c FROM Events__c WHERE Schedule__c =:schRecs[0].Id];
            List<Events__c> updateEveRecs = new List<Events__c>();
            
            if(eveRecs != NULL && eveRecs.size() > 0){            
                
                for(Events__c eve : eveRecs){
                
                    eve.Status__c = 'Completed';
                    updateEveRecs.add(eve);
                }
            }
            
            if(updateEveRecs != NULL && updateEveRecs.size() > 0){
                update updateEveRecs;
            }
        
            schRecs[0].End_Date__c = Date.Today().addDays(-1);
            schRecs[0].Status__c = 'Active';
            schRecs[0].Schedule_Type__c = 'Substitute';
            schRecs[0].Instructor__c = c.Id;
            update schRecs[0];
        
            ScheduleStatusUpdate updateScheduleRec = new ScheduleStatusUpdate();
            String sch = '0 0 5 * * ? *'; //schedule interval time
            system.schedule('One Time Pro', sch, updateScheduleRec); //system method to schedule apex class
            
        Test.stopTest();
        
        List<Schedule__c> updatedSchRecs = [SELECT Id, Status__c FROM Schedule__c WHERE Id = :schRecs[0].Id];
    }
}