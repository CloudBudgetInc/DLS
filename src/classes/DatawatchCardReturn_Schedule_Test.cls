@isTest
private class DatawatchCardReturn_Schedule_Test{

    @testSetup static void setupMethod(){
        
        Test.startTest();
            List<Contact_Assignments__c> conAssign = TestClassUtil.createTestContactAssignment();
        Test.stopTest();
        
        List<MTT_Location__c> locations = TestClassUtil.createTestLocations();
        List<Equipment_Assignment__c> equipmentAssignments = TestClassUtil.createTestEquipmentAssignment();
    }
    
    // Current Date
    private static testMethod void sendEmailToInstructor1(){
    
        List<Contact> conList = [SELECT Id, Last_End_Date_Rosslyn__c FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        conList[0].Last_End_Date_Rosslyn__c = Date.Today();
        update conList;
        
        List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        System.debug('projs ========'+projs );
        
        List<MTT_Location__c> locations = [SELECT Id, Name FROM MTT_Location__c WHERE Name = 'DLS - Rosslyn'];
        System.debug('locations ========='+locations );
        
        Test.startTest();
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Project__c, Candidate_Name__c, Start_Date__c, End_Date__c, Opportunity_Name__c, Status__c FROM Contact_Assignments__c  WHERE RecordType.DeveloperName  = 'Instructor' LIMIT 1];
            System.debug('conAss ======'+conAss );
            conAss[0].Project__c=projs[0].Id;
            conAss[0].Candidate_Name__c=conList[0].Id;
            conAss[0].Start_Date__c=Date.Today().addDays(6);
            conAss[0].End_Date__c=Date.today().addDays(7);
            conAss[0].Opportunity_Name__c=projs[0].AcctSeed__Opportunity__c;
            conAss[0].Status__c = 'Active';
            update conAss[0];
            System.debug('conAss[0]========='+conAss);
            
        Test.stopTest();
        
            List<Equipment__c> equipment = [SELECT Id, Asset_Type__c FROM Equipment__c];
            equipment[0].Asset_Type__c = 'Rosslyn Datawatch';
            update equipment[0];
            System.debug('equipment========='+equipment);
            
            List<Equipment_Assignment__c> equipAssign = [SELECT Id, Contact__c, Contact_Assignment__c, Location__c FROM Equipment_Assignment__c WHERE Stage__c = 'Active'];
            equipAssign[0].Contact__c = conList[0].Id;
            equipAssign[0].Contact_Assignment__c = conAss[0].Id;
            equipAssign[0].Location__c = locations[0].Id;
            update equipAssign;         
        try{
             // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            ReminderofDatawatchCardReturn_Schedule sch = new ReminderofDatawatchCardReturn_Schedule();
            system.schedule('Datawatch Card Access Reminder', CRON_EXP, sch);
            
        }Catch(Exception e){
            system.debug('Exception:'+e+e.getLineNumber());
        }
        
    }   
    
    // 7 days before date
    private static testMethod void sendEmailToInstructor2(){
    
        List<Contact> conList = [SELECT Id, Last_End_Date_Rosslyn__c FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        conList[0].Last_End_Date_Rosslyn__c = System.Today().addDays(-7);
        update conList;
        
        List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        System.debug('projs ========'+projs );
        
        List<MTT_Location__c> locations = [SELECT Id, Name FROM MTT_Location__c WHERE Name = 'DLS - Rosslyn'];
        System.debug('locations ========='+locations );
        
        Test.startTest();
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Project__c, Candidate_Name__c, Start_Date__c, End_Date__c, Opportunity_Name__c, Status__c FROM Contact_Assignments__c  WHERE RecordType.DeveloperName  = 'Instructor' LIMIT 1];
            System.debug('conAss ======'+conAss );
            conAss[0].Project__c=projs[0].Id;
            conAss[0].Candidate_Name__c=conList[0].Id;
            conAss[0].Start_Date__c=Date.Today().addDays(6);
            conAss[0].End_Date__c=Date.today().addDays(7);
            conAss[0].Opportunity_Name__c=projs[0].AcctSeed__Opportunity__c;
            conAss[0].Status__c = 'Active';
            update conAss[0];
            System.debug('conAss[0]========='+conAss);
            
        Test.stopTest();
        
            List<Equipment__c> equipment = [SELECT Id, Asset_Type__c FROM Equipment__c];
            equipment[0].Asset_Type__c = 'Rosslyn Datawatch';
            update equipment[0];
            System.debug('equipment========='+equipment);
            
            List<Equipment_Assignment__c> equipAssign = [SELECT Id, Contact__c, Contact_Assignment__c, Location__c FROM Equipment_Assignment__c WHERE Stage__c = 'Active'];
            equipAssign[0].Contact__c = conList[0].Id;
            equipAssign[0].Contact_Assignment__c = conAss[0].Id;
            equipAssign[0].Location__c = locations[0].Id;
            update equipAssign;         
        try{
             // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            ReminderofDatawatchCardReturn_Schedule sch = new ReminderofDatawatchCardReturn_Schedule();
            system.schedule('Datawatch Card Access Reminder', CRON_EXP, sch);
            
        }Catch(Exception e){
            system.debug('Exception:'+e+e.getLineNumber());
        }
        
    }
    
    // 7 Days after date
    private static testMethod void sendEmailToInstructor3(){
    
        Date satDay = System.Today().toStartofWeek().addDays(7);
        System.debug('satDay==='+satDay);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        System.debug('conList==='+conList);
        conList[0].Last_End_Date_Rosslyn__c = Date.Today().addDays(6);
        update conList;
        
        List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        System.debug('projs ========'+projs );
        
        List<MTT_Location__c> locations = [SELECT Id, Name FROM MTT_Location__c WHERE Name = 'DLS - Rosslyn'];
        System.debug('locations ========='+locations );
        
        Test.startTest();
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Project__c, Candidate_Name__c, Start_Date__c, End_Date__c, Opportunity_Name__c, Status__c FROM Contact_Assignments__c  WHERE RecordType.DeveloperName  = 'Instructor' LIMIT 1];
            System.debug('conAss ======'+conAss );
            conAss[0].Project__c = projs[0].Id;
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Start_Date__c= Date.Today().addDays(6);
            conAss[0].End_Date__c= satDay;
            conAss[0].Opportunity_Name__c = projs[0].AcctSeed__Opportunity__c;
            conAss[0].Status__c = 'Active';
            update conAss[0];
            System.debug('conAss[0]========='+conAss);
            
        Test.stopTest();
        
            List<Equipment__c> equipment = [SELECT Id, Asset_Type__c FROM Equipment__c];
            equipment[0].Asset_Type__c = 'Rosslyn Datawatch';
            update equipment[0];
            System.debug('equipment========='+equipment);
            
            List<Equipment_Assignment__c> equipAssign = [SELECT Id, Contact__c, Contact_Assignment__c, Location__c FROM Equipment_Assignment__c WHERE Stage__c = 'Active'];
            equipAssign[0].Contact__c = conList[0].Id;
            equipAssign[0].Contact_Assignment__c = conAss[0].Id;
            equipAssign[0].Location__c = locations[0].Id;
            update equipAssign;         
        try{
             // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            ReminderofDatawatchCardReturn_Schedule sch = new ReminderofDatawatchCardReturn_Schedule();
            system.schedule('Datawatch Card Access Reminder', CRON_EXP, sch);
            
        }Catch(Exception e){
            system.debug('Exception:'+e+e.getLineNumber());
        }
        
    }
        
    // Send an email to Students (Student RT Contact / Student RT CA)
    private static testMethod void sendEmailToStudent1(){
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Student'];
        System.debug('conList==='+conList);
        System.debug('conList==='+conList);
        conList[0].Last_End_Date_Rosslyn__c = Date.today().addDays(7);
        update conList;
        
        List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        System.debug('projs ========'+projs );
        
        List<MTT_Location__c> locations = [SELECT Id, Name FROM MTT_Location__c WHERE Name = 'DLS - Rosslyn'];
        System.debug('locations ========='+locations );
        
        Test.startTest();
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Project__c, Candidate_Name__c, Start_Date__c, End_Date__c, Opportunity_Name__c, Status__c FROM Contact_Assignments__c  WHERE RecordType.DeveloperName  = 'Student' LIMIT 1];
            System.debug('conAss ======'+conAss );
            conAss[0].Project__c=projs[0].Id;
            conAss[0].Candidate_Name__c=conList[0].Id;
            conAss[0].Start_Date__c=Date.Today().addDays(6);
            conAss[0].End_Date__c=Date.today().addDays(7);
            conAss[0].Opportunity_Name__c=projs[0].AcctSeed__Opportunity__c;
            conAss[0].Status__c = 'Active';
            update conAss[0];
            System.debug('conAss[0]========='+conAss);
            
        Test.stopTest();
        
            List<Equipment__c> equipment = [SELECT Id, Asset_Type__c FROM Equipment__c];
            equipment[0].Asset_Type__c = 'Rosslyn Datawatch';
            update equipment[0];
            System.debug('equipment========='+equipment);
            
            List<Equipment_Assignment__c> equipAssign = [SELECT Id, Contact__c, Contact_Assignment__c, Location__c FROM Equipment_Assignment__c WHERE Stage__c = 'Active'];
            equipAssign[0].Contact__c = conList[0].Id;
            equipAssign[0].Contact_Assignment__c = conAss[0].Id;
            equipAssign[0].Location__c = locations[0].Id;
            update equipAssign;         
        try{
             // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            ReminderofDatawatchCardReturn_Schedule sch = new ReminderofDatawatchCardReturn_Schedule();
            system.schedule('Datawatch Card Access Reminder', CRON_EXP, sch);
            
        }Catch(Exception e){
            system.debug('Exception:'+e+e.getLineNumber());
        }
        
    } 
    
    // Current Date (Saturday)
    private static testMethod void sendEmailToInstructor4(){
    
        Date satDay = Date.Today().toStartofWeek().addDays(6);
        
        List<Contact> conList = [SELECT Id, Last_End_Date_Rosslyn__c FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        conList[0].Last_End_Date_Rosslyn__c = satDay;
        update conList;
        
        List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        System.debug('projs ========'+projs );
        
        List<MTT_Location__c> locations = [SELECT Id, Name FROM MTT_Location__c WHERE Name = 'DLS - Rosslyn'];
        System.debug('locations ========='+locations );
        
        Test.startTest();
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Project__c, Candidate_Name__c, Start_Date__c, End_Date__c, Opportunity_Name__c, Status__c FROM Contact_Assignments__c  WHERE RecordType.DeveloperName  = 'Instructor' LIMIT 1];
            System.debug('conAss ======'+conAss );
            conAss[0].Project__c=projs[0].Id;
            conAss[0].Candidate_Name__c=conList[0].Id;
            conAss[0].Start_Date__c=Date.Today().addDays(6);
            conAss[0].End_Date__c=Date.today().addDays(7);
            conAss[0].Opportunity_Name__c=projs[0].AcctSeed__Opportunity__c;
            conAss[0].Status__c = 'Active';
            update conAss[0];
            System.debug('conAss[0]========='+conAss);
            
        Test.stopTest();
        
            List<Equipment__c> equipment = [SELECT Id, Asset_Type__c FROM Equipment__c];
            equipment[0].Asset_Type__c = 'Rosslyn Datawatch';
            update equipment[0];
            System.debug('equipment========='+equipment);
            
            List<Equipment_Assignment__c> equipAssign = [SELECT Id, Contact__c, Contact_Assignment__c, Location__c FROM Equipment_Assignment__c WHERE Stage__c = 'Active'];
            equipAssign[0].Contact__c = conList[0].Id;
            equipAssign[0].Contact_Assignment__c = conAss[0].Id;
            equipAssign[0].Location__c = locations[0].Id;
            update equipAssign;         
        try{
             // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            ReminderofDatawatchCardReturn_Schedule sch = new ReminderofDatawatchCardReturn_Schedule();
            system.schedule('Datawatch Card Access Reminder', CRON_EXP, sch);
            
        }Catch(Exception e){
            system.debug('Exception:'+e+e.getLineNumber());
        }
        
    }
    
    // 7 days before date (Saturday)
    private static testMethod void sendEmailToInstructor5(){
    
        Date satDay = Date.Today().toStartofWeek().addDays(6);
        Date futSatDay = satDay.addDays(7);
        
        List<Contact> conList = [SELECT Id, Last_End_Date_Rosslyn__c FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        conList[0].Last_End_Date_Rosslyn__c = futSatDay;
        update conList;
        
        List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        System.debug('projs ========'+projs );
        
        List<MTT_Location__c> locations = [SELECT Id, Name FROM MTT_Location__c WHERE Name = 'DLS - Rosslyn'];
        System.debug('locations ========='+locations );
        
        Test.startTest();
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Project__c, Candidate_Name__c, Start_Date__c, End_Date__c, Opportunity_Name__c, Status__c FROM Contact_Assignments__c  WHERE RecordType.DeveloperName  = 'Instructor' LIMIT 1];
            System.debug('conAss ======'+conAss );
            conAss[0].Project__c=projs[0].Id;
            conAss[0].Candidate_Name__c=conList[0].Id;
            conAss[0].Start_Date__c=Date.Today().addDays(6);
            conAss[0].End_Date__c=Date.today().addDays(7);
            conAss[0].Opportunity_Name__c=projs[0].AcctSeed__Opportunity__c;
            conAss[0].Status__c = 'Active';
            update conAss[0];
            System.debug('conAss[0]========='+conAss);
            
        Test.stopTest();
        
            List<Equipment__c> equipment = [SELECT Id, Asset_Type__c FROM Equipment__c];
            equipment[0].Asset_Type__c = 'Rosslyn Datawatch';
            update equipment[0];
            System.debug('equipment========='+equipment);
            
            List<Equipment_Assignment__c> equipAssign = [SELECT Id, Contact__c, Contact_Assignment__c, Location__c FROM Equipment_Assignment__c WHERE Stage__c = 'Active'];
            equipAssign[0].Contact__c = conList[0].Id;
            equipAssign[0].Contact_Assignment__c = conAss[0].Id;
            equipAssign[0].Location__c = locations[0].Id;
            update equipAssign;         
        try{
             // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            ReminderofDatawatchCardReturn_Schedule sch = new ReminderofDatawatchCardReturn_Schedule();
            system.schedule('Datawatch Card Access Reminder', CRON_EXP, sch);
            
        }Catch(Exception e){
            system.debug('Exception:'+e+e.getLineNumber());
        }
        
    }
}