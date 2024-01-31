@isTest
public Class Test_StudentTestResult_ReportPage_Ctrl{
    @testSetup static void setup(){
        List<Language_Testing__c> languageTestList = TestClassUtil.createTestLanguageTesting();
        List<Language__c> langList = TestClassUtil.createTestLanguages();
         List<User> userList = TestClassUtil.createTestUsers();
    }
    public static testMethod void testMethod1(){
        List<User> userList = [SELECT Id,Name,UserType,ContactId,Instructor_Access__c,Partner_Access__c,Student_Access__c,Client_Access__c FROM User WHERE Id =:UserInfo.getUserId()]; 
        
        StudentTestResult_ReportPage_Controller.getReportData('CLIENT');
        StudentTestResult_ReportPage_Controller.PicklistValues('Language_Testing__c','Test_Type__c');
        
        userList[0].Instructor_Access__c = true;
        update userList;
        StudentTestResult_ReportPage_Controller.getReportData('INSTRUCTOR');
    }
}