@istest
public class New_Class_Ann_Project_Comp_Ctrl_Test{
    
    @testSetup static void setup(){    
        Test.StartTest();
        List<Schedule__c> schList = TestClassUtil.createTestSchedule();
        Test.StopTest();
        List<Contact_Assignments__c> conAss = TestClassUtil.createTestContactAssignment();
    }
    
    @istest
    public static void New_Class_Ann_Project_Comp_Ctrl_Testmethod(){
        List<AcctSeed__Project__c> projectList = [SELECT Id, Name FROM AcctSeed__Project__c LIMIT 1];
        Contact_Assignments__c conAss = [SELECT Id, Name, Project__c FROM Contact_Assignments__c WHERE Status__c = 'Active' LIMIT 1];
        RecordType rt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Contact_Assignments__c' AND DeveloperName = 'Student' LIMIT 1];
        
        conAss.RecordTypeId = rt.Id;
        conAss.Project__c = projectList[0].Id;
        update conAss; 
        
        List<Schedule__c> scheduleList = [
                                            SELECT Id, Name, Start_Time__c, End_Time__c, Days__c 
                                            FROM Schedule__c 
                                            WHERE Project__c = :projectList[0].Id
                                         ];
        New_Class_Announcement_Project_Comp_Ctrl newclass = new New_Class_Announcement_Project_Comp_Ctrl();
        newclass.proId = projectList[0].Id;
        newclass.getProj();
        
       
    }
}