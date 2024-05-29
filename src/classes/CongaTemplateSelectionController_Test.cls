@isTest
Private Class CongaTemplateSelectionController_Test{
    @testsetup static void setup() {
        
        List<Contact_Assignments__c> caList = TestClassUtil.createTestContactAssignment(); 
        Test.startTest();
        List<AcctSeed__Cost_Rates__c> crList = TestClassUtil.createTestCostRates();
        List<APXTConga4__Conga_Template__c> ctList = TestClassUtil.createCongaTemplate(); 
        List<APXTConga4__Conga_Merge_Query__c> cqList = TestClassUtil.createCongaQuery();
        Test.stopTest(); 
        
    }  
     
    // Gen & Send DocuSign
    private static testMethod void testMethod1() {
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null LIMIT 1];
        if( costRateList.size() > 0 ) {
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            costRateList[0].Gen_Email_Doc_Conga_Workflow_Template__c = 'Test';
            update costRateList;
            Map<String,String> tempMap = CongaTemplateSelectionController.getCostRateRecord(costRateList[0].Id);
            Test.stopTest();
            System.debug('tempMap =========='+tempMap );
            System.assertEquals(tempMap.size(), 6);
        }
    }
    
    
    // For Cost Rate with Same Template to initiate Docusign Process
    private static testMethod void testMethod2() {
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null LIMIT 1];
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 ) {
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(costRateList[0].Id, costRateList[0].Id, 'Offer Letter - Instructors LT' ,'Offer Letter - Instructors LT', 'Docusign', 'AcctSeed__Cost_Rates__c','','','','','');
            Test.stopTest();
        }
    }
    
    // For Cost Rate with different Template to initiate Docusign Process
    private static testMethod void testMethod3() {
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null LIMIT 1];
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 ) {
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(costRateList[0].Id, costRateList[0].Id, 'Pay Rate Addendum' ,'Offer Letter - Instructors LT', 'Docusign', 'AcctSeed__Cost_Rates__c','','','','','');
            Test.stopTest();
        }
    }
    
    // For Cost Rate with Same Template to initiate Gen_Form Process
    private static testMethod void testMethod4() {
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null LIMIT 1];
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 ) {
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(costRateList[0].Id, costRateList[0].Id, 'Offer Letter - DLI-W new and LT' ,'Offer Letter - DLI-W new and LT', 'Gen_Form', 'AcctSeed__Cost_Rates__c','','','','','');
            Test.stopTest();
        }
    }
    
    // For Cost Rate with different Template to initiate Gen_Form Process
    private static testMethod void testMethod5() {
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null LIMIT 1];
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 ) {
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(costRateList[0].Id, costRateList[0].Id, 'Pay Rate Addendum' ,'Offer Letter - DLI-W new and LT', 'Gen_Form', 'AcctSeed__Cost_Rates__c','','','','','WORD');
            Test.stopTest();
        }
    }
    
    // For Cost Rate with different Template to initiate Gen_Form Process
    private static testMethod void testMethod6() {
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null LIMIT 1];
        List<Contact_Assignments__c> caList = [SELECT Id FROM Contact_Assignments__c LIMIT 1];
        List<User> userList = [SELECT Id,Name FROM User WHERE isPortalEnabled = false LIMIT 1];
        String signer1 = '';
        
        if(userList.size() > 0){
            signer1 = userList[0].Id;
        }
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 && caList.size() > 0) {
            caList[0].Drafted_Labor_Cost_Rate__c = costRateList[0].Id;
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(costRateList[0].Id,costRateList[0].Id, 'Offer Letter - DLI-W new and LT', 'Pay Rate Addendum', 'Gen_Form', 'AcctSeed__Cost_Rates__c',caList[0].Id,signer1,'','','PDF');
            Test.stopTest();
        }
    }
    
    // For Cost Rate with different Template to initiate Gen_Form Process
    private static testMethod void testMethod7() {
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null LIMIT 1];
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 ) {
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(costRateList[0].Id,costRateList[0].Id, 'Offer Letter - DLI-W new and LT', 'Offer Letter - DLI-W New Contract - SCA', 'Gen_Form', 'AcctSeed__Cost_Rates__c','','','','','');
            Test.stopTest();
        }
    } 
    
    // For Cost Rate with different Template to initiate Gen_Form Process
    private static testMethod void testMethod8() {
        List<Contact_Assignments__c> contAssignList = [SELECT Id, Name FROM Contact_Assignments__c LIMIT 10];
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null LIMIT 1];
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 && contAssignList.size() > 0 ) { 
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(contAssignList[0].Id, costRateList[0].Id, 'Offer Letter - DLI-W new and LT', 'MTT ICA', 'Docusign', 'Contact_Assignments__c','','','','','');
            Test.stopTest();
        }
    }
    
    // For Cost Rate with different Template to initiate Gen_Form Process
    private static testMethod void testMethod9() {
        List<Contact_Assignments__c> contAssignList = [SELECT Id, Name FROM Contact_Assignments__c LIMIT 10];
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null LIMIT 1];
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 && contAssignList.size() > 0 ) {
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(contAssignList[0].Id, costRateList[0].Id, 'Offer Letter - DLI-W new and LT', 'Pay Rate Modification', 'Docusign', 'Contact_Assignments__c','','','','','');
            Test.stopTest();
        }
    }
    
    private static testMethod void testMethod10() {
        List<Contact_Assignments__c> contAssignList = [SELECT Id, Name FROM Contact_Assignments__c LIMIT 10];
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null LIMIT 1];
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 && contAssignList.size() > 0 ) {
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(contAssignList[0].Id, costRateList[0].Id, 'Offer Letter - DLI-W new and LT', 'ICA DLI-W 2017', 'Docusign', 'Contact_Assignments__c','','','','','');
            Test.stopTest();
        }
    }
    
    private static testMethod void testMethod11() {
        List<Contact_Assignments__c> contAssignList = [SELECT Id, Name FROM Contact_Assignments__c LIMIT 10];
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null LIMIT 1];
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 && contAssignList.size() > 0 ) {
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(contAssignList[0].Id, costRateList[0].Id, 'Offer Letter - DLI-W new and LT', 'Translation and Interpretation ICA', 'Docusign', 'Contact_Assignments__c','','','','','');
            Test.stopTest();
        }
    }
    
    private static testMethod void testMethod12() {
        List<Contact_Assignments__c> contAssignList = [SELECT Id, Name FROM Contact_Assignments__c LIMIT 10];
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null LIMIT 1];
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 && contAssignList.size() > 0 ) {
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(contAssignList[0].Id, costRateList[0].Id, 'Offer Letter - DLI-W new and LT', 'Translation and Interpretation Addendum to ICA', 'Docusign', 'Contact_Assignments__c','','','','','');
            Test.stopTest();
        }
    }
    
    private static testMethod void testMethod13() {
        //List<Contact_Assignments__c> contAssignList = [SELECT Id, Name FROM Contact_Assignments__c WHERE Rate_Card_Rate__c != NULL OR Drafted_Labor_Cost_Rate__c  != NULL];
        //System.debug('contAssignList ==='+contAssignList);
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c  = 'Non-SCA Translation (Per Hour)' AND Gen_Email_Doc_Conga_Workflow_Template__c != null LIMIT 1];
        System.debug('costRateList ==='+costRateList );
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 ) {
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(costRateList[0].Id, costRateList[0].Id, 'Offer Letter - DLI-W new and LT', 'Offer Letter - DLI-W new and LT', 'Docusign', 'AcctSeed__Cost_Rates__c','','','','','');
            Test.stopTest();
        }
    }
    
    private static testMethod void testMethod14() {
        //List<Contact_Assignments__c> contAssignList = [SELECT Id, Name FROM Contact_Assignments__c WHERE Rate_Card_Rate__c != NULL OR Drafted_Labor_Cost_Rate__c  != NULL];
        //System.debug('contAssignList ==='+contAssignList);
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c  = 'Non-SCA Translation (Per Hour)' AND Gen_Email_Doc_Conga_Workflow_Template__c != null LIMIT 1];
        System.debug('costRateList ==='+costRateList );
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 ) {
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(costRateList[0].Id, costRateList[0].Id, 'Offer Letter - DLI-W new and LT', 'Offer Letter - DLI-W new and LT', 'Gen_Form', 'AcctSeed__Cost_Rates__c','','','','','');
            Test.stopTest();
        }
    }
    private static testMethod void testMethod15() {
        //List<Contact_Assignments__c> contAssignList = [SELECT Id, Name FROM Contact_Assignments__c WHERE Rate_Card_Rate__c != NULL OR Drafted_Labor_Cost_Rate__c  != NULL];
        //System.debug('contAssignList ==='+contAssignList);
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c,Contact__c,Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null LIMIT 1];
        System.debug('costRateList ==='+costRateList );
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 ) {
            List<Contact> conLst = [SELECT Id,Supervisor_Name__c FROM CONTACT WHERE Id =: costRateList[0].Contact__c];
            if(conLst.size() > 0){
                conLst[0].Supervisor_Name__c = UserInfo.getUserId();
                costRateList[0].Rate_Type__c = 'Non-SCA LT'; 
                costRateList[0].Gen_Email_Doc_Conga_Workflow_Template__c = costRateList[0].Gen_Email_Doc_Conga_Workflow_Template__c.replace('[LTS]','');
                System.debug('costRateList[0]:::::'+costRateList[0]);
                Test.startTest();
                update conLst;
                update costRateList;
                wrap = CongaTemplateSelectionController.genSendDocuSign(costRateList[0].Id, costRateList[0].Id, 'Pay Rate Modification', 'Pay Rate Modification', 'Docusign', 'AcctSeed__Cost_Rates__c','','','','','');
                Test.stopTest();
            }
        }
    }
    private static testMethod void testMethod16() {
        //List<Contact_Assignments__c> contAssignList = [SELECT Id, Name FROM Contact_Assignments__c WHERE Rate_Card_Rate__c != NULL OR Drafted_Labor_Cost_Rate__c  != NULL];
        //System.debug('contAssignList ==='+contAssignList);
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c,Contact__c,Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null AND Contact__c != null LIMIT 1];
        System.debug('costRateList ==='+costRateList );
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 ) {
            List<Contact> conLst = [SELECT Id,Supervisor_Name__c FROM CONTACT WHERE Id =: costRateList[0].Contact__c];
            if(conLst.size() > 0){
                conLst[0].Supervisor_Name__c = UserInfo.getUserId();
                costRateList[0].Rate_Type__c = 'Non-SCA LT'; 
                costRateList[0].Gen_Email_Doc_Conga_Workflow_Template__c = costRateList[0].Gen_Email_Doc_Conga_Workflow_Template__c.replace('[LTS]','');
                System.debug('costRateList[0]:::::'+costRateList[0]);
                Test.startTest();
                update conLst;
                update costRateList; 
                wrap = CongaTemplateSelectionController.genSendDocuSign(costRateList[0].Id, costRateList[0].Id, 'Pay Rate Modification', 'Pay Rate Modification', 'Gen_Form', 'AcctSeed__Cost_Rates__c','','','','','');
                Test.stopTest();
            }
        }
    }
    
    private static testMethod void testMethod17() {
        //List<Contact_Assignments__c> contAssignList = [SELECT Id, Name FROM Contact_Assignments__c WHERE Rate_Card_Rate__c != NULL OR Drafted_Labor_Cost_Rate__c  != NULL];
        //System.debug('contAssignList ==='+contAssignList);
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE  Gen_Email_Doc_Conga_Workflow_Template__c != null AND Contact__c != null LIMIT 1];
        System.debug('costRateList ==='+costRateList );
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 ) {
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(costRateList[0].Id, costRateList[0].Id, 'Offer Letter - DLI-W new and LT', 'Pay Rate Addendum', 'Docusign', 'AcctSeed__Cost_Rates__c','','','','','');
            Test.stopTest();
        }
    }
    // For Cost Rate with Same Template to initiate Docusign Process
    private static testMethod void testMethod18() {
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null AND Contact__c != null LIMIT 1];
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 ) {
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(costRateList[0].Id, costRateList[0].Id, 'Offer Letter - DLI-W new and LT' ,'Offer Letters - Tester', 'Docusign', 'AcctSeed__Cost_Rates__c','','','','','');
            Test.stopTest();
        }
    }
      // For Cost Rate with Same Template to initiate Docusign Process
    private static testMethod void testMethod19() {
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null AND Contact__c != null LIMIT 1];
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 ) {
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(costRateList[0].Id, costRateList[0].Id, 'Offer Letter - DLI-W new and LT' ,'Change of Status Form', 'Docusign', 'AcctSeed__Cost_Rates__c',costRateList[0].Id,costRateList[0].Id,costRateList[0].Id,costRateList[0].Id,'');
            Test.stopTest();
        }
    }
    // For Cost Rate with Same Template to initiate Docusign Process
    private static testMethod void testMethod20() {
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null AND Contact__c != null LIMIT 1];
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 ) {
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(costRateList[0].Id, costRateList[0].Id, 'Offer Letter - DLI-W new and LT' ,'Offer Letter - Staff - Exempt', 'Docusign', 'AcctSeed__Cost_Rates__c','','','','','');
            Test.stopTest();
        }
    }    
    // For Cost Rate with Same Template to initiate Docusign Process
    private static testMethod void testMethod21() {
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null AND Contact__c != null LIMIT 1];
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 ) {
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(costRateList[0].Id, costRateList[0].Id, 'Offer Letter - DLI-W new and LT' ,'Offer Letter - UAE Template', 'Docusign', 'AcctSeed__Cost_Rates__c','','','','','');
            Test.stopTest();
        }
    }
    private static testMethod void testMethod22() {
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null AND Contact__c != null LIMIT 1];
        
        if( costRateList.size() > 0 ) {
            Test.startTest();
            CongaTemplateSelectionController.getSignerInfo('Change of Status Form',costRateList[0].Id);     
            Test.stopTest();
        }
    }
     // For Cost Rate with different Template to initiate Gen_Form Process
    private static testMethod void testMethod23() {
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null LIMIT 1];
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 ) {
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(costRateList[0].Id,costRateList[0].Id, 'FSI Letter of Intent', 'FSI Offer Letter', 'Gen_Form', 'AcctSeed__Cost_Rates__c','','','','','');
            Test.stopTest();
        }
    } 
      // For Cost Rate with different Template to initiate Gen_Form Process
    private static testMethod void testMethod24() {
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null LIMIT 1];
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        if( costRateList.size() > 0 ) {
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(costRateList[0].Id,costRateList[0].Id, 'FSI Offer Letter', 'FSI Letter of Intent', 'Gen_Form', 'AcctSeed__Cost_Rates__c','','','','','PDF');
            Test.stopTest();
        } 
    } 
    private static testMethod void testMethod25() {
        List<AcctSeed__Cost_Rates__c> costRateList = [SELECT Id, Name, Gen_Email_Doc_Conga_Workflow_Template__c, Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Gen_Email_Doc_Conga_Workflow_Template__c != null LIMIT 1];
        List<Contact_Assignments__c> caList = [SELECT Id,Project__c FROM Contact_Assignments__c LIMIT 1];

        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper(); 
        if( costRateList.size() > 0 && caList.size() > 0) {
            costRateList[0].Rate_Type__c = 'PT Hourly (OH & G&A)'; 
            costRateList[0].Exempt_Status__c = 'Non-Exempt';
            update costRateList;
            System.debug('costRateList[0]:::::'+costRateList[0]);
            Test.startTest();
            wrap = CongaTemplateSelectionController.genSendDocuSign(costRateList[0].Id,costRateList[0].Id, 'Offer Letter - Staff - Non-Exempt', 'Offer Letter - Staff - Non-Exempt', 'Gen_Form', 'AcctSeed__Cost_Rates__c',caList[0].Id,'','','','WORD');
            Test.stopTest();
        }
    } 
}