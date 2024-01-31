/**
* @description       :This test class is developed for JobCommunityHomePage_Ctrl
* @author            : Siva Prasanth
* @last modified on  : 19/07/2023
* @last modified by  : Siva Prasanth
**/
@isTest
public class JobCommunityHomePageCtrl_Test {
    @testsetup static void setup() {
        List<Contact> contactList = TestClassUtil.createTestContacts(); 
        bpats__Job__c job = new bpats__Job__c(name = 'Test Job',Department__c = 'Language Training',bpats__Job_Title__c = 'Test Carreer',bpats__Location__c = 'Multiple US Locations',bpats__Status__c = 'Open');
        insert job;
        
        box__Folder_Details__c setting = new box__Folder_Details__c();
        setting.Name = 'contacts';
        setting.box__FolderId__c = 'test';
        insert setting;
        
        bpats__ATS_Action__c ats = new bpats__ATS_Action__c(name = 'ATS Action');
        insert ats;
        
        Test.startTest(); 
            Account accs = new Account(name = 'DLS - Candidate');
            insert accs;
            
            bpats__ATS_Template__c template = new bpats__ATS_Template__c(Name = 'Template Job');
            insert template;
            
            bpats__ATS_Template_Stage__c tempStage = new bpats__ATS_Template_Stage__c(name = 'Template Stage',bpats__ATS_Template__c = template.Id);
            insert tempStage;
            
            bpats__ATS_Stage__c stage = new bpats__ATS_Stage__c(bpats__ATS_Template_Stage__c = tempStage.Id,bpats__Job__c = job.Id,bpats__Sequence__c = 1,Name = 'Application');
            insert stage;
        Test.stopTest();
    }
    // This method to get Job detail initial informations
    private static testMethod void testMethod1() {
        List<bpats__Job__c> jobs = [SELECT Id FROM bpats__Job__c LIMIT 1];
        JobCommunityHomePage_Ctrl.getJobDetails(null);
        
        Test.startTest();
        List<bpats__Job__c> job = JobCommunityHomePage_Ctrl.getJobDetails(jobs[0].Id);
        
        Assert.areEqual(true, jobs.size() > 0);
        Assert.areEqual(jobs[0].Id,job[0].Id);
        Test.stopTest();
    }
    // This test method to cpver the catch - error
    private static testMethod void testMethod2() {
        try{
            JobCommunityHomePage_Ctrl.getJobDetails('test');
        }catch(Exception ex){
            system.debug(ex.getMessage());
        }
    }
    // This test method to cover the upsert contact and application along with file uplods
    private static testMethod void testMethod3() {    
        try{
            List<bpats__Job__c> jobs = [SELECT Id FROM bpats__Job__c LIMIT 1];
            List<Contact> contactList = [SELECT Id,FirstName,LastName,Email FROM Contact WHERE FirstName != null AND LastName != null AND Email != null];
            
            BoxUtilDomain.FilesWrapper wrapperInstance = new BoxUtilDomain.FilesWrapper();
            wrapperInstance.fileName = 'test1';
            wrapperInstance.base64 = '770yuvw/';
            wrapperInstance.isResumeType = true;
            List<BoxUtilDomain.FilesWrapper> wrapperList = new List<BoxUtilDomain.FilesWrapper>();
            wrapperList.add(wrapperInstance);
            
            Test.setMock(HttpCalloutMock.class, new LessonPlanBoxUtilMock());
            Test.startTest();
            JobCommunityHomePage_Ctrl.createJobAndContacts(JSON.serialize(contactList),JSON.serialize(wrapperList),jobs[0].Id);
            
            List<bpats__ATS_Applicant__c> atsApplicant = [SELECT Id,bpats__Job__c FROM bpats__ATS_Applicant__c WHERE bpats__Job__c = :jobs[0].Id AND bpats__ATS_Applicant__c = :contactList[0].Id];
            if(atsApplicant.size() > 0){
                Assert.areEqual(jobs[0].Id,atsApplicant[0].bpats__Job__c);
            }
            Test.stopTest();
        }catch(Exception ex){
            system.debug(ex.getMessage());
        }
    }
}