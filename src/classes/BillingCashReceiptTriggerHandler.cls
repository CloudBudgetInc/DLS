/**
 * @description       : 
 * @author            : Dhinesh Kumar
 * @group             : 
 * @last modified on  : 08/12/2022
 * @last modified by  : Dhinesh Kumar
**/
public with sharing class BillingCashReceiptTriggerHandler{
    
    //Created By Dhinesh - W-005838 - Automatically creating funding records in the Project
    public static void createFundingAndFundingItems(List<AcctSeed__Billing_Cash_Receipt__c> newBillingCashReceipts){
        
        try{
            Set<Id> billingIds = new Set<Id>();
            Set<Id> cashReceiptIds = new Set<Id>();
            Set<String> oppIdSet = new Set<String>();
            Map<Id, Id> cashReceiptIdAndBillingMap = new Map<Id, Id>(); //Added By Dhinesh - 14/7/2022 - W-007525
            
            for(AcctSeed__Billing_Cash_Receipt__c billcashRec: newBillingCashReceipts){
                billingIds.add(billcashRec.AcctSeed__Billing__c);
                cashReceiptIds.add(billcashRec.AcctSeed__Cash_Receipt__c);
                cashReceiptIdAndBillingMap.put(billcashRec.AcctSeed__Cash_Receipt__c, billcashRec.AcctSeed__Billing__c);//Added By Dhinesh - 14/7/2022 - W-007525
            }
            
            Map<Id, AcctSeed__Billing__c> billingMap = new Map<Id, AcctSeed__Billing__c>([SELECT Id, AcctSeed__Opportunity__r.A_R_Type__c,Project__r.Billing_Type__c FROM AcctSeed__Billing__c WHERE Id IN :billingIds]);
            
            Map<Id, List<AcctSeed__Billing_Line__c>> billingIdWithBillingLinesMap = new Map<Id, List<AcctSeed__Billing_Line__c>>();
            
            Map<Id, AcctSeed__Cash_Receipt__c> cashReceiptIdWithRecMap = new Map<Id, AcctSeed__Cash_Receipt__c>(AcctSeedCashReceiptService.getAcctSeedCashReceiptsByIds('','AcctSeed__Account__r.Name',cashReceiptIds));
            AcctSeed__Cash_Receipt__c cashReceipt;
            Map<String, Id> payRefStrWithCashReceiptIdMap = new Map<String, Id>();
            
            //Added By Dhinesh - 18/09/2020 - W-005838 - Automatically creating funding records in the Project
            Set<Id> accountIds = new Set<Id>();        
            for(Id cashReceiptId : cashReceiptIdWithRecMap.keySet()){
                cashReceipt = cashReceiptIdWithRecMap.get(cashReceiptId);
                AcctSeed__Billing__c billing = cashReceiptIdAndBillingMap.get(cashReceiptId) != null ? billingMap.get(cashReceiptIdAndBillingMap.get(cashReceiptId)) : null;
                // Commented "|| billing.Project__r.Billing_Type__c == '11005-Prepayment'" condition on Sep 11 2023
                // W-007876 : Double Funding created in Project - The funding should be created only if the opportunity linked to the Billing
                if(cashReceipt.AcctSeed__Account__c != null && ((billing != null && (billing.AcctSeed__Opportunity__c != null && billing.AcctSeed__Opportunity__r.A_R_Type__c == '11005-Prepayment')) 
                    || cashReceipt.AcctSeed__Account__r.Name.startsWith('PVT'))){
                    accountIds.add(cashReceipt.AcctSeed__Account__c);
                }
                if(cashReceipt.AcctSeed__Payment_Reference__c != null){
                    payRefStrWithCashReceiptIdMap.put(cashReceipt.AcctSeed__Payment_Reference__c, cashReceipt.Id);
                }
            }
            
            //Added By Dhinesh - 30/10/2020 - W-005838 - To avoid creating new funding and funding items if it's already exist for related Cash Receipt's Payment Reference
            for(Transaction__c fund : [ SELECT Id, Transaction_Notes__c FROM Transaction__c 
                                       WHERE Transaction_Notes__c IN :payRefStrWithCashReceiptIdMap.keySet()]){
                                           
               cashReceiptIdWithRecMap.remove(payRefStrWithCashReceiptIdMap.get(fund.Transaction_Notes__c));
            }
            
            if(cashReceiptIdWithRecMap.size() > 0){        
                Map<Id, Account> accIdWithAccRecMap = new Map<Id, Account>([SELECT Id, (SELECT Id FROM Contacts LIMIT 1) FROM Account WHERE Id IN :accountIds]);
                Set<Id> oppLineIds = new Set<Id>();    
                Map<Id, OpportunityLineItem> oppLineItemIdWithRecMap = new Map<Id, OpportunityLineItem>();            
                
                for(AcctSeed__Billing_Line__c billingLine : BillingLineService.getBillLineByParentIds(' WHERE AcctSeed__Billing__c',' , AcctSeed__Billing__r.CreatedById, AcctSeed__Billing__r.AcctSeed__Status__c, AcctSeed__Billing__r.Project__c, AcctSeed__Project_Task__r.RecordType.Name, AcctSeed__Project_Task__r.Project_Task_Type__c, AcctSeed__Project_Task__r.Name, AcctSeed__Project_Task__r.Product__c, AcctSeed__Project_Task__r.Rate__c, AcctSeed__Project_Task__r.Total_Qty_Planned__c, AcctSeed__Project_Task__r.Total_Amount_Paid__c, AcctSeed__Billing__r.AcctSeed__Opportunity__r.A_R_Type__c, AcctSeed__Billing__r.AcctSeed__Opportunity__c',billingIds)){
                    if(!billingIdWithBillingLinesMap.containsKey(billingLine.AcctSeed__Billing__c)){
                        billingIdWithBillingLinesMap.put(billingLine.AcctSeed__Billing__c, new List<AcctSeed__Billing_Line__c>());
                    }
                    billingIdWithBillingLinesMap.get(billingLine.AcctSeed__Billing__c).add(billingLine);
                    if(billingLine.AcctSeed__Billing__r.AcctSeed__Opportunity__c != null && billingLine.AcctSeed__Billing__r.Project__c == null){
                        oppLineIds.add(billingLine.AcctSeed__Opportunity_Product_Id__c);
                    }
                }
                
                if(oppLineIds.size() > 0){
                    for(OpportunityLineItem oppLine : [SELECT Id, Product2.Id, Product2.Family, Product2.Name, Quantity, UnitPrice, TotalPrice FROM OpportunityLineItem WHERE Id IN :oppLineIds]){
                        oppLineItemIdWithRecMap.put(oppLine.Id, oppLine);
                    }
                }
                
                List<Transaction__c> fundingList = new List<Transaction__c>();
                Transaction__c funding;        
                AcctSeed__Billing__c billing;
                Map<String, List<Payment_Item__c>> fundingItemToInsertMap = new Map<String, List<Payment_Item__c>>();
                Map<String, Transaction__c> fundingToInsertMap = new Map<String, Transaction__c>();
                
                //Added By Dhinesh - 18/09/2020 - W-005838 - Automatically creating funding records in the Project
                Map<Id, AcctSeed__Billing__c> billingsToUpdate = new Map<Id, AcctSeed__Billing__c>(); 
                List<AcctSeed__Billing__c> billingsToPost = new List<AcctSeed__Billing__c>();
                Map<Id, AcctSeed__Billing__c> billingsToUnPostMap = new Map<Id, AcctSeed__Billing__c>();
                List<AcctSeed__Billing_Line__c> billingLinesToUpdate = new List<AcctSeed__Billing_Line__c >(); 
                
                //Added By Dhinesh - 16/11/2020 - W-006035 - Update Project Task Record when Planned Hrs < Paid Hrs
                List<AcctSeed__Project_Task__c> updateProjTaskRecs = new List<AcctSeed__Project_Task__c>();
                Decimal newQty;
                
                for(AcctSeed__Billing_Cash_Receipt__c billcashRec: newBillingCashReceipts){
                    
                    cashReceipt = cashReceiptIdWithRecMap.get(billcashRec.AcctSeed__Cash_Receipt__c);
                    billing = cashReceiptIdAndBillingMap.get(cashReceipt.Id) != null ? billingMap.get(cashReceiptIdAndBillingMap.get(cashReceipt.Id)) : null;
                    
                    if(cashReceipt != null && cashReceipt.AcctSeed__Account__c != null 
                        // Commented "|| billing.Project__r.Billing_Type__c == '11005-Prepayment'" condition on Sep 11 2023
                        && ((billing != null && (billing.AcctSeed__Opportunity__c != null && billing.AcctSeed__Opportunity__r.A_R_Type__c == '11005-Prepayment')) 
                        || cashReceipt.AcctSeed__Account__r.Name.startsWith('PVT'))){
                        
                        funding = new Transaction__c();                    
                        funding.Transaction_Date__c = cashReceipt.AcctSeed__Receipt_Date__c;
                        
                        //Added By Dhinesh - 18/09/2020 - W-005838 - Automatically creating funding records in the Project
                        if(cashReceipt.AcctSeed__Account__c != null && accIdWithAccRecMap.get(cashReceipt.AcctSeed__Account__c) != null && accIdWithAccRecMap.get(cashReceipt.AcctSeed__Account__c).contacts.size() > 0){
                            funding.Customer_Name__c = accIdWithAccRecMap.get(cashReceipt.AcctSeed__Account__c).contacts[0].id;
                        }
                        
                        //Changes made by Dhinesh - 11/11/2020 - W-006032 - Changed the reference of cash receipt's AcctSeed__Payment_Reference__c from Funding Auth_last_4_digits__c to Transaction_Notes__c                    
                        funding.Transaction_Notes__c = cashReceipt.AcctSeed__Payment_Reference__c;
                        funding.Method_of_Payment__c = 'CC';
                        
                        funding.Type__c = 'Payment';
                        
                        Decimal totAmnt = 0;
                        Decimal totqty = 0;
                        Decimal totPrice = 0;            
                        String Key = billcashRec.AcctSeed__Cash_Receipt__c+'~'+billcashRec.AcctSeed__Billing__c;
                        
                        for(AcctSeed__Billing_Line__c billingLine : billingIdWithBillingLinesMap.get(billcashRec.AcctSeed__Billing__c)){
                            
                            OpportunityLineItem oli;
                            
                            if(oppLineItemIdWithRecMap.get(billingLine.AcctSeed__Opportunity_Product_Id__c) != null){
                                oli = oppLineItemIdWithRecMap.get(billingLine.AcctSeed__Opportunity_Product_Id__c);
                            }
                            
                            if(billingLine.AcctSeed__Billing__r.Project__c != null){
                                funding.Project__c = billingLine.AcctSeed__Billing__r.Project__c;
                            }
                            
                            if(billingLine.AcctSeed__Billing__r.AcctSeed__Opportunity__c != null){
                                funding.Opportunity__c = billingLine.AcctSeed__Billing__r.AcctSeed__Opportunity__c; 
                                if(billingLine.AcctSeed__Billing__r.Project__c == null) //Added By Dhinesh - 02/09/2021 - W-006997 - Fix Email sent for project payment after opp conversion
                                    oppIdSet.add(billingLine.AcctSeed__Billing__r.AcctSeed__Opportunity__c+'~'+billingLine.AcctSeed__Billing__r.CreatedById);
                            }
                            
                            if(!fundingItemToInsertMap.containsKey(key)){
                                fundingItemToInsertMap.put(key, new List<Payment_Item__c>());
                            }
                            fundingItemToInsertMap.get(key).add(
                                new Payment_Item__c(
                                    Project_Task__c = billingLine.AcctSeed__Project_Task__c,
                                    Product__c = billingLine.AcctSeed__Project_Task__c != null ? billingLine.AcctSeed__Project_Task__r.Product__c : (oli != null ? oli.Product2.Id : null),
                                    Rate_per_Quantity__c = billingLine.AcctSeed__Project_Task__c != null ? billingLine.AcctSeed__Project_Task__r.Rate__c : (oli != null ? oli.UnitPrice : null),
                                    Quantity__c = billingLine.AcctSeed__Hours_Units__c,
                                    Amount__c = billingLine.AcctSeed__Total__c,
                                    Opportunity_Product_Id__c = billingLine.AcctSeed__Opportunity_Product_Id__c
                                )
                            );
                            
                            totAmnt += billingLine.AcctSeed__Total__c != null ? billingLine.AcctSeed__Total__c : 0;
                            // Modified on Aug 02 2023 : W-007855 - Issue on the Funding quick view from Related List Quick Links
                            if((billingLine.AcctSeed__Project_Task__c != null && (billingLine.AcctSeed__Project_Task__r.Project_Task_Type__c == 'Language Training' || billingLine.AcctSeed__Project_Task__r.Project_Task_Type__c == 'Preparation time' || billingLine.AcctSeed__Project_Task__r.Project_Task_Type__c == 'Curriculum Development')) || (oli != null && (oli.Product2.Family == 'Language Training' || oli.Product2.Family == 'Curriculum Development'))){
                                totqty += (((billingLine.AcctSeed__Project_Task__c != null && billingLine.AcctSeed__Project_Task__r.Name != null && !billingLine.AcctSeed__Project_Task__r.Name.contains('Additional Stud')) || ( oli != null && !oli.Product2.Name.contains('Additional Stud'))) && billingLine.AcctSeed__Hours_Units__c != null) ? billingLine.AcctSeed__Hours_Units__c : 0;
                                // Modified on Sep 11 2023, W-007875 - System Duplicated the Hourly Rate Total on Funding Transaction Record of DODA Opportunity
                                // The hourly rate value should not be the sum of Unit Price/Rate 
                                if(totPrice > 0){
                                    totPrice += (billingLine.AcctSeed__Project_Task__c != null && (billingLine.AcctSeed__Project_Task__r.Project_Task_Type__c == 'Language Training' || billingLine.AcctSeed__Project_Task__r.Project_Task_Type__c == 'Curriculum Development') && billingLine.AcctSeed__Rate__c != null) ? billingLine.AcctSeed__Rate__c : ( oli != null && ((oli.Product2.Family == 'Language Training' || oli.Product2.Family == 'Curriculum Development')) && oli.UnitPrice != null ? oli.UnitPrice : 0);
                                }
                            }
                            
                            //Added By Dhinesh - 18/09/2020 - W-005838 - Automatically creating funding records in the Project
                            if(billingLine.AcctSeed__Billing__r.AcctSeed__Status__c != 'Posted'){
                                if(billingsToUpdate.get(billingLine.AcctSeed__Billing__c) == null){
                                    AcctSeed__Billing__c billingForUpdate = new AcctSeed__Billing__c(Id = billingLine.AcctSeed__Billing__c, AcctSeed__Date__c = cashReceipt.AcctSeed__Receipt_Date__c, AcctSeed__Due_Date2__c =  cashReceipt.AcctSeed__Receipt_Date__c, AcctSeed__Accounting_Period__c = cashReceipt.AcctSeed__Accounting_Period__c);
                                    billingsToUpdate.put(billingLine.AcctSeed__Billing__c, billingForUpdate);
                                    if(billingLine.AcctSeed__Billing__r.Project__c != null){
                                        billingsToPost.add(billingForUpdate);
                                    } 
                                }
                                billingLinesToUpdate.add(new AcctSeed__Billing_Line__c(Id = billingLine.Id, AcctSeed__Date__c = cashReceipt.AcctSeed__Receipt_Date__c));
                            }
                            
                            if(billingLine.AcctSeed__Billing__r.AcctSeed__Status__c == 'Posted' && billingLine.AcctSeed__Billing__r.AcctSeed__Opportunity__c != null && billingLine.AcctSeed__Billing__r.Project__c == null){
                                billingsToUnPostMap.put(billingLine.AcctSeed__Billing__c, new AcctSeed__Billing__c(Id = billingLine.AcctSeed__Billing__c));
                            }
                            
                            //Added By Dhinesh - 16/11/2020 - W-006035 - Update Project Task Record when Planned Hrs < Paid Hrs
                            newQty = 0;
                            if(billingLine.AcctSeed__Project_Task__c != null && billingLine.AcctSeed__Project_Task__r.Name.contains('Training')){
                                billingLine.AcctSeed__Project_Task__r.Total_Amount_Paid__c = billingLine.AcctSeed__Project_Task__r.Total_Amount_Paid__c != null ? billingLine.AcctSeed__Project_Task__r.Total_Amount_Paid__c : 0; 
                                newQty = billingLine.AcctSeed__Project_Task__r.Rate__c > 0 ? (billingLine.AcctSeed__Project_Task__r.Total_Amount_Paid__c/billingLine.AcctSeed__Project_Task__r.Rate__c) + (billingLine.AcctSeed__Total__c/billingLine.AcctSeed__Project_Task__r.Rate__c) : 0;
                                
                                if(newQty > billingLine.AcctSeed__Project_Task__r.Total_Qty_Planned__c){
                                    updateProjTaskRecs.add(new AcctSeed__Project_Task__c(Id = billingLine.AcctSeed__Project_Task__c,Total_Qty_Planned__c = newQty.setscale(2)));
                                }
                            }
                        }
                        
                        funding.Hours_Paid__c = totqty;
                        funding.Hourly_Rate__c = totPrice;
                        
                        fundingToInsertMap.put(key, funding);    
                    }
                }
                
                if(fundingToInsertMap.values().size() > 0){
                    
                    insert fundingToInsertMap.values();
                    
                    List<Payment_Item__c> fundingItemToInsert = new List<Payment_Item__c>();
                    for(String key : fundingToInsertMap.keySet()){
                        for(Payment_Item__c pi : fundingItemToInsertMap.get(key)){
                            pi.Payment__c = fundingToInsertMap.get(key).Id;
                            fundingItemToInsert.add(pi);
                        }
                    }
                    
                    if(fundingItemToInsert.size() > 0){
                        insert fundingItemToInsert;
                    }
                    
                    //Added By Dhinesh - 18/09/2020 - W-005838 - Automatically creating funding records in the Project
                    if(billingsToUpdate.size() > 0 && billingLinesToUpdate.size() > 0){
                        update billingsToUpdate.values();
                        update billingLinesToUpdate;
                        
                        AcctSeed.PostResult[] postResults = AcctSeed.BillingPostService.postBillings(billingsToPost);
                    }
                    
                    //Added By Dhinesh - 16/11/2020 - W-006035 - Update Project Task Record when Planned Hrs < Paid Hrs
                    if(updateProjTaskRecs.size() > 0){
                        update updateProjTaskRecs;
                    }
                    
                    if(oppIdSet.size() > 0){
                        for(String oppIdAndUserId : oppIdSet){
                            sendMailForPrepaymentInvoice(oppIdAndUserId);
                        }
                    }
                    
                    if(billingsToUnPostMap.size() > 0){
                        AcctSeed.PostResult[] unpostResults = AcctSeed.BillingPostService.unpostBillings(billingsToUnPostMap.values());                    
                    }
                }
            }
        }catch(Exception exe){
            ErrorHandler.publishErrorLog(new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('BillingCashReceiptTriggerHandler','createFundingAndFundingItems','',exe.getMessage()+' at line number '+exe.getLineNumber(),JSON.serialize(newBillingCashReceipts),'Trigger')});
        }     
    }
    
    public static void sendMailForPrepaymentInvoice(String oppIdAndUserId){
        
        Set<Id> userIds = new Set<Id>();//CommonUtil.fetchUserIdsOfPublicGroup('Registrar'); 
        Id oppId = oppIdAndUserId.split('~')[0];
        String userId = oppIdAndUserId.split('~')[1];
        userIds.add(userId);       
        List<EmailTemplate> emailTemp = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Funding_created_for_Prepayment_Invoice']; 
        
        List<String> toMailAddress = new List<String>();
        
        for(User usr : [SELECT Id, FirstName, LastName, Email FROM User WHERE Id IN :userIds]){
            toMailAddress.add(usr.Email);
        }
        List<Id> contactIds = PlannedDaysOffHandler.getUserRelatedContacts(userIds).values();
        if(contactIds.size() > 0){
            Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
            
            message.setTargetObjectId(contactIds[0]); 
            message.setSenderDisplayName(UserInfo.getName());        
            message.setTemplateID(emailTemp[0].Id); 
            message.setWhatId(oppId); //This is important for the merge fields in template to work
            message.toAddresses = toMailAddress;
            
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
    
    //Added By Dhinesh - W-006606 - To provide project task ids to populateProjTaskRollupfieldsInFuture to populate Total_Amount_Paid_Billing_Line__c, Most_Recent_Payment_Received_Date_Bill__c  - Fields in related Project Tasks once the payments are done
    public static void populateProjTaskRollupFields(List<AcctSeed__Billing_Cash_Receipt__c> newBillingCashReceipts){
        Set<Id> billingIds = new Set<Id>();
        Set<Id> cashReceiptIds = new Set<Id>();
        Set<Id> projTasksIds = new Set<Id>();
        
        for(AcctSeed__Billing_Cash_Receipt__c billcashRec: newBillingCashReceipts){
            cashReceiptIds.add(billcashRec.AcctSeed__Cash_Receipt__c);
        }
        
        Map<Id, AcctSeed__Cash_Receipt__c> cashReceiptIdWithRecMap = new Map<Id, AcctSeed__Cash_Receipt__c>(AcctSeedCashReceiptService.getAcctSeedCashReceiptsByIds('AND Contract__c = null','',cashReceiptIds));
        
        for(AcctSeed__Billing_Cash_Receipt__c billcashRec: newBillingCashReceipts){
            if(cashReceiptIdWithRecMap.containsKey(billcashRec.AcctSeed__Cash_Receipt__c)){
                billingIds.add(billcashRec.AcctSeed__Billing__c);
            }
        }
        
        if(billingIds.size() > 0){
            
            for(AcctSeed__Billing_Line__c billingLine : BillingLineService.getBillLineByParentIds(' WHERE AcctSeed__Billing__c','',billingIds)){
                
                if(billingLine.AcctSeed__Project_Task__c != null){
                    projTasksIds.add(billingLine.AcctSeed__Project_Task__c);
                }
            }
            
            if(projTasksIds.size() > 0){
                if(!System.isFuture() && !System.isBatch()){
                    populateProjTaskRollupfieldsInFuture(projTasksIds);
                }else{
                    populateProjTaskRollupfieldsValues(projTasksIds);
                }
            }
        }
    }
    
    //Added By Dhinesh - W-006606 - To populate Total_Amount_Paid_Billing_Line__c, Most_Recent_Payment_Received_Date_Bill__c  - Fields in related Project Tasks once the payments are done
    //Called from BillingCashReceiptTriggerHandler - Project Funding and BillingLineTriggerHandler - Prepayment Funding on convert to project
    @future
    public static void populateProjTaskRollupfieldsInFuture(Set<Id> projTasksIds){
        populateProjTaskRollupfieldsValues(projTasksIds);
    }
    
    // Added on Nov 11 2023
    // W-007922 : CR Code Review and Feedback from Accounting Seed
    public static void populateProjTaskRollupfieldsValues(Set<Id> projTasksIds){
        
        Map<String, AcctSeed__Project_Task__c> projTasksToUpdate = new Map<String, AcctSeed__Project_Task__c>();
        AggregateResult[] groupedResults = [SELECT AcctSeed__Project_Task__c, SUM(AcctSeed__Total__c) TotalAmountPaid //, MAX(AcctSeed__Date__c) mostRecentPaymentReceivedDate  
                                            FROM AcctSeed__Billing_Line__c
                                            WHERE AcctSeed__Project_Task__c IN :projTasksIds 
                                            AND AcctSeed__Billing__c IN (SELECT AcctSeed__Billing__c FROM AcctSeed__Billing_Cash_Receipt__c)
                                            GROUP BY AcctSeed__Project_Task__c];
        
        for (AggregateResult ar : groupedResults)  {
            
            projTasksToUpdate.put(String.valueOf(ar.get('AcctSeed__Project_Task__c')), new AcctSeed__Project_Task__c(Id = String.valueOf(ar.get('AcctSeed__Project_Task__c')), Total_Amount_Paid_Billing_Line__c = (Decimal)ar.get('TotalAmountPaid'))); //Most_Recent_Payment_Received_Date_Bill__c = (Date)ar.get('mostRecentPaymentReceivedDate')
        } 
        
        Map<Id, List<Id>> projectTaskIdWithBillingsIdsMap = new Map<Id, List<Id>>();
        Set<Id> billingIds = new Set<Id>();
        for(AcctSeed__Billing_Line__c bl : [SELECT AcctSeed__Project_Task__c, AcctSeed__Billing__c
                                            FROM AcctSeed__Billing_Line__c
                                            WHERE AcctSeed__Project_Task__c IN :projTasksIds AND AcctSeed__Billing__c IN (SELECT AcctSeed__Billing__c FROM AcctSeed__Billing_Cash_Receipt__c)]){
            if(!projectTaskIdWithBillingsIdsMap.containsKey(bl.AcctSeed__Project_Task__c))                                   
                projectTaskIdWithBillingsIdsMap.put(bl.AcctSeed__Project_Task__c, new List<Id>());
            
            projectTaskIdWithBillingsIdsMap.get(bl.AcctSeed__Project_Task__c).add(bl.AcctSeed__Billing__c); 
            billingIds.add(bl.AcctSeed__Billing__c);
        }
        
        Map<Id, Date> billingIdWithMostRecentPaymentReceivedDateMap = new Map<Id, Date>();
        for(AcctSeed__Billing_Cash_Receipt__c bcr : [SELECT Id, AcctSeed__Cash_Receipt__r.AcctSeed__Receipt_Date__c, AcctSeed__Billing__c 
                                                     FROM AcctSeed__Billing_Cash_Receipt__c 
                                                     WHERE AcctSeed__Billing__c IN :billingIds]){
                                                         
            if(!billingIdWithMostRecentPaymentReceivedDateMap.containsKey(bcr.AcctSeed__Billing__c) || billingIdWithMostRecentPaymentReceivedDateMap.get(bcr.AcctSeed__Billing__c) < bcr.AcctSeed__Cash_Receipt__r.AcctSeed__Receipt_Date__c)
                billingIdWithMostRecentPaymentReceivedDateMap.put(bcr.AcctSeed__Billing__c, bcr.AcctSeed__Cash_Receipt__r.AcctSeed__Receipt_Date__c);    
        }
        
        for(Id projTaskId : projectTaskIdWithBillingsIdsMap.keyset()){
            Date mostRecentPaymentReceivedDate;
            for(Id billingId : projectTaskIdWithBillingsIdsMap.get(projTaskId)){
                if(billingIdWithMostRecentPaymentReceivedDateMap.containsKey(billingId) && (mostRecentPaymentReceivedDate == null || mostRecentPaymentReceivedDate < billingIdWithMostRecentPaymentReceivedDateMap.get(billingId))){
                    mostRecentPaymentReceivedDate = billingIdWithMostRecentPaymentReceivedDateMap.get(billingId);
                }
            }
            AcctSeed__Project_Task__c projTask = projTasksToUpdate.get(projTaskId);
            projTask.Most_Recent_Payment_Received_Date_Bill__c = mostRecentPaymentReceivedDate;
            projTasksToUpdate.put(projTaskId, projTask);
        }
        
        if(projTasksToUpdate.size() > 0){
            update projTasksToUpdate.values();
        }
    }
}