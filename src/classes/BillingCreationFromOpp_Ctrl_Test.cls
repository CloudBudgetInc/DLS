// Created by sivaprasanth on 17/3/2020
@isTest
public class BillingCreationFromOpp_Ctrl_Test {
    
    @testsetup static void setup() {
        
        Test.StartTest();
        List<OpportunityLineItem> opli = TestClassUtil.createTestOppLineItem();
        Test.stopTest();
        
        List<AcctSeed__Accounting_Period__c> acpList = TestClassUtil.createTestAccountingPeriod();        
        TestClassUtil.createAccountSettings();
        
        Set<Id> userIds = CommonUtil.fetchUserIdsOfPublicGroup('Registrar');
        List<Contact> contacts = new List<Contact>();
        for(User usr : [SELECT Id, FirstName, LastName, MiddleName, Email FROM User WHERE Id IN :userIds]){
            contacts.add(new Contact(FirstName=usr.FirstName, MiddleName=usr.MiddleName, LastName=usr.LastName, email=usr.email));
        }
        insert contacts;
    }
    // get Billing row formation
    private static testMethod void testMethod1() {
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        if(opp.size() > 0){
        
            opp[0].A_R_Type__c = '11005-Prepayment';
            update opp;
            
            String billInfoJSON = BillingCreationFromOpp_Ctrl.getBillingInfoFromOPP(opp[0].Id);
            BillingCreationFromOpp_Ctrl.BillingRowInfo billingRow = (BillingCreationFromOpp_Ctrl.BillingRowInfo) JSON.deserialize(billInfoJSON ,BillingCreationFromOpp_Ctrl.BillingRowInfo.Class);
            
            if(billingRow != null){
                System.assertEquals(billingRow.oppId,opp[0].Id);
            }
            
        }
        
    }//  Billing and Billing Line Creation and Conga Url formation
    private static testMethod void testMethod2() {
        
        Date currentMonthStartDt = System.Date.today().toStartOfMonth(); 
        Date currentMonthEndDt =  currentMonthStartDt.addMonths(1).addDays(-1);
        
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c WHERE AcctSeed__Start_Date__c = :currentMonthStartDt AND AcctSeed__End_Date__c = :currentMonthEndDt];
        List<OpportunityLineItem> opli = [SELECT Id,Product2Id,OpportunityId FROM OpportunityLineItem LIMIT 1];
        List<Account> accList = [SELECT Id,Name FROM Account LIMIT 1];
        accList[0].Name = 'PVT '+ accList[0].Name;
        update accList;
        List<AcctSeed__Ledger__c> ledger =  [SELECT Id FROM AcctSeed__Ledger__c LIMIT 1];
        List<AcctSeed__GL_Account__c> glAccList  = new List<AcctSeed__GL_Account__c> {new AcctSeed__GL_Account__c(Name = 'AccountSettingGLAccount14',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Balance Sheet', AcctSeed__Bank__c = false)  };
        
        insert glAccList  ;
        
        AcctSeed__Billing__c billingRec = new AcctSeed__Billing__c();
        AcctSeed__Billing_Line__c billLine = new AcctSeed__Billing_Line__c();
        List<AcctSeed__Billing_Line__c> billLineList = new List<AcctSeed__Billing_Line__c>();
        
        Test.StartTest();
        
        AcctSeed__Billing_Format__c pdfFormat= new AcctSeed__Billing_Format__c(); 
        pdfFormat.AcctSeed__Default_Email_Template__c = 'Billing_Email_Template';
        pdfFormat.AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF';
        pdfFormat.AcctSeed__Type__c = 'Billing';
        pdfFormat.Name = 'Default Billing Product';
        
        insert pdfFormat;
        
        List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c> {
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Non-GSA Prepayment Invoice Template'),
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'GSA Prepayment Invoice Template')
           };
           insert congaTemp;
        
        List<APXTConga4__Conga_Merge_Query__c > congaQuery = new List<APXTConga4__Conga_Merge_Query__c> {
            new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Billing Query - Billing PDF'),
            new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Billing Line Query - Billing PDFr')
           };
           insert congaQuery;
        
        List<RecordType> recType = [SELECT Id,DeveloperName,SobjectType FROM RecordType where SobjectType='Contact_Assignments__c' AND DeveloperName = 'Student'];
        List<Contact> con1 = [SELECT Id,Name,Email FROM Contact LIMIT 1];
        
        List<Contact_Assignments__c> contactAss = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(Opportunity_Name__c = opli[0].OpportunityId,Candidate_Name__c = con1[0].Id,RecordTypeId = recType[0].Id,Start_Date__c = system.today(),Status__c = 'Active')
        };
        insert contactAss;
        
        Test.StopTest();
        
        if(acpList.size() > 0){            
            billingRec.AcctSeed__Accounting_Period__c = acpList[0].Id;
            billingRec.AcctSeed__Billing_Cycle_Start_Date__c = acpList[0].AcctSeed__Start_Date__c;
            billingRec.AcctSeed__Billing_Cycle_End_Date__c = acpList[0].AcctSeed__End_Date__c ;
        }
        
        if(opli.size() > 0){
            billingRec.AcctSeed__Opportunity__c = opli[0].OpportunityId;
            billLine.AcctSeed__Opportunity_Product_Id__c = opli[0].Product2Id;            
        }
        
        if(accList.size() > 0){
            billingRec.AcctSeed__Customer__c = accList[0].Id;            
        }
        
        if(ledger.size() > 0){
            billingRec.AcctSeed__Ledger__c = ledger[0].Id;
        }
        
        if(glAccList.size() > 0){
            billLine.AcctSeed__Revenue_GL_Account__c = glAccList[0].Id;
        }
        
        billingRec.AcctSeed__Billing_Format__c = pdfFormat.Id;           
        billLine.AcctSeed__Rate__c = 20;
        billLine.AcctSeed__Hours_Units__c = 30;
        billLineList.add(billLine);
        
        Contact conRec = [SELECT Id, Name, Email FROM Contact WHERE Id = :contactAss[0].Candidate_Name__c];
        
        String congaUrlJSON = BillingCreationFromOpp_Ctrl.createBillingRecs(JSON.serialize(billingRec), JSON.serialize(billLineList),'',opli[0].OpportunityId, JSON.serialize(conRec));
        
        BillingCreationFromOpp_Ctrl.CongaURLWrapper congaUrl = (BillingCreationFromOpp_Ctrl.CongaURLWrapper) JSON.deserialize(congaUrlJSON ,BillingCreationFromOpp_Ctrl.CongaURLWrapper.class);
        
        if(congaUrl.queryNameIdMap != null){
            System.assertEquals(congaQuery[0].Id,congaUrl.queryNameIdMap.get('Billing Query - Billing PDF'));
        }
        
        if(congaUrl.billingRec != null){
            List<AcctSeed__Billing__c> billRec  = [SELECT Id,  AcctSeed__Accounting_Period__c, AcctSeed__Total__c, AcctSeed__Customer__c FROM AcctSeed__Billing__c WHERE Id = :congaUrl.billingRec.Id];
            System.assertEquals(1,billRec.size());
            
               
            List<AcctSeed__Cash_Receipt__c> cashReciepts = new List<AcctSeed__Cash_Receipt__c>{
            new AcctSeed__Cash_Receipt__c(
                            AcctSeed__Accounting_Period__c=billRec[0].AcctSeed__Accounting_Period__c, 
                            AcctSeed__Amount__c=billRec[0].AcctSeed__Total__c, AcctSeed__Receipt_Date__c=System.today(),
                            AcctSeed__Payment_Reference__c='Test1234', AcctSeed__Account__c=billRec[0].AcctSeed__Customer__c
                )
            };
            insert cashReciepts;  
             
        
            AcctSeed.PostResult[] postResults = AcctSeed.CashReceiptPostService.postCashReceipts(cashReciepts);
            
            AcctSeed__Billing_Cash_Receipt__c billingCashReceipt = new AcctSeed__Billing_Cash_Receipt__c(AcctSeed__Billing__c=billRec[0].Id, AcctSeed__Cash_Receipt__c=cashReciepts[0].Id,
                                                    AcctSeed__Accounting_Period__c=billRec[0].AcctSeed__Accounting_Period__c,
                                                    AcctSeed__Applied_Amount__c=billRec[0].AcctSeed__Total__c,AcctSeed__Applied_Date__c=System.today()); 
            insert billingCashReceipt;
        } 
    }    
}