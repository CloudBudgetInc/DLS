@isTest 
private class ContactExperienceRollupHelper_Sch_Test{
    
    @testSetup static void setupMethod(){
    
        List<Experience__c> experiences = TestClassUtil.createTestExperience();
    }
    
    @isTest static void updateExpInContact1(){
        
        List<Experience__c> experiences = [SELECT Id, Services__c, Start_Date__c, End_Date__c FROM Experience__c];
        List<Experience__c> updateExp = new List<Experience__c>();
        
        for(Experience__c e : experiences){
            e.Services__c = 'Language Training';
            e.End_Date__c = null;
            updateExp.add(e);
        }
        update updateExp;
        
        Test.startTest();
    
        ContactExperienceRollupHelper_Schedule  sch2 = new ContactExperienceRollupHelper_Schedule(); 
        String sch = '0 0 0 * * ?'; 
        system.schedule('Contact Experience Rollup Helper Schedule', sch, sch2);
        
        Test.stopTest();
    }    
    
    @isTest static void updateExpInContact2(){
        
        List<Contact> conRec = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Candidate'];
        List<Experience__c> updateExp = new List<Experience__c>();
        
        List<Experience__c> experiences = [SELECT Id, Services__c, Start_Date__c, End_Date__c FROM Experience__c];        
        
        for(Experience__c e : experiences){
            e.Services__c = 'Language Training';
            e.End_Date__c = null;
            e.Intensive_Proficiency_Oriented_Experienc__c = True;
            e.Contact__c = conRec[0].Id;
            updateExp.add(e);
        }
        update updateExp;
        
        Test.startTest();
    
        ContactExperienceRollupHelper_Schedule  sch2 = new ContactExperienceRollupHelper_Schedule(); 
        String sch = '0 0 0 * * ?'; 
        system.schedule('Contact Experience Rollup Helper Schedule', sch, sch2);
        
        Test.stopTest();
    }    
}