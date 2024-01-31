/**
 * @description       : 
 * @author            : Dhinesh Kumar
 * @group             : 
 * @last modified on  : 12/14/2022
 * @last modified by  : Dhinesh Kumar
**/
@isTest
public class AssessmentReport_Ctrl_Test{
    @TestSetup
    static void setupMethod(){
         List<Assessment_Report__c> assessmentReports = TestClassUtil.createTestAssessmentReport(); 
         TestClassUtil.createTestContactAssignment();
        
    }
    
    private static testMethod void testgetCommunityType(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
        
            try{
                
                System.runAs(user) {
                    String communityType = AssessmentReport_Ctrl.getCommunityType();                    
                }               
                
            }catch(Exception e){
            
                System.debug('EXception===='+e.getMessage());
            }
        Test.stopTest();
    }
    
      private static testMethod void testgetAssessments(){
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        List<Assessment_Report__c> assessmentReports = [SELECT Id, Instructor__c , Status__c, RecordType.DeveloperName, Project__c FROM Assessment_Report__c WHERE Instructor__c != null];
        System.debug('assessmentReports ::>'+assessmentReports);
        //List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        //System.debug('conList==='+conList);
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = assessmentReports[0].Instructor__c, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
        System.runAs(user) {
        AssessmentReport_Ctrl.assessmentCmpWrap wrap = AssessmentReport_Ctrl.getAssessments('All',null, 'All');
        }
        Test.stopTest();
    }
   
    private static testMethod void testAssessmentReport_CtrlMethods(){
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        List<Assessment_Report__c> assessmentReports = [SELECT Id, Project__c, Instructor__c FROM Assessment_Report__c];
        assessmentReports[0].Instructor__c = conList[0].Id;
        update assessmentReports;
        
        List<Contact_Assignments__c> conAssign = [SELECT Id, Status__c, Project__c FROM Contact_Assignments__c];
        conAssign[0].Status__c = 'Active';
        conAssign[0].RecordTypeId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByName().get('Student').getRecordTypeId(); 
        conAssign[0].Project__c = assessmentReports[0].Project__c;
        update conAssign;
        
        Test.startTest();
            System.runAs(user) {
                AssessmentReport_Ctrl.assessmentRecForEdit assessmentRecForEditObj = AssessmentReport_Ctrl.getAssessmentReportById(assessmentReports[0].Id);
                Assessment_Report__c assReport = assessmentRecForEditObj.assessmentRec;
                System.assertEquals(true, assessmentRecForEditObj.isAllowEdit);
                System.assertEquals(null, assReport.Instructor_Comment__c);
                
                AssessmentReport_Ctrl.ActionPlanAndTestScoreWrap actionWrap = AssessmentReport_Ctrl.getActionPlanAndTestScoreByAssessmentId(assessmentReports[0].Id);
                
                System.assertEquals(0,actionWrap.actionPlans.size());
                System.assertEquals(0,actionWrap.testScores.size());
                
                List<Test_Score__c> testScores = new List<Test_Score__c>{
                    new Test_Score__c(Assessment_Report__c = assReport.Id, Date__c = System.today(), Result__c = '10'),
                    new Test_Score__c(Assessment_Report__c = assReport.Id, Date__c = System.today(), Result__c = '10')
                };
                List<Action_Plan__c> actionPlans = new  List<Action_Plan__c>{
                    new Action_Plan__c(Assessment_Report__c = assReport.Id,From_Date__c=System.today(), To_date__c = System.today())
                };
                assReport.Instructor_Comment__c = 'test comment';
                
                AssessmentReport_Ctrl.SaveReportWrap saveWrap = new AssessmentReport_Ctrl.SaveReportWrap();
                saveWrap.assessmentReport = assReport;
                saveWrap.actionPlans = actionPlans;
                saveWrap.testScores = testScores;
                
                String result = AssessmentReport_Ctrl.saveAssessmentReport(JSON.serialize(saveWrap));
                System.assertEquals('success', result);
                
                assessmentRecForEditObj = AssessmentReport_Ctrl.getAssessmentReportById(assessmentReports[0].Id);
                assReport = assessmentRecForEditObj.assessmentRec;
                System.assertEquals('test comment', assReport.Instructor_Comment__c);
                
                actionWrap = AssessmentReport_Ctrl.getActionPlanAndTestScoreByAssessmentId(assessmentReports[0].Id);
                System.assertEquals(1,actionWrap.actionPlans.size());
                System.assertEquals(2,actionWrap.testScores.size());
                
                List<Id> recordsToDelete = new List<Id>();
                recordsToDelete.add(actionWrap.testScores[0].Id);
                
                saveWrap = new AssessmentReport_Ctrl.SaveReportWrap();
                saveWrap.assessmentReport = assReport;
                saveWrap.recordsToDelete = recordsToDelete;
                
                result = AssessmentReport_Ctrl.saveAssessmentReport(JSON.serialize(saveWrap));
                System.assertEquals('success', result);
                
                actionWrap = AssessmentReport_Ctrl.getActionPlanAndTestScoreByAssessmentId(assessmentReports[0].Id);
                System.assertEquals(1,actionWrap.actionPlans.size());
                System.assertEquals(1,actionWrap.testScores.size());
            }
        Test.stopTest();
    }
    @isTest
    public static void test_getAssessments_My_Observation_Report(){
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        List<Assessment_Report__c> assessmentReports = [SELECT Id, Instructor__c , Status__c, RecordType.DeveloperName, Project__c FROM Assessment_Report__c WHERE Instructor__c != null AND RecordType.DeveloperName = 'Observation_Report'];        
        
        if(assessmentReports.size() > 0){
                    
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = assessmentReports[0].Instructor__c, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                    timezonesidkey='America/Los_Angeles', username='test@testdlsobservationreport.com');
        
            insert user;

            assessmentReports[0].Status__c = 'Completed';
            assessmentReports[0].Date_Completed__c = System.today();
            update assessmentReports;

            List<AcctSeed__Project__c> projectList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
            
            AssessmentReport_Ctrl.assessmentCmpWrap wrap;
            
            Test.startTest();
            System.runAs(user) {
                wrap = AssessmentReport_Ctrl.getAssessments('All',projectList[0].Id, 'My Observation Report');
            }
            Test.stopTest();
            System.assert(wrap.assessments[0].recordTypeDevName == 'Observation_Report');
        }
    }
    @isTest
    public static void test_getAssessments_My_Annual_Reports(){
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        List<Assessment_Report__c> assessmentReports = [SELECT Id, Instructor__c , Status__c, RecordType.DeveloperName, Project__c FROM Assessment_Report__c WHERE Instructor__c != null];
        System.debug('assessmentReports ::>'+assessmentReports);
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = assessmentReports[0].Instructor__c, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='test@testdlsmyannualreport.com');
       
        insert user;
        
        Id annualPerformanceReportId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Annual_Instructor_Performance_Review').getRecordTypeId();
        
        Assessment_Report__c assessmentReportAnnual = new Assessment_Report__c(Name = 'AIPRReport',Project__c=assessmentReports[0].Project__c,RecordTypeId = annualPerformanceReportId,Status__c = 'Completed',Instructor__c = assessmentReports[0].Instructor__c,Classes_Conducted_Primarily_in_Target__c = 'Meets',Prepares_for_Each_Class_and_Assigns__c = 'Meets',Prepares_and_Uses_Student_Centered_Act__c = 'Meets',Shows_Ability_to_Work_Beyond__c = 'Meets',Understands_ILR_Levels__c = 'Meets',Receives_Consistently_Positive_Feedback__c = 'Meets',Performs_Uses_Assessment__c = 'Meets',Utilizes_Technology_Appropriately__c = 'Meets',Participates_in_Teacher_Training__c = 'Meets',Helps_LTS_Prepare_Programs__c = 'Meets',Contributes_in_Helping_Other__c = 'Meets',Willing_to_Share_Resources__c = 'Meets',Participates_in_Extracurricular_Events__c = 'Meets',Adheres_to_DLS_Code_of_Conduct__c = 'Meets',Communicates_Clearly_and_Openly__c = 'Meets',Works_Collaboratively__c = 'Meets',Exemplifies_Professional_Behavior__c = 'Meets',Understands_and_Adapts_Behaviors__c = 'Meets',Submits_Thoughtfully_Completed__c = 'Meets',Uses_Correct_Methods_to_Request_Time__c = 'Meets',Brings_Potential_Problems__c = 'Meets',Offers_Ideas_and_Suggestions_to_Improve__c = 'Meets',Has_Good_Rapport__c = 'Meets');
        insert assessmentReportAnnual;
        List<AcctSeed__Project__c> projectList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        
        AssessmentReport_Ctrl.assessmentCmpWrap wrap;
        
        Test.startTest();
        System.runAs(user) {
            wrap = AssessmentReport_Ctrl.getAssessments('All',projectList[0].Id, 'My Annual Reports');
        }
        Test.stopTest();
        System.assert(wrap.assessments[0].recordTypeDevName == 'Annual_Instructor_Performance_Review');
    }
    @isTest
    public static void test_getAssessments_Test_Reports(){
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        List<Assessment_Report__c> assessmentReports = [SELECT Id, Instructor__c , Status__c, RecordType.DeveloperName, Project__c FROM Assessment_Report__c WHERE Instructor__c != null LIMIT 1];
        System.debug('assessmentReports ::>'+assessmentReports);
        if(assessmentReports.size() > 0) {
            assessmentReports[0].Status__c = 'Completed';
            assessmentReports[0].Date_Completed__c = System.Today();
            update assessmentReports;
            
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = assessmentReports[0].Instructor__c, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                    timezonesidkey='America/Los_Angeles', username='test@testdlstestreports.com');
           
            insert user;
            
            List<AcctSeed__Project__c> projectList = [SELECT Id,Name FROM AcctSeed__Project__c WHERE Id =: assessmentReports[0].Project__c LIMIT 1];
            AssessmentReport_Ctrl.assessmentCmpWrap wrap;
            
            Test.startTest();
            System.runAs(user) {
                wrap = AssessmentReport_Ctrl.getAssessments('All',projectList[0].Id, 'All');
            }
            Test.stopTest();
            if(wrap.assessments.size() > 0){
                System.assert(wrap.assessments.size() > 0);
            }
        }
    }
    @isTest
    public static void test_getAssessments_All(){
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        List<Assessment_Report__c> assessmentReports = [SELECT Id, Instructor__c , Status__c, RecordType.DeveloperName, Project__c FROM Assessment_Report__c WHERE Instructor__c != null];
        System.debug('assessmentReports ::>'+assessmentReports);
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = assessmentReports[0].Instructor__c, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        List<AcctSeed__Project__c> projectList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        
        AssessmentReport_Ctrl.assessmentCmpWrap wrap;
        
        Test.startTest();
        System.runAs(user) {
            wrap = AssessmentReport_Ctrl.getAssessments('All',projectList[0].Id, 'All');
        }
        Test.stopTest();
        System.assert(wrap.assessments[0].recordTypeDevName == 'DLI_W_Progress');
    }
    @isTest
    public static void test_saveAssessmentReport_Exception(){
        String saveWrap = 'Test Non-JSON Record';
        String result;
        try{
            Test.startTest();
            result = AssessmentReport_Ctrl.saveAssessmentReport(JSON.serialize(saveWrap));
            Test.stopTest();
        }
        finally{
            System.assert(result.contains('Malformed JSON'));
        }
    }
}