/* Created by Siva Prasanth K.T on 07/22/2019 */
@isTest
public class GenericUrlLaunch_Ctrl_Test {

    @testSetup static void setupMethod(){ 
            
        Test.startTest();
            List<Contact_Assignments__c> conAssigns = TestClassUtil.createTestContactAssignment();
        Test.stopTest();
        List<Quote> testQuote = TestClassUtil.createTestQuote();
    }
    
    private static testMethod void myTest1(){
                
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<User> userList = [SELECT Id FROM User LIMIT 1];
         
        List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
            new Assessment_Report__c(Name = 'Test Report1', Project_Manager__c = userList[0].Id, Instructor__c = conList[1].Id, Project__c = projList[0].Id, Report_Type__c = 'DLI',Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
        };
        
        insert assReport;
        
        box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = assReport[0].Id);
        insert frup;
        
        List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c> {
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'DLI Report', APXTConga4__Template_Group__c = 'Assessment Report')
        };
        insert congaTemp;
        
        CongaButtonsController.generateWrapper wrap = GenericUrlLaunch_Ctrl.getCongaUrlInfo('Assessment_Report__c',assReport[0].Id);
        System.assertEquals(' test ',wrap.sessionIdServerURL);
    }
    private static testMethod void myTestLangTrainReport(){
                
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<User> userList = [SELECT Id FROM User LIMIT 1];

        List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
            new Assessment_Report__c(Name = 'Test Report1', Project_Manager__c = userList[0].Id, Instructor__c = conList[1].Id, Project__c = projList[0].Id,Report_Type__c = 'Language Training' ,Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
        };
        insert assReport;
        
        box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = assReport[0].Id);
        insert frup;
        
        List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c> {
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Language Training Report', APXTConga4__Template_Group__c = 'Assessment Report')
        };
        insert congaTemp;
        
        CongaButtonsController.generateWrapper wrap = GenericUrlLaunch_Ctrl.getCongaUrlInfo('Assessment_Report__c',assReport[0].Id);
        System.assertEquals(' test ',wrap.sessionIdServerURL);

    }
    private static testMethod void myTestDLIWReport(){
                
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<User> userList = [SELECT Id FROM User LIMIT 1];

        List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
            new Assessment_Report__c(Name = 'Test Report1', Project_Manager__c = userList[0].Id, Instructor__c = conList[1].Id, Project__c = projList[0].Id,Report_Type__c = 'DLI' ,Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
        };
        insert assReport; 
        
        box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = assReport[0].Id); 
        insert frup;
        
        List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c> {
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'DLI-W Progress 2022 Report', APXTConga4__Template_Group__c = 'Assessment Report')
        };
        insert congaTemp;
        
        CongaButtonsController.generateWrapper wrap = GenericUrlLaunch_Ctrl.getCongaUrlInfo('Assessment_Report__c',assReport[0].Id);
        System.assertEquals(' test ',wrap.sessionIdServerURL);

    }
     private static testMethod void myTestCoverAPMOReport(){
                
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<User> userList = [SELECT Id FROM User LIMIT 1];

        List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
            new Assessment_Report__c(Name = 'Test Report1', Project_Manager__c = userList[0].Id, Instructor__c = conList[1].Id, Project__c = projList[0].Id,Report_Type__c = 'APMO' ,Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
        };
        insert assReport; 
        
        box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = assReport[0].Id); 
        insert frup;
        
        List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c> {
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'APMO Progress Report', APXTConga4__Template_Group__c = 'Assessment Report')
        };
        insert congaTemp;
        
        CongaButtonsController.generateWrapper wrap = GenericUrlLaunch_Ctrl.getCongaUrlInfo('Assessment_Report__c',assReport[0].Id);
        System.assertEquals(' test ',wrap.sessionIdServerURL);

    }
    
     private static testMethod void myTestCoverDEAReport(){
                
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<User> userList = [SELECT Id FROM User LIMIT 1];

        List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
            new Assessment_Report__c(Name = 'Test Report1', Project_Manager__c = userList[0].Id, Instructor__c = conList[1].Id, Project__c = projList[0].Id,Report_Type__c = 'DEA' ,Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
        };
        insert assReport; 
        
        box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = assReport[0].Id); 
        insert frup;
        
        List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c> {
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'DEA Progress Report', APXTConga4__Template_Group__c = 'Assessment Report')
        };
        insert congaTemp;
        
        CongaButtonsController.generateWrapper wrap = GenericUrlLaunch_Ctrl.getCongaUrlInfo('Assessment_Report__c',assReport[0].Id);
        System.assertEquals(' test ',wrap.sessionIdServerURL);

    }
    
    
    // This method  to display message 'Already this Progress Report is Submitted to report Student'
      private static testMethod void myTest3(){
                
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 1];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
          
        List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
            new Assessment_Report__c(Name = 'Test Report1',Project__c = projList[0].Id,Report_Type__c = 'FAS' ,Status__c = 'Submitted to Student',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
        };
        insert assReport;
        
        box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = assReport[0].Id);
        insert frup;
          
        CongaButtonsController.generateWrapper wrap = GenericUrlLaunch_Ctrl.getCongaUrlInfo('Assessment_Report__c',assReport[0].Id);
        System.assertEquals(wrap.errorMsg , 'This Progress Report has already been submitted to the Student');
    }
    // This method  to display message 'Please following fields: Manager and Instructor,'
    private static testMethod void myTest4(){
                
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
                
        List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
            new Assessment_Report__c(Name = 'Test Report1', Project__c = projList[0].Id, Report_Type__c = 'DLI',Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
        };
        insert assReport;
        
        box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = assReport[0].Id);
        insert frup;
    
        CongaButtonsController.generateWrapper wrap = GenericUrlLaunch_Ctrl.getCongaUrlInfo('Assessment_Report__c',assReport[0].Id);
        System.assertEquals('Please populate following fields: Manager and Instructor.',wrap.errorMsg);
    }
    // this method to display 'Please populate following fields: Student, Instructor and Manager.'s
    private static testMethod void myTest5(){
                
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];

        List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
            new Assessment_Report__c(Name = 'Test Report1', Project__c = projList[0].Id,Report_Type__c = 'Language Training' ,Status__c = 'Draft',Language__c = 'Tamil',Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
        };
        insert assReport;
        
        box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = assReport[0].Id);
        insert frup;
                
        CongaButtonsController.generateWrapper wrap = GenericUrlLaunch_Ctrl.getCongaUrlInfo('Assessment_Report__c',assReport[0].Id);
        System.assertEquals('Please populate following fields: Student, Instructor and Manager.',wrap.errorMsg);

    }
     private static testMethod void myTest6(){
                
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<User> userList = [SELECT Id FROM User LIMIT 1];
        
        List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
            new Assessment_Report__c(Name = 'Test Report1', Instructor__c = conList[1].Id, Project__c = projList[0].Id,Report_Type__c = 'Language Training' ,Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
        };
        insert assReport;
         
         box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = assReport[0].Id);
         insert frup;
        
         CongaButtonsController.generateWrapper wrap = GenericUrlLaunch_Ctrl.getCongaUrlInfo('Assessment_Report__c',assReport[0].Id);
         System.assertEquals('Please populate Manager.',wrap.errorMsg);
         
         Test.startTest();
         assReport[0].Student__c = null;
         update assReport;
         
         CongaButtonsController.generateWrapper wrap1 = GenericUrlLaunch_Ctrl.getCongaUrlInfo('Assessment_Report__c',assReport[0].Id);
         System.assertEquals('Please populate following fields: Student and Manager.',wrap1.errorMsg);
         Test.stopTest();
         
     }
    
    private static testMethod void myTest7(){
        
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<User> userList = [SELECT Id FROM User LIMIT 1];

        List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
            new Assessment_Report__c(Name = 'Test Report1', Project__c = projList[0].Id,Report_Type__c = 'Language Training' ,Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
        };
        insert assReport;
        
        box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = assReport[0].Id);
        insert frup;
         
         Test.startTest();
         GenericUrlLaunch_Ctrl.getCongaUrlInfo('Assessment_Report__c',assReport[0].Id);

         assReport[0].Student__c = null;
         assReport[0].Project_Manager__c = userList[0].Id;
         update assReport;

         CongaButtonsController.generateWrapper wrap = GenericUrlLaunch_Ctrl.getCongaUrlInfo('Assessment_Report__c',assReport[0].Id);
         System.assertEquals('Please populate following fields: Student and Instructor.',wrap.errorMsg);
         Test.stopTest();       
     }
       
    private static testMethod void myTest8(){
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
       
        String obType = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('DLI_W_Progress').getRecordTypeId();

        List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
            new Assessment_Report__c(Name = 'Test Report1', Project__c = projList[0].Id,Report_Type__c = 'Language Training' ,Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10,RecordTypeId = obType)
         };
         insert assReport;
        
        insert new box__Folder_Details__c(Name = 'Assessment Reports',box__FolderId__c = '1235');
        insert new box__FRUP__c(box__Record_ID__c = assReport[0].Id);
        
        Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new HttpResponseMockGenerator.ZapierUtilMock1());
            
            CongaButtonsController.generateWrapper wrap = GenericUrlLaunch_Ctrl.getCongaUrlInfo('Assessment_Report__c',assReport[0].Id);
            System.assertEquals('Please populate following fields: Manager and Instructor.',wrap.errorMsg);
        Test.stopTest();
     }
    private static testMethod void myTest9(){
        
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        
        String obType = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('DLI_W_Progress').getRecordTypeId();

        List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
            new Assessment_Report__c(Name = 'Test Report1', Project__c = projList[0].Id,Report_Type__c = 'Language Training' ,Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10,RecordTypeId = obType)
        };
        insert assReport;
        
        insert new box__FRUP__c(box__Record_ID__c = assReport[0].Id,box__Folder_ID__c = '12345');
        
        Test.startTest();
        
        GenericUrlLaunch_Ctrl.updateAssesmentReports(assReport[0].Id);
        List<Assessment_Report__c> assRep = [SELECT Id FROM Assessment_Report__c WHERE Box_Folder_Id__c  = '12345'];
        System.assertEquals(assRep.size() > 0,true);
        
        Test.stopTest();
    }
     private static testMethod void myTest10(){ 
        
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];

        box__FRUP__c boxfrup = new box__FRUP__c();
        
        String obType = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('DLI_W_Progress').getRecordTypeId();
         
         List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
             new Assessment_Report__c(Name = 'Test Report1', Project__c = projList[0].Id,Report_Type__c = 'Language Training' ,Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10,RecordTypeId = obType)
           };
         insert assReport;
         
         Test.startTest();
         
         boxfrup =  new box__FRUP__c(box__Record_ID__c = assReport[0].Id,box__Folder_ID__c = '12345',box__Object_Name__c = 'Assessment_Report__c');
         GenericUrlLaunch_Ctrl.createBoxFRUPRecs(JSON.serialize(boxfrup));
         
         List<box__FRUP__c> frup = [SELECT Id FROM box__FRUP__c WHERE box__Record_ID__c = :assReport[0].Id];
         System.assertEquals(assReport.size() > 0,true);
         
         Test.stopTest();
     }
    private static testMethod void myTest12(){
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
      
        try{
            String obType = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Observation_Report').getRecordTypeId();
            Test.setMock(HttpCalloutMock.class, new HttpResponseMockGenerator.ZapierUtilMock1());
           
            List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
                new Assessment_Report__c(Name = 'Test Report1', Project__c = projList[0].Id,Report_Type__c = 'Language Training' ,Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10,RecordTypeId = obType)
                    };
                        insert assReport;
            
            Test.startTest(); 
            insert new box__Folder_Details__c(Name = 'Assessment Reports',box__FolderId__c = '1235');
            insert new box__FRUP__c(box__Record_ID__c = assReport[0].Id);
            
            CongaButtonsController.generateWrapper wrap = GenericUrlLaunch_Ctrl.getCongaUrlInfo('Assessment_Report__c',assReport[0].Id);
            System.assertEquals('This process is not available for Observation Report Record Type.',wrap.errorMsg);
            Test.stopTest();
        }catch (exception ex){
            System.assertEquals('Script-thrown exception',ex.getMessage());
        }
    }
   
    // This Test method get the Opportunity Procedure Info
    private static testMethod void myTest11(){
       try{       
            List<Quote> quoteList = [SELECT Id,OpportunityId FROM Quote WHERE OpportunityId != null LIMIT 1 ];
           
           Test.startTest();
           
           List<Contact_Assignments__c> conAssigns = [SELECT Id,Opportunity_Name__c FROM Contact_Assignments__c WHERE Recordtype.DeveloperName = 'Student' LIMIT 1];
           if(conAssigns.size() > 0){
               conAssigns[0].Opportunity_Name__c = quoteList[0].OpportunityId;
               update conAssigns;
               
               List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c> {
                 new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'PVT Enrollment Form', APXTConga4__Template_Group__c = 'Assessment Report')
               };
               insert congaTemp;
               
               box__Folder_Details__c boxFolder = new box__Folder_Details__c();
               boxFolder.box__Folder_Name__c = 'test';
               boxFolder.Name = conAssigns[0].Opportunity_Name__c;
               insert boxFolder;
               
               box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = quoteList[0].OpportunityId);
               insert frup;
                
                String result = GenericUrlLaunch_Ctrl.validateOppStartAndEndDateForPolicyAndProcedure(quoteList[0].OpportunityId); 
                System.assertEquals('success', result);
           }
           CongaButtonsController.generateWrapper wrap = GenericUrlLaunch_Ctrl.getStudentProcedureInfo('Opportunity', quoteList[0].OpportunityId);
           System.assertEquals(' test ',wrap.sessionIdServerURL);
           Test.stopTest();
       }catch(Exception ex){
           System.assertEquals('Script-thrown exception',ex.getMessage());
       }
    }
    // This Test method handle the Refund calculation
    private static testMethod void myTest13(){
        List<AcctSeed__Project__c> projList = [SELECT Id,AcctSeed__Status__c FROM AcctSeed__Project__c LIMIT 1];
        
        if(projList.size() > 0){
            projList[0].AcctSeed__Status__c = 'Canceled';
            update projList;
            
            CongaButtonsController.generateWrapper wrap = GenericUrlLaunch_Ctrl.getRefundCalculationInfo(projList[0].Id);
            System.assertEquals(' test ',wrap.sessionIdServerURL);
        }
    }
    // This Test method handle the Refund calculation ErrorMsg
    private static testMethod void myTest14(){ 
        List<AcctSeed__Project__c> projList = [SELECT Id,AcctSeed__Status__c FROM AcctSeed__Project__c WHERE (AcctSeed__Status__c != 'Canceled' OR AcctSeed__Status__c != 'Ended') LIMIT 1];
        
        if(projList.size() > 0){  
            CongaButtonsController.generateWrapper wrap = GenericUrlLaunch_Ctrl.getRefundCalculationInfo(projList[0].Id);
            System.assertEquals('This Process only for Canceled or Ended Projects.',wrap.errorMsg);
        }
    }
    // This Test method to create ErrorLog
    private static testMethod void myTest15(){
        try{
            GenericUrlLaunch_Ctrl.createErrorLog('GenericLaunchCmp','Aura Component', 'Controller', 'Script-Thrown Exception' ,'','Opportunity');
        }catch(Exception ex){
            System.assertEquals('Script-thrown exception',ex.getMessage());
        }
    } 
    // This Test method to get Project Student Procedure Info
    private static testMethod void myTest16(){
        try{       
            List<Contact_Assignments__c> conList = [SELECT Id, Project__c FROM Contact_Assignments__c WHERE Project__c != null AND RecordType.DeveloperName = 'Student' LIMIT 1];
            
            Test.startTest();
            
            if(conList.size() > 0){
                List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c> {
                 new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Student Policies & Procedures', APXTConga4__Template_Group__c = 'Assessment Report')
               };
                insert congaTemp;
                
                 
               box__Folder_Details__c boxFolder = new box__Folder_Details__c();
               boxFolder.box__Folder_Name__c = 'test';
               boxFolder.Name = conList[0].Project__c; 
               insert boxFolder;
               
               box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = conList[0].Project__c); 
               insert frup;
                
                    
                CongaButtonsController.generateWrapper wrap = GenericUrlLaunch_Ctrl.getStudentProcedureInfo('AcctSeed__Project__c', conList[0].Project__c);
                System.assertEquals(' test ',wrap.sessionIdServerURL);
            }
            Test.stopTest();
        }catch(Exception ex){
            System.assertEquals('Script-thrown exception',ex.getMessage());
        }
    }
    
       private static testMethod void myTest17(){
        try{       
            List<Contact_Assignments__c> conList = [SELECT Id, Project__c FROM Contact_Assignments__c WHERE Project__c != null AND RecordType.DeveloperName = 'Student' LIMIT 1];
            
            Test.startTest();
            
            if(conList.size() > 0){
                List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c> {
                 new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Student Policies & Procedures', APXTConga4__Template_Group__c = 'Assessment Report')
               };
                insert congaTemp;
                
                 
               box__Folder_Details__c boxFolder = new box__Folder_Details__c();
               boxFolder.box__Folder_Name__c = 'test';
               boxFolder.Name = conList[0].Project__c; 
               insert boxFolder;
                
                CongaButtonsController.generateWrapper wrap = GenericUrlLaunch_Ctrl.getStudentProcedureInfo('AcctSeed__Project__c', conList[0].Project__c);
                System.assertEquals(' test ',wrap.sessionIdServerURL);
            }
            Test.stopTest();
        }catch(Exception ex){
            System.assertEquals('Script-thrown exception',ex.getMessage());
        }
    }
      private static testMethod void myTest18(){
                 
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
          
          if(projList.size() > 0){              
              box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = projList[0].Id);
              insert frup;
              GenericUrlLaunch_Ctrl.updateOppProjects(projList[0].Id, 'AcctSeed__Project__c'); 

          }
          
    }
    private static testMethod void myTest19(){
                 
        List<Opportunity> oppList = [SELECT Id FROM Opportunity LIMIT 1];
          
          if(oppList.size() > 0){              
              box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = oppList[0].Id);
              insert frup;
              GenericUrlLaunch_Ctrl.updateOppProjects(oppList[0].Id, 'Opportunity'); 

          }
          
    }
    private static testmethod void testcreateBoxFRUPRecs(){
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Opportunity> oppList = [SELECT Id FROM Opportunity LIMIT 1];
        
        box__FRUP__c boxfrup =  new box__FRUP__c(box__Record_ID__c = projList[0].Id,box__Folder_ID__c = '1278345',box__Object_Name__c = 'AcctSeed__Project__c');
        GenericUrlLaunch_Ctrl.createBoxFRUPRecs(JSON.serialize(boxfrup));
         
        boxfrup =  new box__FRUP__c(box__Record_ID__c = oppList[0].Id,box__Folder_ID__c = '1278345',box__Object_Name__c = 'Opportunity');
        GenericUrlLaunch_Ctrl.createBoxFRUPRecs(JSON.serialize(boxfrup));
    }
    
    private static testMethod void validateAssessmentRecBoxFolderTest(){
                
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<User> userList = [SELECT Id FROM User LIMIT 1];
        
        Id observationRecordTypeId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Observation_Report').getRecordTypeId();
        List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
            new Assessment_Report__c(Report_Date__c = System.Today(),RecordTypeId=observationRecordTypeId, Name = 'Test Report1', Project_Manager__c = userList[0].Id, Instructor__c = conList[1].Id, Project__c = projList[0].Id, Report_Type__c = 'DLI',Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10),
            new Assessment_Report__c(Report_Date__c = System.Today(),RecordTypeId=observationRecordTypeId, Name = 'Test Report2', Project_Manager__c = userList[0].Id, Instructor__c = conList[1].Id, Project__c = projList[0].Id, Report_Type__c = 'DLI',Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
        };
        
        insert assReport;
        
        box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = assReport[0].Id);
        insert frup;
        
        List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c> {
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Observation Report', APXTConga4__Template_Group__c = 'Observation Report')
        };
        insert congaTemp;
        
        string result = GenericUrlLaunch_Ctrl.validateAssessmentRecBoxFolder(assReport[0].Id);
        box__Folder_Details__c boxDetails  = new box__Folder_Details__c(Name='Training Reports', box__FolderId__c='1256',box__Folder_Name__c='Training Reports');
        insert boxDetails;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HttpResponseMockGenerator.ZapierUtilMock1());
            result = GenericUrlLaunch_Ctrl.validateAssessmentRecBoxFolder(assReport[1].Id);
          //  System.assertEquals('No Box Record',result ); 
        Test.stopTest();
    }
    private static testMethod void validateAssessmentRecBoxFolderTes1(){
                
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<User> userList = [SELECT Id FROM User LIMIT 1];
        
        Id observationRecordTypeId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Test_Report').getRecordTypeId();
        List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
            new Assessment_Report__c(Report_Date__c = System.Today(),RecordTypeId=observationRecordTypeId, Name = 'Test Report1', Project_Manager__c = userList[0].Id, Instructor__c = conList[1].Id, Project__c = projList[0].Id, Report_Type__c = 'DLI',Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10),
            new Assessment_Report__c(Report_Date__c = System.Today(),RecordTypeId=observationRecordTypeId, Name = 'Test Report2', Project_Manager__c = userList[0].Id, Instructor__c = conList[1].Id, Project__c = projList[0].Id, Report_Type__c = 'DLI',Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
        };
        
        insert assReport;
        
        box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = assReport[0].Id);
        insert frup;
        
        List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c> {
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Observation Report', APXTConga4__Template_Group__c = 'Observation Report')
        };
        insert congaTemp;
        
        string result = GenericUrlLaunch_Ctrl.validateAssessmentRecBoxFolder(assReport[0].Id);
        box__Folder_Details__c boxDetails  = new box__Folder_Details__c(Name='Training Reports', box__FolderId__c='1256',box__Folder_Name__c='Training Reports');
        insert boxDetails;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HttpResponseMockGenerator.ZapierUtilMock1());
            result = GenericUrlLaunch_Ctrl.validateAssessmentRecBoxFolder(assReport[1].Id);
          //  System.assertEquals('No Box Record',result ); 
        Test.stopTest();
    }
    
    private static testMethod void validateAssessmentRecBoxFolderTest2(){
                
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        conList[0].LastName = 'Con1';
        conList[1].LastName = 'Con2';
        update conList;
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<User> userList = [SELECT Id FROM User LIMIT 1];
        
        Id observationRecordTypeId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('DLI_W_Test_Report').getRecordTypeId();
        List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
            new Assessment_Report__c(Report_Date__c = System.Today(),RecordTypeId=observationRecordTypeId, Name = 'Test Report1', Project_Manager__c = userList[0].Id, Instructor__c = conList[1].Id, Project__c = projList[0].Id, Report_Type__c = 'DLI',Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10),
            new Assessment_Report__c(Report_Date__c = System.Today(),RecordTypeId=observationRecordTypeId, Name = 'Test Report2', Project_Manager__c = userList[0].Id, Instructor__c = conList[1].Id, Project__c = projList[0].Id, Report_Type__c = 'DLI',Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
        };
        
        insert assReport;
        
        box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = assReport[0].Id);
        insert frup;
        
        List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c> {
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Observation Report', APXTConga4__Template_Group__c = 'Observation Report')
        };
        insert congaTemp;
        
        string result = GenericUrlLaunch_Ctrl.validateAssessmentRecBoxFolder(assReport[0].Id);
        box__Folder_Details__c boxDetails  = new box__Folder_Details__c(Name='Training Reports', box__FolderId__c='1256',box__Folder_Name__c='Training Reports');
        insert boxDetails;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HttpResponseMockGenerator.ZapierUtilMock1());
            result = GenericUrlLaunch_Ctrl.validateAssessmentRecBoxFolder(assReport[1].Id);
          //  System.assertEquals('No Box Record',result ); 
        Test.stopTest();
    }
    private static testMethod void validateAssessmentRecBoxFolderTest3(){
                
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<User> userList = [SELECT Id FROM User LIMIT 1];
        
        Id observationRecordTypeId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('DLI_W_Self_Assessment_Test_Report').getRecordTypeId();
        List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
            new Assessment_Report__c(Report_Date__c = System.Today(),RecordTypeId=observationRecordTypeId, Name = 'Test Report1', Project_Manager__c = userList[0].Id, Instructor__c = conList[1].Id, Project__c = projList[0].Id, Report_Type__c = 'DLI',Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10),
            new Assessment_Report__c(Report_Date__c = System.Today(),RecordTypeId=observationRecordTypeId, Name = 'Test Report2', Project_Manager__c = userList[0].Id, Instructor__c = conList[1].Id, Project__c = projList[0].Id, Report_Type__c = 'DLI',Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
        };
        
        insert assReport;
        
        box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = assReport[0].Id);
        insert frup;
        
        List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c> {
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Observation Report', APXTConga4__Template_Group__c = 'Observation Report')
        };
        insert congaTemp;
        
        string result = GenericUrlLaunch_Ctrl.validateAssessmentRecBoxFolder(assReport[0].Id);
        box__Folder_Details__c boxDetails  = new box__Folder_Details__c(Name='Training Reports', box__FolderId__c='1256',box__Folder_Name__c='Training Reports');
        insert boxDetails;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HttpResponseMockGenerator.ZapierUtilMock1());
            result = GenericUrlLaunch_Ctrl.validateAssessmentRecBoxFolder(assReport[1].Id);
          //  System.assertEquals('No Box Record',result ); 
        Test.stopTest();
    }
    private static testMethod void validateAssessmentRecBoxFolderTest4(){
                
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<User> userList = [SELECT Id FROM User LIMIT 1];
        
        Id observationRecordTypeId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Annual_Instructor_Performance_Review').getRecordTypeId();
        List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
            new Assessment_Report__c(Contributes_in_Helping_Other__c='Meets', 
                                     Willing_to_Share_Resources__c = 'Meets',
                                     Participates_in_Extracurricular_Events__c = 'Meets',
                                     Adheres_to_DLS_Code_of_Conduct__c = 'Meets',
                                     Communicates_Clearly_and_Openly__c = 'Meets',
                                     Works_Collaboratively__c = 'Meets',
                                     Exemplifies_Professional_Behavior__c = 'Meets',
                                     Understands_and_Adapts_Behaviors__c = 'Meets',
                                     Submits_Thoughtfully_Completed__c = 'Meets',
                                     Uses_Correct_Methods_to_Request_Time__c = 'Meets',
                                     Brings_Potential_Problems__c = 'Meets',
                                     Offers_Ideas_and_Suggestions_to_Improve__c = 'Meets',
                                     Has_Good_Rapport__c = 'Meets',
                                     Helps_LTS_Prepare_Programs__c='Meets',
                                     Participates_in_Teacher_Training__c='Meets',
                                     Utilizes_Technology_Appropriately__c='Meets',
                                     Performs_Uses_Assessment__c='Meets',
                                     Receives_Consistently_Positive_Feedback__c='Meets',
                                     Understands_ILR_Levels__c='Meets',
                                     Prepares_and_Uses_Student_Centered_Act__c='Meets',
                                     Shows_Ability_to_Work_Beyond__c='Meets',
                                     Prepares_for_Each_Class_and_Assigns__c='Meets',
                                     Classes_Conducted_Primarily_in_Target__c='Meets',
                                     Has_Good_Rapport_Comments__c = 'Test',Report_Date__c = System.Today(),RecordTypeId=observationRecordTypeId, Name = 'Test Report1', Project_Manager__c = userList[0].Id, Instructor__c = conList[1].Id, Project__c = projList[0].Id, Report_Type__c = 'DLI',Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
        };
        
        insert assReport;
        
        box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = assReport[0].Id);
        insert frup;
        
        List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c> {
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Observation Report', APXTConga4__Template_Group__c = 'Observation Report')
        };
        insert congaTemp;
        
        string result = GenericUrlLaunch_Ctrl.validateAssessmentRecBoxFolder(assReport[0].Id);
        box__Folder_Details__c boxDetails  = new box__Folder_Details__c(Name='Training Reports', box__FolderId__c='1256',box__Folder_Name__c='Training Reports');
        insert boxDetails;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HttpResponseMockGenerator.ZapierUtilMock1());
            result = GenericUrlLaunch_Ctrl.validateAssessmentRecBoxFolder(assReport[0].Id);
            System.assertEquals(true,result.contains('Instructor Annual Performance Review – '+conList[1].Name));   
        Test.stopTest();
    }
    
    private static testMethod void validateSendDLSOfficeProcedure(){
                
        List<AcctSeed__Project__c> projList = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        List<Contact_Assignments__c> caList = [SELECT Id FROM Contact_Assignments__c];        
        
        List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c> {
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'DLS Office Procedure', APXTConga4__Template_Group__c = 'DLS Office Procedure')
        };
        insert congaTemp;
        GenerateCertificateCmp_Ctrl.GenerateCertificateWrap wrapObj = new GenerateCertificateCmp_Ctrl.GenerateCertificateWrap();        
        box__Folder_Details__c boxDetails  = new box__Folder_Details__c(Name='Opportunities', box__FolderId__c='1256',box__Folder_Name__c='Opportunities');
        insert boxDetails;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HttpResponseMockGenerator.ZapierUtilMock1());
            wrapObj = (GenerateCertificateCmp_Ctrl.GenerateCertificateWrap)JSON.deserialize(GenericUrlLaunch_Ctrl.getRecordsAndCongaUrlForSendDLSOfficeProcedure(projList[0].Id), GenerateCertificateCmp_Ctrl.GenerateCertificateWrap.class);        
            //System.assertEquals('No Box Record',wrapObj.errorMsg); 
        Test.stopTest();
        
        box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = projList[0].Id);
        insert frup;
        
        wrapObj = (GenerateCertificateCmp_Ctrl.GenerateCertificateWrap)JSON.deserialize(GenericUrlLaunch_Ctrl.getRecordsAndCongaUrlForSendDLSOfficeProcedure(projList[0].Id), GenerateCertificateCmp_Ctrl.GenerateCertificateWrap.class);
        System.assertNotEquals('No Box Record',wrapObj.errorMsg); 
        
        String result = GenericUrlLaunch_Ctrl.updateContactRecords(Json.serialize(caList),true);        
    }
    private static testMethod void myTest23(){
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
      
        try{
            String obType = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Observation_Report').getRecordTypeId();
            Test.setMock(HttpCalloutMock.class, new HttpResponseMockGenerator.ZapierUtilMock1());
            
            List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
                new Assessment_Report__c(Name = 'Test Report1', Project__c = projList[0].Id,Report_Type__c = 'Language Training' ,Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Report_Date__c = System.today(),Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10,RecordTypeId = obType)
            };
             insert assReport;
            
            Test.startTest(); 
            insert new box__Folder_Details__c(Name = 'Assessment Reports',box__FolderId__c = '1235');
            GenericUrlLaunch_Ctrl.calloutToCreateBoxRecs(assReport[0].Id ,'Assessment Reports1' ,'Assessment Reports','Assessment_Report__c');
            Test.stopTest();
        }catch (exception ex){
            System.assertEquals('Script-thrown exception',ex.getMessage());
        }
    }
      private static testMethod void myTest24(){
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
      
        try{
            String obType = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Observation_Report').getRecordTypeId();
            
            List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
                new Assessment_Report__c(Name = 'Test Report1', Project__c = projList[0].Id,Report_Type__c = 'Language Training' ,Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[0].Id,Sponser__c = accList[0].Id,Report_Date__c = System.today(),Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10,RecordTypeId = obType)
            };
           insert assReport;
            
            
            box__FRUP__c frup= new box__FRUP__c(box__Record_ID__c = assReport[0].Id);
            insert frup;
           GenericUrlLaunch_Ctrl.validateAndInitiateBoxFolderCreation(assReport[0].Id,'Testing Reports','parentFolder','AcctSeed__Cost_Rates__c');
            
        }catch (exception ex){
            System.assertEquals('Script-thrown exception',ex.getMessage());
        }
    }
}