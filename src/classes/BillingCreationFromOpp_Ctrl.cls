/* Created by Siva Prasanth K.T on 13/03/20*/
public class BillingCreationFromOpp_Ctrl {
    
    // Get Billing Row Information
    @AuraEnabled
    public static String getBillingInfoFromOPP(String oppId){
        
        BillingRowInfo billingRow = new BillingRowInfo();
        
        List<Opportunity> oppList = [SELECT Id,A_R_Type__c FROM Opportunity WHERE Id = :oppId];
        
        
        if(oppList.size() > 0 && oppList[0].A_R_Type__c == '11005-Prepayment'){
            billingRow.isPrePaymentOpp = true;

            List<AcctSeed__Project__c> projectRec = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c = :oppId];
            if(projectRec.size() > 0){ 
                billingRow.projectExist = true;
            }else {
                billingRow.projectExist = false;
            }
            // if Opportunity hasn't Project then go for Billing table row formation
            if(billingRow.projectExist == false){
                Date currentMonthStartDt = System.Date.today().toStartOfMonth(); 
                Date currentMonthEndDt =  currentMonthStartDt.addMonths(1).addDays(-1);
                //System.debug('currentMonthStartDt:::'+currentMonthStartDt);
                //System.debug('currentMonthEndDt:::'+currentMonthEndDt);
                List<AcctSeed__Accounting_Period__c> acpList = AccountingPeriodService.getAccountperiodRec( new Set<Date>{currentMonthStartDt}, new Set<Date>{currentMonthEndDt});   
                List<billingLineOPLIItemsInfo> opliItemList = new List<billingLineOPLIItemsInfo>();
                List<OpportunityLineItem> opliItems = OpportunityLineItemService.getOPLIByOppId(new Set<Id>{oppId},'',',Opportunity.Account.Account_Code__c,Product2.Name,CLIN_LU__r.Name,Opportunity.Name,Opportunity.AccountId,Opportunity.Account.Name,Opportunity.Account.AcctSeed__Billing_Days_Due__c,Opportunity.Account.AcctSeed__Billing_Contact__c,Opportunity.A_R_Type__c');
                Map<Id, Contact_Assignments__c> contAssignments = new Map<Id, Contact_Assignments__c>([SELECT Id, Candidate_Name__c, RecordType.Name, Candidate_Name__r.Name, Candidate_Name__r.FirstName , Candidate_Name__r.LastName, Candidate_Name__r.Email FROM Contact_Assignments__c WHERE Opportunity_Name__c = :oppId AND RecordType.DeveloperName IN ('Student','Client_Partner')]);
                Set<Id> billingRowOppIds = new Set<Id>();
                String studentNames = '';
                List<String> tdyDate = (String.valueOf(System.today())).split('-');
                String dateString = (tdyDate != null) ? (tdyDate[1]+tdyDate[2]+tdyDate[0]) : null;
                Set<String> glNameSet = new Set<String>{'11005 - AR - Deferred Revenue', '40820 - Other Misc. Income'};
                Map<String,Id> glMap = new Map<String,Id>();
                for(Acctseed__GL_Account__c gl : [SELECT Id,Name FROM Acctseed__GL_Account__c WHERE Name IN: glNameSet]) {
                    glMap.put(gl.Name, gl.Id);
                }
                System.debug('glMap:::'+glMap);
                Set<Id> conIds = new Set<Id>();
                for(Contact_Assignments__c ca : contAssignments.values()){
                    conIds.add(ca.Candidate_Name__c);
                    if(ca.Candidate_Name__c != null){
                        String stuName = '';
                        if(ca.Candidate_Name__r.FirstName != null){
                            stuName = ca.Candidate_Name__r.FirstName.substring(0,1);
                        }
                        if(ca.Candidate_Name__r.LastName != null){
                            stuName += ca.Candidate_Name__r.LastName.substring(0,1);
                        }
                        studentNames += stuName+'/';
                    } 
                }
                studentNames = studentNames.removeEnd('/');
                //W-007576 Added by Dinesh on 03.10.2022
                Map<Id,Contact> contactsMap = new Map<Id, Contact>([SELECT Id, Name , FirstName, LastName, Email FROM Contact WHERE Id IN :conIds]);
                
                if(opliItems.size() > 0){         
                    Decimal billingColumnTotal = 0.00;
                    Decimal billingRecCount = 0.00;
                    
                    String billingRecExistMapJSON =  checkBillingLineExistorNot(oppId);
                    Map<String,AcctSeed__Billing_Line__c> billingRecExistMap = (Map<String,AcctSeed__Billing_Line__c>) JSON.deserialize(billingRecExistMapJSON , Map<String,AcctSeed__Billing_Line__c>.class);
                    String userName = UserInfo.getName();
                    List<Contact> userContact = ContactService.getContactByName('',null,null,userName);
                    if(userContact.size() > 0){
                        contactsMap.put(userContact[0].Id , userContact[0]);
                    }
                    billingRow.studentContactsMap = contactsMap;
                    
                    for(OpportunityLineItem opli : opliItems){
                        
                        billingLineOPLIItemsInfo opliInfo = new billingLineOPLIItemsInfo();
                        List<CLIN__c> clinLookup = new List<CLIN__c>();
                        
                        opliInfo.oppId = opli.OpportunityId;
                        opliInfo.oppName = opli.Opportunity.Name;
                        opliInfo.quantity = opli.Quantity != null ? String.valueOf(opli.Quantity) : '0.00';
                        opliInfo.unitPrice = opli.UnitPrice != null ? String.valueOf(opli.UnitPrice) : '0.00';
                        opliInfo.glAccountVar1 = opli.AcctSeed__GL_Account_Variable_1__c;
                        opliInfo.opliId = opli.Id;  
                        
                        if(!billingRecExistMap.containsKey(opli.OpportunityId+'~'+opli.Id)){
                            opliInfo.isBillineNotExist = true;
                        }
                        
                        opliInfo.total = (Decimal.valueOf(opliInfo.quantity) * Decimal.valueOf(opliInfo.unitPrice));
                        
                        // For the Registration fee OPLI make the GL Account as 40820 - Other Misc. Income
                        if(opli.Opportunity.A_R_Type__c == '11005-Prepayment') {
                            //System.debug('opli.Product2.Name::'+opli.Product2.Name);
                            if(opli.Product2.Name.contains('Registration Fee') && glMap.containskey('40820 - Other Misc. Income')) {
                                opliInfo.revenueGLAccount = glMap.get('40820 - Other Misc. Income');
                            } else if(glMap.Containskey('11005 - AR - Deferred Revenue')) {
                                opliInfo.revenueGLAccount = glMap.get('11005 - AR - Deferred Revenue');                 
                            }
                        } else if(opli.Revenue_GL_Account__c != null) {
                            opliInfo.revenueGLAccount = opli.Revenue_GL_Account__c;
                        }
                        
                        if(opli.CLIN_LU__c != null){
                            opliInfo.clinName = opli.CLIN_LU__r.Name;
                            opliInfo.clinId = opli.CLIN_LU__c;
                        }
                        
                        opliInfo.comment = 'Prepayment for ';
                        if(opli.Product2Id != null){
                            opliInfo.opliName = opli.Product2.Name;
                            opliInfo.productId = opli.Product2Id;  
                            opliInfo.comment += opli.Product2.Name+', ';
                        }
                        
                        if(opli.Opportunity != null){
                            opliInfo.comment += opli.Opportunity.Name+'.';
                        }
                        
                        opliItemList.add(opliInfo);  
                        
                        billingColumnTotal = billingColumnTotal + opliInfo.total;
                        billingRecCount = billingRecCount + 1; 
                        
                        
                        if(!billingRowOppIds.contains(opli.OpportunityId)){
                            billingRowOppIds.add(opli.OpportunityId);
                            String proprietaryNo;
                            
                            billingRow.oppName = opli.Opportunity.Name;
                            billingRow.oppId = opli.OpportunityId;
                            
                            if(opli.Opportunity.AccountId != null){
                                billingRow.accountId = opli.Opportunity.AccountId;
                                billingRow.billingContact = opli.Opportunity.Account.AcctSeed__Billing_Contact__c;
                                
                                if(opli.Opportunity.Account.AcctSeed__Billing_Days_Due__c != null){
                                    billingRow.accBillingDueDays = System.today().addDays(Integer.valueOf(opli.Opportunity.Account.AcctSeed__Billing_Days_Due__c));
                                }
                                
                                if(opli.Opportunity.Account.Name != null){
                                    proprietaryNo = opli.Opportunity.Account.Name; 
                                }
                            }
                            billingRow.opliItemsList= new List<billingLineOPLIItemsInfo>();
                            
                            if(acpList.size() > 0){
                                billingRow.acpId = acpList[0].Id;
                                billingRow.acpStDt = acpList[0].AcctSeed__Start_Date__c;
                                billingRow.acpEdDt = acpList[0].AcctSeed__End_Date__c;
                            }
                            proprietaryNo += dateString +'-'+ studentNames; 
                            billingRow.proprietaryNo = proprietaryNo ; 
                        }  
                    }
                    System.debug('opliItemList::::'+opliItemList);
                    if(opliItemList.size() > 0){
                        billingRow.billingColumnTotal = billingColumnTotal;
                        billingRow.billingRecCount = billingRecCount;
                        billingRow.opliItemsList = opliItemList; 
                        billingRow.billingRecExistMapJSON = billingRecExistMapJSON;
                    }
                }
                
            }
        }else{
            billingRow.isPrePaymentOpp = false; 
        }
        return JSON.serialize(billingRow);
    } 
    // Billing and Billing Line Creation
    @AuraEnabled
    public static String createBillingRecs(String billingJSON, String billingLineJSON, String billingId, String opportId, String contactStr){
        AcctSeed__Billing__c bill;
        List<AcctSeed__Billing_Line__c> billLineList = (List<AcctSeed__Billing_Line__c>) JSON.deserialize(billingLineJSON,List<AcctSeed__Billing_Line__c>.class);                
        CongaURLWrapper congaUrl = new CongaURLWrapper();
                
        //W-007576 Modified by Dinesh on 03.10.2022
        Contact contactInstance = (Contact) JSON.deserialize(contactStr, Contact.Class);
        System.debug('contactInstance::>'+contactInstance);
        
        try {
            // Billing insertion
            if(String.isNotBlank(billingJSON)){
                bill = (AcctSeed__Billing__c) JSON.deserialize(billingJSON,AcctSeed__Billing__c.class);
            }
            
            if(String.isBlank(billingId)){
                
                bill.AcctSeed__Date__c = system.today();             
                bill.AcctSeed__Status__c = 'Approved';
                
                insert bill;
                
                billingId = bill.Id;
            }
            
            if(billingId != null && billLineList.size() > 0){
                // Billing line  insertion
                List<AcctSeed__Billing_Line__c> billingLinesToInsert = new List<AcctSeed__Billing_Line__c>();
                for(AcctSeed__Billing_Line__c bl : billLineList){
                    if(bl.AcctSeed__Hours_Units__c != null && bl.AcctSeed__Hours_Units__c != 0){
                        bl.AcctSeed__Date__c = system.today();
                        bl.AcctSeed__Date__c = system.today();
                        bl.AcctSeed__Billing__c = billingId;
                        billingLinesToInsert.add(bl);
                    }
                }
                
                insert billingLinesToInsert;    
                
                //  Conga URL formation
                congaUrl = prepaymentCongaUrlInfo(billingId,opportId); 
                                
                if(contactInstance != null){
                    sendbillingNotification(bill, contactInstance);                    
                }                
            }
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.serialize(congaUrl);
    }
    // Check Billing Line already exist or not
    @AuraEnabled
    public static String checkBillingLineExistorNot(String oppId){ 
        Map<String,AcctSeed__Billing_Line__c> oppAndOPLIMap = new Map<String,AcctSeed__Billing_Line__c>();
        
        if(String.isNotBlank(oppId)){
            
            for(AcctSeed__Billing_Line__c billLine : BillingLineService.getBillLineByParentIds(' WHERE AcctSeed__Billing__c != null AND AcctSeed__Opportunity_Product_Id__c != null AND AcctSeed__Billing__r.AcctSeed__Opportunity__c',',AcctSeed__Billing__r.AcctSeed__Opportunity__c',new Set<Id>{oppId})) {
                
                if(!oppAndOPLIMap.containsKey(billLine.AcctSeed__Billing__r.AcctSeed__Opportunity__c+'~'+billLine.AcctSeed__Opportunity_Product_Id__c)){
                    oppAndOPLIMap.put(billLine.AcctSeed__Billing__r.AcctSeed__Opportunity__c+'~'+billLine.AcctSeed__Opportunity_Product_Id__c,billLine);
                }
            }
        }
        
        return JSON.serialize(oppAndOPLIMap );  
    }
    // Conga Url formation
    @AuraEnabled
    public static CongaURLWrapper prepaymentCongaUrlInfo(String billId, String opportId){ 
        CongaURLWrapper congaUrl = new CongaURLWrapper();
        
        List<AcctSeed__Billing__c> billRec = [SELECT Id,Project_s_QB_Contract_Type__c,AcctSeed__Proprietary_Billing_Number__c FROM AcctSeed__Billing__c  WHERE Id = :billId];            

        if(billRec.size() > 0){              
            
            if(billRec[0].Project_s_QB_Contract_Type__c == 'nonGSA'){                  
                congaUrl.tempNameIdMap = CongaButtonsController.getTempMap('Non-GSA Prepayment Invoice Template');                    
            }else{                    
                congaUrl.tempNameIdMap = CongaButtonsController.getTempMap('GSA Prepayment Invoice Template');                   
            } 
            
            congaUrl.queryNameIdMap.putAll(CongaButtonsController.getQryMap('Billing Query - Billing PDF'));
            congaUrl.queryNameIdMap.putAll(CongaButtonsController.getQryMap('Billing Line Query - Billing PDF'));
            congaURl.queryNameIdMap.putAll(CongaButtonsController.getQryMap('Contact Assignment Query - Product Billing PDF'));
            congaUrl.sessionIdServerURL = CongaButtonsController.getServerUrlSessionId();
            congaUrl.billingRec = billRec[0]; 
            
            String caId = null;
            for(Contact_Assignments__c ca :  [SELECT Id,Assignment_Position__c FROM Contact_Assignments__c WHERE Status__c IN ('Active','Planned') AND RecordType.DeveloperName = 'Student' AND Opportunity_Name__c = :opportId]){
                
                if(caId == null){
                    caId = ca.Id;
                }else if(ca.Assignment_Position__c == 'Class Leader'){
                    caId = ca.Id;
                }
            }
            congaUrl.conAssignId = caId;
        }
        return congaUrl;        
    }
    
    public static void sendbillingNotification(AcctSeed__Billing__c billingCreated, Contact contactInstance){
        
        AcctSeed__Billing__c billing = [SELECT Id, AcctSeed__Billing_Format__c, AcctSeed__Billing_Format__r.AcctSeed__Default_Email_Template__c FROM AcctSeed__Billing__c WHERE Id = :billingCreated.Id LIMIT 1];
        
        if(contactInstance.email != null && billing.AcctSeed__Billing_Format__c != null && billing.AcctSeed__Billing_Format__r.AcctSeed__Default_Email_Template__c != null){
            Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
            
            message.setTargetObjectId(contactInstance.Id); 
            message.setSenderDisplayName(UserInfo.getName());        
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = :billing.AcctSeed__Billing_Format__r.AcctSeed__Default_Email_Template__c];
            message.setTemplateID(emailTemplate.Id); 
            message.setWhatId(billing.Id); //This is important for the merge fields in template to work
            message.toAddresses = new String[] { contactInstance.email};
                
                if(!Test.isRunningTest()){
                    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    
                    if (results[0].success) {
                        System.debug('The email was sent successfully.');
                    } else {
                        System.debug('The email failed to send: ' +  results[0].errors[0].message);
                    }
              }
        }
    }
    
    public Class BillingRowInfo{
        @AuraEnabled
        public List<billingLineOPLIItemsInfo> opliItemsList; 
        @AuraEnabled
        Public String oppId;
        @AuraEnabled
        public String oppName;
        @AuraEnabled
        public String billingContact;       
        @AuraEnabled
        public String accountId;
        @AuraEnabled 
        public String acpId;
        @AuraEnabled 
        public Date acpStDt;
        @AuraEnabled 
        public Date acpEdDt;
        @AuraEnabled
        public Date accBillingDueDays;
        @AuraEnabled 
        public string proprietaryNo;
        @AuraEnabled
        public Decimal billingColumnTotal;
        @AuraEnabled 
        public Decimal billingRecCount;  
        @AuraEnabled
        public String billingRecExistMapJSON;
        @AuraEnabled
        public Boolean projectExist;
        @AuraEnabled
        public Boolean isPrePaymentOpp;
        @AuraEnabled
        public Map<Id, Contact> studentContactsMap;//W-007576 Modified by Dinesh on 03.10.2022
    }
    public Class billingLineOPLIItemsInfo{
        @AuraEnabled
        public Id oppId;       
        @AuraEnabled
        public String opliName;
        @AuraEnabled
        public String oppName;
        @AuraEnabled
        public String comment;
        @AuraEnabled
        public String quantity;
        @AuraEnabled
        public String unitPrice;
        @AuraEnabled
        public Decimal total;        
        @AuraEnabled
        public String glAccountVar1;
        @AuraEnabled
        public String revenueGLAccount;      
        @AuraEnabled
        public Id opliId;        
        @AuraEnabled
        public String clinName;
        @AuraEnabled
        public String clinId;
        @AuraEnabled
        public String productId;
        @AuraEnabled
        public Boolean isBillineNotExist;
    }
    
    public Class CongaURLWrapper{  
        @AuraEnabled 
        public Map<String, Id> queryNameIdMap = new Map<String, Id>();
        @AuraEnabled 
        public Map<String, Id> tempNameIdMap = new Map<String, Id>();
        @AuraEnabled 
        public String sessionIdServerURL; 
        @AuraEnabled 
        public AcctSeed__Billing__c billingRec;
        @AuraEnabled 
        public String conAssignId;
        
    }
}