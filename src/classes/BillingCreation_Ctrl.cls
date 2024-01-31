/*Developed by Siva Prasanth K.T on 24/09/2019*/
public class BillingCreation_Ctrl {
    /*W-002782 - Batch Billings (Invoice) Creation Process*/
     
    @AuraEnabled
    public static String getInitialFilterValues(){
        
        BillingInitialFilterInfo initialInfo = new BillingInitialFilterInfo();
        List<AcctSeed__Accounting_Period__c> periodList= new List<AcctSeed__Accounting_Period__c>();
        List<String> options = new List<String>();
        
        Date previousMonthStartDt = System.Date.today().toStartOfMonth().addMonths(-1); 
        Date previousMonthEndDt = previousMonthStartDt.addMonths(1).addDays(-1);
        
        //for(AcctSeed__Accounting_Period__c accPeriod : [SELECT Id,Name FROM AcctSeed__Accounting_Period__c WHERE AcctSeed__Start_Date__c = :previousMonthStartDt AND AcctSeed__End_Date__c = :previousMonthEndDt LIMIT 1]){
        for(AcctSeed__Accounting_Period__c accPeriod : AccountingPeriodService.getAccountperiodRec( new Set<Date>{previousMonthStartDt}, new Set<Date>{previousMonthEndDt})) {    
            AcctSeed__Accounting_Period__c accP = new AcctSeed__Accounting_Period__c();
            accP.Id = accPeriod.Id;
            accP.Name = accPeriod.Name;
            periodList.add(accP);
        }
        // get Previous month Accounting Period Lookup Value
        if(periodList.size() > 0){
            initialInfo.accountingPeriodFilter = periodList;
        }
        //Project Billing_Type__c Field PickList Value Formation
        Schema.DescribeFieldResult fieldResult = AcctSeed__Project__c.Billing_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {
            if(f.getValue() != 'Non-Billable'){
                options.add(f.getValue());
            }
        }
        
        if(options.size() > 0){
            initialInfo.billingTypePickList = options;
        }
        
        return JSON.serialize(initialInfo);
    }
    // Billing Row Formation
    @AuraEnabled
    public static String getBillingRowInfo(String projectId,String accId,String accountPeriodId,String billingType){
        
        List<AcctSeed__Project__c> projectList = new  List<AcctSeed__Project__c>();
        //List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id,Name,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c WHERE Id = :accountPeriodId];
        List<AcctSeed__Accounting_Period__c> acpList = SObjectQueryService.SObjectQuery('AcctSeed__Accounting_Period__c', new Set<Id> {accountPeriodId}, '');
        //Set<String> projectRT = new Set<String>{'Language_Training_Projects','DODA_Projects','DLI_W_LT_Projects','CD_Projects','Testing_Projects','Linguist_Support_Projects','Translation_Projects'};
        Set<Id> materialBudgetPTSet = new Set<Id>();
        Set<Id> otherPTSet = new Set<Id>();
        Set<String> tcdGlAccNameSet = new Set<String>();
        Map<Id,String> proBillingConMap = new Map<Id,String>();
        List<AcctSeed__Accounting_Variable__c> accVariable = new List<AcctSeed__Accounting_Variable__c>();
        
        Map<String,String> billingTypeMap = new Map<String,String>{'11001 - Accounts Receivable' => '11001-Monthly Arrears' ,
                                                                  '11005 - AR - Deferred Revenue' => '11005-Prepayment' ,
                                                                  '11002 - Unbilled Accounts Receivable' => '11002-Billed at End'};
                
        Map<String,String> mRVendorGlAccountMap = new Map<String,String>{'12101 - Inventory- LT Materials VA' => 'Stock',
                                                                         '40540 - Learning Mngmt System Revenue' => 'D2L',
                                                                         '40520 - In-house Materials Revenue' => 'In-House' ,
                                                                         '25501 - Sales Tax Payable - New' => 'SalesTax',
                                                                         '22050 - Accrued Expenses' => 'GSAFees',
                                                                         '12853 - RE - Language Materials' => 'External Material'};
                        
        Map<String,Id> billingTypeRelGLAccountMap = new Map<String,Id>();
        Map<String,Id> matReqVendarRelGLAccountMap = new Map<String,Id>();
        Map<String,Id> qbClassficationRelGlVarMap = new Map<String,Id>();
        Map<Id,Id> billingContactMap = new Map<Id,Id>();
        Map<String,String> accountCodeMap = new Map<String,String>();
        
        List<String> pTvendarNameList = new List<String>{'D2L','In-House','SalesTax','ExternalMaterial'};
            
        Set<Id> projectIds = new Set<Id>(); 
        Set<String> timeCardStatus = new Set<String>{'Approved', 'Admin Approved'}; 
               
       //W-007676 - Urgent - LT without Prep (RT5) payroll item is not pulling in the "Create Billings"
        Set<String> testingPayRollItems = new Set<String>{'R', 'TES','RT5','RT3'};  
        Set<String> dliPayRollItems= new Set<String>{'RT2'};  
        Set<String> otherPayRollItems = new Set<String>{'R', 'RT5','RT3'}; //W-007941 - Create Billings - RT3 new payroll item needs to be added as a billable payroll item 
            
        Date stDate;
        Date endDate;
        
        String accPeriodName;
        String billingContact;
        String deferredARRevenue;
        String accName = '';
        String accParentName = '';
        String gLvarName1 = 'ON0LT0ARL'; //The classifications: ON0ARL0AFP and ON0ARL0CLP should all map to the GL Variable 1: ON0LT0ARL.

        Boolean isShowClin = true;
        Decimal billingColumnTotal = 0.00;
        Integer billingRecCount = 0;
        
        
        String timeCardDayQuery = 'SELECT Id,GL_Variable_2__c, QB_Classification__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,Total_Hours_Before_Approved__c,AcctSeed__Hours__c FROM AcctSeed__Time_Card_Day__c';
        timeCardDayQuery = timeCardDayQuery + ' WHERE AcctSeed__Hours__c > 0 AND AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Billable__c = true AND AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c = true AND Status__c IN: timeCardStatus';
        timeCardDayQuery = timeCardDayQuery + ' AND (( (AcctSeed__Time_Card_Line__r.Payroll_Item__c IN :testingPayRollItems) AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName = \'Testing_Projects\' AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Test_Type__c != \'In-house Non-Billable\')';
        timeCardDayQuery = timeCardDayQuery + ' OR (AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName = \'DLI_W_LT_Projects\' AND AcctSeed__Time_Card_Line__r.Payroll_Item__c IN :dliPayRollItems)';
        timeCardDayQuery = timeCardDayQuery +' OR (AcctSeed__Time_Card_Line__r.Payroll_Item__c IN :otherPayRollItems AND ( AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName != \'Testing_Projects\' OR AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName != \'DLI_W_LT_Projects\')) )';
        
        String matReqQuery = 'SELECT Id,Name,DLS_Total__c,Vendor_Name__c,Project__r.QB_Classification__c,Vendor_Name__r.Name,Materials_Name__r.Name,project_Task__r.AcctSeed__Project__r.RecordTypeId,Materials_Name__r.RecordType.DeveloperName,Qty__c,DLS_Sales_Tax_Formula__c,Item_Price_Formula__c,Project_Task__r.AcctSeed__Project__r.Name,Project_Task__r.AcctSeed__Project__c,Project_Task__r.AcctSeed__Project__r.AcctSeed__Account__c,Project_Task__c,Project_Task__r.AcctSeed__Project__r.AcctSeed__Account__r.Name,Project_Task__r.AcctSeed__Project__r.AcctSeed__Account__r.AcctSeed__Billing_Contact__c,Project_Task__r.Name,Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,Project_Task__r.CLIN__c,Project_Task__r.AcctSeed__GL_Account_Variable_2__c,Project_Task__r.AcctSeed__GL_Account_Variable_2__r.Name,Project_Task__r.AcctSeed__GL_Account_Variable_1__c,Project_Task__r.CLIN__r.Name,Project_Task__r.Revenue_GL_Account__c,Project_Task__r.Product__c,Project_Task__r.AcctSeed__Project__r.QB_Classification__c,GSA_Fee_Formula__c FROM Materials_Request__c WHERE RecordType.DeveloperName = \'Project_Materials_Request\' AND Project_Task__r.Billable__c = true AND Project_Task__r.RecordType.DeveloperName = \'Material_Budget\' AND Request_Status__c = \'Delivered\' AND Vendor_Total__c > 0 ';       
        
        String payableLineQuery = 'SELECT Id,Name,AcctSeed__Project__c,AcctSeed__Internal_Comment__c,Amount_per_Quantity__c,AcctSeed__Project__r.AcctSeed__Account__r.Name,AcctSeed__Project_Task__r.Name,AcctSeed__Project_Task__r.CLIN__c,AcctSeed__Project__r.AcctSeed__Account__c,AcctSeed__Project__r.RecordType.DeveloperName,AcctSeed__Project__r.AcctSeed__Account__r.AcctSeed__Billing_Contact__c,AcctSeed__Project_Task__r.CLIN__r.Name,AcctSeed__Quantity__c,AcctSeed__Project_Task__r.AcctSeed__GL_Account_Variable_2__c,AcctSeed__Project_Task__r.AcctSeed__GL_Account_Variable_2__r.Name,AcctSeed__Project_Task__r.AcctSeed__GL_Account_Variable_1__c,AcctSeed__Project__r.Name,AcctSeed__Project_Task__r.Product__c,AcctSeed__Project_Task__r.Project_Task_Type__c,AcctSeed__Amount__c,AcctSeed__Project__r.QB_Classification__c,AcctSeed__Project_Task__c,AcctSeed__Project_Task__r.Revenue_GL_Account__c  FROM AcctSeed__Account_Payable_Line__c WHERE AcctSeed__Project__c != null AND AcctSeed__Project_Task__c != null AND Billable__c = true';
        
        if(acpList.size() > 0) {
            stDate = acpList[0].AcctSeed__Start_Date__c;
            endDate = acpList[0].AcctSeed__End_Date__c;
            accPeriodName = acpList[0].Name;
            
            payableLineQuery += ' AND Period_to_Bill__c = \''+acpList[0].Id+'\'';
        }
        
        if(accId != null){
            // get Account Code
            List<Account> accList = [SELECT Id,Name,Parent.Name,Account_Code__c,AcctSeed__Billing_Contact__r.Name FROM Account WHERE Id = :accId];
            Set<String> accIdSet = new Set<String>{accId};
            
            if(accList.size() > 0){
                accName = accList[0].Name;
                accParentName = accList[0].Parent.Name;
                billingContact = accList[0].AcctSeed__Billing_Contact__r.Name;
                accountCodeMap = new Map<String,String>{accList[0].Id+'~'+accList[0].Name => accList[0].Account_Code__c};
            }
            
            if(accparentName == 'PVT' || accName == 'PVT'){
                isShowClin = false;
            }
            
            if(accName == 'PVT'){
                for(Account acc : [SELECT Id,ParentId,Name,Account_Code__c FROM Account WHERE ParentId = :accId]){
                    accIdSet.add(acc.Id);
                    if(!accountCodeMap.containsKey(acc.Id+'~'+acc.Name)){
                        accountCodeMap.put(acc.Id+'~'+acc.Name,acc.Account_Code__c);
                    }
                    
                }
            }
           
            timeCardDayQuery += ' AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.AcctSeed__Account__c IN :accIdSet';
            matReqQuery += ' AND Project__r.AcctSeed__Account__c IN :accIdSet';
            payableLineQuery += ' AND AcctSeed__Project__r.AcctSeed__Account__c IN :accIdSet';
            
            system.debug('accIdSet:::::'+accIdSet);
        }
        if(stDate != null && endDate != null){ 
            timeCardDayQuery  += ' AND AcctSeed__Date__c >= :stDate AND AcctSeed__Date__c <= :endDate';
            matReqQuery += ' AND (Date_Delivered__c >= :stDate AND Date_Delivered__c <= :endDate)';
        }
        
        if(projectId != null){
            timeCardDayQuery += ' AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__c = \''+projectId+'\'';
            matReqQuery += ' AND Project__c = \''+projectId+'\'';
            payableLineQuery += ' AND AcctSeed__Project__c = \''+projectId+'\'';
        }
        
        if(billingType != null){
            timeCardDayQuery += ' AND  AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Billing_Type__c = \''+billingType+'\'';
            matReqQuery += ' AND Project__r.Billing_Type__c = \''+billingType+'\'';
            payableLineQuery += ' AND AcctSeed__Project__r.Billing_Type__c = \''+billingType+'\'';
        }
        System.debug('matReqQuery:::::'+matReqQuery);
        
        //get hour related projects
       // Map<String,Decimal> ptQuantityMap = new Map<String,Decimal>();
        Map<Id,Integer> projectWithStudentCountMap = new Map<Id,Integer>();
        Map<String,Map<String,Decimal>> ptQuantityMapWithQbs = new Map<String,Map<String,Decimal>>();


        for(AcctSeed__Time_Card_Day__c tcd : Database.query(timeCardDayQuery)){
            
            Id proId = tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
            Id proTaskId = tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
            Decimal totalApprovedHrs = (tcd.AcctSeed__Hours__c != null ? tcd.AcctSeed__Hours__c : 0.00);
            projectIds.add(tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c);
            
            if(tcd.QB_Classification__c != null){
                tcdGlAccNameSet.add(tcd.QB_Classification__c);
                if(ptQuantityMapWithQbs.containsKey(proId +'~'+proTaskId)){
                    if(ptQuantityMapWithQbs.get(proId +'~'+proTaskId).containsKey(tcd.QB_Classification__c)){
                        ptQuantityMapWithQbs.get(proId +'~'+proTaskId).put(tcd.QB_Classification__c, ptQuantityMapWithQbs.get(proId +'~'+proTaskId).get(tcd.QB_Classification__c)+totalApprovedHrs);        
                    }else{
                        ptQuantityMapWithQbs.get(proId +'~'+proTaskId).put(tcd.QB_Classification__c,  totalApprovedHrs);
                    } 
                }else{
                    ptQuantityMapWithQbs.put(proId +'~'+proTaskId,new Map<String,Decimal>{tcd.QB_Classification__c => totalApprovedHrs});
                }
            }
        }
        
        //Modified by siva on 6/15/21
        // Matching QB classification related Gl Accounting variable Map

        if(tcdGlAccNameSet.size() > 0){
            for(AcctSeed__Accounting_Variable__c gl : [SELECT Id,Name FROM AcctSeed__Accounting_Variable__c WHERE Name In :tcdGlAccNameSet]){
                if(!qbClassficationRelGlVarMap.containsKey(gl.Name)){
                    qbClassficationRelGlVarMap.put(gl.Name,gl.Id);
                }
            }
        }
        
        System.debug('ptQuantityMapWithQbs::'+ptQuantityMapWithQbs);
        if(projectIds.size() > 0){
            
            for(Contact_Assignments__c ca  : [SELECT Id,Project__c,RecordType.DeveloperName FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c IN ('Active','Ended','On Hold') AND Project__c IN :projectIds]){ // not used service class since we used only limited fields
                if(!projectWithStudentCountMap.containsKey(ca.Project__c)){
                    
                    projectWithStudentCountMap.put(ca.Project__c,1);
                }else{
                    projectWithStudentCountMap.put(ca.Project__c,projectWithStudentCountMap.get(ca.Project__c) + 1); 
                }
            }
        } 
        
        for(AcctSeed__GL_Account__c gcA : [SELECT Id,Name FROM AcctSeed__GL_Account__c WHERE (Name IN :billingTypeMap.keySet() OR Name IN :mRVendorGlAccountMap.keySet())]){
            
            //billing Type related GL Account Map
            if(billingTypeMap.containsKey(gcA.Name)){
                billingTypeRelGLAccountMap.put(billingTypeMap.get(gcA.Name),gcA.Id);
            }
            
            //Material Request Vendar Name related GL Account Map   
            if(mRVendorGlAccountMap.containsKey(gcA.Name)){
                matReqVendarRelGLAccountMap.put(mRVendorGlAccountMap.get(gcA.Name),gcA.Id);
            }
        }
        
        system.debug('matReqVendarRelGLAccountMap'+matReqVendarRelGLAccountMap);
        
        List<BillingRowInfo> billingRowList = new List<BillingRowInfo>();
        Map<Id,List<billingLineProjecTaskInfo>> projectPTMap = new Map<Id,List<billingLineProjecTaskInfo>>();
        Map<Id,List<billingLineProjecTaskInfo>> proEachAdditionStuPTMap = new Map<Id,List<billingLineProjecTaskInfo>>();
        Set<Id> eachAddStudentProIds = new Set<Id>();
        
        Set<Id> billingRowProIds = new Set<Id>();
        /* for(AcctSeed__Project_Task__c proTask : [SELECT Id,Name,Rate__c,CLIN__c,CLIN__r.Name,AcctSeed__GL_Account_Variable_1__c,RecordType.DeveloperName,Project_Task_Type__c,Parent_Project_Task__c,
                                                 Product__c,Revenue_GL_Account__c,AcctSeed__Project__r.Name,AcctSeed__Project__r.AcctSeed__Account__c,AcctSeed__Project__r.AcctSeed__Account__r.Name,
                                                 AcctSeed__Project__r.RecordType.DeveloperName,AcctSeed__Project__r.QB_Classification__c,AcctSeed__Project__r.AcctSeed__Account__r.AcctSeed__Billing_Contact__c
                                                    FROM AcctSeed__Project_Task__c 
                                                    WHERE Billable__c = true AND AcctSeed__Project__c IN :projectIds AND RecordType.DeveloperName != 'Material_Budget' ORDER BY Project_Task_Type__c]){ */
        if(projectIds.size() > 0) {
            
            for(AcctSeed__Project_Task__c proTask : ProjectTaskService.getProjectTaskRecbyParentId(', CLIN__r.Name, RecordType.DeveloperName, AcctSeed__Project__r.Name,AcctSeed__Project__r.AcctSeed__Account__c, AcctSeed__Project__r.AcctSeed__Account__r.Name, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Project__r.QB_Classification__c,AcctSeed__GL_Account_Variable_2__r.Name, AcctSeed__Project__r.AcctSeed__Account__r.AcctSeed__Billing_Contact__c ', ' WHERE Billable__c = true AND RecordType.DeveloperName != \'Material_Budget\' AND AcctSeed__Project__c ' , projectIds, ' ORDER BY Project_Task_Type__c' )) {   
                String proId = proTask.AcctSeed__Project__c;
                String proIdPtId = ''; // Project and Project Task Id Combination
                
                if(proTask.Name.contains('Additional Student')) {
                    proIdPtId = proId + '~' + proTask.Parent_Project_Task__c;
                } else {
                    proIdPtId = proId + '~' + proTask.Id; 
                }
                Decimal total = 0.00;
                
                // get Project Task info from project
                if( ptQuantityMapWithQbs.containsKey(proIdPtId)) {
                    //GRK if(proId != null && ((ptQuantityMap.containsKey(proId+'~'+proTask.Id) && ptQuantityMap.get(proId+'~'+proTask.Id) > 0) ||(proTask.Name.contains('Additional Student') && (ptQuantityMap.containsKey(proId+'~'+proTask.Parent_Project_Task__c) && ptQuantityMap.get(proId+'~'+proTask.Parent_Project_Task__c) > 0)) )){
                    
                    billingLineProjecTaskInfo proTaskInfo = new billingLineProjecTaskInfo();
                    List<CLIN__c> clinLookup = new List<CLIN__c>();
                    
                    proTaskInfo.projecTaskId = proTask.Id;
                    proTaskInfo.projecTaskName = proTask.Name;
                    proTaskInfo.parentProjectId = proId;
                    proTaskInfo.revenueGLAccount = proTask.Revenue_GL_Account__c;
                    proTaskInfo.unitPrice = ((proTask.Rate__c != null) ? String.valueOf((proTask.Rate__c).setScale(2)) : '0.00');
                    proTaskInfo.total = '0.00';
                    proTaskInfo.projectTaskType = proTask.Project_Task_Type__c;
                    proTaskInfo.projectTaskProductId = proTask.Product__c;
                    proTaskInfo.comment = proTask.Name+' - '+accPeriodName;
                    proTaskInfo.projecTaskId = proTask.Id;
                    proTaskInfo.isBillingLineChecked = false;
                    proTaskInfo.isHidePTs = false;
                    proTaskInfo.vendorName = '';
                    proTaskInfo.projectName = proTask.AcctSeed__Project__r.Name; 
                    
                    proTaskInfo.glAccountVar1 = proTask.AcctSeed__GL_Account_Variable_1__c;
                    proTaskInfo.glAccountVar2 = proTask.AcctSeed__GL_Account_Variable_2__c;
                    proTaskInfo.glAccountVar2Name = proTask.AcctSeed__GL_Account_Variable_2__r.Name;
                    
                    if(proTask.CLIN__c != null && isShowClin == true){
                        clinLookup.add(new CLIN__c(Id = proTask.CLIN__c,Name = proTask.CLIN__r.Name));
                        proTaskInfo.clinLookup = clinLookup;
                        proTaskInfo.clinName = proTask.CLIN__r.Name;
                    }
                    
                    /* if(proTask.Name.contains('Additional Student')){
                         proTaskInfo.hrsRelProjecTaskId = proTask.Parent_Project_Task__c;
                        }else {
                         proTaskInfo.hrsRelProjecTaskId = proTask.Id;
                        } commented by GRK*/ 
                    
                    if(proTask.AcctSeed__Project__r.RecordType != null && proTask.AcctSeed__Project__r.RecordType.DeveloperName == 'Testing_Projects'){
                        proTaskInfo.quantity = '1.00';
                  /*  } else if(ptQuantityMap.containskey(proIdPtId) && ptQuantityMap.get(proIdPtId) != null) {
                        proTaskInfo.quantity = (string.valueOf(ptQuantityMap.get(proIdPtId).setScale(2)));*/
                    } else {
                        proTaskInfo.quantity = '0.00';
                    }
                    
                    if(proTask.AcctSeed__Project__r.RecordType != null && proTask.AcctSeed__Project__r.RecordType.DeveloperName == 'Testing_Projects' && proTaskInfo.unitPrice != null){
                        total = Decimal.valueOf(proTaskInfo.unitPrice);
                    }/* else if(proTaskInfo.quantity != null && proTaskInfo.unitPrice != null){
                        total = ((Decimal.valueOf(proTaskInfo.quantity)) * (Decimal.valueOf(proTaskInfo.unitPrice)));
                    }
                    proTaskInfo.total = String.ValueOf(total.setScale(2));*/
                    //System.debug('projectWithStudentCountMap::::'+projectWithStudentCountMap);
                    //System.debug('proTask.Name::::'+proTask.Name);
                    if(proTask.Name.contains('Additional Student')){
                        proTaskInfo.hrsRelProjecTaskId = proTask.Parent_Project_Task__c;
                        
                        if(!eachAddStudentProIds.contains(proId)){
                            eachAddStudentProIds.add(proId);
                            
                            if(projectWithStudentCountMap.containsKey(proId)){
                                Integer stuCount = 0;
                                if(proTask.AcctSeed__Project__r.RecordType.DeveloperName == 'DLI_W_LT_Projects' && (projectWithStudentCountMap.get(proId) > 2)){
                                    stuCount = projectWithStudentCountMap.get(proId) - 2;
                                } else if(proTask.AcctSeed__Project__r.RecordType.DeveloperName != 'DLI_W_LT_Projects' && projectWithStudentCountMap.get(proId) > 1){
                                    stuCount = projectWithStudentCountMap.get(proId) - 1;
                                }
                                System.debug('stuCount::::'+stuCount);
                                if(stuCount > 0){
                                    
                                    List<billingLineProjecTaskInfo> eachAddStudentPTList = new List<billingLineProjecTaskInfo>();
                                    for(Integer i = 0;i < stuCount; i++){
                                        eachAddStudentPTList.add(proTaskInfo);
                                    }
                                    
                                    if(eachAddStudentPTList.size() > 0){
                                        Integer eachAddPTCnt = eachAddStudentPTList.size();
                                        if(!proEachAdditionStuPTMap.containsKey(proId)){
                                            proEachAdditionStuPTMap.put(proId,eachAddStudentPTList);
                                        } else {
                                            proEachAdditionStuPTMap.get(proId).addAll(eachAddStudentPTList);  
                                        }
                                    }
                                }
                            }
                        }
                        
                    } else {
                        proTaskInfo.hrsRelProjecTaskId = proTask.Id;
                        if(!projectPTMap.containsKey(proId)){
                            projectPTMap.put(proId,new List<billingLineProjecTaskInfo>{proTaskInfo});
                        } else {
                            projectPTMap.get(proId).add(proTaskInfo);  
                        }
                    }
                    
                    if(!billingRowProIds.contains(proId)){
                        billingRowProIds.add(proId);
                        
                        BillingRowInfo billingRow = new BillingRowInfo();
                        billingRow.proName = proTask.AcctSeed__Project__r.Name;
                        billingRow.projectId = proId;
                        
                        if(proTask.AcctSeed__Project__r.AcctSeed__Account__c != null){
                            billingRow.accountId = proTask.AcctSeed__Project__r.AcctSeed__Account__c;
                            billingRow.proAccIdWithName = proTask.AcctSeed__Project__r.AcctSeed__Account__c+'~'+proTask.AcctSeed__Project__r.AcctSeed__Account__r.Name;
                            billingRow.billingContact = proTask.AcctSeed__Project__r.AcctSeed__Account__r.AcctSeed__Billing_Contact__c;
                        }
                        billingRow.projectTaskList = new List<billingLineProjecTaskInfo>();
                        billingRow.projectRTName = proTask.AcctSeed__Project__r.RecordType.DeveloperName; 
                        billingRowList.add(billingRow); 
                    }
                }
            }
            
        } 
        //Material request row formation
        
        Map<Id,List<billingLineProjecTaskInfo>> matReqPTMap = new Map<Id,List<billingLineProjecTaskInfo>>();
        Map<Id,billingLineProjecTaskInfo> matReqWithSalesPTMap = new Map<Id,billingLineProjecTaskInfo>();
        Map<Id,List<billingLineProjecTaskInfo>> matReqWithGSAFeesPTMap = new Map<Id,List<billingLineProjecTaskInfo>>();
        
        
        for(Materials_Request__c matReqs : Database.query(matReqQuery)){
            
            //Added Account condition by NS on Feb 17 2022 - W-007362
            if(matReqs.Project_Task__c != null && matReqs.Project_Task__r.AcctSeed__Project__c != null && !(matReqs.Materials_Name__r.Name.contains('LMS Enrollment') && matReqs.DLS_Total__c == 0) 
                && (matReqs.Vendor_Name__c == null || (matReqs.Vendor_Name__c != null && !matReqs.Vendor_Name__r.Name.contains('Free')))){
                
                Id proId = matReqs.Project_Task__r.AcctSeed__Project__c;
                Decimal totalSalesTax = 0.00;
                Boolean isSalesTaxMR = false;
                
                Decimal totalGSAFees = 0.00;
                Boolean isGSAFeeMR = false;
                
                billingLineProjecTaskInfo matReqInfo = new billingLineProjecTaskInfo();
                
                if(matReqs.DLS_Sales_Tax_Formula__c != null && matReqs.DLS_Sales_Tax_Formula__c != 0.00){
                    totalSalesTax = matReqs.DLS_Sales_Tax_Formula__c;
                    isSalesTaxMR = true;
                    system.debug('totalSalesTax'+totalSalesTax);
                }
                
                if(matReqs.GSA_Fee_Formula__c != null && matReqs.GSA_Fee_Formula__c != 0.00){
                    totalGSAFees = matReqs.GSA_Fee_Formula__c;
                    isGSAFeeMR = true;
                    system.debug('totalGSAFees'+totalGSAFees);
                }
                
                List<CLIN__c> clinLookup = new List<CLIN__c>();
                
                matReqInfo.projecTaskId = matReqs.Project_Task__c;
                matReqInfo.projecTaskName = matReqs.Project_Task__r.Name;
                // GRK matReqInfo.quantity = (matReqs.Qty__c != null  ? String.valueOf((matReqs.Qty__c).setScale(2)) : '0.00');
                matReqInfo.unitPrice = (matReqs.Item_Price_Formula__c != null  ? String.valueOf((matReqs.Item_Price_Formula__c).setScale(2)) : '0.00'); 
                matReqInfo.parentProjectId = matReqs.Project_Task__r.AcctSeed__Project__c;
                matReqInfo.matRequestId = matReqs.Id;
                matReqInfo.qbClassificationName = matReqs.Project__r.QB_Classification__c;
                matReqInfo.isBillingLineChecked = false;
                matReqInfo.isHidePTs = false;
                matReqInfo.projectName = matReqs.Project_Task__r.AcctSeed__Project__r.Name;
                
                if(matReqs.project_Task__r.AcctSeed__Project__r.RecordTypeId != null && matReqs.Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName == 'Testing_Projects'){
                    matReqInfo.quantity =  '1.00';
                    matReqInfo.total = ''+(Decimal.valueOf(matReqInfo.unitPrice)).setScale(2);
                }else{
                    matReqInfo.quantity = (matReqs.Qty__c != null  ? String.valueOf((matReqs.Qty__c).setScale(2)) : '0.00');
                    matReqInfo.total = String.valueOf(((Decimal.valueOf(matReqInfo.quantity)) * (Decimal.valueOf(matReqInfo.unitPrice))).setScale(2));
                }
                
                billingColumnTotal = billingColumnTotal + (Decimal.valueOf(matReqInfo.total));
                billingRecCount = billingRecCount + 1;
                
                if(matReqs.Project_Task__r.CLIN__c != null && isShowClin == true){
                    clinLookup.add(new CLIN__c(Id = matReqs.Project_Task__r.CLIN__c,Name = matReqs.Project_Task__r.CLIN__r.Name));
                    matReqInfo.clinLookup = clinLookup;
                    matReqInfo.clinName = matReqs.Project_Task__r.CLIN__r.Name;
                }
                
                if(matReqs.Materials_Name__r.RecordType.DeveloperName == 'DLS_LMS_Enrollment' && ((matReqs.Materials_Name__r.Name).contains('LMS Enrollment')
                                                                                              && (!(matReqs.Materials_Name__r.Name).contains('Free')))){
                    if(matReqVendarRelGLAccountMap.containsKey('D2L')) {
                        matReqInfo.revenueGLAccount = matReqVendarRelGLAccountMap.get('D2L');
                    }
                }else {
                    if(matReqs.Vendor_Name__c != null && String.isNotBlank(matReqs.Vendor_Name__r.Name)){
                        
                        if(pTvendarNameList.contains(matReqs.Vendor_Name__r.Name)){
                            matReqInfo.vendorName = matReqs.Vendor_Name__r.Name;
                        }else{
                            matReqInfo.vendorName = 'External';
                        }
                        
                        if(matReqVendarRelGLAccountMap.containsKey(matReqs.Vendor_Name__r.Name) && matReqVendarRelGLAccountMap.get(matReqs.Vendor_Name__r.Name) != null){
                            matReqInfo.revenueGLAccount = matReqVendarRelGLAccountMap.get(matReqs.Vendor_Name__r.Name);
                        }else if(matReqVendarRelGLAccountMap.containskey('External Material') && matReqVendarRelGLAccountMap.get('External Material') != null){
                            matReqInfo.revenueGLAccount = matReqVendarRelGLAccountMap.get('External Material');
                        }
                        
                    }else if(matReqs.Vendor_Name__c == null){
                        matReqInfo.vendorName = 'External';
                        if(matReqVendarRelGLAccountMap.containskey('External Material') && matReqVendarRelGLAccountMap.get('External Material') != null){
                            matReqInfo.revenueGLAccount = matReqVendarRelGLAccountMap.get('External Material');
                        }
                    }
                }
                
                matReqInfo.projectTaskProductId = matReqs.Project_Task__r.Product__c;
                matReqInfo.glAccountVar1 = matReqs.Project_Task__r.AcctSeed__GL_Account_Variable_1__c;
                matReqInfo.glAccountVar2 = matReqs.Project_Task__r.AcctSeed__GL_Account_Variable_2__c;
                matReqInfo.glAccountVar2Name = matReqs.Project_Task__r.AcctSeed__GL_Account_Variable_2__r.Name;
                matReqInfo.comment = matReqs.Materials_Name__r.Name;
                
                if(!matReqPTMap.containsKey(proId)){
                    matReqPTMap.put(matReqs.Project_Task__r.AcctSeed__Project__c,new List<billingLineProjecTaskInfo>{matReqInfo});
                }else{
                    matReqPTMap.get(proId).add(matReqInfo);  
                }                    
                
                if((!matReqWithSalesPTMap.containskey(proId)) && isSalesTaxMR == true){
                    List<CLIN__c> clinLookups = new List<CLIN__c>();
                    
                    billingLineProjecTaskInfo salesTax = new billingLineProjecTaskInfo();
                    
                    salesTax.projecTaskId = matReqs.Project_Task__c;
                    salesTax.projectName =  matReqs.Project_Task__r.AcctSeed__Project__r.Name;
                    salesTax.projecTaskName = 'Sales Tax';
                    salesTax.parentProjectId =  matReqs.Project_Task__r.AcctSeed__Project__c;
                    salesTax.qbClassificationName = matReqs.Project__r.QB_Classification__c;
                    salesTax.quantity = '1.00';
                    salesTax.unitPrice = String.valueOf((totalSalesTax).setScale(2));
                    salesTax.total = String.valueOf((totalSalesTax).setScale(2));
                    salesTax.projectTaskProductId =  matReqs.Project_Task__r.Product__c;
                    salesTax.glAccountVar1 =  matReqs.Project_Task__r.AcctSeed__GL_Account_Variable_1__c;
                    salesTax.glAccountVar2 =  matReqs.Project_Task__r.AcctSeed__GL_Account_Variable_2__c;
                    salesTax.glAccountVar2Name =  matReqs.Project_Task__r.AcctSeed__GL_Account_Variable_2__r.Name;
                    salesTax.comment = 'SalesTax';
                    salesTax.isBillingLineChecked = false;
                    salesTax.isHidePTs = false;
                    salesTax.vendorName = 'SalesTax';
                    
                    if(matReqVendarRelGLAccountMap.containskey('SalesTax')){
                        salesTax.revenueGLAccount = matReqVendarRelGLAccountMap.get('SalesTax');
                    }  
                    
                    if(matReqs.Project_Task__r.CLIN__c != null && isShowClin == true){
                        clinLookups.add(new CLIN__c(Id =  matReqs.Project_Task__r.CLIN__c,Name =  matReqs.Project_Task__r.CLIN__r.Name));
                        salesTax.clinLookup = clinLookup;
                        salesTax.clinName =  matReqs.Project_Task__r.CLIN__r.Name;
                    }
                    
                    billingColumnTotal = billingColumnTotal + (Decimal.valueOf(salesTax.total));
                    billingRecCount = billingRecCount + 1;
                    matReqWithSalesPTMap.put(proId,salesTax);
                    
                }else if(isSalesTaxMR == true && totalSalesTax != null && matReqWithSalesPTMap.containskey(proId) 
                                              && (String.isNotBlank(MatReqWithSalesPTMap.get(proId).unitPrice) && String.isNotBlank(MatReqWithSalesPTMap.get(proId).total))) {
                                                  
                    billingLineProjecTaskInfo salTax = MatReqWithSalesPTMap.get(proId);
                    Decimal priceTotal = Decimal.valueOf(salTax.unitPrice);

                    priceTotal = priceTotal + totalSalesTax;
                    salTax.unitPrice = String.valueOf(priceTotal.setScale(2)); 
                    salTax.total = String.valueOf(priceTotal.setScale(2)); 
                    matReqWithSalesPTMap.put(proId,salTax);
                }
                if((!matReqWithGSAFeesPTMap.containskey(proId)) && isGSAFeeMR == true){
                        matReqWithGSAFeesPTMap.put(proId, new List<billingLineProjecTaskInfo>());
                 }
                 if((matReqWithGSAFeesPTMap.containskey(proId)) && isGSAFeeMR == true){
                    List<CLIN__c> clinLookups = new List<CLIN__c>();
                    
                    billingLineProjecTaskInfo GSAFeesTax = new billingLineProjecTaskInfo();
                    
                    GSAFeesTax.projecTaskId = matReqs.Project_Task__c;
                    GSAFeesTax.projectName =  matReqs.Project_Task__r.AcctSeed__Project__r.Name;
                    GSAFeesTax.projecTaskName = 'GSA Fees';
                    GSAFeesTax.parentProjectId =  matReqs.Project_Task__r.AcctSeed__Project__c;
                    GSAFeesTax.qbClassificationName = matReqs.Project__r.QB_Classification__c;
                    GSAFeesTax.quantity = '1.00';
                    GSAFeesTax.unitPrice = String.valueOf((totalGSAFees).setScale(2));
                    GSAFeesTax.total = String.valueOf((totalGSAFees).setScale(2));
                    GSAFeesTax.projectTaskProductId =  matReqs.Project_Task__r.Product__c;
                    GSAFeesTax.glAccountVar1 =  matReqs.Project_Task__r.AcctSeed__GL_Account_Variable_1__c;
                    GSAFeesTax.glAccountVar2 =  matReqs.Project_Task__r.AcctSeed__GL_Account_Variable_2__c;
                    GSAFeesTax.glAccountVar2Name =  matReqs.Project_Task__r.AcctSeed__GL_Account_Variable_2__r.Name;
                    GSAFeesTax.comment = 'GSA Materials Fee on '+matReqs.Name;
                    GSAFeesTax.isBillingLineChecked = false;
                    GSAFeesTax.isHidePTs = false;
                    GSAFeesTax.vendorName = 'GSAFees';
                    
                    if(matReqVendarRelGLAccountMap.containskey('GSAFees')){
                        GSAFeesTax.revenueGLAccount = matReqVendarRelGLAccountMap.get('GSAFees');
                    }  
                    
                    if(matReqs.Project_Task__r.CLIN__c != null && isShowClin == true){
                        clinLookups.add(new CLIN__c(Id =  matReqs.Project_Task__r.CLIN__c,Name =  matReqs.Project_Task__r.CLIN__r.Name));
                        GSAFeesTax.clinLookup = clinLookup;
                        GSAFeesTax.clinName =  matReqs.Project_Task__r.CLIN__r.Name;
                    }
                    
                    billingColumnTotal = billingColumnTotal + (Decimal.valueOf(GSAFeesTax.total));
                    billingRecCount = billingRecCount + 1;
                    matReqWithGSAFeesPTMap.get(proId).add(GSAFeesTax);                    
                }
                
                if(!billingRowProIds.contains(proId)){
                    billingRowProIds.add(proId);
                    
                    BillingRowInfo billingRow = new BillingRowInfo();
                    billingRow.proName = matReqs.Project_Task__r.AcctSeed__Project__r.Name;
                    billingRow.projectId = proId;
                    
                    if(matReqs.Project_Task__r.AcctSeed__Project__c != null && matReqs.Project_Task__r.AcctSeed__Project__r.AcctSeed__Account__c != null){
                        billingRow.accountId = matReqs.Project_Task__r.AcctSeed__Project__r.AcctSeed__Account__c;
                        billingRow.proAccIdWithName = matReqs.Project_Task__r.AcctSeed__Project__r.AcctSeed__Account__c+'~'+matReqs.Project_Task__r.AcctSeed__Project__r.AcctSeed__Account__r.Name;
                        billingRow.billingContact = matReqs.Project_Task__r.AcctSeed__Project__r.AcctSeed__Account__r.AcctSeed__Billing_Contact__c;
                    }
                    billingRow.projectTaskList = new List<billingLineProjecTaskInfo>();
                    
                    if(matReqs.project_Task__r.AcctSeed__Project__r.RecordTypeId != null){
                        billingRow.projectRTName = matReqs.Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName; 
                    }
                    billingRowList.add(billingRow); 
                }
            } 
        }
      
        //Payable Line  row formation
        List<billingLineProjecTaskInfo> payableLineList = new List<billingLineProjecTaskInfo>();
        Map<Id,List<billingLineProjecTaskInfo>> payableLineRecMap = new Map<Id,List<billingLineProjecTaskInfo>>();

        for(AcctSeed__Account_Payable_Line__c pl : Database.query(payableLineQuery)){
            
            billingLineProjecTaskInfo payLine = new billingLineProjecTaskInfo();
            
            payLine.projecTaskId = pl.AcctSeed__Project_Task__c;
            payLine.projecTaskName = pl.AcctSeed__Project_Task__r.Name;
            payLine.parentProjectId = pl.AcctSeed__Project__c;
            payLine.quantity = (pl.AcctSeed__Quantity__c != null ? String.valueOf(pl.AcctSeed__Quantity__c.setScale(2)) : '0.00');
            payLine.revenueGLAccount = pl.AcctSeed__Project_Task__r.Revenue_GL_Account__c;
            payLine.unitPrice = (pl.Amount_per_Quantity__c != null ? String.valueOf(pl.Amount_per_Quantity__c.setScale(2)) : '0.00');
            payLine.total = String.valueOf(((Decimal.valueOf(payLine.quantity)) * (Decimal.valueOf(payLine.unitPrice))));
            payLine.projectTaskType = pl.AcctSeed__Project_Task__r.Project_Task_Type__c;
            payLine.projectTaskProductId =  pl.AcctSeed__Project_Task__r.Product__c;
            payLine.comment = pl.AcctSeed__Internal_Comment__c;
            payLine.projecTaskId = pl.AcctSeed__Project_Task__c;
            payLine.isBillingLineChecked = false;
            payLine.isHidePTs = false;
            payLine.vendorName = '';
            payLine.qbClassificationName = pl.AcctSeed__Project__r.QB_Classification__c;
            payLine.projectName = pl.AcctSeed__Project__r.Name; 
            payLine.glAccountVar1 = pl.AcctSeed__Project_Task__r.AcctSeed__GL_Account_Variable_1__c;
            payLine.glAccountVar2 = pl.AcctSeed__Project_Task__r.AcctSeed__GL_Account_Variable_2__c;
            payLine.glAccountVar2Name = pl.AcctSeed__Project_Task__r.AcctSeed__GL_Account_Variable_2__r.Name;
            payLine.payableLineId = pl.Id;
            
            List<CLIN__c> clinLookup = new List<CLIN__c>();
            
            if(pl.AcctSeed__Project_Task__r.CLIN__c != null && isShowClin == true){
                clinLookup.add(new CLIN__c(Id = pl.AcctSeed__Project_Task__r.CLIN__c,Name = pl.AcctSeed__Project_Task__r.CLIN__r.Name));
                payLine.clinLookup = clinLookup;
                payLine.clinName = pl.AcctSeed__Project_Task__r.CLIN__r.Name;
            }
            
            billingColumnTotal = billingColumnTotal + (Decimal.valueOf(payLine.total));
            billingRecCount = billingRecCount + 1;
            
            payableLineList.add(payLine);
            
            if(!payableLineRecMap.containsKey(pl.AcctSeed__Project__c)){
                payableLineRecMap.put(pl.AcctSeed__Project__c,new List<billingLineProjecTaskInfo>{payLine});
            }else{
                payableLineRecMap.get(pl.AcctSeed__Project__c).add(payLine);  
            }
            
            if(!billingRowProIds.contains(pl.AcctSeed__Project__c)){
                billingRowProIds.add(pl.AcctSeed__Project__c);
                BillingRowInfo payableRow = new BillingRowInfo();
                
                payableRow.proName = pl.AcctSeed__Project__r.Name;
                payableRow.accountId = pl.AcctSeed__Project__r.AcctSeed__Account__c;
                payableRow.projectId = pl.AcctSeed__Project__c;
                payableRow.proAccIdWithName =  pl.AcctSeed__Project__r.AcctSeed__Account__c+'~'+pl.AcctSeed__Project__r.AcctSeed__Account__r.Name;
                payableRow.billingContact = pl.AcctSeed__Project__r.AcctSeed__Account__r.AcctSeed__Billing_Contact__c;
                payableRow.projectRTName = pl.AcctSeed__Project__r.RecordType.DeveloperName; 
                payableRow.projectTaskList = new List<billingLineProjecTaskInfo>();
                billingRowList.add(payableRow);
            }
            
        }
          
        List<BillingRowInfo> finalBillingRow = new List<BillingRowInfo>();

        for(BillingRowInfo rowInfo : billingRowList){
            
            if(projectPTMap.containsKey(rowInfo.projectId)){
                
                MapProjectTasksWithQBInfo ptWithQb = mapProjectTaskWithQB(projectPTMap,rowInfo,ptQuantityMapWithQbs,billingRecCount,billingColumnTotal,qbClassficationRelGlVarMap);
                billingRecCount = ptWithQb.billingRecCount;
                billingColumnTotal = ptWithQb.billingColumnTotal;
                rowInfo = ptWithQb.rowInfo;
            }

            if(proEachAdditionStuPTMap.containsKey(rowInfo.projectId)){
                
                MapProjectTasksWithQBInfo ptWithQb = mapProjectTaskWithQB(proEachAdditionStuPTMap,rowInfo,ptQuantityMapWithQbs,billingRecCount,billingColumnTotal,qbClassficationRelGlVarMap);
                billingRecCount = ptWithQb.billingRecCount;
                billingColumnTotal = ptWithQb.billingColumnTotal;
                rowInfo = ptWithQb.rowInfo;
            }
            
            if(matReqPTMap.containsKey(rowInfo.projectId)){
                rowInfo.projectTaskList.addAll(matReqPTMap.get(rowInfo.projectId));
            }
            
            if(payableLineRecMap.containsKey(rowInfo.projectId)){
                rowInfo.projectTaskList.addAll(payableLineRecMap.get(rowInfo.projectId)); 
            }
            
            if(matReqWithSalesPTMap.containsKey(rowInfo.projectId)){
                rowInfo.projectTaskList.add(matReqWithSalesPTMap.get(rowInfo.projectId)); 
            }
            
             if(matReqWithGSAFeesPTMap.containsKey(rowInfo.projectId)){
                rowInfo.projectTaskList.addAll(matReqWithGSAFeesPTMap.get(rowInfo.projectId)); 
            }
            
            if(rowInfo.projectTaskList.size() > 0){
                finalBillingRow.add(rowInfo);
            }
        }
        BillingInfo billInfo = new BillingInfo();
        
        billInfo.billingContact = billingContact;
        billInfo.debitGLAccount = billingTypeRelGLAccountMap;
        billInfo.billingRowInfo = finalBillingRow;
        billInfo.accountCodeMap = accountCodeMap;
        billInfo.isEditableClin = false;
        billInfo.isShowCLIN = isShowClin;
        billInfo.billingColumnTotal = billingColumnTotal;
        billInfo.billingRecordsCnt = billingRecCount;
     
        
        Id profileId = userinfo.getProfileId();
        if(profileId != null) {
            List<Profile> profileList = [Select Id,Name from Profile where Id=:profileId];
            if(profileList[0].Name == 'System Administrator'){
                billInfo.isEditableClin = true;
            }
        }
        
        return JSON.serialize(billInfo);
    }
    // Billing and Billing Line Creation
    @AuraEnabled
    public static String createBillings(String billingLineJSON,String billingJSON,String accPeriod,String accId){
        
        Map<String,List<AcctSeed__Billing_Line__c>> billingLineMap = (Map<String,List<AcctSeed__Billing_Line__c>>) JSON.deserialize(billingLineJSON, Map<String,List<AcctSeed__Billing_Line__c>>.class);
        Map<String,AcctSeed__Billing__c> billingMap = (Map<String,AcctSeed__Billing__c>) JSON.deserialize(billingJSON, Map<String,AcctSeed__Billing__c>.class);
        Map<String,Integer> accBillingDueMap = new Map<String,Integer>();
        List<AcctSeed__Billing_Line__c> billingLine = new List<AcctSeed__Billing_Line__c>();
        List<AcctSeed__Accounting_Period__c>  acpList = new List<AcctSeed__Accounting_Period__c>();
        
           
        Map<String,String> proprietaryBillingNoMap = new Map<String,String>();
        Map<String,Integer> proprietaryBillingNoCountMap = new Map<String,Integer>();
        Set<String> propBillNumSet = new Set<String>();
        
        List<Account> accList = new List<Account>();
        Set<String> projectIds = new Set<String>();
        Set<Id> eflLingProIds = new Set<Id>();

        String proIdsJSON;
        String accpdName = null;
        
        Date stDate;
        Date edDate;
        String billingContact = null;
        String accCode = null;
        Integer BillingDaysDue = 0;
        
        if(accPeriod != null){
            //acpList = [SELECT Id,Name,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c WHERE Id = :accPeriod];
            acpList = SObjectQueryService.SObjectQuery('AcctSeed__Accounting_Period__c', new Set<Id> {accPeriod}, '');
            if(acpList.size() > 0){
                stDate = acpList[0].AcctSeed__Start_Date__c;
                edDate = acpList[0].AcctSeed__End_Date__c;
                accpdName = acpList[0].Name;
            }
        }
        
        if(billingMap.containsKey('Single Billing')){
            
            if(accId != null){
                accList =  [SELECT Id,AcctSeed__Billing_Contact__c,Account_Code__c,AcctSeed__Billing_Days_Due__c FROM Account WHERE Id = :accId];
                if(accList.size() > 0){
                    accCode = accList[0].Account_Code__c;
                    billingContact = accList[0].AcctSeed__Billing_Contact__c;
                    BillingDaysDue = ((accList[0].AcctSeed__Billing_Days_Due__c != null ) ? Integer.valueOf(accList[0].AcctSeed__Billing_Days_Due__c) : 0);
                  
                    if(!accBillingDueMap.containsKey('Single Billing')){
                        accBillingDueMap.put('Single Billing',BillingDaysDue); 
                    }
                }
            }
        }else {
            
            for(String proId : billingMap.keySet()){
                projectIds.add(proId);
            }
            
            if(projectIds.size() > 0){
                
                proIdsJSON = JSON.serialize(projectIds);
                ProprietaryNoJournalNameInfo propBillNoJE = proprietaryNoJournalNameFormation(proIdsJSON,accpdName,'Billing');
                proprietaryBillingNoMap = propBillNoJE.proprietaryNoJENameMap;
                proprietaryBillingNoCountMap = propBillNoJE.proprietaryNoJENameCountMap;
                eflLingProIds = new Set<Id>(propBillNoJE.eflLingProIds);
                
                for(AcctSeed__Project__c  pro : [SELECT Id,AcctSeed__Account__r.AcctSeed__Billing_Days_Due__c FROM AcctSeed__Project__c WHERE Id IN :projectIds]){
                    BillingDaysDue = 0;
                    if(!accBillingDueMap.containsKey(pro.Id)){
                        
                        BillingDaysDue = ((pro.AcctSeed__Account__r.AcctSeed__Billing_Days_Due__c != null ) ? Integer.valueOf(pro.AcctSeed__Account__r.AcctSeed__Billing_Days_Due__c) : 0);
                        accBillingDueMap.put(pro.Id,BillingDaysDue); 
                    }
                }
            }
        }
        
        try {
            
            if(billingMap.containsKey('Single Billing')){
                //if user select the option, 'Create single Billing for all Project'
                AcctSeed__Billing__c singleBilling =  billingMap.get('Single Billing');
                singleBilling.AcctSeed__Billing_Contact__c = billingContact;
                singleBilling.AcctSeed__Date__c = system.today();
                singleBilling.AcctSeed__Proprietary_Billing_Number__c = accCode+'-'+accpdName;
                singleBilling.AcctSeed__Billing_Cycle_Start_Date__c = stDate;
                singleBilling.AcctSeed__Billing_Cycle_End_Date__c = edDate;
                singleBilling.AcctSeed__Status__c = 'Approved';
                
                if(accBillingDueMap.containsKey('Single Billing')){
                    singleBilling.AcctSeed__Due_Date2__c = system.today().addDays(accBillingDueMap.get('Single Billing'));
                }
                billingMap.put('Single Billing',singleBilling);
            }else{
                //if user select the option, 'Create individual Billing for each Project'
                
                Integer billingNoCount = 1;
                for(String proId : billingMap.keySet()){
                    
                    AcctSeed__Billing__c individualBill =  billingMap.get(proId);
                    individualBill.AcctSeed__Date__c = system.today();
                    individualBill.AcctSeed__Billing_Cycle_Start_Date__c = stDate;
                    individualBill.AcctSeed__Billing_Cycle_End_Date__c = edDate;
                    individualBill.AcctSeed__Status__c = 'Approved';
                    
                    if(accBillingDueMap.containsKey(proId)){
                        individualBill.AcctSeed__Due_Date2__c = system.today().addDays(accBillingDueMap.get(proId));
                    }
                    
                    
                    if(proprietaryBillingNoMap.containsKey(proId)){
                        
                        if(eflLingProIds.contains(proId)){// for'EFL_Projects','Linguist_Support_Projects', 'FSI_Projects' related proprietary Billing Number population
                            if(proprietaryBillingNoCountMap.containsKey(proprietaryBillingNoMap.get(proId))){
                                
                                billingNoCount = (proprietaryBillingNoCountMap.get(proprietaryBillingNoMap.get(proId)) + 1);
                                proprietaryBillingNoCountMap.put(proprietaryBillingNoMap.get(proId),billingNoCount);
                            }else if(!propBillNumSet.contains(proprietaryBillingNoMap.get(proId))){
                                propBillNumSet.add(proprietaryBillingNoMap.get(proId));    
                            }
                            
                            if(billingNoCount < 10){
                                individualBill.AcctSeed__Proprietary_Billing_Number__c =  proprietaryBillingNoMap.get(proId) +'00'+ billingNoCount;
                            }else if(billingNoCount >= 10 && billingNoCount < 100){
                                individualBill.AcctSeed__Proprietary_Billing_Number__c =  proprietaryBillingNoMap.get(proId) +'0'+ billingNoCount;
                            }else{
                                individualBill.AcctSeed__Proprietary_Billing_Number__c =  proprietaryBillingNoMap.get(proId) + billingNoCount;
                            }
                            
                            if(propBillNumSet.contains(proprietaryBillingNoMap.get(proId))){
                                billingNoCount += 1;        
                            }                            
                        }else {
                            individualBill.AcctSeed__Proprietary_Billing_Number__c = proprietaryBillingNoMap.get(proId);
                        }
                    }
                    
                    billingMap.put(proId,individualBill);
                }
            }
                        
            if(billingMap.size() > 0){
                insert billingMap.values();
            }
            
            if(billingLineMap.size() > 0){
                Id userId = UserInfo.getUserId();
                for(String proId : billingLineMap.keySet()){
                    
                    List<AcctSeed__Billing_Line__c> billLineLst = billingLineMap.get(proId);
                    for(AcctSeed__Billing_Line__c  bl : billLineLst){
                        
                        bl.AcctSeed__Date__c = system.today();
                       // bl.AcctSeed__Employee__c = userId; 
                        
                        if(billingMap.containsKey('Single Billing')){
                            bl.AcctSeed__Billing__c = billingMap.get('Single Billing').Id;
                        }else if(billingMap.containskey(proId)){
                            bl.AcctSeed__Billing__c = billingMap.get(proId).Id;
                        }
                    }
                    if(billingMap.containsKey('Single Billing')){
                        billingLineMap.put('Single Billing',billLineLst);
                    }else{
                        billingLineMap.put(proId,billLineLst); 
                    }
                    billingLine.addAll(billingLineMap.get(proId));
                }
            }    
            
            if(billingLine.size() > 0){
                insert billingLine;
            }
            Set<Id> billingIds = new  Set<Id>();
            Set<String> proIds = new  Set<String>();
            Set<String> projectTaskIds = new  Set<String>();
            Map<String,Id> proWithPTRelBillLineMap = new Map<String,Id>();
            Set<String> timeCardStatus = new Set<String>{'Approved', 'Admin Approved'};
            
            // Populate Billing Line Id to related Time Card Day AcctSeed__Billing_Line__c field
            if(billingMap.size() > 0 && billingLine.size() > 0){
                for(AcctSeed__Billing__c bill : billingMap.values()){
                    billingIds.add(bill.Id); 
                    System.debug('billingIds'+billingIds);
                }
                
                /*for(AcctSeed__Billing_Line__c billLine : [SELECT Id,AcctSeed__Project__c,AcctSeed__Project_Task__c,AcctSeed__Billing__c FROM AcctSeed__Billing_Line__c
                                                            WHERE AcctSeed__Project_Task__r.RecordType.DeveloperName = 'Language_Training' AND AcctSeed__Project_Task__r.Name  LIKE 'Language Training%'
                                                              AND AcctSeed__Billing__c IN :billingIds]){*/
                    
                    
                for(AcctSeed__Billing_Line__c billLine : BillingLineService.getBillLineByParentIds(' WHERE AcctSeed__Project_Task__r.RecordType.DeveloperName = \'Language_Training\' AND AcctSeed__Project_Task__r.Name  LIKE \'Language Training%\' AND AcctSeed__Billing__c','',billingIds)) {

                        proIds.add(billLine.AcctSeed__Project__c);
                        projectTaskIds.add(billLine.AcctSeed__Project_Task__c);
                        
                        if(!proWithPTRelBillLineMap.containsKey(billLine.AcctSeed__Project__c+'~'+billLine.AcctSeed__Project_Task__c)){
                            proWithPTRelBillLineMap.put(billLine.AcctSeed__Project__c+'~'+billLine.AcctSeed__Project_Task__c,billLine.Id);
                        }
                }
                
                List<AcctSeed__Time_Card_Day__c> toUpdateTcdList = new List<AcctSeed__Time_Card_Day__c>();
                   for(AcctSeed__Time_Card_Day__c timeCD : [SELECT Id,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,Total_Hours_Before_Approved__c 
                                                              FROM AcctSeed__Time_Card_Day__c
                                                              WHERE AcctSeed__Hours__c > 0 
                                                               AND Status__c IN: timeCardStatus 
                                                               AND ((AcctSeed__Time_Card_Line__r.Payroll_Item__c = 'R' AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName != 'DLI_W_LT_Projects')
                                                                OR (AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName = 'DLI_W_LT_Projects' AND AcctSeed__Time_Card_Line__r.Payroll_Item__c = 'RT2'))
                                                               AND AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Billable__c = true 
                                                               AND AcctSeed__Date__c >= :stDate AND AcctSeed__Date__c <= :edDate 
                                                               AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__c IN :proIds
                                                               AND AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c IN :projectTaskIds
                                                               AND AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c = true]){
                
                    String projectId = timeCD.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
                    String projectaskId = timeCD.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
                    
                    if(proWithPTRelBillLineMap.containsKey(projectId+'~'+projectaskId)){
                        AcctSeed__Time_Card_Day__c tcd = new AcctSeed__Time_Card_Day__c();

                        tcd.Id = timeCD.Id;
                        tcd.AcctSeed__Billing_Line__c = proWithPTRelBillLineMap.get(projectId+'~'+projectaskId);
                        
                        toUpdateTcdList.add(tcd);
                    }
                }
                
                if(toUpdateTcdList.size() > 0){
                    System.debug('toUpdateTcdList'+toUpdateTcdList);
                    update toUpdateTcdList;
                }
            }
            
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return 'Success';
    }
    // JournalEntry and JournalEntryLineCreation
    @AuraEnabled
    public static string journalEntryCreation(String journalEntryJSON,String journalEntryLineJSON,String accId,String accPeriod){
        Map<String,AcctSeed__Journal_Entry__c> journalMap = (Map<String,AcctSeed__Journal_Entry__c>) JSON.deserialize(journalEntryJSON, Map<String,AcctSeed__Journal_Entry__c>.class);
        Map<String,List<AcctSeed__Journal_Entry_Line__c>> journalLineMap = (Map<String,List<AcctSeed__Journal_Entry_Line__c>>) JSON.deserialize(journalEntryLineJSON, Map<String,List<AcctSeed__Journal_Entry_Line__c>>.class);
        
        List<AcctSeed__Accounting_Period__c>  acpList = new List<AcctSeed__Accounting_Period__c>();
        List<AcctSeed__Journal_Entry_Line__c>  journalLineEntryList = new List<AcctSeed__Journal_Entry_Line__c>();
        List<AcctSeed__Journal_Entry__c> journalEntryList = new List<AcctSeed__Journal_Entry__c>();
        
        Set<Id> projectIds = new Set<Id>();
        Set<Id> eflLingProIds = new Set<Id>();
        
        Map<String,String> journalEntryNameMap = new Map<String,String>();
        Map<String,Integer> journalEntryNameCountMap = new Map<String,Integer>();
        
        Date endDate;
        String accPdName = '';
        Integer journalCount = 0;
        
        if(accPeriod != null){
            //acpList = [SELECT Id,Name,AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c WHERE Id = :accPeriod];
            acpList = SObjectQueryService.SObjectQuery('AcctSeed__Accounting_Period__c', new Set<Id> {accPeriod}, '');
            if(acpList.size() > 0){
                endDate = acpList[0].AcctSeed__End_Date__c;
                accPdName = acpList[0].Name;
            }
            
            for(String proId : journalMap.keySet()){
                projectIds.add(proId);
            }
            
            if(projectIds.size() > 0){
                String proIdsJSON = JSON.serialize(projectIds);
                ProprietaryNoJournalNameInfo propBillNoJE = proprietaryNoJournalNameFormation(proIdsJSON,accpdName,'Journal Entry');
                journalEntryNameMap = propBillNoJE.proprietaryNoJENameMap;
                journalEntryNameCountMap = propBillNoJE.proprietaryNoJENameCountMap;
                eflLingProIds = new Set<Id>(propBillNoJE.eflLingProIds);
            }
        }

        List<AcctSeed__Ledger__c> ledgerList = [SELECT Id,Name FROM AcctSeed__Ledger__c WHERE Name = 'Actual'];
        
        try{ 
                //if user select the option, 'Create individual Journal for each Project'

                for(String proId : journalMap.keySet()){
                    AcctSeed__Journal_Entry__c individualjournal =  journalMap.get(proId);
                    individualjournal.AcctSeed__Journal_Date__c = endDate;
                    individualjournal.AcctSeed__Status__c = 'Approved';
                    individualjournal.AcctSeed__Ledger__c = (ledgerList.size() > 0 ? ledgerList[0].Id : null);
                    journalCount = 1;
                    
                    if(journalEntryNameMap.containsKey(proId)){
                        
                        if(eflLingProIds.contains(proId)){// for'EFL_Projects','Linguist_Support_Projects' related Journal Name population
                            if(journalEntryNameCountMap.containsKey(journalEntryNameMap.get(proId))){
                                
                                journalCount = (journalEntryNameCountMap.get(journalEntryNameMap.get(proId)) + 1);
                                journalEntryNameCountMap.put(journalEntryNameMap.get(proId),journalCount);
                            }

                            if(journalCount < 10){
                                individualjournal.Name =  journalEntryNameMap.get(proId) +'00'+ journalCount;
                            }else if(journalCount >= 10 && journalCount < 100){
                                individualjournal.Name =  journalEntryNameMap.get(proId) +'0'+ journalCount;
                            }else{
                                individualjournal.Name =  journalEntryNameMap.get(proId) + journalCount;
                            }
                            
                        }else {
                            individualjournal.Name =  journalEntryNameMap.get(proId);
                        }
                    }
                    journalMap.put(proId,individualjournal);
                }
            
            if(journalMap.size() > 0){
                insert journalMap.values();
            }
            if(journalMap.size() > 0){
                for(String proId : journalLineMap.keySet()){
                    
                    List<AcctSeed__Journal_Entry_Line__c> journalLineLst = journalLineMap.get(proId);
                    for(AcctSeed__Journal_Entry_Line__c  journ : journalLineLst){
                        
                        if(journalMap.containsKey(proId)){
                            journ.AcctSeed__Journal_Entry__c =  journalMap.get(proId).Id;
                        }
                        journ.AcctSeed__Date__c = endDate;
                    }
                    journalLineMap.put(proId,journalLineLst); 
                    journalLineEntryList.addAll(journalLineMap.get(proId));
                }
            }    
            system.debug('journalLineEntryList::'+journalLineEntryList);
            if(journalLineEntryList.size() > 0){
                insert journalLineEntryList;
            }
            
        }catch(Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
        
        return 'Success';
    } 
    // To get lookup records
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        
        system.debug('::::::searchTerm::::'+searchString);
        system.debug(':::objNAme:::fieldName::::'+objectName+' '+fieldName);
        // Prepare query paramters
        
        List<sObject> lookupRecords = new List<sObject>();
        String query = 'SELECT Id, Name FROM ' + objectName;
        if(fieldName != null && fieldName != '' && searchString != null && searchString != '') {
            query += ' WHERE '+fieldName+' LIKE \'%' + searchString + '%\'';
        }
        system.debug('condition'+condition);
        if(condition != null && condition != '') {
            if(searchString != null && searchString != '') {
                
                query += ' AND ' + condition;
            } else {
                
                query += ' WHERE ' + condition;
            }
        }
        
        if(selectedIds != null && selectedIds.size() > 0) {
            query += ' AND Id NOT IN :selectedIds';
        }
        
        query += ' ORDER BY CreatedDate ASC LIMIT 10';
        System.debug('query log ' + query);
        
        lookupRecords = Database.query(query);
        system.debug('lookup records'+lookupRecords);
        
        return lookupRecords;
    }
    // Get Billing ListView Id
    @AuraEnabled
    public static String getListViews(String sObjectName) {
        List<ListView> listviews = [SELECT Id, Name FROM ListView WHERE SobjectType = :sObjectName];
        
        if(listviews.size() > 0){
            return listviews[0].Id;
        }      
        return null;
    }
    // get existing Billing OR journal Records
    @AuraEnabled
    public static String checkBillORJournalExist(String objectType,String projectIdsJSON, String accPeriod) {
        Set<Id> projectIds = (Set<Id>) JSON.deserialize(projectIdsJSON,Set<Id>.class);
        
        Map<String,Id> projectWithPTMatReqMap = new Map<String,Id>();
        
        //Work Item : W-005400 - Issue in Create Billing page
        // Need to exclude the Journal Entry with the name starting with these letters
        Set<String> jeNameSet = new Set<String>{'JE', 'TR', 'WO', 'PR'};
        
        if(projectIds.size() > 0){
            if(objectType == 'Billing'){
            
                                                            
                /*for(AcctSeed__Billing_Line__c billLine : [SELECT Id,AcctSeed__Comment__c,AcctSeed__Project__c,Materials_Request__c,Payable_Line__c,
                                                        AcctSeed__Project_Task__c,AcctSeed__Revenue_GL_Account__r.Name FROM AcctSeed__Billing_Line__c WHERE 
                                                        AcctSeed__Project__c IN :projectIds AND AcctSeed__Revenue_GL_Account__r.Name != '13999 - Undeposited Funds' AND
                                                        AcctSeed__Billing__r.AcctSeed__Accounting_Period__c = :accPeriod]){*/
                                                        
                for(AcctSeed__Billing_Line__c billLine : BillingLineService.getBillLineByParentIds(' WHERE AcctSeed__Revenue_GL_Account__r.Name  != \'13999 - Undeposited Funds\' AND AcctSeed__Billing__r.AcctSeed__Accounting_Period__c = \''+accPeriod+'\' AND AcctSeed__Project__c',', AcctSeed__Revenue_GL_Account__r.Name',projectIds)) {
                    
                    
                    if(billLine.AcctSeed__Project__c != null && billLine.AcctSeed__Project_Task__c != null){
                        
                        String proPTMatReqName = '';
                        if(billLine.AcctSeed__Revenue_GL_Account__r.Name != '13999 - Undeposited Funds'){
                            if(billLine.AcctSeed__Comment__c != null &&(billLine.AcctSeed__Comment__c).contains('SalesTax')){
                                proPTMatReqName = billLine.AcctSeed__Project__c+'~'+billLine.AcctSeed__Project_Task__c+'~'+'SalesTax';
                            }else if(billLine.Materials_Request__c != null){
                                proPTMatReqName = billLine.AcctSeed__Project__c+'~'+billLine.AcctSeed__Project_Task__c+'~'+billLine.Materials_Request__c;
                            }else if(billLine.Payable_Line__c != null){
                                proPTMatReqName = billLine.AcctSeed__Project__c+'~'+billLine.AcctSeed__Project_Task__c+'~'+billLine.Payable_Line__c;
                            }else if(billLine.AcctSeed__GL_Account_Variable_1__c != null){
                                proPTMatReqName = billLine.AcctSeed__Project__c+'~'+billLine.AcctSeed__Project_Task__c+'~'+billLine.AcctSeed__GL_Account_Variable_1__c;
                            }
                            
                            if(!projectWithPTMatReqMap.containsKey(proPTMatReqName)){
                                projectWithPTMatReqMap.put(proPTMatReqName,Billline.Id);  
                            }
                        }
                    }
                }
            }else if(objectType == 'Journal'){
               
               
               /* for(AcctSeed__Journal_Entry_Line__c jeLine : [SELECT Id,AcctSeed__Project_Task__c,Payable_Line__c,AcctSeed__Reference__c,Materials_Request__c,AcctSeed__Project__c,AcctSeed__GL_Account__r.Name,AcctSeed__GL_Account__c 
                                                               FROM AcctSeed__Journal_Entry_Line__c WHERE AcctSeed__Project__c IN :projectIds AND AcctSeed__GL_Account__r.Name != '13999 - Undeposited Funds' AND
                                                                AcctSeed__Journal_Entry__r.AcctSeed__Accounting_Period__c = :accPeriod]){*/
                
                  for(AcctSeed__Journal_Entry_Line__c jeLine : JournalEntryLineService.getJELByParentIds(' WHERE AcctSeed__GL_Account__r.Name != \'13999 - Undeposited Funds\' AND  AcctSeed__GL_Account__r.AcctSeed__Type__c != \'Expense\' AND  AcctSeed__Project__c != null AND AcctSeed__Project_Task__c != null AND AcctSeed__Journal_Entry__r.AcctSeed__Accounting_Period__c = \''+accPeriod+'\' AND AcctSeed__Project__c',', AcctSeed__Journal_Entry__r.Name',projectIds)) {
                      
                      String jeName = jeLine.AcctSeed__Journal_Entry__r.Name.left(2);
                      //System.debug('::::jeName:::::'+jeName);
                      if(!jeNameSet.contains(jeName)){
                      
                          String proPTMatReqName = '';
                          
                          if(jeLine.AcctSeed__Reference__c != null && (jeLine.AcctSeed__Reference__c).contains('SalesTax')){
                              proPTMatReqName = jeLine.AcctSeed__Project__c+'~'+jeLine.AcctSeed__Project_Task__c+'~'+'SalesTax';
                          }else if(jeLine.Materials_Request__c != null){
                              proPTMatReqName = jeLine.AcctSeed__Project__c+'~'+jeLine.AcctSeed__Project_Task__c+'~'+jeLine.Materials_Request__c;
                          }else if(jeLine.Payable_Line__c != null){
                              proPTMatReqName = jeLine.AcctSeed__Project__c+'~'+jeLine.AcctSeed__Project_Task__c+'~'+jeLine.Payable_Line__c;
                          }else {
                              if(jeLine.AcctSeed__GL_Account_Variable_1__c != null){
                                  proPTMatReqName = jeLine.AcctSeed__Project__c+'~'+jeLine.AcctSeed__Project_Task__c+'~'+jeLine.AcctSeed__GL_Account_Variable_1__c;
                              }
                          }
                          
                          if(!projectWithPTMatReqMap.containsKey(proPTMatReqName)){
                              projectWithPTMatReqMap.put(proPTMatReqName,jeLine.Id);  
                          }
                      }
                  }
            }
        }
        return JSON.serialize(projectWithPTMatReqMap);
    }
    // Proprietary Billing Number /Journal Entry Name Formation
    public static ProprietaryNoJournalNameInfo proprietaryNoJournalNameFormation(String projectIdsJSON, String accpdName, String objName){
        Set<String> proRTs = new Set<String>{'DODA_Projects','Language_Training_Projects','Testing_Projects','CD_Projects','Interpretation Projects','Translation_Projects'};
        Set<String> eflLingProRTs = new Set<String>{'EFL_Projects','Linguist_Support_Projects'};
        Set<String> eflLingFSIProRTs = new Set<String>{'EFL_Projects','Linguist_Support_Projects', 'FSI_Projects'};
        Set<String> dliMTTProRTs = new Set<String>{'DLI_W_LT_Projects','MTT_Projects'};
        Set<Id> eflLingProIds = new Set<Id>();
        Set<String> billingNoJournNameSet = new Set<String>();
        Set<Id> projectIds = (Set<Id>) JSON.deserialize(projectIdsJSON, Set<Id>.class);

        Map<String,String> propBillingNoJENameMap = new Map<String,String>();
        Map<String,Integer> propBillingNoJENameCountMap = new Map<String,Integer>();// for'EFL_Projects','Linguist_Support_Projects'
        
        ProprietaryNoJournalNameInfo propBillingNoJE = new ProprietaryNoJournalNameInfo();
        System.debug('::proIds::'+projectIds);
        
        if(projectIds.size() > 0){               
            
            Map<Id,String> proIdWithConInitial = new Map<Id,String>();                                       
            
            for(Contact_Assignments__c ca : [SELECT Id,Assignment_Position__c,Project__c,Candidate_Name__r.LastName,Candidate_Name__r.firstName 
                                             FROM Contact_Assignments__c 
                                             WHERE Project__c IN :projectIds 
                                              AND RecordType.DeveloperName='Student' AND Status__c != 'Transferred' 
                                              AND (Project__r.AcctSeed__Account__r.Parent.Name = 'PVT' OR Project__r.RecordType.DeveloperName IN :proRTS)]){
                
                String firsNameInitial =  ca.Candidate_Name__r.FirstName;
                String lastNameInitial =  ca.Candidate_Name__r.LastName;
                
                if(firsNameInitial != null){
                    firsNameInitial = firsNameInitial.substring(0,1);
                }else{
                    firsNameInitial = '';  
                }
                
                if(lastNameInitial != null){
                    lastNameInitial = lastNameInitial.substring(0,1);
                }else {
                    lastNameInitial = '';
                }
                
                if(!proIdWithConInitial.containsKey(ca.Project__c)){
                    proIdWithConInitial.put(ca.Project__c,firsNameInitial+''+lastNameInitial); 
                }else{
                    if(ca.Assignment_Position__c == 'Class Leader'){
                        proIdWithConInitial.put(ca.Project__c,firsNameInitial+''+lastNameInitial); 
                        
                    }
                }
            }

            for(AcctSeed__Project__c  pro : [SELECT Id,Name,AcctSeed__Account__r.Parent.Account_Code__c,AcctSeed__Account__r.Parent.Name,AcctSeed__Account__c,
                                             AcctSeed__Account__r.Account_Code__c,Contract_No__c,RecordType.DeveloperName,AcctSeed__Account__r.Name,Language__r.Name
                                              FROM AcctSeed__Project__c WHERE Id IN :projectIds]){ 
                                                 
                if(!propBillingNoJENameMap.containsKey(pro.Id)){
                    String propNoJEName = null;
                    
                    if(pro.AcctSeed__Account__r.Parent != null && pro.AcctSeed__Account__r.Parent.Name == 'PVT'){
                        propNoJEName = pro.AcctSeed__Account__r.Parent.Account_Code__c+'-'+accPdName;
                    }else {
                        propNoJEName = pro.AcctSeed__Account__r.Account_Code__c+'-'+accPdName;
                        
                    }

                    if((pro.AcctSeed__Account__c != null && pro.AcctSeed__Account__r.Name == 'ELT III') && pro.RecordType.DeveloperName == 'Language_Training_Projects'){
                        if(pro.Contract_No__c != null){
                            propNoJEName = propNoJEName+'-'+pro.Contract_No__c.right(4);
                        }

                        propBillingNoJENameMap.put(pro.Id,propNoJEName);

                    }else if((pro.AcctSeed__Account__r.Parent != null && pro.AcctSeed__Account__r.Parent.Name == 'PVT') || proRTs.contains(pro.RecordType.DeveloperName)){

                
                        if(proIdWithConInitial.containsKey(pro.Id) && proIdWithConInitial.get(pro.Id) != null ){
                            propNoJEName = propNoJEName +  '-'+proIdWithConInitial.get(pro.Id);
                        }
                        
                        if(!propBillingNoJENameMap.containsKey(pro.Id)){
                            propBillingNoJENameMap.put(pro.Id,propNoJEName);
                        }
                        
                    }else if(dliMTTProRTs.contains(pro.RecordType.DeveloperName)){
                        
                        if(pro.Contract_No__c != null){
                            propNoJEName = propNoJEName+'-'+pro.Contract_No__c.right(5);
                        }

                        propBillingNoJENameMap.put(pro.Id,propNoJEName);
                    }else if(eflLingProRTs.contains(pro.RecordType.DeveloperName)){
                        
                        propNoJEName = pro.AcctSeed__Account__r.Account_Code__c+'-'+accPdName+'-';
                        propBillingNoJENameMap.put(pro.Id,propNoJEName);
                        billingNoJournNameSet.add(propNoJEName+'%');
                        eflLingProIds.add(pro.Id);
                    }else if(pro.RecordType.DeveloperName == 'FSI_Projects'){    // W-007889 : Missing Proprietary Billing Number when creating billings for new FSI Projects
                        
                        if(pro.Language__c != null && pro.Language__r.Name != null){
                            propNoJEName = propNoJEName+'-'+pro.Language__r.Name+'-';
                            billingNoJournNameSet.add(propNoJEName+'%');
                            eflLingProIds.add(pro.Id);
                        }
                        propBillingNoJENameMap.put(pro.Id,propNoJEName);    
                    }
                }
            } 
            system.debug(':::::bill:::Journal::'+billingNoJournNameSet);
            
            // for'EFL_Projects','Linguist_Support_Projects' related Billing Number / Journal Entry Name Population
            if(billingNoJournNameSet.size() > 0){
                
                if(objName == 'Journal Entry'){
                    for(AcctSeed__Journal_Entry__c je : [SELECT Id,Name,Project__r.RecordType.DeveloperName,Project__r.Language__r.Name FROM AcctSeed__Journal_Entry__c WHERE Name Like :billingNoJournNameSet AND Project__r.RecordType.DeveloperName IN :eflLingFSIProRTs]){
                        String jeName;
                        if(eflLingProRTs.contains(je.Project__r.RecordType.DeveloperName)){
                            jeName = (je.Name.split(accPdName+'-')[0])+accPdName+'-'; 
                        }else if(je.Project__r.RecordType.DeveloperName == 'FSI_Projects'){
                            jeName = (je.Name.split(accPdName+'-')[0])+accPdName+'-'+je.Project__r.Language__r.Name+'-';
                        }
                        
                        if(jeName != null){
                            if(propBillingNoJENameCountMap.containsKey(jeName)){
                                propBillingNoJENameCountMap.put(jeName,propBillingNoJENameCountMap.get(jeName) + 1);
                            }else{
                                propBillingNoJENameCountMap.put(jeName,1);
                            }
                        }
                    }
                }else if(objName == 'Billing'){
                    for(AcctSeed__Billing__c bill : [SELECT Id,AcctSeed__Proprietary_Billing_Number__c,Project__r.RecordType.DeveloperName,Project__r.Language__r.Name FROM AcctSeed__Billing__c WHERE AcctSeed__Proprietary_Billing_Number__c Like :billingNoJournNameSet AND Project__r.RecordType.DeveloperName IN :eflLingFSIProRTs]){
                        String billingNo;
                        if(eflLingProRTs.contains(bill.Project__r.RecordType.DeveloperName)){
                            billingNo = (bill.AcctSeed__Proprietary_Billing_Number__c.split(accPdName+'-')[0])+accPdName+'-'; 
                        }else if(bill.Project__r.RecordType.DeveloperName == 'FSI_Projects'){
                            billingNo = (bill.AcctSeed__Proprietary_Billing_Number__c.split(accPdName+'-')[0])+accPdName+'-'+bill.Project__r.Language__r.Name+'-';
                        }
                        
                        if(billingNo != null){
                            if(propBillingNoJENameCountMap.containsKey(billingNo)){
                                propBillingNoJENameCountMap.put(billingNo,propBillingNoJENameCountMap.get(billingNo) + 1);
                            }else{
                                propBillingNoJENameCountMap.put(billingNo,1);
                            }
                        }
                    }
                }
            }
           
            propBillingNoJE.proprietaryNoJENameMap = propBillingNoJENameMap;
            propBillingNoJE.proprietaryNoJENameCountMap = propBillingNoJENameCountMap;
            propBillingNoJE.eflLingProIds = new List<Id>(eflLingProIds);
        }
        return propBillingNoJE;
    }
    public static MapProjectTasksWithQBInfo mapProjectTaskWithQB( Map<Id,List<billingLineProjecTaskInfo>> ptMap,BillingRowInfo rowInfo,Map<String,Map<String,Decimal>> ptQuantityMapWithQbs, Integer billingRecCount, Decimal billingColumnTotal, Map<String,Id> qbClassficationRelGlVarMap){
        MapProjectTasksWithQBInfo ptWithQb = new MapProjectTasksWithQBInfo();
        if(ptMap.containsKey(rowInfo.projectId)){
            if(ptMap.get(rowInfo.projectId) != null && ptMap.get(rowInfo.projectId).size() > 0){
                for(billingLineProjecTaskInfo rowPt : ptMap.get(rowInfo.projectId)){
                    if(ptQuantityMapWithQbs.containsKey(rowInfo.projectId+'~'+rowPt.hrsRelProjecTaskId) && ptQuantityMapWithQbs.get(rowInfo.projectId+'~'+rowPt.hrsRelProjecTaskId).keySet().size() > 0) { 
                        
                        for(String qb : ptQuantityMapWithQbs.get(rowInfo.projectId+'~'+rowPt.hrsRelProjecTaskId).keySet()){
                            billingLineProjecTaskInfo pttask = (billingLineProjecTaskInfo) JSON.deserialize(JSON.serialize(rowPt), billingLineProjecTaskInfo.class);
                            Decimal quantity = 0.00;
                            
                            if(rowInfo.projectRTName != null && rowInfo.projectRTName == 'Testing_Projects'){
                                quantity = 1.00; 
                            }else{
                                quantity = ptQuantityMapWithQbs.get(rowInfo.projectId+'~'+pttask.hrsRelProjecTaskId).get(qb);  
                            }
                            pttask.qbClassificationName = qb;
                            
                            if(qbClassficationRelGlVarMap.size() > 0 && qbClassficationRelGlVarMap.containsKey(qb)){
                                pttask.glAccountVar1 = qbClassficationRelGlVarMap.get(qb);
                            }
                            
                            pttask.total = '0.00';
                            if(quantity != null){
                                pttask.quantity = String.valueOf(quantity);
                            }else{
                                pttask.quantity = '0.00';
                            }
                            billingRecCount = billingRecCount +1;
                            if(pttask.quantity != null && pttask.unitPrice != null){
                                pttask.total = String.valueOf(((Decimal.valueOf(pttask.quantity)) * (Decimal.valueOf(pttask.unitPrice))).setScale(2));
                            }
                            billingColumnTotal = billingColumnTotal + (Decimal.valueOf(pttask.total));
                            rowInfo.projectTaskList.add(pttask);
                        }
                    }
                }
            }
            ptWithQb.rowInfo = rowInfo;
            ptWithQb.billingRecCount = billingRecCount;
            ptWithQb.billingColumnTotal = billingColumnTotal;
        }
        return ptWithQb;
    }
    
    public Class BillingInitialFilterInfo{
        @AuraEnabled
        public List<AcctSeed__Accounting_Period__c> accountingPeriodFilter;
        @AuraEnabled
        Public List<String> billingTypePickList;
    }
    public Class BillingInfo{
        @AuraEnabled
        Public String billingContact;
        @AuraEnabled
        Public Map<String,String> accountCodeMap;
        @AuraEnabled
        Public List<BillingRowInfo> billingRowInfo;
        @AuraEnabled
        public Map<String,Id> debitGLAccount;
        @AuraEnabled
        public Boolean isShowCLIN;
        @AuraEnabled
        public Boolean isEditableClin;
        @AuraEnabled
        public Decimal billingColumnTotal;
        @AuraEnabled
        public Integer billingRecordsCnt;
    }
    public Class BillingRowInfo{
        @AuraEnabled
        public List<billingLineProjecTaskInfo> projectTaskList; 
        @AuraEnabled
        Public String projectId;
        @AuraEnabled
        public String proName;
        @AuraEnabled
        public String billingContact;
        @AuraEnabled
        public String proAccIdWithName;
        @AuraEnabled
        public String accountId;
        @AuraEnabled
        public String projectRTName;
    }
    public Class billingLineProjecTaskInfo{
        @AuraEnabled
        public Id projecTaskId;
        @AuraEnabled
        public Id hrsRelProjecTaskId;
        @AuraEnabled
        public String projectTaskType;
        @AuraEnabled
        public Id matRequestId;
        @AuraEnabled
        public String projecTaskName;
        @AuraEnabled
        public String projectName;
        @AuraEnabled
        public String comment;
        @AuraEnabled
        public String quantity;
        @AuraEnabled
        public String unitPrice;
        @AuraEnabled
        public String total;
        @AuraEnabled
        public String clinName;
        @AuraEnabled
        public String parentProjectId;
        @AuraEnabled
        public String glAccountVar1;
        @AuraEnabled
        public String revenueGLAccount;
        @AuraEnabled
        public String vendorName;
        @AuraEnabled
        public String qbClassificationName;
        @AuraEnabled
        public Id projectTaskProductId;
        @AuraEnabled
        public Boolean isBillingLineChecked;
        @AuraEnabled
        public Boolean isHidePTs;
        @AuraEnabled
        public String payableLineId;
        @AuraEnabled
        public List<CLIN__c> clinLookup;
        @AuraEnabled
        public String glAccountVar2;
        @AuraEnabled
        public String glAccountVar2Name;
    }
    public Class MapProjectTasksWithQBInfo{
     @AuraEnabled 
        public BillingRowInfo rowInfo;     
        @AuraEnabled
        public Integer billingRecCount;
        @AuraEnabled
        public Decimal billingColumnTotal;
    }
    public Class ProprietaryNoJournalNameInfo{
        @AuraEnabled
        public  Map<String,String> proprietaryNoJENameMap;
        @AuraEnabled
        public Map<String,Integer> proprietaryNoJENameCountMap;
        @AuraEnabled
        public List<Id> eflLingProIds;
    }
}