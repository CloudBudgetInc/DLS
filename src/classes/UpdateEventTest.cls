@istest
public class UpdateEventTest {

    @testSetup static void setup(){
        Test.startTest();
            List<Events__c> evtlist = TestClassUtil.createTestEvent();
            List<Room__c> roomlist = TestClassUtil.createTestRoom();
        Test.stopTest();
        List<Contact_Assignments__c> cas = TestClassUtil.createTestContactAssignment();
    }
    
    /*public static testmethod void updateEventstaticTestMethod() {
        List < schedule__c > schList1 = //new List < schedule__c > {
            [select id, Name, Instructor__c, Room__c, Project__c, Status__c from schedule__c]; //limit 1]
       // };
        
        List<Room__c> rmList = [SELECT Id, Name FROM Room__c LIMIT 2];
        List<Schedule__c> sch = new List<Schedule__c>();
       
        System.debug('schList1 -------->>>>>'+schList1);
        if(schList1 != null && schList1.size() > 0){

            List<Contact> conList = [SELECT Id, Name FROM Contact WHERE ID !=: schList1[0].Instructor__c];
            
            for (schedule__c schli: schList1){
                schli.Room__c = rmList[0].id;
                schli.Instructor__c = conList[0].id;
                schli.Monday__c = true;
                schli.Tuesday__c = true;
                schli.Wednesday__c = true;
                schli.Thursday__c = true;
                schli.Friday__c = true;
               
                if(schli.Name == 'scheduleWithoutEvent' && schli.Project__c != null && schli.Status__c == 'Active') {
                    schli.Room__c = rmList[1].id;
                    sch.add(schli);
                }
            }
            update schList1;
            
            List<Schedule__c> updatedSch = [SELECT Id,Name,Days__c FROM Schedule__c WHERE Id =: schList1[0].Id];
            // To check the Days field is updated through the updateEvent trigger
            System.assertEquals('M-F', updatedSch[0].Days__c);   
        
            for (schedule__c schli: schList1){
                schli.Instructor__c = conList[0].id;
                schli.Wednesday__c = false;
                schli.Thursday__c = false;
                schli.Friday__c = false;
                schli.Status__c = 'Active';
            }
            update schList1;
         
            List<Schedule__c> updatedSch1 = [SELECT Id,Name,Days__c FROM Schedule__c WHERE Id =: schList1[0].Id];
            // To check the Days field is updated through the updateEvent trigger
            System.assertEquals('M;T', updatedSch1[0].Days__c);   
            
            //added
            updatedSch1[0].Id = null;
            insert updatedSch1;
            //ended
            
            List<AcctSeed__Project__c> pros = [Select Id,Name,All_Active_Rooms__c FROM AcctSeed__Project__c WHERE Id =: schList1[0].Project__c LIMIT 1];
            // To check the 'All Active Rooms' field value in the Project
            System.assertEquals('Room,Room 1', pros[0].All_Active_Rooms__c);    
     
            delete sch;     
            // To check the 'All Active Rooms' field value in the Project 
            List<AcctSeed__Project__c> proj = [Select Id,Name,All_Active_Rooms__c FROM AcctSeed__Project__c WHERE Id =: schList1[2].Project__c LIMIT 1];
            System.assertEquals('Room', proj[0].All_Active_Rooms__c); 
        } 
    }*/
   
    // For sending the mail when the schedule is updated and project schedule or instructor is changed
    private static TestMethod void testMethod1() {
        
        List<Schedule__c> schList = [SELECT Id, Name, End_Date__c FROM Schedule__c LIMIT 3];
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        List<AcctSeed__Project__c> proList = [SELECT Id, Name FROM AcctSeed__Project__c LIMIT 2];
        List<Room__c> roomList = [SELECT Id, Name FROM Room__c LIMIT 2];
        List<MTT_Location__c> locList = [SELECT Id, Name FROM MTT_Location__c LIMIT 2];
        List<Events__c> eveList = [SELECT Id, Name FROM Events__c LIMIT 2];
        
        List<System_Values__c> sysValuesList = new List<System_Values__c> {
            new System_Values__c(Name = 'Schedule Update Notify Mail', Value__c = 'karthiga@softsquare.biz')
        };
        insert sysValuesList;
        
        if(schList.size() > 0 && conList.size() > 0 && proList.size() > 0 && roomList.size() > 0 && locList.size() > 0 && eveList.size() > 0) {
            
            locList[0].Name = 'DLS - Online';
            update locList;
            
            List<Schedule__c> schListIn = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Room__c = roomList[0].Id, Project__c = proList[0].Id, Total_Hours__c = 5,End_Date__c=schList[0].End_Date__c+5, Start_Date__c=System.Today(),Status__c= 'Active', Prior_Schedule__c = schList[0].Id, Schedule_Type__c = 'Schedule Change', Training_Location_LU__c = locList[0].Id),
                new Schedule__c(Name = '15-00687-SH2', Instructor__c = conList[0].Id, Room__c = roomList[1].Id, Project__c = proList[0].Id, Total_Hours__c = 5,End_Date__c=schList[0].End_Date__c+5, Start_Date__c=System.Today(),Status__c= 'Active', Prior_Schedule__c = schList[0].Id, Schedule_Type__c = 'Replace Instructor', Training_Location_LU__c = locList[0].Id),
                new Schedule__c(Name = '15-00687-SH3', Room__c = roomList[0].Id, Project__c = proList[0].Id, Total_Hours__c = 5,End_Date__c=schList[0].End_Date__c+5, Start_Date__c=System.Today(),Status__c= 'Active', Prior_Schedule__c = schList[0].Id, Schedule_Type__c = 'Substitute', Training_Location_LU__c = locList[0].Id),
                new Schedule__c(Name = '15-00687-SH4', Room__c = roomList[0].Id, Project__c = proList[0].Id, Total_Hours__c = 5,End_Date__c=schList[0].End_Date__c+5, Start_Date__c=System.Today(),Status__c= 'Canceled', Training_Location_LU__c = locList[0].Id, Schedule_Type__c = 'Room Change', Prior_Schedule__c = schList[0].Id)
            };
            insert schListIn;
            
            for(Events__c eve : eveList) {
                eve.Schedule__c = schList[1].Id;
                eve.Date__c = System.today();
            }
            update eveList;
            
            for(Events__c eve : eveList) {
                eve.Id = null;
                eve.Schedule__c = schListIn[2].Id;
                eve.SequenceNo__c = 101;
                eve.Duration__c = 10;
            }
            insert eveList;
            
            Test.startTest();
            
            schList[0].End_Date__c = System.today().addDays(20);
            schList[0].Project__c = proList[0].Id;
            schList[0].Monday__c = true;
            schList[0].Tuesday__c = true;
            schList[0].Wednesday__c = true;
            schList[0].Thursday__c = true;
            schList[0].Room__c = roomList[0].Id;
            schList[0].Status__c = 'Active';
            schList[0].Start_Date__c = system.today().addDays(1);

            update schList[0];
            
            schList[0].End_Date__c = System.today().addDays(5);
            schList[0].Friday__c = true;
            schList[0].Room__c = roomList[1].Id;
            schList[0].Schedule_Type__c = 'Extended';
            schList[1].Status__c = 'Canceled';
            schList[1].Cancellation_Reason__c = 'Test Cancel';
            update schList;
                        
            List<AcctSeed__Project__c> proListUp = [SELECT Id, Name, All_Active_Rooms__c FROM AcctSeed__Project__c WHERE Id = :schList[0].Project__c];
            if(proListUp.size() > 0)
                System.assertEquals(roomList[1].Name+','+roomList[0].Name, proListUp[0].All_Active_Rooms__c);
                
        } 
    }
    
    // To prevent the updation of schedule records when it is editing by LTS User
    private static testMethod void testMethod2() {
    
        Id p = [SELECT Id FROM Profile WHERE Name='LTS'].Id;
        System.debug('p=========='+p);
                
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Sche Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive = true, 
                timezonesidkey='America/Los_Angeles', username='recentscheduletester@noemail.com');
       
        insert user;
        
        List<Schedule__c> schList = [SELECT Id, Project__c, Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        
        System.runAs(user){
        
            try{
            
                schList[0].Status__c = 'Completed';
                update schList[0];
            }catch(Exception e){
            
                Boolean expectedExceptionThrown =  e.getMessage().contains('Please edit the schedule using the Actions from the Project page.') ? true : false;    
                System.AssertEquals(expectedExceptionThrown, true);
            }
        }
    }
    
    // To prevent the deletion of schedule records when they have Status__c != 'Drafted'
    private static testMethod void testMethod3() {
            
        List<Schedule__c> schList = [SELECT Id, Project__c, Status__c FROM Schedule__c WHERE Status__c != 'Drafted' LIMIT 1];
                
        try{
        
            delete schList[0];
        }catch(Exception e){
        
            Boolean expectedExceptionThrown =  e.getMessage().contains('You cannot delete Schedule record.') ? true : false;    
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
    private static testMethod void testMethod4(){
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        ScheduleTriggerHandler.getConIdAndUserIdMap(new Set<Id>{conList[0].Id});
    }
    
    //To Create Assessment Report after First Schedule Activation
    private static testMethod void testMethod5(){
            
        List<Contact> contacts = [SELECT Id, Name, AccountId FROM Contact LIMIT 1];
         
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        System.debug('opp ===='+opp );
        
        Id langTrainingRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c project = new AcctSeed__Project__c(Name = 'My Test Project 1',AcctSeed__Account__c = contacts[0].AccountId, AcctSeed__Status__c = 'Active',RecordTypeId = langTrainingRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10));
        insert project;
        
        Test.startTest();
        
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Client_Contact__c=contacts[0].Id,AcctSeed__Project__c=project.Id,Project_Task_Type__c='Language Training',AcctSeed__Labor_GL_Account__c=glAccList[0].Id,Rate__c=41);
            insert projTask;
            
            Schedule__c mySche = new Schedule__c(Name = '18-00687-SH1',Project__c = project.Id,Project_Task__c=projTask.Id, Opportunity__c = opp[0].Id, Total_Hours__c = 0,End_Date__c=System.Today() + 10, Start_Date__c=System.Today(),Status__c= 'Drafted');
            insert mySche;
            
            List<Schedule__c> updateSche = [SELECT Id, Status__c, Total_Hours__c FROM Schedule__c WHERE Id = :mySche.Id];
            updateSche[0].Status__c = 'Active';
            updateSche[0].Total_Hours__c = 20;
            update updateSche[0];
            
        Test.stopTest();
    }
    
     //To cover updatePriorSchEveStatus() method
    private static testMethod void testMethod6(){
    
        List<Contact> con = [SELECT Id, Name FROM Contact LIMIT 2];
        
        List<Schedule__c> schList = [SELECT Id, Project__c, Status__c, Project_Task__c FROM Schedule__c WHERE Status__c = 'Drafted' LIMIT 1];        
        
        List<Schedule__c> updateSch = [SELECT Id, Status__c, Total_Hours__c FROM Schedule__c WHERE Id IN :schList];
        updateSch[0].Status__c = 'Active';
        update updateSch[0];
        
        Test.startTest();
        
        Schedule__c substitueSch = new Schedule__c(Prior_Schedule__c = schList[0].Id, Name = '15-00687-SH2', Project__c = schList[0].Project__c,Project_Task__c=schList[0].Project_Task__c, Total_Hours__c = 40,End_Date__c=System.Today()+10, Start_Date__c=System.Today().addDays(1),Status__c= 'Active', Schedule_Type__c = 'Substitute', Instructor__c = con[1].Id);
        insert substitueSch;
        
        List<Events__c> eve = [SELECT Id, Status__c, Date__c FROM Events__c WHERE Schedule__c =:schList[0].Id];
        eve[0].Status__c = 'Substituted';
        eve[0].Date__c = System.Today().addDays(1);
        update eve[0];
        
        List<Schedule__c> updateSubstitueSch = [SELECT Id, Status__c FROM Schedule__c WHERE Id = :substitueSch.Id];
        updateSubstitueSch[0].Status__c = 'Canceled';
        updateSubstitueSch[0].Cancellation_Reason__c = 'Test Cancellation';
        update updateSubstitueSch[0];
        
        List<Events__c> eve1 = [SELECT Id, Status__c FROM Events__c WHERE Schedule__c =:schList[0].Id];
        System.debug(':::MY::'+eve1[0].Status__c);
        
        Test.stopTest();
    }
    
    // To cover update_SubstituteScheduleCA() method
    private static testMethod void testMethod7(){
        
        List<Contact> con = [SELECT Id, Name FROM Contact LIMIT 2];
        
        List<Schedule__c> schList = [SELECT Id, Project__c, Status__c, Project_Task__c FROM Schedule__c WHERE Status__c = 'Drafted' LIMIT 1];        
        
        List<Schedule__c> updateSch = [SELECT Id, Status__c, Total_Hours__c FROM Schedule__c WHERE Id IN :schList];
        updateSch[0].Status__c = 'Active';
        update updateSch[0];
        
        Test.startTest();
        
        Schedule__c substitueSch = new Schedule__c(Prior_Schedule__c = schList[0].Id, Name = '15-00687-SH2', Project__c = schList[0].Project__c,Project_Task__c=schList[0].Project_Task__c, Total_Hours__c = 40,End_Date__c=System.Today(), Start_Date__c=System.Today()-5,Status__c= 'Draft', Schedule_Type__c = 'Substitute', Instructor__c = con[1].Id);
        insert substitueSch;
                        
        List<Contact_Assignments__c> insCA  = [SELECT Id, Candidate_Name__c, End_Date__c, Status__c 
                                                FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' LIMIT 1];
        insCA[0].Project__c = substitueSch.Project__c;
        insCA[0].Candidate_Name__c = con[1].Id;
        insCA[0].Assignment_Position__c = 'Substitute Instructor';
        insCA[0].End_Date__c = System.Today();
        insCA[0].Status__c = 'Ended';
        update insCA[0];
        
        List<Schedule__c> updateSubstitueSch = [SELECT Id, Status__c, End_Date__c FROM Schedule__c WHERE Id = :substitueSch.Id];
        updateSubstitueSch[0].Status__c = 'Active';
        update updateSubstitueSch[0];
        
        List<Contact_Assignments__c> updatedCAs  = [SELECT Id, Candidate_Name__c, End_Date__c, Status__c FROM Contact_Assignments__c WHERE Id IN : insCA];
        System.assertEquals(updatedCAs[0].End_Date__c, updateSubstitueSch[0].End_Date__c);
                                
        Test.stopTest();
    }
    
    private static testMethod void testMethod8(){
        try{
            List<Contact> con = [SELECT Id, Name FROM Contact LIMIT 2];
            List<Account> acc = [SELECT Id, Name FROM Account LIMIT 1];
            acc[0].Name = 'DODA';
            update acc;
            List<AcctSeed__Project_Task__c> pt = [SELECT Id,Project_Task_Type__c,AcctSeed__Client_Contact__c,AcctSeed__Project__c,AcctSeed__Labor_GL_Account__c,Rate__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c='Language Training' LIMIT 1];
            
            AcctSeed__Project__c pro = new AcctSeed__Project__c();
            pro.AcctSeed__Account__c = acc[0].Id;
            pro.Id =  pt[0].AcctSeed__Project__c;
            pro.Project_Type__c = 'PLP'; 
            update pro;
            
            Test.startTest(); 
            AcctSeed__Project_Task__c prepProjTask = new AcctSeed__Project_Task__c(AcctSeed__Labor_GL_Account__c=pt[0].AcctSeed__Labor_GL_Account__c,Name='Language Training-Preparation',Parent_Project_Task__c = pt[0].Id,AcctSeed__Project__c= pro.Id,Project_Task_Type__c='Preparation time',Rate__c=5);   
            insert prepProjTask;
            
            List<Schedule__c> schList = [SELECT Id, Project__c, Status__c, Project_Task__c,Hours_Planned__c,Schedule_Type__c FROM Schedule__c WHERE Status__c = 'Active' LIMIT 1];        

            Schedule__c updateSch = new Schedule__c(Name = '15-00687-SH2', Hours_Planned__c = 6,Project__c = pro.Id,Project_Task__c=pt[0].Id, Total_Hours__c = 40,End_Date__c=System.Today()+10, Start_Date__c=System.Today().addDays(1),Status__c= 'Drafted', Schedule_Type__c = 'Substitute',Prior_Schedule__c = schList[0].Id, Instructor__c = con[1].Id);
            insert updateSch;
            
            updateSch.Status__c ='Active'; 
            update updateSch;
           
            List<Schedule__c> prepLTSch = [SELECT Id, Project__c, Status__c, Project_Task__c,Hours_Planned__c,Schedule_Type__c FROM Schedule__c WHERE Parent_Schedule__c = :updateSch.Id LIMIT 1];        
            System.assertEquals(true,prepLTSch.size() > 0);
            Test.stopTest();
        }catch(exception ex){
            System.debug(ex.getMessage());  
        }
        
    }
     
    private static testMethod void testMethod9(){ 
        try{
            List<Contact> con = [SELECT Id, Name FROM Contact LIMIT 2];
            List<Account> acc = [SELECT Id, Name FROM Account LIMIT 1];
            acc[0].Name = 'DLI';
            update acc;
            
            List<AcctSeed__Project_Task__c> pt = [SELECT Id,Project_Task_Type__c,AcctSeed__Client_Contact__c,AcctSeed__Project__c,AcctSeed__Labor_GL_Account__c,Rate__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c='Language Training' LIMIT 1];
            
            AcctSeed__Project__c pro = new AcctSeed__Project__c();
            pro.AcctSeed__Account__c = acc[0].Id;
            pro.Id =  pt[0].AcctSeed__Project__c;
            pro.Project_Type__c = null; 
            update pro;
            
            Test.startTest();
            AcctSeed__Project_Task__c prepProjTask = new AcctSeed__Project_Task__c(AcctSeed__Labor_GL_Account__c=pt[0].AcctSeed__Labor_GL_Account__c,Name='Language Training-Preparation',Parent_Project_Task__c = pt[0].Id,AcctSeed__Project__c= pro.Id,Project_Task_Type__c='Preparation time',Rate__c=5);   
            insert prepProjTask;
            
            List<Schedule__c> schList = [SELECT Id, Project__c, Status__c, Project_Task__c,Hours_Planned__c,Schedule_Type__c FROM Schedule__c WHERE Status__c = 'Active' LIMIT 1];        

            Schedule__c updateSch = new Schedule__c(Prior_Schedule__c = schList[0].Id,Name = '15-00687-SH2', Hours_Planned__c = 6,Project__c = pro.Id,Project_Task__c=pt[0].Id,End_Date__c=System.Today()+5, Start_Date__c=System.Today()+2,Status__c= 'Drafted', Schedule_Type__c = 'Schedule Change', Instructor__c = con[1].Id);
            insert updateSch;
            
            updateSch.Status__c ='Active';
            update updateSch;
           
            List<Schedule__c> prepLTSch = [SELECT Id, Project__c, Status__c, Project_Task__c,Hours_Planned__c,Schedule_Type__c FROM Schedule__c WHERE Parent_Schedule__c = :updateSch.Id LIMIT 1];        
            System.assertEquals(true,prepLTSch.size() > 0);
            Test.stopTest();
        }catch(exception ex){
            System.debug(ex.getMessage());  
        }
    }
     
    private static testMethod void testMethod10(){ 
        try{
            List<Contact> con = [SELECT Id, Name FROM Contact LIMIT 2];
            List<Account> acc = [SELECT Id, Name FROM Account LIMIT 1];
            acc[0].Name = 'Test';
            update acc;
            
            List<AcctSeed__Project_Task__c> pt = [SELECT Id,Project_Task_Type__c,AcctSeed__Client_Contact__c,AcctSeed__Project__c,AcctSeed__Labor_GL_Account__c,Rate__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c='Language Training' LIMIT 1];
            
            AcctSeed__Project__c pro = new AcctSeed__Project__c();
            pro.AcctSeed__Account__c = acc[0].Id;
            pro.Id =  pt[0].AcctSeed__Project__c;
            pro.Project_Type__c = null; 
            update pro;
            
            Test.startTest();
            AcctSeed__Project_Task__c prepProjTask = new AcctSeed__Project_Task__c(AcctSeed__Labor_GL_Account__c=pt[0].AcctSeed__Labor_GL_Account__c,Name='Language Training-Preparation',Parent_Project_Task__c = pt[0].Id,AcctSeed__Project__c= pro.Id,Project_Task_Type__c='Preparation time',Rate__c=5);   
            insert prepProjTask;
            
            List<Schedule__c> schList = [SELECT Id, Project__c, Status__c, Project_Task__c,Hours_Planned__c,Schedule_Type__c FROM Schedule__c WHERE Status__c = 'Drafted' LIMIT 2];        

            List<Schedule__c> updateSch = new List<Schedule__c>{
                new Schedule__c(Prior_Schedule__c = schList[0].Id,Name = '15-00687-SH2', Hours_Planned__c = 6,Project__c = pro.Id,Project_Task__c=pt[0].Id,End_Date__c=System.Today().addDays(5), Start_Date__c=System.Today().addDays(1),Status__c= 'Drafted', Schedule_Type__c = 'Schedule Change', Instructor__c = con[1].Id),
                new Schedule__c(Parent_Schedule__c = schList[0].Id,Name = '15-00687-SH3', Hours_Planned__c = 6,Project__c = pro.Id,Project_Task__c=prepProjTask.Id,End_Date__c=System.Today().addDays(5), Start_Date__c=System.Today().addDays(1),Status__c= 'Active', Schedule_Type__c = 'Schedule Change', Instructor__c = con[1].Id)
            };
            insert updateSch; 
            
            updateSch[0].Status__c ='Active';
            update updateSch[0];
           
            List<Schedule__c> prepLTSch = [SELECT Id, Project__c, Status__c, Project_Task__c,Hours_Planned__c,Schedule_Type__c FROM Schedule__c WHERE Parent_Schedule__c = :updateSch[0].Id LIMIT 1];        
            System.assertEquals(true,prepLTSch.size() > 0);
            Test.stopTest();
        }catch(exception ex){
            System.debug(ex.getMessage());  
        }
    }
    
    // To cover schedule activation process via Manage Project Status Button
    private static testMethod void testMethod11(){ 
        try{
            List<Contact> con = [SELECT Id, Name FROM Contact LIMIT 2];
            List<Account> acc = [SELECT Id, Name FROM Account LIMIT 1];
            acc[0].Name = 'Test';
            update acc;
            
            List<AcctSeed__Project_Task__c> pt = [SELECT Id,Project_Task_Type__c,AcctSeed__Client_Contact__c,AcctSeed__Project__c,AcctSeed__Labor_GL_Account__c,Rate__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c='Language Training' LIMIT 1];
            
            AcctSeed__Project__c pro = new AcctSeed__Project__c();
            pro.AcctSeed__Account__c = acc[0].Id;
            pro.Id =  pt[0].AcctSeed__Project__c;
            pro.Project_Type__c = null; 
            update pro;
            
            Test.startTest();
            AcctSeed__Project_Task__c prepProjTask = new AcctSeed__Project_Task__c(AcctSeed__Labor_GL_Account__c=pt[0].AcctSeed__Labor_GL_Account__c,Name='Language Training-Preparation',Parent_Project_Task__c = pt[0].Id,AcctSeed__Project__c= pro.Id,Project_Task_Type__c='Preparation time',Rate__c=5);   
            insert prepProjTask;

            List<Schedule__c> updateSch = new List<Schedule__c>{
                new Schedule__c(Name = '15-00687-SH2', Hours_Planned__c = 6,Project__c = pro.Id,Project_Task__c=pt[0].Id,End_Date__c=System.Today().addDays(50), Start_Date__c=System.Today().addDays(1),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = con[1].Id)
            };
            insert updateSch; 
            
            CustomButtonService.isFromManageProjectStatus = True;
            updateSch[0].Status__c ='Active';
            update updateSch[0];
           
            List<Schedule__c> prepLTSch = [SELECT Id, Project__c, Status__c, Project_Task__c,Hours_Planned__c,Schedule_Type__c FROM Schedule__c WHERE Parent_Schedule__c = :updateSch[0].Id LIMIT 1];        
            System.assertEquals(true,prepLTSch.size() > 0);
            Test.stopTest();
        }catch(exception ex){
            System.debug(ex.getMessage());  
        }
    }
}