@isTest
public class BillingCreation_Ctrl_Test {
      //W-002782 - Batch Billings (Invoice) Creation Process-->
    @testsetup static void setup() {
       
        List<Materials_Request__c> materialReqList = TestClassUtil.createTestMaterialRequest();
        List<AcctSeed__Project_Task__c> ptList = TestClassUtil.createTestProjectTask();
        Test.StartTest();
        List<AcctSeed__Time_Card_Day__c> tcdList = TestClassUtil.createTestTimeCardDay();
        List<Contact_Assignments__c> conAssignList = TestClassUtil.createTestContactAssignment();
        List<AcctSeed__Accounting_Variable__c> accVar = TestClassUtil.createAccountingVariable();
        Test.Stoptest();  
    }
    // get Previous month Accounting Period Lookup Value
   private static testMethod void testMethod1() {
        
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id FROM AcctSeed__Accounting_Period__c LIMIT 1];
        
        Date previousMonthStartDt = System.Date.today().toStartOfMonth().addMonths(-1); 
        Date previousMonthEndDt = previousMonthStartDt.addMonths(1).addDays(-1);
        Id accPId = null;
        
        if(acpList.size() > 0){
            acpList[0].AcctSeed__Start_Date__c = previousMonthStartDt;
            acpList[0].AcctSeed__End_Date__c = previousMonthEndDt;
            accPId = acpList[0].Id;
            update acpList;
        }
        String lookupFilterJSON = BillingCreation_Ctrl.getInitialFilterValues();
        BillingCreation_Ctrl.BillingInitialFilterInfo filterInfo = (BillingCreation_Ctrl.BillingInitialFilterInfo) JSON.deserialize(lookupFilterJSON,BillingCreation_Ctrl.BillingInitialFilterInfo.class);
        if(filterInfo != null){
            system.assertEquals(accPId,(filterInfo.accountingPeriodFilter)[0].Id);
        }
    }
    // Billing line row formation
    private static testMethod void testMethod2(){
        List<AcctSeed__Time_Card_Line__c> tclList = [SELECT Id,AcctSeed__Project__c,AcctSeed__Project_Task__c,AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c FROM AcctSeed__Time_Card_Line__c LIMIT 1];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<AcctSeed__Project__c> proList = [SELECT Id,AcctSeed__Account__c FROM AcctSeed__Project__c];
        List<AcctSeed__Project_Task__c> proPTList = [SELECT Id,RecordTypeId FROM AcctSeed__Project_Task__c LIMIT 2];
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c ORDER BY AcctSeed__Start_Date__c LIMIT 2];
        List<AcctSeed__Accounting_Variable__c> accVar = [SELECT Id,Name FROM AcctSeed__Accounting_Variable__c LIMIT 1];
        List<CLIN__c> clinList = [SELECT Id FROM CLIN__c LIMIT 1];
        
        String ptLTRT = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Language_Training').getRecordTypeId();
        
        Date myDate = date.today();
        Date weekStart = myDate.toStartofWeek()+1;
        Date weekEnd = myDate.toStartofWeek()+7;
        
        date monthStart = weekStart.toStartofMonth();
        date monthEnd = weekStart.addMonths(1).toStartofMonth().addDays(-1);
        date monthStart1 = weekEnd.toStartofMonth();
        date monthEnd1 = weekEnd.addMonths(1).toStartofMonth().addDays(-1);
        
        Id accId = null;
        Id proId = null;
        Id accPId = null;
        Id proPT = null;
        
        if(accList.size() > 0){
            Account parentAcc = new Account();
                parentAcc.Name = 'PVT';
                insert parentAcc;
            
            accId = parentAcc.Id;
            accList[0].parentId = parentAcc.Id;
            update accList;
        }
        if(acpList.size() > 0){
            if(monthStart == monthStart1 && monthEnd == monthEnd1) {
                accPId = acpList[0].Id;
            }else{
                accPId = acpList[1].Id;   
            }
        }
        if(proList.size() > 0){
            proId = proList[0].Id; 
            proList[0].AcctSeed__Account__c = accId;
            proList[0].QB_Classification__c = 'ADM';
            proList[0].Billing_Type__c = '11002-Billed at End';
            update proList;
        }
        if(proPTList.size() > 0){
            proPT = proPTList[0].Id;
            proPTList[0].RecordTypeId = ptLTRT;
            proPTList[0].Total_Amount_Paid__c = 100;
            proPTList[0].Billable__c = true;
            
            if(clinList.size() > 0){
               proPTList[0].CLIN__c = clinList[0].Id;
            }
            
            update proPTList;   
        }
        if(accVar.size() > 0){
           accVar[0].Name = 'ADM';
            update accVar;
        }
        if(tclList.size() > 0){
            List<AcctSeed__Time_Card_Day__c> tcd = [SELECT Id FROM AcctSeed__Time_Card_Day__c WHERE AcctSeed__Time_Card_Line__c != null];
            
            if(tcd.size() > 0){
                tcd[0].QB_Classification__c = 'CD';
                update tcd[0];
            }
            tclList[0].AcctSeed__Project__c = proId;
            tclList[0].AcctSeed__Project_Task__c = proPT;
            tclList[0].AcctSeed__Billable__c = true;
            update tclList;
        }
        Test.StartTest();
       
        List<AcctSeed__GL_Account__c> glAcc = new List<AcctSeed__GL_Account__c> {
            new AcctSeed__GL_Account__c(Name = '11001 - Accounts Receivable',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Active__c  = true, AcctSeed__Bank__c = true),
            new AcctSeed__GL_Account__c(Name = '40540 - Learning Mngmt System Revenue',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Active__c  = true, AcctSeed__Bank__c = true),
            new AcctSeed__GL_Account__c(Name = '25501 - Sales Tax Payable - New',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Active__c  = true, AcctSeed__Bank__c = true),
            new AcctSeed__GL_Account__c(Name = '12853 - RE - Language Materials',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Active__c  = true, AcctSeed__Bank__c = true)
           
        };
        
        insert glAcc;
        String billingInfoJSON = BillingCreation_Ctrl.getBillingRowInfo(proId,accId,accpId,'11002-Billed at End');
        
        BillingCreation_Ctrl.BillingInfo billInfo = (BillingCreation_Ctrl.BillingInfo) JSON.deserialize(billingInfoJSON,BillingCreation_Ctrl.BillingInfo.class);
        system.debug('billInfo'+billInfo);

        if(billInfo != null  && billInfo.billingRowInfo.size() > 0){
            system.assertEquals(proId,billInfo.billingRowInfo[0].projectId);
        }
        Test.StopTest();
    }
     // Billing line row formation
    private static testMethod void testMethod3(){
        List<AcctSeed__Time_Card_Line__c> tclList = [SELECT Id,AcctSeed__Project__c,AcctSeed__Project_Task__c,AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c FROM AcctSeed__Time_Card_Line__c LIMIT 1];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<AcctSeed__Project__c> proList = [SELECT Id,AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Project_Task__c> proPTList = [SELECT Id,RecordTypeId FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :proList[0].Id LIMIT 2];
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c ORDER BY AcctSeed__Start_Date__c LIMIT 2];
        List<Materials_Request__c> materialReqList = [SELECT Id,Project__c,Date_Delivered__c,Project_Task__c,Qty__c FROM Materials_Request__c LIMIT 2];
        List<AcctSeed__Accounting_Variable__c> accVar = [SELECT Id,Name FROM AcctSeed__Accounting_Variable__c LIMIT 1];
        List<CLIN__c> clinList = [SELECT Id FROM CLIN__c LIMIT 1];
        
        String ptRT = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Material_Budget').getRecordTypeId();
        String matReqRT = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Project_Materials_Request').getRecordTypeId();
        
        Date myDate = date.today();
        Date weekStart = myDate.toStartofWeek()+1;
        Date weekEnd = myDate.toStartofWeek()+7;
        
        date monthStart = weekStart.toStartofMonth();
        date monthEnd = weekStart.addMonths(1).toStartofMonth().addDays(-1);
        date monthStart1 = weekEnd.toStartofMonth();
        date monthEnd1 = weekEnd.addMonths(1).toStartofMonth().addDays(-1);
        
        Id accId = null;
        Id proId = null;
        Id accPId = null;
        Id proPT = null;
        
        system.debug('acpList'+acpList);
        if(accList.size() > 0){
            accId = accList[0].Id;
        }
        if(acpList.size() > 0){
            if(monthStart != monthStart1 && monthEnd != monthEnd1) {
                accPId = acpList[1].Id;
            }else{
                accPId = acpList[0].Id;   
            }
        }
        system.debug('acpList'+[SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c WHERE Id = :accPId]);
        if(proList.size() > 0){
            proId = proList[0].Id; 
            proList[0].AcctSeed__Account__c = accId;
            proList[0].QB_Classification__c = 'ADM';
            proList[0].Billing_Type__c = '11002-Billed at End';
            update proList;
        }
        if(proPTList.size() > 0){
            proPT = proPTList[0].Id;
            proPTList[0].RecordTypeId = ptRT;
            proPTList[0].Total_Amount_Paid__c = 100;
            proPTList[0].Billable__c = true;
            
            if(clinList.size() > 0){
                proPTList[0].CLIN__c = clinList[0].Id;
            }
            
            update proPTList;   
        }
        if(accVar.size() > 0){
           accVar[0].Name = 'ADM';
            update accVar;
        }
        Test.StartTest();
      
        if(materialReqList.size() > 0){
            materialReqList[0].Project__c = proId;
            materialReqList[0].Project_Task__c = proPT;
            materialReqList[0].RecordTypeId = matReqRT;
            materialReqList[0].Qty__c = 3.00;
             materialReqList[0].Vendor_Total__c = 16;
            materialReqList[0].Request_Status__c = 'Delivered';
            
            materialReqList[1].Project__c = proId;
            materialReqList[1].Project_Task__c = proPT;
            materialReqList[1].Vendor_Total__c = 16;
            materialReqList[1].DLS_Sales_Tax_Percentage__c = 2;
            materialReqList[1].GSA_Fee_Percentage__c = 2;
             materialReqList[1].Request_Status__c = 'Delivered';
          
            materialReqList[1].RecordTypeId = matReqRT;
            materialReqList[1].Qty__c = 8.00;
            
            if(monthStart != monthStart1 && monthEnd != monthEnd1) {
                materialReqList[1].Date_Delivered__c = monthStart1;
                materialReqList[0].Date_Delivered__c = monthStart1;
            }else{
                materialReqList[1].Date_Delivered__c = monthStart;
                materialReqList[0].Date_Delivered__c = monthStart;  
            }
            
            update materialReqList;
        }
        
        List<AcctSeed__GL_Account__c> glAcc = new List<AcctSeed__GL_Account__c> {
            new AcctSeed__GL_Account__c(Name = '11001 - Accounts Receivable',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Active__c  = true, AcctSeed__Bank__c = true),
            new AcctSeed__GL_Account__c(Name = '40540 - Learning Mngmt System Revenue',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Active__c  = true, AcctSeed__Bank__c = true),
            new AcctSeed__GL_Account__c(Name = '25501 - Sales Tax Payable - New',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Active__c  = true, AcctSeed__Bank__c = true),
            new AcctSeed__GL_Account__c(Name = '12853 - RE - Language Materials',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Active__c  = true, AcctSeed__Bank__c = true)
           
        };
        
        insert glAcc;
       
        String billingInfoJSON = BillingCreation_Ctrl.getBillingRowInfo(proId,accId,accpId,'11002-Billed at End');
        
        BillingCreation_Ctrl.BillingInfo billInfo = (BillingCreation_Ctrl.BillingInfo) JSON.deserialize(billingInfoJSON,BillingCreation_Ctrl.BillingInfo.class);
        system.debug('billInfo'+billInfo);

        if(billInfo != null  && billInfo.billingRowInfo.size() > 0){
            system.assertEquals(proId,billInfo.billingRowInfo[0].projectId);
        }
        Test.StopTest();
    }
    //Create single Billing for all Project
    private static testMethod void testMethod4(){
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<AcctSeed__Project__c> proList = [SELECT Id,AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 2];
        List<AcctSeed__Project_Task__c> proPTList = [SELECT Id,RecordTypeId FROM AcctSeed__Project_Task__c LIMIT 2];
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id FROM AcctSeed__Accounting_Period__c LIMIT 1];
        Map<String,AcctSeed__Billing__c> billingMap = new Map<String,AcctSeed__Billing__c>();
        Map<String,List<AcctSeed__Billing_Line__c>> billingLineMap = new Map<String,List<AcctSeed__Billing_Line__c>>();
        List<AcctSeed__Billing_Line__c> billingLineList = new List<AcctSeed__Billing_Line__c>();
        
        List<AcctSeed__GL_Account__c> glAccList  = new List<AcctSeed__GL_Account__c> {new AcctSeed__GL_Account__c(Name = 'AccountSettingGLAccount14',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Balance Sheet', AcctSeed__Bank__c = false)  };
        insert glAccList;
         
        String proRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('EFL_Projects').getRecordTypeId();
        
        Id proId = null;
        Id proPT = null;
        Id accPId = null;
        Id accId = null;
        
        AcctSeed__Billing__c singlebilling = new AcctSeed__Billing__c();
        
        if(proList.size() > 0){
            proId = proList[0].Id; 
            proList[0].RecordTypeId = proRT;

            if(accList.size() > 0){
                proList[0].AcctSeed__Account__c =  accList[0].Id;
                proList[0].Name = 'Language Training - Hindi';
                update proList;
            }
        }
        if(acpList.size() > 0){
            accPId = acpList[0].Id;
        }
        if(proPTList.size() > 0){
            proPT = proPTList[0].Id;
        }
        if(accList.size() > 0){
            singlebilling.AcctSeed__Customer__c  = accList[0].Id;
            accId = accList[0].Id;
        }
        billingMap.put('Single Billing',singlebilling);
        
        Test.StartTest();
        AcctSeed__Billing_Line__c bl = new AcctSeed__Billing_Line__c();
        bl.AcctSeed__Project__c = proId;
        bl.AcctSeed__Project_Task__c = proPT;
        bl.AcctSeed__Hours_Units__c = 2;
        bl.AcctSeed__Rate__c = 10;
        bl.AcctSeed__Comment__c = 'Test';
        bl.AcctSeed__Revenue_GL_Account__c = glAccList[0].Id;
        
        AcctSeed__Billing_Line__c bl2 = new AcctSeed__Billing_Line__c();
        bl2.AcctSeed__Project__c = proId;
        bl2.AcctSeed__Project_Task__c = proPT;
        bl2.AcctSeed__Hours_Units__c = 3;
        bl2.AcctSeed__Rate__c = 50;
        bl2.AcctSeed__Comment__c = 'SalesTax';
        bl2.AcctSeed__Revenue_GL_Account__c = glAccList[0].Id;
        
        billingLineList.add(bl);
        billingLineList.add(bl2);
        
        billingLineMap.put('Single Billing',billingLineList);
        String billingJSON = JSON.serialize(billingMap);
        String billingLineJSON = JSON.serialize(billingLineMap);
        
        BillingCreation_Ctrl.createBillings(billingLineJSON,billingJSON,accPId,accId); 
        
        List<AcctSeed__Billing__c> singlebiling = [SELECT Id FROM AcctSeed__Billing__c];
        if(singlebiling.size() > 0){
            system.assertEquals(singlebiling.size(), 1);
        }
        String billJSON = BillingCreation_Ctrl.checkBillORJournalExist('Billing',JSON.serialize(new List<Id> {proId}),accpId);
        Map<String,Id> billingExistMap = (Map<String,Id>) JSON.deserialize(billJSON,Map<String,Id>.class);
        
        if(billingExistMap.size() > 0){
          system.assertEquals(true,billingExistMap.containsKey(proId+'~'+proPT+'~'+'SalesTax'));
        }
        Test.StopTest();
    }
    //Create individual Billing for each Project
    private static testMethod void testMethod5(){
        
        List<Account> accList = [SELECT Id,Account_Code__c FROM Account LIMIT 1];
        List<AcctSeed__Project__c> proList = [SELECT Id,AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 2];
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id,Name FROM AcctSeed__Accounting_Period__c LIMIT 1];
        List<AcctSeed__Project_Task__c> proPTList = [SELECT Id,RecordTypeId FROM AcctSeed__Project_Task__c LIMIT 2];
        Map<String,AcctSeed__Billing__c> billingMap = new Map<String,AcctSeed__Billing__c>();
        Map<String,List<AcctSeed__Billing_Line__c>> billingLineMap = new Map<String,List<AcctSeed__Billing_Line__c>>();
        
        List<AcctSeed__GL_Account__c> glAccList  = new List<AcctSeed__GL_Account__c> {new AcctSeed__GL_Account__c(Name = 'AccountSettingGLAccount14',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Balance Sheet', AcctSeed__Bank__c = false)  };
        insert glAccList;
        
        String proEFLRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('EFL_Projects').getRecordTypeId();
        String proDLIRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        String accPdName = null;
        String accCode = null;

        Id proId1 = null;
        Id proId2 = null;
        Id proPT1 = null;
        Id proPT2 = null;
        Id accPId = null;
        Id accId = null;
        
        AcctSeed__Billing__c billing = new AcctSeed__Billing__c();
        
        if(proList.size() > 0){
            proId1 = proList[0].Id; 
            proId2 = proList[1].Id;
            
            proList[0].RecordTypeId = proEFLRT;
            proList[1].RecordTypeId = proDLIRT;
            if(accList.size() > 0){
                proList[0].AcctSeed__Account__c =  accList[0].Id;
                proList[1].AcctSeed__Account__c =  accList[0].Id;
            }
            update proList;
        }
        if(proPTList.size() > 0){
            proPT1 = proPTList[0].Id;
            proPT2 = proPTList[1].Id;
        }
        if(acpList.size() > 0){
            accPId = acpList[0].Id;
            accPdName = acpList[0].Name;
        }
        if(accList.size() > 0){
            billing.AcctSeed__Customer__c  = accList[0].Id;
            accId = accList[0].Id;
            accCode = accList[0].Account_Code__c;
        }
        if(proId1 != null){
            billingMap.put(proId1,billing);
            
            AcctSeed__Billing_Line__c bl = new AcctSeed__Billing_Line__c();
            bl.AcctSeed__Project__c = proId1;
            bl.AcctSeed__Project_Task__c = proPT1;
            bl.AcctSeed__Hours_Units__c = 2;
            bl.AcctSeed__Rate__c = 10;
            bl.AcctSeed__Comment__c = 'Test';
            bl.AcctSeed__Revenue_GL_Account__c = glAccList[0].Id;
            billingLineMap.put(proId1,new List<AcctSeed__Billing_Line__c>{bl});
        }
        
        if(proId2 != null){
            billingMap.put(proId2,billing);
            
            AcctSeed__Billing_Line__c bl2 = new AcctSeed__Billing_Line__c();
            bl2.AcctSeed__Project__c = proId2;
            bl2.AcctSeed__Project_Task__c = proPT2;
            bl2.AcctSeed__Hours_Units__c = 3;
            bl2.AcctSeed__Rate__c = 50;
            bl2.AcctSeed__Comment__c = 'Test Comment1';
            bl2.AcctSeed__Revenue_GL_Account__c = glAccList[0].Id;
            billingLineMap.put(proId2,new List<AcctSeed__Billing_Line__c>{bl2});
        }
        String billingJSON = JSON.serialize(billingMap);
        String billingLineJSON = JSON.serialize(billingLineMap);
        Test.startTest();
        
        List<AcctSeed__Billing__c> billLineList = new List<AcctSeed__Billing__c>{
            new AcctSeed__Billing__c(AcctSeed__Proprietary_Billing_Number__c = accCode+'-'+accPdName+'-001',Project__c = proId1,AcctSeed__Customer__c = accId),
            new AcctSeed__Billing__c(AcctSeed__Proprietary_Billing_Number__c = accCode+'-'+accPdName+'-002',Project__c = proId1,AcctSeed__Customer__c = accId)
        };
        insert billLineList;
        
        BillingCreation_Ctrl.createBillings(billingLineJSON,billingJSON,accPId,accId); 
        String billName = accCode+'-'+accPdName+'-003';
        
        List<AcctSeed__Billing__c> biling = [SELECT Id,AcctSeed__Proprietary_Billing_Number__c  FROM AcctSeed__Billing__c WHERE AcctSeed__Proprietary_Billing_Number__c = :billName];
        if(biling.size() > 0){
            system.assertEquals(billName,biling[0].AcctSeed__Proprietary_Billing_Number__c);
        }
        Test.stopTest();
        
    }// get Lookup Records and List View Id
    private static testMethod void testMethod6(){
        BillingCreation_Ctrl.getLookupRecords('', 'Account', '', '', new List<String>{});
        List<ListView> listviews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'AcctSeed__Journal_Entry__c'];
        
        Test.StartTest();
        String listViewId = BillingCreation_Ctrl.getListViews('AcctSeed__Journal_Entry__c');
        if(listViewId != null){
            system.assertEquals(listViewId,listviews[0].Id);
        }
        Test.StopTest();
    }
     //Create individual Journal for each Project
    private static testMethod void testMethod7(){
        
        List<Account> accList = [SELECT Id,Account_Code__c FROM Account LIMIT 1];
        List<AcctSeed__Project__c> proList = [SELECT Id,AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 2];
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id,Name FROM AcctSeed__Accounting_Period__c LIMIT 1];
        List<AcctSeed__Project_Task__c> proPTList = [SELECT Id,RecordTypeId FROM AcctSeed__Project_Task__c LIMIT 2];
        Map<String,AcctSeed__Journal_Entry__c> journalMap = new Map<String,AcctSeed__Journal_Entry__c>();
        Map<String,List<AcctSeed__Journal_Entry_Line__c>> journalMapLineMap = new Map<String,List<AcctSeed__Journal_Entry_Line__c>>();
        List<AcctSeed__GL_Account__c> glAcclist = [SELECT Name FROM AcctSeed__GL_Account__c LIMIT 1];
        
        String proEFLRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('EFL_Projects').getRecordTypeId();
        String accPdName = null;
        String accCode = null;

        Id proId1 = null;
        Id proPT1 = null;
        Id accPId = null;
        Id accId = null;
        Id glAcc = null;
        
        AcctSeed__Journal_Entry__c je = new AcctSeed__Journal_Entry__c();
        
        if(proList.size() > 0){
            proId1 = proList[0].Id; 
            proList[0].RecordTypeId = proEFLRT;
            if(accList.size() > 0){
                proList[0].AcctSeed__Account__c =  accList[0].Id;
            }
            update proList;
        }
        if(proPTList.size() > 0){
            proPT1 = proPTList[0].Id;
        }
        if(acpList.size() > 0){
            accPId = acpList[0].Id;
            accPdName = acpList[0].Name;
            je.AcctSeed__Accounting_Period__c  = acpList[0].Id;
        }
        if(accList.size() > 0){
            accCode = accList[0].Account_Code__c;
            accId = accList[0].Id;
        }
        if(glAcclist.size() > 0){
        
            glAcc = glAcclist[0].Id;
            glAcclist[0].Name = 'Actual';
            glAcclist[0].AcctSeed__Type__c= 'Balance Sheet';
            update glAcclist;
        }
        

        if(proId1 != null){
            journalMap.put(proId1,je);

            List<AcctSeed__Journal_Entry_Line__c> jel = new List<AcctSeed__Journal_Entry_Line__c>();
            AcctSeed__Journal_Entry_Line__c jelCredit = new AcctSeed__Journal_Entry_Line__c();
            jelCredit.AcctSeed__Project__c = proId1;
            jelCredit.AcctSeed__Project_Task__c = proPT1;
            jelCredit.AcctSeed__Credit__c = 100;
            jelCredit.AcctSeed__GL_Account__c = glAcc;
            jelCredit.AcctSeed__Reference__c = 'SalesTax';
            
            AcctSeed__Journal_Entry_Line__c jelDebit = new AcctSeed__Journal_Entry_Line__c();
            jelDebit.AcctSeed__Debit__c = 100;
            jelDebit.AcctSeed__GL_Account__c = glAcc;
            
            jel.add(jelCredit);
            jel.add(jelDebit);
            journalMapLineMap.put(proId1,jel);
        }
      
        String journalJSON = JSON.serialize(journalMap);
        String journaLineJSON = JSON.serialize(journalMapLineMap);
        
        
        List<AcctSeed__Journal_Entry__c> jeList = new List<AcctSeed__Journal_Entry__c>{
            new AcctSeed__Journal_Entry__c(Name = accCode+'-'+accPdName+'-001',Project__c = proId1,AcctSeed__Journal_Date__c = system.today()),
            new AcctSeed__Journal_Entry__c(Name = accCode+'-'+accPdName+'-002',Project__c = proId1,AcctSeed__Journal_Date__c = system.today().addDays(1))
        };
           
        Test.startTest();
        
        if(jeList.size() > 0){
            insert jeList;
        }
        
        BillingCreation_Ctrl.journalEntryCreation(journalJSON,journaLineJSON,accId,accPId);
        String jeName = accCode+'-'+accPdName+'-003';
        
        List<AcctSeed__Journal_Entry__c> journal = [SELECT Id,Name FROM AcctSeed__Journal_Entry__c WHERE Name = :jeName]; 

        if(journal.size() > 0){
            system.assertEquals(accCode+'-'+accPdName+'-003',journal[0].Name);
        }
        Test.stoptest();
        
        String journalExistJSON = BillingCreation_Ctrl.checkBillORJournalExist('Journal',JSON.serialize(new List<Id> {proId1}),accpId);
        Map<String,Id> journalExistMap = (Map<String,Id>) JSON.deserialize(journalExistJSON,Map<String,Id>.class);
        
        if(journalExistMap.size() > 0){
            system.assertEquals(true,journalExistMap.containsKey(proId1+'~'+proPT1+'~SalesTax'));
        }
    }    
    
    //Create individual Journal for each Project
    private static testMethod void testMethod7a(){
        
        List<Account> accList = [SELECT Id,Account_Code__c FROM Account LIMIT 1];
        List<AcctSeed__Project__c> proList = [SELECT Id,AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 2];
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id,Name FROM AcctSeed__Accounting_Period__c LIMIT 1];
        List<AcctSeed__Project_Task__c> proPTList = [SELECT Id,RecordTypeId FROM AcctSeed__Project_Task__c LIMIT 2];
        Map<String,AcctSeed__Journal_Entry__c> journalMap = new Map<String,AcctSeed__Journal_Entry__c>();
        Map<String,List<AcctSeed__Journal_Entry_Line__c>> journalMapLineMap = new Map<String,List<AcctSeed__Journal_Entry_Line__c>>();
        List<AcctSeed__GL_Account__c> glAcclist = [SELECT Name FROM AcctSeed__GL_Account__c LIMIT 1];

        Id proId1 = null;
        Id proPT1 = null;
        Id accPId = null;
        Id accId = null;
        Id glAcc = null;
        String accCode = null;
        String accpdName = null;
        
        AcctSeed__Journal_Entry__c je = new AcctSeed__Journal_Entry__c();
        
        if(proList.size() > 0){
            proId1 = proList[0].Id; 
            if(accList.size() > 0){
                proList[0].AcctSeed__Account__c =  accList[0].Id;
                update proList;
            }
        }
        if(proPTList.size() > 0){
            proPT1 = proPTList[0].Id;
        }
        if(acpList.size() > 0){
            accPId = acpList[0].Id;
            accpdName = acpList[0].Name;
            je.AcctSeed__Accounting_Period__c  = acpList[0].Id;
        }
        if(accList.size() > 0){
            accId = accList[0].Id;
            accCode = accList[0].Account_Code__c;
        }
        if(glAcclist.size() > 0){
            glAcclist[0].Name = 'Actual';
            update glAcclist;
            glAcc = glAcclist[0].Id;
        }
        
        if(proId1 != null){
            journalMap.put(proId1,je);

            List<AcctSeed__Journal_Entry_Line__c> jel = new List<AcctSeed__Journal_Entry_Line__c>();
            AcctSeed__Journal_Entry_Line__c jelCredit = new AcctSeed__Journal_Entry_Line__c();
            jelCredit.AcctSeed__Project__c = proId1;
            jelCredit.AcctSeed__Project_Task__c = proPT1;
            jelCredit.AcctSeed__Credit__c = 100;
            jelCredit.AcctSeed__GL_Account__c = glAcc;
            
            AcctSeed__Journal_Entry_Line__c jelDebit = new AcctSeed__Journal_Entry_Line__c();
            jelDebit.AcctSeed__Debit__c = 100;
            jelDebit.AcctSeed__GL_Account__c = glAcc;
            
            jel.add(jelCredit);
            jel.add(jelDebit);
            journalMapLineMap.put(proId1,jel);
        }
      
        String journalJSON = JSON.serialize(journalMap);
        String journaLineJSON = JSON.serialize(journalMapLineMap);
        Test.startTest();
        BillingCreation_Ctrl.journalEntryCreation(journalJSON,journaLineJSON,accId,accPId);
        
        List<AcctSeed__Journal_Entry__c> journal = [SELECT Id,Name FROM AcctSeed__Journal_Entry__c]; 

        if(journal.size() > 0){
            system.assertEquals(1,journal.size());
        }
        Test.stoptest();
    }
    
    //Create individual Journal for each Project
    // To exclude the Journal Entry with the name starting with JE,TR, WO, PR
    private static testMethod void testMethod7b(){
        
        List<Account> accList1 = [SELECT Id,Account_Code__c FROM Account LIMIT 1];
        accList1[0].Account_Code__c = 'JECode';
        update accList1[0];
        
        List<Account> accList = [SELECT Id,Account_Code__c FROM Account WHERE Id = :accList1[0].Id];
        
        List<AcctSeed__Project__c> proList = [SELECT Id,AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 2];
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id,Name FROM AcctSeed__Accounting_Period__c LIMIT 1];
        List<AcctSeed__Project_Task__c> proPTList = [SELECT Id,RecordTypeId FROM AcctSeed__Project_Task__c LIMIT 2];
        Map<String,AcctSeed__Journal_Entry__c> journalMap = new Map<String,AcctSeed__Journal_Entry__c>();
        Map<String,List<AcctSeed__Journal_Entry_Line__c>> journalMapLineMap = new Map<String,List<AcctSeed__Journal_Entry_Line__c>>();
        List<AcctSeed__GL_Account__c> glAcclist = [SELECT Name FROM AcctSeed__GL_Account__c LIMIT 1];
        
        String proEFLRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('EFL_Projects').getRecordTypeId();
        String accPdName = null;
        String accCode = null;

        Id proId1 = null;
        Id proPT1 = null;
        Id accPId = null;
        Id accId = null;
        Id glAcc = null;
        
        AcctSeed__Journal_Entry__c je = new AcctSeed__Journal_Entry__c();
        
        if(proList.size() > 0){
            proId1 = proList[0].Id; 
            proList[0].RecordTypeId = proEFLRT;
            if(accList.size() > 0){
                proList[0].AcctSeed__Account__c =  accList[0].Id;
            }
            update proList;
        }
        if(proPTList.size() > 0){
            proPT1 = proPTList[0].Id;
        }
        if(acpList.size() > 0){
            accPId = acpList[0].Id;
            accPdName = acpList[0].Name;
            je.AcctSeed__Accounting_Period__c  = acpList[0].Id;
        }
        if(accList.size() > 0){
            accCode = accList[0].Account_Code__c;
            accId = accList[0].Id;
        }
        if(glAcclist.size() > 0){
        
            glAcc = glAcclist[0].Id;
            glAcclist[0].Name = 'Actual';
            glAcclist[0].AcctSeed__Type__c= 'Balance Sheet';
            update glAcclist;
        }
        

        if(proId1 != null){
            journalMap.put(proId1,je);

            List<AcctSeed__Journal_Entry_Line__c> jel = new List<AcctSeed__Journal_Entry_Line__c>();
            AcctSeed__Journal_Entry_Line__c jelCredit = new AcctSeed__Journal_Entry_Line__c();
            jelCredit.AcctSeed__Project__c = proId1;
            jelCredit.AcctSeed__Project_Task__c = proPT1;
            jelCredit.AcctSeed__Credit__c = 100;
            jelCredit.AcctSeed__GL_Account__c = glAcc;
            
            AcctSeed__Journal_Entry_Line__c jelDebit = new AcctSeed__Journal_Entry_Line__c();
            jelDebit.AcctSeed__Debit__c = 100;
            jelDebit.AcctSeed__GL_Account__c = glAcc;
            
            jel.add(jelCredit);
            jel.add(jelDebit);
            journalMapLineMap.put(proId1,jel);
        }
      
        String journalJSON = JSON.serialize(journalMap);
        String journaLineJSON = JSON.serialize(journalMapLineMap);
        
        
        List<AcctSeed__Journal_Entry__c> jeList = new List<AcctSeed__Journal_Entry__c>{
            new AcctSeed__Journal_Entry__c(Name = accCode+'-'+accPdName+'-001',Project__c = proId1,AcctSeed__Journal_Date__c = system.today()),
            new AcctSeed__Journal_Entry__c(Name = accCode+'-'+accPdName+'-002',Project__c = proId1,AcctSeed__Journal_Date__c = system.today().addDays(1))
        };
           
        Test.startTest();
        
        if(jeList.size() > 0){
            insert jeList;
        }
        
        BillingCreation_Ctrl.journalEntryCreation(journalJSON,journaLineJSON,accId,accPId);
        String jeName = accCode+'-'+accPdName+'-003';
        
        List<AcctSeed__Journal_Entry__c> journal = [SELECT Id,Name FROM AcctSeed__Journal_Entry__c WHERE Name = :jeName]; 

        if(journal.size() > 0){
            system.assertEquals(accCode+'-'+accPdName+'-003',journal[0].Name);
        }
        Test.stoptest();
        
        String journalExistJSON = BillingCreation_Ctrl.checkBillORJournalExist('Journal',JSON.serialize(new List<Id> {proId1}),accpId);
        Map<String,Id> journalExistMap = (Map<String,Id>) JSON.deserialize(journalExistJSON,Map<String,Id>.class);
        
        if(journalExistMap.size() > 0){
            system.assertEquals(true,journalExistMap.containsKey(proId1+'~'+proPT1));
        }
    }
    
   // get user Lookup Records 
    private static testMethod void testMethod8(){
        List<User> userList = BillingCreation_Ctrl.getLookupRecords('softsquare', 'User', 'Name', ' isPortalEnabled = false', new List<String>{});
        if(userList.size() > 0){
          System.assertEquals(userList.size(), 1);  
        }
    }
    private static testMethod void testMethod9(){
        List<Contact> conRec = [SELECT Id FROM Contact LIMIT 1];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c ORDER BY AcctSeed__Start_Date__c LIMIT 2];
        List<AcctSeed__Project_Task__c> proPTList = [SELECT Id,AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 1];
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id FROM AcctSeed__GL_Account__c LIMIT 1]; 
        List<AcctSeed__Project__c> proList = [SELECT Id,AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 1];
        List<CLIN__c> clinList = [SELECT Id FROM CLIN__c LIMIT 1];
        
        Date myDate = date.today();
        Date weekStart = myDate.toStartofWeek()+1;
        Date weekEnd = myDate.toStartofWeek()+7;
        
        Date monthStart = weekStart.toStartofMonth();
        Date monthEnd = weekStart.addMonths(1).toStartofMonth().addDays(-1);
        Date monthStart1 = weekEnd.toStartofMonth();
        Date monthEnd1 = weekEnd.addMonths(1).toStartofMonth().addDays(-1);
        
        Id accPId = null;
        Id proId = null;
        Id accId = null;
        Id proPT = null;
        
        if(glAccList.size() > 0){
            glAccList[0].AcctSeed__Type__c ='Expense';
            glAccList[0].AcctSeed__Bank__c = false;
            
            update glAccList;
        }

        if(proList.size() > 0){
            proId = proList[0].Id; 
            proList[0].Billing_Type__c = '11002-Billed at End';
            if(accList.size() > 0){
                accId= accList[0].Id;
                proList[0].AcctSeed__Account__c =  accList[0].Id;
            }
            update proList;
        }
        
        if(proPTList.size() > 0){
            proPT = proPTList[0].Id;
            if(clinList.size() > 0){
               proPTList[0].CLIN__c = clinList[0].Id;
                update proPTList;
            }
        }
        
        if(acpList.size() > 0){
            if(monthStart != monthStart1 && monthEnd != monthEnd1) {
                accPId = acpList[1].Id;
            }else{
                accPId = acpList[0].Id;   
            }
        }

        Test.startTest();
        if(conRec.size() > 0){
            
            List<AcctSeed__Account_Payable__c> payableRec = new List<AcctSeed__Account_Payable__c> {
                new AcctSeed__Account_Payable__c(AcctSeed__Payee_Reference__c = 'Reference ',AcctSeed__Status__c = 'Approved',AcctSeed__Contact__c = conRec[0].Id,AcctSeed__Due_Date__c = System.today())
             };
             insert payableRec;
            
            if(payableRec.size() > 0 && payableRec[0].Id != null && proPTList.size() > 0 && glAccList.size() > 0){
                
                List<AcctSeed__Account_Payable_Line__c> payableLineRec = new List<AcctSeed__Account_Payable_Line__c> {
                    new AcctSeed__Account_Payable_Line__c(AcctSeed__Account_Payable__c = payableRec[0].Id,AcctSeed__Expense_GL_Account__c = glAccList[0].Id,AcctSeed__Amount__c = 250,Billable__c = true,Period_to_Bill__c = accPId,AcctSeed__Date__c = System.today(),AcctSeed__Project__c = proId,AcctSeed__Project_Task__c =  proPT,AcctSeed__Quantity__c = 1, Amount_per_Quantity__c = 250),
                    new AcctSeed__Account_Payable_Line__c(AcctSeed__Account_Payable__c = payableRec[0].Id,AcctSeed__Expense_GL_Account__c = glAccList[0].Id,AcctSeed__Amount__c = 200,Billable__c = true,Period_to_Bill__c = accPId,AcctSeed__Date__c = System.today().addDays(1),AcctSeed__Project__c = proId,AcctSeed__Project_Task__c = proPT, AcctSeed__Quantity__c = 1, Amount_per_Quantity__c = 200)
                };
                insert payableLineRec;
            }

            
            String billingInfoJSON = BillingCreation_Ctrl.getBillingRowInfo(null,accId,accpId,'11002-Billed at End');
            
            BillingCreation_Ctrl.BillingInfo billInfo = (BillingCreation_Ctrl.BillingInfo) JSON.deserialize(billingInfoJSON,BillingCreation_Ctrl.BillingInfo.class);
            
            if(billInfo != null  && billInfo.billingRowInfo.size() > 0){
                system.assertEquals(proId,billInfo.billingRowInfo[0].projectId);
            }
        }
        Test.stopTest();
    }
    // Billing line row formation
    private static testMethod void testMethod10(){
        List<AcctSeed__Time_Card_Line__c> tclList = [SELECT Id,AcctSeed__Project__c,AcctSeed__Project_Task__c,AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c FROM AcctSeed__Time_Card_Line__c LIMIT 1];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<AcctSeed__Project__c> proList = [SELECT Id,AcctSeed__Account__c FROM AcctSeed__Project__c];
        List<AcctSeed__Project_Task__c> proPTList = [SELECT Id,RecordTypeId FROM AcctSeed__Project_Task__c LIMIT 2];
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c ORDER BY AcctSeed__Start_Date__c LIMIT 2];
        List<AcctSeed__Accounting_Variable__c> accVar = [SELECT Id,Name FROM AcctSeed__Accounting_Variable__c LIMIT 1];
        List<CLIN__c> clinList = [SELECT Id FROM CLIN__c LIMIT 1];
        List<Contact_Assignments__c> conAssignList = [SELECT Id FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student'];
        
        String ptLTRT = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Language_Training').getRecordTypeId();
        
        Date myDate = date.today();
        Date weekStart = myDate.toStartofWeek()+1;
        Date weekEnd = myDate.toStartofWeek()+7;
        
        Date monthStart = weekStart.toStartofMonth();
        Date monthEnd = weekStart.addMonths(1).toStartofMonth().addDays(-1);
        Date monthStart1 = weekEnd.toStartofMonth();
        Date monthEnd1 = weekEnd.addMonths(1).toStartofMonth().addDays(-1);
        
        Id accId = null;
        Id proId = null;
        Id accPId = null;
        Id proPT = null;
        
        system.debug('acpList'+acpList);
        if(accList.size() > 0){
            accId = accList[0].Id;
        }
        if(acpList.size() > 0){
            if(monthStart == monthStart1 && monthEnd == monthEnd1) {
                accPId = acpList[0].Id;
            }else{
                accPId = acpList[1].Id;   
            }
        }
        if(proList.size() > 0){
            proId = proList[0].Id; 
            proList[0].AcctSeed__Account__c = accId;
            proList[0].QB_Classification__c = 'ADM';
            proList[0].Billing_Type__c = '11002-Billed at End';
            update proList;
            
            if(conAssignList.size() > 0){
                conAssignList[0].Project__c = proId;
                conAssignList[1].Project__c = proId;
                
                update conAssignList;
            }
            
            List<AcctSeed__Project_Task__c> ptList = new List<AcctSeed__Project_Task__c>{
                new AcctSeed__Project_Task__c(Name = 'Language Training - Hindi',Total_Amount_Paid__c = 100,Acctseed__Project__c = proId,Project_Task_Type__c='Language Training',Rate__c = 41,RecordTypeId = ptLTRT,Billable__c = true),
                new AcctSeed__Project_Task__c(Name = 'Each Additional Student',Acctseed__Project__c = proId,Project_Task_Type__c='Language Training',Rate__c = 40,RecordTypeId = ptLTRT,Billable__c = true)
            };
                
                if(ptList.size() > 0){
                    insert  ptList;
                    
                    proPT = ptList[0].Id;
                    ptList[1].Parent_Project_Task__c = proPT;
                    update ptList[1];
                }
            
        }
        
        if(accVar.size() > 0){
            accVar[0].Name = 'ADM';
            update accVar;
        }
        if(tclList.size() > 0){
            tclList[0].AcctSeed__Project__c = proId;
            tclList[0].AcctSeed__Project_Task__c = proPT;
            tclList[0].AcctSeed__Billable__c = true;
            update tclList;
        }
        Test.StartTest();
        
        List<AcctSeed__GL_Account__c> glAcc = new List<AcctSeed__GL_Account__c> {
            new AcctSeed__GL_Account__c(Name = '11001 - Accounts Receivable',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Active__c  = true, AcctSeed__Bank__c = true),
                new AcctSeed__GL_Account__c(Name = '40540 - Learning Mngmt System Revenue',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Active__c  = true, AcctSeed__Bank__c = true),
                new AcctSeed__GL_Account__c(Name = '25501 - Sales Tax Payable - New',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Active__c  = true, AcctSeed__Bank__c = true),
                new AcctSeed__GL_Account__c(Name = '12853 - RE - Language Materials',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Active__c  = true, AcctSeed__Bank__c = true)
                
                };
                    
              insert glAcc;
        String billingInfoJSON = BillingCreation_Ctrl.getBillingRowInfo(proId,accId,accpId,'11002-Billed at End');
        
        BillingCreation_Ctrl.BillingInfo billInfo = (BillingCreation_Ctrl.BillingInfo) JSON.deserialize(billingInfoJSON,BillingCreation_Ctrl.BillingInfo.class);
        system.debug('billInfo'+billInfo);
        
        if(billInfo != null  && billInfo.billingRowInfo.size() > 0){
            system.assertEquals(proId,billInfo.billingRowInfo[0].projectId);
        }
        Test.StopTest();
    }
}