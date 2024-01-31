@isTest
public class TeamworkPage_Ctrl_Test {
    
    public static testMethod void myTest() {
       
        List<Profile> Profile = [SELECT Id FROM Profile WHERE Name = 'LTS'];
        
        String un = String.valueOf(System.now().millisecond())+'@dlsTestOrg.dlsdc';
        String en = String.valueOf(System.now().millisecond())+'@dlsTestOrg.com';
        
        Account a = new Account(Name='Test Account Name');
        insert a;
        
        User usr = new User(Alias = 'standt', Email='Test@gmail.com',EmailEncodingKey='UTF-8',FirstName='Test',
        LastName = 'People',LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = Profile[0].Id,
        TimeZoneSidKey='America/Los_Angeles', UserName=un);
        
        insert usr;
       
        TeamforcePro__Project__c proRec = new TeamforcePro__Project__c(Name='Test Project');
        insert proRec;
        
        system.debug('::::proRec'+proRec);
       
        List<TeamforcePro__TaskList__c> taskList = new List<TeamforcePro__TaskList__c>{
           new TeamforcePro__TaskList__c(Name = 'Test 1', TeamforcePro__Test__c = proRec.Id)
        };
        insert taskList;
        system.debug(':::taskList'+taskList);
        
        List<TeamforcePro__People__c> teampeopleList = new List<TeamforcePro__People__c>{
            new TeamforcePro__People__c(Name = 'Test1', TeamforcePro__First_Name__c = 'Test', TeamforcePro__Last_Name__c = 'People', TeamforcePro__Email__c = 'Test@gmail.com', TeamforcePro__ID__c='157688', User__c = usr.Id , TeamforcePro__User_Type__c = 'account'),
            new TeamforcePro__People__c(Name = 'Test2', TeamforcePro__First_Name__c = 'Test1', TeamforcePro__Last_Name__c = 'People', TeamforcePro__Email__c = 'Test1@gmail.com', TeamforcePro__ID__c='121234', User__c = usr.Id, TeamforcePro__User_Type__c = 'account')
        };
        insert teampeopleList; 
       
        List<TeamforcePro__Tasks__c> teamTaskList = new List<TeamforcePro__Tasks__c>{
           new TeamforcePro__Tasks__c(Name = 'Test 1', TeamforcePro__Task_List__c = taskList[0].Id, TeamforcePro__Assigned_To_LookUp__c = teampeopleList[0].Id, TeamforcePro__Start_Date__c = system.today(), TeamforcePro__Priority__c = 'Medium', TeamforcePro__Test__c = proRec.Id,TeamforcePro__Completed__c = false)
        };
        insert teamTaskList;
        
        List<TeamforcePro__Teamwork_Sub_Task__c> teamSubtaskList = new List<TeamforcePro__Teamwork_Sub_Task__c>{
            new TeamforcePro__Teamwork_Sub_Task__c(Name = 'Test Sub_Task', TeamforcePro__Teamwork_Task__c = teamTaskList[0].Id, TeamforcePro__Task_List__c = taskList[0].Id, TeamforcePro__Teamwork_Project__c = proRec.Id,TeamforcePro__Completed__c = false,TeamforcePro__Assigned_To_LookUp__c = teampeopleList[0].Id)
        };
        insert teamSubtaskList;
       
        system.runAs(usr){
            TeamworkPage_Ctrl.getTaskDetails();
        }
    }
}