@isTest
public class TeamworkUserPopulation_Test {
    
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
        
        String profileId = '00e3C000000UBB3, 00e320000017Ymu, 00e320000017Ymz, 00e320000017Yn4, 00e320000017Yn9, 00e320000017ZcU, 00e6000000141Of, 00e600000017Kgf, 00e600000017Koj, 00e600000017L0u, 00e600000017MKg, 00e600000017MUW, 00e600000017MZl, 00e600000017Y1P, 00e600000017YRN';
        
        System_Values__c sysVal = new System_Values__c(Name='Teamwork_People User Profile', Value__c = profileId);
        insert sysVal;
        
        List<TeamforcePro__People__c> teampeopleList = new List<TeamforcePro__People__c>{
            new TeamforcePro__People__c(Name = 'Test1', TeamforcePro__First_Name__c = 'Test', TeamforcePro__Last_Name__c = 'People', TeamforcePro__Email__c = 'Test@gmail.com', TeamforcePro__ID__c='157688'),
            new TeamforcePro__People__c(Name = 'Test1', TeamforcePro__First_Name__c = 'Test1', TeamforcePro__Last_Name__c = 'People', TeamforcePro__Email__c = 'Test1@gmail.com', TeamforcePro__ID__c='121234')
        };
        insert teampeopleList; 
        
        teampeopleList[1].TeamforcePro__Email__c = 'Test@gmail.com';
        update teampeopleList;
            
    }
}