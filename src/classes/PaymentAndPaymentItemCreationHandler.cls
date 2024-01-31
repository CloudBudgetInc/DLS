/**
    create Payment and Payment Item in single Page
    This is directed from opportunity Or Project    
**/
public Class PaymentAndPaymentItemCreationHandler {
    
    public Transaction__c paymentRec;
    public List<paymentItemInnerClass> paymentItemList { get; set; } 
    public List<paymentItemInnerClass> newPaymentItemList {get; set;}
    public Boolean hasProject { get; set; }
    public Attachment attach {get; set;}
    public String oppId { get; set; }
    //public String paymentId{get; set;}
    public String projectId { get; set; }
    public Boolean isDLIWLTProject { get; set; }
    public Boolean showCLIN {get; set;}
    public Map<Id, CLIN__c> parentCLINs {get; set;}
    public Map<Id, CLIN__c> childCLINs {get; set;}
    public Map<String, CLIN__c> clinsToUpsert {get; set;}
    public AcctSeed__Project__c proj {get; set;}
    public Boolean refreshPage {get; set;}
    Public List<SelectOption> projTaskNameList {get; set;}
    List<AcctSeed__Project_Task__c> projectTaskList = new List<AcctSeed__Project_Task__c>();
    List<OpportunityLineItem> opliList = new List<OpportunityLineItem>();
    Set<String> projWithPaymentItem = new Set<String>();
    public String strForPage {get; set;}
    public String prodIdPaidMap {get; set;}
    public Map<String,Decimal> opliPaid;
    public Id parentId;
    public Boolean errorAlert = false;
        
    // Added By HL
    public String typeOfAction { get; set; }
    public String genStrForPage {get; set;}
    public Boolean preReviewedVal;
    
    public class paymentItemInnerClass {
        public String prodName {get; set; }
        public Payment_Item__c payItem{get; set;}
        public Integer index {get; set;}
        public Decimal qty {get; set;}
        public String unit {get; set;}
        public Decimal unitPrice {get; set;}
        public Boolean notFullyPaid {get; set;}
        public Decimal totalPrice {get; set;}
        public string redirectId{ get; set;}
        public Decimal oldAmt {get; set;}
        // For Project Task
        public String projTaskName {get; set;}
        public Decimal Total_Budgeted {get; set;}
        public Decimal Total_Spent {get; set;}
        public Decimal Total_Amount_Paid {get; set;}
        public Decimal quantity {get; set;}
        public String typeVal {get; set;}
        
        // Added By HL
        public String position {get; set;}
        public Decimal preAmount {get; set;}
        
        public String parentClin {get; set;}
    }
    
    public List<SelectOption> getParentCLINsOptions() {
        List<SelectOption> countryOptions = new List<SelectOption>();
        countryOptions.add(new SelectOption('','-None-'));
        if(parentCLINs != null && parentCLINs.size() > 0){
            for(CLIN__c clin : parentCLINs.values()){
                countryOptions.add(new SelectOption(clin.Id,clin.Name));
            }
        }
        return countryOptions;
    }
    
    public void createChildContract(){
        Id parentContract;
        if(isDLIWLTProject && proj != null && (proj.Contract__c != null || paymentRec.Contract__c != null)){
            Id childContractId;
            
            if( proj.Contract__r.APXT_Redlining__Contract_Family_Parent__c != null ){
                parentContract = proj.Contract__r.APXT_Redlining__Contract_Family_Parent__c;
                childContractId = proj.Contract__c;
            }else if(paymentRec.Contract__c != null){
                List<Contract> childContracts = [SELECT Id, APXT_Redlining__Contract_Family_Parent__c FROM Contract WHERE Id = :paymentRec.Contract__c];
                parentContract = childContracts[0].APXT_Redlining__Contract_Family_Parent__c;
                childContractId = childContracts[0].Id;
            }
            
            if(childContractId != null){
                childCLINs = new Map<Id, CLIN__c>([SELECT Id, Name, CLIN_End_Date__c, CLIN_Name__c, CLIN_Start_Date__c,Amount_Funded__c, CLIN_Type__c, Contract__c, CLIN_Max_Amount__c, CLIN_Max_Quantity__c, CLIN_Unit__c, CLIN_Unit_Price__c, Parent_CLIN__c, Parent_CLIN__r.CLIN_Name__c,Parent_CLIN__r.Name,Total_Amount_Invoiced_rollup__c FROM CLIN__c WHERE Contract__c = :childContractId ORDER BY Name ASC]);
                if(childCLINs.size() == 0){
                    showCLIN = true;
                }else{
                    
                    for(Acctseed__Project_Task__c projectTask : [SELECT Id, CLIN__c, AcctSeed__Project__c, Total_Amount_Paid__c, Project_Task_Type__c FROM Acctseed__Project_Task__c WHERE CLIN__c IN :childCLINs.keySet()]){
                        String key = 'other';
                        CLIN__c clin = new CLIN__c();
                        if(projectTask.Project_Task_Type__c == 'Material Budget') key = 'material';
                        if(projectTask.Project_Task_Type__c == 'Travel') key = 'Travel';
                        if(projectTask.Project_Task_Type__c == 'ODC') key = 'ODC';
                        clin = childCLINs.get(projectTask.CLIN__c);
                        
                        if(!clinsToUpsert.containsKey(key)){                            
                            clin.CLIN_Unit_Price__c = 0;
                        }
                        
                        
                        if(projectTask.AcctSeed__Project__c != proj.Id && projectTask.Total_Amount_Paid__c != null){
                            if(clin.CLIN_Unit_Price__c == null){
                                clin.CLIN_Unit_Price__c = 0;
                            }
                            clin.CLIN_Unit_Price__c += projectTask.Total_Amount_Paid__c;
                        }
                        
                        clinsToUpsert.put(key, clin);
                    }
                    if(clinsToUpsert.size() == 0){
                        showCLIN = true;
                    }
                    System.debug('clinsToUpsert::>'+clinsToUpsert);
                }
            }      
            paymentRec.Contract__c = childContractId;
            
            parentCLINs = new Map<Id, CLIN__c>([SELECT Id, Name, CLIN_End_Date__c, CLIN_Name__c, CLIN_Start_Date__c,Amount_Funded__c, CLIN_Type__c, Contract__c, CLIN_Max_Amount__c, CLIN_Max_Quantity__c, CLIN_Unit__c, CLIN_Unit_Price__c, Parent_CLIN__c, Parent_CLIN__r.CLIN_Name__c,Parent_CLIN__r.Name,Total_Amount_Invoiced_rollup__c FROM CLIN__c WHERE Contract__c = :parentContract AND ( (CLIN_Start_Date__c <= :System.today() AND CLIN_End_Date__c >= :System.today()) OR  (CLIN_Start_Date__c >= :System.today())) ORDER BY Name ASC]);            
        }
    }
    
    public PaymentAndPaymentItemCreationHandler(ApexPages.StandardController stdcontroller){
    
        // Initializing 
        attach = new Attachment();
        refreshPage = false;
        hasProject = false;
        paymentRec = new Transaction__c();
        paymentItemList = new List<paymentItemInnerClass>();
        newPaymentItemList = new List<paymentItemInnerClass>();
        projTaskNameList = new List<SelectOption>{new SelectOption('','---None---')};
        Map<String, List<paymentItemInnerClass>> mapForPage = new Map<String, List<paymentItemInnerClass>>();
        opliPaid = new Map<String,Decimal>();
        clinsToUpsert = new Map<String, CLIN__c>();
        
        // Added By HL 
        List<paymentItemInnerClass> genListForPage = new List<paymentItemInnerClass>();
        
        // Assinging the record from Page
        paymentRec = (Transaction__c)stdController.getRecord();
        if( paymentRec.Transaction_Date__c == null ) paymentRec.Transaction_Date__c = System.today(); // To defaultly populate today's date
        projectId = paymentRec.Project__c;
        oppId = paymentRec.Opportunity__c;
        System.debug('projectId ::::'+projectId );
        isDLIWLTProject = false;
        
        if(String.isNotEmpty(projectId)){
            proj = [SELECT Id,RecordType.DeveloperName, AcctSeed__Account__r.Name, Contract__c, Order__c, Language__c, Start_Date__c, End_Date__c, Contract__r.Prime__c, Contract__r.RecordTypeId, Contract__r.APXT_Redlining__Contract_Family_Parent__c, Contract__r.AccountId, Contract__r.Contract_Type__c, Contract__r.Name FROM AcctSeed__Project__c WHERE Id = :projectId LIMIT 1];
            //Added the project record type and account name condition - W-007186 - By Dhinesh - 25-11-2021
            List<String> accountNameListForCLIN = new List<String>{'DLI-W - LT', 'DLI-W - MTT', 'DLI-W - CD'};
            List<String> projectRecordTypeListForCLIN = new List<String>{'CD_Projects', 'DLI_W_LT_Projects', 'MTT_Projects'};   
            if(projectRecordTypeListForCLIN.contains(proj.RecordType.DeveloperName) && accountNameListForCLIN.contains(proj.AcctSeed__Account__r.Name)){
                isDLIWLTProject = true;
                
                if(paymentRec.Id == null || paymentRec.Contract__c == null) {
                    if(proj.Contract__c != null && proj.Contract__r.APXT_Redlining__Contract_Family_Parent__c != null){
                        paymentRec.Contract__c = proj.Contract__c;
                    }
                }
            }
        }
        preReviewedVal = paymentRec.Reviewed__c;
        
        // To avoid the same name conflict on Project Task Creation.
        Map<String, Decimal> prodNameCountMap = new Map<String, Decimal>();
        Map<Id,String> oPLIIdKeyProdNameValueMap = new Map<Id,String>();
        
        // To Check what is the Parent Object and query the Corresponding Child Object
        if(projectId != null && projectId != '') {
            hasProject = true;
            projectTaskList = [SELECT Id, Name, Total_Budgeted__c, Total_Spent__c, Project_Task_Type__c, Total_Amount_Paid__c, Total_Qty_Planned__c, Rate__c,AcctSeed__Project__c, AcctSeed__Project__r.AcctSeed__Opportunity__c,Unit__c,Product__c From AcctSeed__Project_Task__c WHERE AcctSeed__Project__c =: projectId];
            parentId = oppId;
        } else if(oppId != null) {
            opliList  = [SELECT Id,Name,OpportunityId,Product2.Id,Product2.Name,Product2.Family,UnitPrice,Quantity,TotalPrice,Unit__c From OpportunityLineItem WHERE OpportunityId =: oppId ORDER BY CreatedDate];
            for( OpportunityLineItem  opl : opliList ) {
                String pdName = opl.Product2.Name;
                if(prodNameCountMap.containskey(opl.Product2.Name)) {
                    prodNameCountMap.put(opl.Product2.Name, prodNameCountMap.get(opl.Product2.Name) + 1);
                    pdName = pdName + ' ' + prodNameCountMap.get(opl.Product2.Name); 
                } else {
                    prodNameCountMap.put(opl.Product2.Name, 1);
                }
                oPLIIdKeyProdNameValueMap.put(opl.Id,pdName);
            }
            
            parentId = oppId;
            for(Payment_Item__c pi : [SELECT Id,Name,Opportunity_Product_Id__c,Project_Task__c,Project_Task__r.Id,Project_Task__r.Name,Project_Task__r.Project_Task_Type__c,Project_Task__r.Total_Budgeted__c,Project_Task__r.Total_Spent__c,Project_Task__r.Total_Amount_Paid__c,Payment__c,Product__c,Amount__c,Payment__r.Project__c,
                    Product__r.Name,Product__r.Family,Payment__r.Opportunity__c,Product__r.Unit_Type__c,Quantity__c,Rate_per_Quantity__c,Project_Task__r.Total_Qty_Planned__c,Project_Task__r.Unit__c FROM Payment_Item__c
                        WHERE Payment__r.Opportunity__c =: oppId]) {
                if(pi.Product__c != null && opliPaid.containskey(pi.Opportunity_Product_Id__c)) {
                    Decimal amt =  opliPaid.get(pi.Opportunity_Product_Id__c) + pi.Amount__c;
                    opliPaid.put(pi.Opportunity_Product_Id__c, amt);
                } else if(pi.Opportunity_Product_Id__c != null) {
                    opliPaid.put(pi.Opportunity_Product_Id__c, pi.Amount__c);
                }
            }
            if(opliPaid != null && opliPaid.size() > 0 ) {
                prodIdPaidMap = JSON.serialize(opliPaid);
            }
            System.debug('prodIdPaidMap:::::'+prodIdPaidMap);
        }
        
        System.debug('paymentRec:::::'+paymentRec);
        
        
        // When a Payment is already created and it is now for Editing
        if(paymentRec.Id != null) {
            
            System.debug(':::::::11111:::::::');
            
            typeOfAction = 'Edit';
            
            Set<Id> oppIdSet = new Set<Id>();
            List<Payment_Item__c> paymentItemRecList = new List<Payment_Item__c>();
            Map<Id,Map<Id,OpportunityLineItem>> oppIdKeyProdIdWithOppLineItem = new Map<Id,Map<Id,OpportunityLineItem>>();
            Map<Id,OpportunityLineItem> opliIdValueMap = new Map<Id,OpportunityLineItem>();
            
            for( Payment_Item__c PayRec : [SELECT Id,Name,Opportunity_Product_Id__c,Project_Task__c,Project_Task__r.Id,Project_Task__r.Name,Project_Task__r.Project_Task_Type__c,Project_Task__r.Total_Budgeted__c,Project_Task__r.Total_Spent__c,Project_Task__r.Total_Amount_Paid__c,Payment__c,Product__c,Amount__c,Payment__r.Project__c,
                    Product__r.Name,Product__r.Family,Payment__r.Opportunity__c,Product__r.Unit_Type__c,Quantity__c,Rate_per_Quantity__c,Project_Task__r.Total_Qty_Planned__c,Project_Task__r.Unit__c, Project_Task__r.CLIN__r.Parent_CLIN__c FROM Payment_Item__c
                        WHERE Payment__c =: paymentRec.Id] ) {
                
                paymentItemRecList.add(PayRec);        
                oppIdSet.add(PayRec.Payment__r.Opportunity__c);    
            }   
            
            if( oppIdSet != null && oppIdSet.size() > 0 ) {
                
                for( OpportunityLineItem oli : [SELECT Id,Name,OpportunityId,Product2.Id,Product2.Name,UnitPrice,Quantity,TotalPrice,Unit__c From OpportunityLineItem WHERE OpportunityId IN : oppIdSet] ) {
                    
                    if(!oppIdKeyProdIdWithOppLineItem.containsKey(oli.OpportunityId)) {
                        oppIdKeyProdIdWithOppLineItem.put(oli.OpportunityId,new Map<Id,OpportunityLineItem>());
                    }
                    oppIdKeyProdIdWithOppLineItem.get(oli.OpportunityId).put(oli.Product2.Id,oli);
                    projTaskNameList.add(new SelectOption(oli.Id,oli.Name));
                    // After creation of Opportunity Product Id field in Funding Item Object.
                    opliIdValueMap.put(oli.Id,oli);   
                }    
            } 
            
            if(projectTaskList != null && projectTaskList.size() > 0) {
                for(AcctSeed__Project_Task__c pt : projectTaskList) {
                    projTaskNameList.add(new SelectOption(pt.Id,pt.Name));
                }
            }
            
            for( Payment_Item__c PayRec : paymentItemRecList ) {
            
                paymentItemInnerClass pIClas = new paymentItemInnerClass();
                pIClas.payItem = PayRec;
                pIClas.index = paymentItemList.size();
                pIClas.notFullyPaid = false;
                pIClas.quantity = PayRec.Rate_per_Quantity__c;
                pIClas.position = 'Old';
                pIClas.preAmount = PayRec.Amount__c;
                
                if(PayRec.Payment__r.Project__c != null) {
                    
                    hasProject = true;
                    pIClas.projTaskName = PayRec.Project_Task__r.Name;
                    pIClas.Total_Budgeted = PayRec.Project_Task__r.Total_Budgeted__c;
                    pIClas.Total_Spent = PayRec.Project_Task__r.Total_Spent__c;
                    pIClas.Total_Amount_Paid = PayRec.Project_Task__r.Total_Amount_Paid__c;
                    pIClas.typeVal = PayRec.Project_Task__r.Project_Task_Type__c;
                    pIClas.unit = PayRec.Project_Task__r.Unit__c;
                    pIClas.qty = PayRec.Project_Task__r.Total_Qty_Planned__c;
                    if(pIClas.qty != NULL){
                        pIClas.qty = (pIClas.qty).setscale(2);
                    }
                    pIClas.redirectId = PayRec.Project_Task__r.Id;
                    pIClas.parentClin = PayRec.Project_Task__r.CLIN__r.Parent_CLIN__c;
                    if( PayRec.Project_Task__r.Total_Budgeted__c != null && PayRec.Project_Task__r.Total_Amount_Paid__c != null && PayRec.Project_Task__r.Total_Budgeted__c > PayRec.Project_Task__r.Total_Amount_Paid__c ) {
                        pIClas.notFullyPaid = true;
                    } 
                    if(pIClas.Total_Amount_Paid == NULL){
                       pIClas.Total_Amount_Paid = 0; 
                    }
                    projWithPaymentItem.add(PayRec.Project_Task__r.Name + '-' + PayRec.Project_Task__c); // Added to edit the same funding record to split the funding Item
                                     
                //} else if (oppIdKeyProdIdWithOppLineItem != null && oppIdKeyProdIdWithOppLineItem.containsKey(PayRec.Payment__r.Opportunity__c) && oppIdKeyProdIdWithOppLineItem.get(PayRec.Payment__r.Opportunity__c) != null && oppIdKeyProdIdWithOppLineItem.get(PayRec.Payment__r.Opportunity__c).containskey(PayRec.Product__c)){
                } else if(opliIdValueMap != null && opliIdValueMap.containskey(payRec.Opportunity_Product_Id__c) && oPLIIdKeyProdNameValueMap.containskey(payRec.Opportunity_Product_Id__c)) {
                  
                     pIClas.prodName = oPLIIdKeyProdNameValueMap.get(PayRec.Opportunity_Product_Id__c); //oppIdKeyProdIdWithOppLineItem.get(PayRec.Payment__r.Opportunity__c).get(PayRec.Product__c).Product2.Name;
                     pIClas.unitPrice = opliIdValueMap.get(PayRec.Opportunity_Product_Id__c).UnitPrice;//oppIdKeyProdIdWithOppLineItem.get(PayRec.Payment__r.Opportunity__c).get(PayRec.Product__c).UnitPrice;
                     pIClas.qty = opliIdValueMap.get(PayRec.Opportunity_Product_Id__c).Quantity;//oppIdKeyProdIdWithOppLineItem.get(PayRec.Payment__r.Opportunity__c).get(PayRec.Product__c).Quantity;
                     if(pIClas.qty != NULL){
                        pIClas.qty = (pIClas.qty).setscale(2);
                     }
                     pIClas.totalPrice = opliIdValueMap.get(PayRec.Opportunity_Product_Id__c).TotalPrice;//oppIdKeyProdIdWithOppLineItem.get(PayRec.Payment__r.Opportunity__c).get(PayRec.Product__c).TotalPrice;
                     pIClas.typeVal = PayRec.Product__r.Family;
                     pIClas.unit = PayRec.Product__r.Unit_Type__c;
                     pIClas.redirectId = opliIdValueMap.get(PayRec.Opportunity_Product_Id__c).Id; //oppIdKeyProdIdWithOppLineItem.get(PayRec.Payment__r.Opportunity__c).get(PayRec.Product__c).Id;
                     pIClas.parentClin = PayRec.Project_Task__r.CLIN__r.Parent_CLIN__c;
                     if( pIClas.totalPrice > pIClas.payItem.Amount__c ) {
                         pIClas.notFullyPaid = true;
                     }
                     projWithPaymentItem.add(pIClas.prodName + '-' + pIClas.redirectId); // Added to edit the same funding record to split the funding Item
                }
                paymentItemList.add(pIClas);
            }
            system.debug('paymentItemList::::'+paymentItemList);
            
            // To add the remaining PRoject Task/ OPLI when launched from Edit button 
            if( opliList != null && opliList.size() > 0 ) { // If the creation is requested from Opportunity
                
                for( OpportunityLineItem  opl : opliList ) {
                    if(oPLIIdKeyProdNameValueMap.containskey(opl.Id) && !projWithPaymentItem.contains(oPLIIdKeyProdNameValueMap.get(opl.Id) + '-' + opl.Id)) {
                        paymentItemInnerClass pIClas = new paymentItemInnerClass();
                        pIClas.prodName = oPLIIdKeyProdNameValueMap.get(opl.Id);
                        pIClas.payItem = new Payment_Item__c(Product__c = opl.Product2Id,Quantity__c = 0,Amount__c = 0,Rate_per_Quantity__c = opl.UnitPrice,Opportunity_Product_Id__c = opl.Id);
                        pIClas.index = paymentItemList.size();
                        pIClas.unitPrice=opl.UnitPrice;
                        pIClas.qty=opl.Quantity;
                        if(pIClas.qty != NULL){
                            pIClas.qty = (pIClas.qty).setscale(2);
                        }
                        pIClas.notFullyPaid = true;
                        pIClas.totalPrice = opl.TotalPrice; 
                        pIClas.quantity = pIClas.unitPrice;
                        pIClas.typeVal = opl.Product2.Family;
                        pIClas.unit = opl.Unit__c;
                        pIclas.redirectId = opl.Id;
                        pIClas.position = 'New';
                        newPaymentItemList.add(pIClas);   
                    } 
                }
            }
            if( projectTaskList != null && projectTaskList.size() > 0 ) { // If the creation is requested from Project
                
                for( AcctSeed__Project_Task__c pt : projectTaskList) {
                    if(!projWithPaymentItem.contains(pt.Name + '-' +pt.Id)) {
                        paymentItemInnerClass pIClas = new paymentItemInnerClass();
                        pIClas.projTaskName = pt.Name;
                        pIClas.payItem = new Payment_Item__c(Project_Task__c = pt.Id,Quantity__c = 0,Amount__c = 0,Rate_per_Quantity__c = pt.Rate__c,Product__c = pt.Product__c);
                        pIClas.Total_Budgeted = pt.Total_Budgeted__c;
                        pIClas.Total_Spent = pt.Total_Spent__c;
                        pIClas.Total_Amount_Paid = pt.Total_Amount_Paid__c;
                        pIClas.qty = pt.Total_Qty_Planned__c; //Edited by Melbin 03/05/2016
                        if(pIClas.qty != NULL){
                            pIClas.qty = (pIClas.qty).setscale(2);
                        }
                        pIClas.quantity = pt.Rate__c;
                        pIClas.unitPrice = pt.Rate__c;
                        pIClas.unit = pt.Unit__c;
                        pIClas.redirectId = pt.Id;
                        pIClas.position = 'New';
                        paymentRec.Opportunity__c = pt.AcctSeed__Project__r.AcctSeed__Opportunity__c; // Added by GRK 5/5/2016
                        pIClas.typeVal = pt.Project_Task_Type__c;
                        if(pt.Total_Amount_Paid__c == null || pt.Total_Amount_Paid__c < pt.Total_Budgeted__c) {
                            pIClas.notFullyPaid = true;
                        } else {
                            pIClas.notFullyPaid = false;
                        }
                        if(pIClas.Total_Amount_Paid == NULL){
                           pIClas.Total_Amount_Paid = 0; 
                        }
                        newPaymentItemList.add(pIClas);
                    } 
                }    
            }
            System.debug('newPaymentItemList::::::'+newPaymentItemList);
        
        } else {  // To create a new Payment Record
            
            typeOfAction = 'Create';
            
            System.debug(':::::::222222:::::::');
            if( opliList != null && opliList.size() > 0 ) { // If the creation is requested from Opportunity
                
                for( OpportunityLineItem  opl : opliList ) {
        
                    paymentItemInnerClass pIClas = new paymentItemInnerClass();
                    if(oPLIIdKeyProdNameValueMap.containskey(opl.Id)){
                        pIClas.prodName = oPLIIdKeyProdNameValueMap.get(opl.Id);
                    }
                    pIClas.payItem = new Payment_Item__c(Product__c = opl.Product2Id,Quantity__c = 0,Amount__c = 0,Rate_per_Quantity__c = opl.UnitPrice,Opportunity_Product_Id__c = opl.Id);
                    pIClas.index = paymentItemList.size();
                    pIClas.unitPrice=opl.UnitPrice;
                    pIClas.qty=opl.Quantity;
                    if(pIClas.qty != NULL){
                        pIClas.qty = (pIClas.qty).setscale(2);
                    }
                    pIClas.notFullyPaid = true;
                    pIClas.totalPrice = opl.TotalPrice; 
                    pIClas.quantity = pIClas.unitPrice;
                    pIClas.typeVal = opl.Product2.Family;
                    pIClas.unit = opl.Unit__c;
                    pIclas.redirectId = opl.Id;
                    pIClas.position = 'New';
                    newPaymentItemList.add(pIClas); 
                }
            }
        
            if( projectTaskList != null && projectTaskList.size() > 0 ) { // If the creation is requested from Project
                
                for( AcctSeed__Project_Task__c pt : projectTaskList) {
                    paymentItemInnerClass pIClas = new paymentItemInnerClass();
                    pIClas.projTaskName = pt.Name;
                    pIClas.payItem = new Payment_Item__c(Project_Task__c = pt.Id,Quantity__c = 0,Amount__c = 0,Rate_per_Quantity__c = pt.Rate__c,Product__c = pt.Product__c);
                    pIClas.Total_Budgeted = pt.Total_Budgeted__c;
                    pIClas.Total_Spent = pt.Total_Spent__c;
                    pIClas.Total_Amount_Paid = pt.Total_Amount_Paid__c;
                    pIClas.qty = pt.Total_Qty_Planned__c; //Edited by Melbin 03/05/2016
                    if(pIClas.qty != NULL){
                        pIClas.qty = (pIClas.qty).setscale(2);
                    }
                    pIClas.quantity = pt.Rate__c;
                    pIClas.unitPrice = pt.Rate__c;
                    pIClas.unit = pt.Unit__c;
                    pIClas.redirectId = pt.Id;
                    pIClas.position = 'New';
                    paymentRec.Opportunity__c = pt.AcctSeed__Project__r.AcctSeed__Opportunity__c; // Added by GRK 5/5/2016
                    pIClas.typeVal = pt.Project_Task_Type__c;
                    if(pt.Total_Amount_Paid__c == null || pt.Total_Amount_Paid__c < pt.Total_Budgeted__c) {
                        pIClas.notFullyPaid = true;
                    } else {
                        pIClas.notFullyPaid = false;
                    }
                    if(pIClas.Total_Amount_Paid == NULL){
                       pIClas.Total_Amount_Paid = 0; 
                    }
                    newPaymentItemList.add(pIClas);
                }     
            }
        }
        System.debug('paymentItemList:::::'+paymentItemList);
        if(paymentItemList != null && paymentItemList.size() > 0 ) {
            mapForPage.put('Old', paymentItemList);
            genListForPage.addAll(paymentItemList);
        } 
        if(newPaymentItemList != null && newPaymentItemList.size() > 0) {
            mapForPage.put('New',newPaymentItemList);
            genListForPage.addAll(newPaymentItemList);
        }
        strForPage = JSON.serialize(mapForPage);
        genStrForPage = JSON.serialize(genListForPage);
    }
    
    public pageReference createPayment() { // Save button is clicked to save the Payment and Payment Line Item
                
        List<Payment_Item__c> paymentItemListToInsert = new List<Payment_Item__c>();
        List<paymentItemInnerClass> totalPaymentItemList = new List<paymentItemInnerClass>();
        Decimal paymentItemTotal = 0;
        pageReference pgRef;
        Decimal hoursPaid = 0;
        Decimal hourlyRate = 0;
        Decimal materialRate = 0;
        //paymentItemList.addall(newPaymentItemList);
        totalPaymentItemList.addall(paymentItemList);
        totalPaymentItemList.addall(newPaymentItemList);
        system.debug(':::totalPaymentItemList::'+totalPaymentItemList);
        
        Map<Id, AcctSeed__Project_Task__c> updateProjTaskRecs = new Map<Id, AcctSeed__Project_Task__c>();        
        
        try {
            
            for( paymentItemInnerClass pl : totalPaymentItemList ) {
                
                if(String.isEmpty(pl.parentClin) && isDLIWLTProject 
                    && parentCLINs != null && parentCLINs.size() > 0 
                    && clinsToUpsert != null && clinsToUpsert.size() > 0){

                    String typeKey = (pl.typeVal == 'Material Budget') ? 'material' : 'other';
                    if(pl.typeVal == 'Travel') typeKey = 'Travel';
                    if(pl.typeVal == 'ODC') typeKey = 'ODC';
                        
                    if(clinsToUpsert.get(typeKey) != null){
                        Id parentClinId = clinsToUpsert.get(typeKey).Parent_CLIN__c;
                        pl.parentClin = parentCLINs.containsKey(parentClinId) ? parentCLINs.get(parentClinId).Id : null;
                    }

                }
                //System.debug(':::::Total_Amount_Paid::::::'+pl.Total_Amount_Paid);
                //System.debug(':::::payItem.Rate_per_Quantity__c::::::'+pl.payItem.Rate_per_Quantity__c);
                //System.debug(':::::payItem.Amount__c::::::'+pl.payItem.Amount__c);
                //System.debug(':::::payItem.Quantity__c::::::'+pl.payItem.Quantity__c);
                //System.debug(':::::qty::::::'+pl.qty);
                //System.debug(':::::position::::::'+pl.position);  
                //System.debug(':::::preAmount::::::'+pl.preAmount);
                
                Decimal newQty = 0;
                
                if(hasProject && pl.projTaskName != null && pl.projTaskName.contains('Training')){
                
                    if(pl.position == 'New' && pl.payItem.Rate_per_Quantity__c > 0){
                        newQty = (pl.Total_Amount_Paid/pl.payItem.Rate_per_Quantity__c) + (pl.payItem.Amount__c/pl.payItem.Rate_per_Quantity__c);
                    }             
                    if(pl.position == 'Old' && pl.payItem.Rate_per_Quantity__c > 0){
                        newQty = (pl.Total_Amount_Paid/pl.payItem.Rate_per_Quantity__c) - (pl.preAmount/pl.payItem.Rate_per_Quantity__c) + (pl.payItem.Amount__c/pl.payItem.Rate_per_Quantity__c);                
                    }
                
                    System.debug(':::::newQty::::::'+newQty);
                    
                    if(newQty > pl.qty){
                    
                        AcctSeed__Project_Task__c updatePT = new AcctSeed__Project_Task__c();
                        updatePT.Id = pl.redirectId;
                        updatePt.Project_Task_Type__c = pl.typeVal;
                        updatePT.Total_Qty_Planned__c = newQty.setscale(2);
                        updateProjTaskRecs.put(updatePT.Id, updatePT);
                    }
                }
                if(pl.payItem != null && pl.payItem.Amount__c != null) {
                    paymentItemTotal += pl.payItem.Amount__c;
                } else {
                    apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'Please Add a Payment Line Item.');
                    apexpages.addmessage(msg);
                }
                
                if( ( pl.typeVal == 'Language Training' || pl.typeVal == 'Preparation time' || pl.typeVal == 'Curriculum Development') && pl.payItem.Amount__c != 0 && pl.payItem.Quantity__c != 0) {
                    if((pl.projTaskName != null && !pl.projTaskName.contains('Additional Stud')) || (pl.prodName != null && !pl.prodName.contains('Additional Stud')) ) {
                        hoursPaid += pl.payItem.Quantity__c;
                    }
                    //System.debug('::Input Field:::quantity:::'+pl.payItem.Rate_per_Quantity__c);
                    //System.debug(':::::quantity:::'+pl.quantity);
                    //hourlyRate = pl.quantity;
                    if(pl.typeVal == 'Language Training' || pl.typeVal == 'Curriculum Development'){
                        hourlyRate = pl.payItem.Rate_per_Quantity__c;
                    }
                }
                if(pl.typeVal == 'Material Budget' && pl.payItem.Amount__c != 0 && pl.payItem.Quantity__c != 0 ){
                    materialRate +=  pl.payItem.Amount__c;
                }
                System.debug('isDLIWLTProject::>'+isDLIWLTProject);
                if(isDLIWLTProject){                
                    String key;    
                    System.debug('clinsToUpsert::>'+clinsToUpsert);
                    CLIN__c clin = new CLIN__c(CLIN_Max_Quantity__c=1,CLIN_Start_Date__c=proj.Start_Date__c,
                                                   CLIN_End_Date__c=proj.End_Date__c, Contract__c=paymentRec.Contract__c,CLIN_Unit_Price__c=0 
                                                  );                                        
                        
                    if(pl.typeVal == 'Material Budget'){
                        if(clinsToUpsert.get('material') != null)
                            clin = clinsToUpsert.get('material');  
                        key = 'material';
                    }else if(pl.typeVal == 'Travel'){
                        if(clinsToUpsert.get('Travel') != null)
                            clin = clinsToUpsert.get('Travel');  
                        key = 'Travel';                        
                    }else if(pl.typeVal == 'ODC'){
                        if(clinsToUpsert.get('ODC') != null)
                            clin = clinsToUpsert.get('ODC');  
                        key = 'ODC';                        
                    }else{
                        if(clinsToUpsert.get('other') != null)
                            clin = clinsToUpsert.get('other'); 
                        key = 'other';
                    }
                    System.debug('::>parentclin::>'+pl.parentClin+'::>'+clin.Parent_CLIN__c);
                    string parentClinId = pl.parentClin != null ? pl.parentClin : clin.Parent_CLIN__c;
                    System.debug('Clin:before:>'+clin);
                    System.debug('parentClinId::>'+parentClinId);
                    if(String.isNotEmpty(parentClinId)){
                        
                        if(updateProjTaskRecs.get(pl.redirectId) == null){
                            AcctSeed__Project_Task__c updatePT = new AcctSeed__Project_Task__c();
                            updatePT.Id = pl.redirectId;
                            updatePt.Project_Task_Type__c = pl.typeVal;
                            updateProjTaskRecs.put(updatePT.Id, updatePT);
                        }
                       
                        CLIN__c parentClin = parentCLINs.get(parentClinId);
                        System.debug('parentClin::>'+parentClin);
                        if(clin.Id == null){
                            clin.CLIN_Type__c = parentClin.CLIN_Type__c;
                            clin.Name = parentClin.Name;
                            clin.CLIN_Name__c = parentClin.CLIN_Name__c;
                            clin.CLIN_Unit__c = parentClin.CLIN_Unit__c;
                            clin.Parent_CLIN__c = pl.parentClin;
                        }
                        clin.CLIN_Unit_Price__c += pl.payItem.Amount__c; 
                        clin.Amount_Funded__c = clin.CLIN_Unit_Price__c;
                        System.debug('CLIN::'+key+'::>'+clin);
                        clinsToUpsert.put(key, clin);
                    }
                }
            }
            
            System.debug(':::::hourlyRate:::'+hourlyRate);
            System.debug(':::::updateProjTaskRecs:::'+updateProjTaskRecs);
            System.debug(':::::updateProjTaskRecs:: SIZE:'+updateProjTaskRecs.size());
            
             /*********
                - Added By HL on Nov 17 2020
                - Work Item : W-006036 - Funding transaction "Reviewed" button issue
                - To update Reviewed__c field as "Unchecked" if anyone edits the funding transaction after checking the checkbox.
                ***********/            
            if(paymentRec.Id != NULL){
            
                if(preReviewedVal && paymentRec.Reviewed__c){
                
                    paymentRec.Reviewed__c = FALSE;
                }
            }
            
            // To update the hourly rate and Hours Paid 
            paymentRec.Hours_Paid__c = hoursPaid;
            //paymentRec.Materials_Amount__c = materialRate; // To refer the Rollup helper field, Commented by NS on 21/2/2018
            //if(paymentRec.Id == null) { // Commented to update the hourly_rate__c field in Funding object during the update process also
                paymentRec.Hourly_Rate__c = hourlyRate;
            //}
            System.debug(':::::paymentRec.Hourly_Rate__c:::'+paymentRec.Hourly_Rate__c);
            System.debug('paymentRec: Reviewed__c::'+paymentRec.Reviewed__c);
            SYstem.debug('clinsToUpsert::>'+clinsToUpsert);
            Upsert paymentRec;
            refreshPage = TRUE;
            system.debug('paymentItemList ::::'+paymentItemList);
            for( paymentItemInnerClass pl : totalPaymentItemList ) {
                if(!(pl.payItem.Payment__c != null)) {
                    pl.payItem.Payment__c = paymentRec.Id;
                }
                System.debug('pl.notFullyPaid::'+pl);
                if( /*pl.notFullyPaid != null && pl.notFullyPaid == true &&*/ pl.payItem.Amount__c != 0 && pl.payItem.Quantity__c != 0 ) { 
                    paymentItemListToInsert.add(pl.payItem);  
                }
            }
            
            if(clinsToUpsert != null && clinsToUpsert.size() > 0){
                upsert clinsToUpsert.values();
            }
            
            System.debug('paymentItemListToInsert:::::'+paymentItemListToInsert);
            if( paymentItemListToInsert != null && paymentItemListToInsert.size() > 0 ) {
                Upsert paymentItemListToInsert;
                paymentItemListToInsert = new List<Payment_Item__c>();
            }
            System.debug('attach :::'+attach);
            //Insert attachment on October 17, 2016
            if(attach.Body != null){
                attach.ParentId = paymentRec.Id;
                Insert attach;
            }
            
            for(AcctSeed__Project_Task__c projTask : updateProjTaskRecs.values()){
                if(projTask.Project_Task_Type__c == 'Material Budget' && clinsToUpsert.get('material') != null){
                    projTask.CLIN__c = clinsToUpsert.get('material').Id;
                }else if(projTask.Project_Task_Type__c == 'Travel'  && clinsToUpsert.get('Travel') != null){
                    projTask.CLIN__c = clinsToUpsert.get('Travel').Id;
                }else if(projTask.Project_Task_Type__c == 'ODC'  && clinsToUpsert.get('ODC') != null){
                    projTask.CLIN__c = clinsToUpsert.get('ODC').Id;
                }else if( clinsToUpsert.get('other') != null){
                    projTask.CLIN__c = clinsToUpsert.get('other').Id;
                }
            }
            
            if(updateProjTaskRecs != NULL && updateProjTaskRecs.size() > 0){
            
                update updateProjTaskRecs.values();
            }
        } catch(DMLException dex) {
            errorAlert = true;
            
            String showError = dex.getMessage();
            if(showError.contains('DUPLICATE')){
                showError += ' Please check the Unique Fields: ';
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Map<String, Schema.SObjectField> fieldMap = schemaMap.get('Transaction__c').getDescribe().fields.getMap();
                Integer i = 0;
                for(String fieldName : fieldMap.keyset()){
                    if(fieldMap.get(fieldName).getDescribe().isUnique()){
                        if(i == 0){
                            showError += fieldName;
                        } else {
                            showError += ', '+fieldName;
                        }
                        i++;
                    }
                }
            }
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,showError);
            ApexPages.addMessage(myMsg);
            
        } catch(Exception ex) {
            errorAlert = true;
            System.debug('Error:::'+ex);
            System.debug('Error::LINE NO:'+ex.getLineNumber());
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
            ApexPages.addMessage(myMsg);
        } 
        PageReference trans;
        if(!errorAlert){
            trans = new PageReference('/'+paymentRec.Id);
        } else {
            errorAlert = false;
        }
        /*if(paymentRec != null && paymentRec.Id != null) {
            trans = new PageReference('/'+paymentRec.Id);
        } else {
            //ApexPages.Message myMsg = new ApexPages.message(ApexPages.severity.FATAL,'Something went wrong. Please try again later.');
            //ApexPages.addMessage(myMsg);
            //trans = new PageReference('/'+parentId);
        }*/
        return trans;   
    }
            
    public pageReference previousPage() {
    
        PageReference pgRef;
        if(paymentRec.Id != null) {
            pgRef = new PageReference('/'+paymentRec.Id);
        } else if( projectId != null ) {
            pgRef = new PageReference('/'+projectId);
        } else if (oppId != null) {
            pgRef = new PageReference('/'+oppId);
        }
        return pgRef; 
    }   
    
    public void insertNewPayment() {
        paymentItemInnerClass pIClas = new paymentItemInnerClass();
        pIClas.projTaskName = '';
        newPaymentItemList.add(pIClas);
    }
}