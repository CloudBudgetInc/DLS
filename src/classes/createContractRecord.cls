/**********************************************************************
    Created by Karthiga on Feb 03, 2017: Class called from "Create Contract" Button in Opportunity
***********************************************************************/
global class createContractRecord {
    
    @AuraEnabled
    webservice static Id createContractRec(Id oppId) { 
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = SObjectQueryService.SObjectQuery('Opportunity',new Set<Id>{oppId},'');
        
        if(oppList != null && oppList.size() > 0 ) {
            Contract c = new Contract();
            c.AccountId = oppList[0].AccountId;
            c.StartDate = oppList[0].Start_Date__c;
            c.EndDate = oppList[0].End_Date__c;
            c.Contract_Amount__c = oppList[0].Amount;
            c.Value__c = oppList[0].Contract_Value__c;
            c.Name = oppList[0].Name;
            c.Estimated_Revenue_Current_Year__c = oppList[0].Estimated_Revenue_Current_Year__c;
            c.Estimated_Revenue_Following_Year__c = oppList[0].Estimated_Revenue_Following_Year__c;
            c.Estimated_Revenue_Next_Year__c = oppList[0].Estimated_Revenue_Next_Year__c;
            c.Set_Aside_Award_Type_s__c = oppList[0].Set_Aside__c; // Added by GRK on May 23, 2018 #tasks/17293774
            
            Insert c;
            return c.Id;
        }
        return null;
      
    }
    
    // Launched from "Add All Product" button in Opportunity Detail page.
    // Currently only for DODA Opportunities
    @AuraEnabled
    webservice static String createOPLIRecord(Id oppId) { 
        try {
            List<Opportunity> oppList = new List<Opportunity>();
            oppList = SObjectQueryService.SObjectQuery('Opportunity',new Set<Id>{oppId},',RecordType.DeveloperName,Language_LU__r.Name, Account.Name');
            List<OpportunityLineItem> oplis = OpportunityLineItemService.getOPLIByOppId(new Set<Id>{oppId}, '', '');
            List<OpportunityLineItem> opliToInsert = new List<OpportunityLineItem>();
            List<Program_Iteration__c> iterationList = new List<Program_Iteration__c>();
            List<Contact_Assignments__c> students = new List<Contact_Assignments__c>();
            
            // Added on July 20 2022
            // W-007528: Add All Products Button Not Accurately Creating Products on DODA Opp
            Map<String, String>  languageNameAndProductName = new Map<String, String>{
                'Albanian - Gheg' => 'Albanian', 'Albanian - Tosk' => 'Albanian', 'Arabic - Algerian' => 'Arabic (MSA and all dialects)',
                'Arabic - Egyptian' => 'Arabic (MSA and all dialects)', 'Arabic - Gulf' => 'Arabic (MSA and all dialects)', 'Arabic - Iraqi' => 'Arabic (MSA and all dialects)',
                'Arabic - Levantine' => 'Arabic (MSA and all dialects)', 'Arabic - Libyan' => 'Arabic (MSA and all dialects)', 'Arabic - Maghrebi' => 'Arabic (MSA and all dialects)',
                'Arabic - Mauritanian' => 'Arabic (MSA and all dialects)', 'Arabic - Moroccan' => 'Arabic (MSA and all dialects)', 'Arabic - MSA' => 'Arabic (MSA and all dialects)',
                'Arabic - Omani' => 'Arabic (MSA and all dialects)', 'Arabic - Saudi' => 'Arabic (MSA and all dialects)', 'Arabic - Sudanese' => 'Arabic (MSA and all dialects)',
                'Arabic - Tunisian' => 'Arabic (MSA and all dialects)', 'Arabic - Yemeni' => 'Arabic (MSA and all dialects)', 'Azeri (Azerbaijani)' => 'Azerbaijani',
                'Chinese - Cantonese' => 'Chinese (Cantonese)', 'Chinese - Mandarin' => 'Chinese (Mandarin)', 'Dari & Pashto' => 'Pashto',
                'Kurdish - Kurmanji' => 'Kurdish', 'Kurdish - Sorani' => 'Kurdish', 'Pashto - Pakistani' => 'Pashto', 'Portuguese - Brazilian' => 'Portuguese (all dialects)',
                'Portuguese - Continental' => 'Portuguese (all dialects)',  'Spanish - Equatoguinean' => 'Spanish', 'Spanish - Latin American' => 'Spanish'
            };
            
            if(!oppList.IsEmpty() && oppList[0].RecordType.DeveloperName == 'ODNI_CLP_Opportunities') {
            // Doda Record Type Condition need to be added
                if( oppList[0].Program_Iteration__c != null ) {
                    iterationList = ProgramIterationService.getIterationRec( ' WHERE Id = \'' + oppList[0].Program_Iteration__c +'\'','RecordType.DeveloperName');
                    students = ContactAssignmentService.getContactassignmentByparentIds( new Set<Id>{oppList[0].Id}, new Set<String>(), new Set<String>{'Student'}, '');
                    Decimal matPrice;
                    
                    if(iterationList[0].RecordType.DeveloperName == 'AFPAK_Cohort') {
                        matPrice = 1500;
                    } else {
                        if(oppList[0].Project_Type__c == 'JMAS' || oppList[0].Project_Type__c == 'IND') {
                            if(iterationList[0].Total_LT_Class_Hours__c > 61) 
                                matPrice = 200; 
                            else if( iterationList[0].Total_LT_Class_Hours__c > 41 && iterationList[0].Total_LT_Class_Hours__c < 61 )
                                matPrice = 150;
                            else if (iterationList[0].Total_LT_Class_Hours__c > 0 && iterationList[0].Total_LT_Class_Hours__c < 40) 
                                matPrice = 100;
                        } else if ( oppList[0].Project_Type__c == 'SLP-FT' || oppList[0].Project_Type__c == 'SLP-PT') {
                            matPrice = 299;
                        }
                    }
                    
                    if(!students.IsEmpty()) {
                        if(oplis.IsEmpty()) {
                            if( oppList[0].Language_LU__c != null && !iterationList.isEmpty() ) { 
                                for( PriceBookEntry pbe : [SELECT Id,Name,Pricebook2Id,UnitPrice,Product2Id,Product2.Name,Product2.Language_LU__c, Product2.Language_LU__r.Name, Product2.Family FROM PriceBookEntry WHERE Pricebook2.Name = 'DODA Price Book' AND IsActive = True]) {
                                    // To insert the Language Training related Product 
                                    if(pbe.Product2.Name == 'Language Training- ' + oppList[0].Language_LU__r.Name || (languageNameAndProductName.containsKey(oppList[0].Language_LU__r.Name) && 
                                        pbe.Product2.Name == 'Language Training- ' + languageNameAndProductName.get(oppList[0].Language_LU__r.Name))) {
                                        OpportunityLineItem opli = new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = pbe.Id, Product2Id = pbe.Product2Id, Quantity = (iterationList[0].Total_LT_Class_Hours__c != null ? iterationList[0].Total_LT_Class_Hours__c : 0), UnitPrice = pbe.UnitPrice, Language__c = oppList[0].Language_LU__c);
                                        opliToInsert.add(opli);
                                        
                                    } else if(pbe.Product2.Name == 'Language Training- Preparation' && (iterationList[0].RecordType.DeveloperName == 'SLP_Iteration' || iterationList[0].RecordType.DeveloperName == 'PLP_Iteration')) {
                                        OpportunityLineItem opli = new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = pbe.Id, Product2Id = pbe.Product2Id, Quantity = (iterationList[0].Total_LT_Prep_Hours__c != null ? iterationList[0].Total_LT_Prep_Hours__c : 0), UnitPrice = pbe.UnitPrice, Language__c = oppList[0].Language_LU__c);
                                        opliToInsert.add(opli);
                                        
                                    } else if (pbe.Product2.Name == 'Language Materials'){
                                        OpportunityLineItem opli = new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = pbe.Id, Product2Id = pbe.Product2Id, Quantity = students.size(), UnitPrice = pbe.UnitPrice, Language__c = oppList[0].Language_LU__c);
                                        opliToInsert.add(opli);
                                    }
                                }
                                System.debug('opliToInsert:::'+opliToInsert);
                                if(!opliToInsert.IsEmpty()) {
                                    Insert opliToInsert;
                                }
                            } else {
                                return 'Error - Please select a Langauge';
                            }
                        } else {
                            return 'Error - Already there is a Product'; // Need to add Popup message.
                        }
                    } else {
                        return 'Error - Please add student contact assignments before adding Products';
                    }
                } else {
                    return 'Error - Please select a Iteration Program'; 
                }
            } else {
                return 'Error - OPLI only can be created for DODA Opportunities';
            }
            return 'Success';    
        } catch(Exception ex) {
            return ex.getMessage();
        }
    }
    
    // Launced from "Contract Funding" button in Opportunity Detail Page.
    // Only for DODA Opportunities and DLI-W TO Opportunities
    @AuraEnabled
    webservice static String createFundingRecord(Id oppId) {
        
        List<Opportunity> oppList = SObjectQueryService.SObjectQuery('Opportunity',new Set<Id>{oppId},',RecordType.DeveloperName');
        List<OpportunityLineItem> oplis = OpportunityLineItemService.getOPLIByOppId(new Set<Id>{oppId}, '', '');
        List<Transaction__c> fundings;
        List<Payment_Item__c> payItems = new List<Payment_Item__c>();
        Decimal hours = 0;
        
        if(!oppList.IsEmpty() && ( oppList[0].RecordType.DeveloperName == 'DLI_W_TO_Opportunities' || oppList[0].RecordType.DeveloperName == 'ODNI_CLP_Opportunities')) {
            fundings = FundingService.getTransactionsAndAttachmentByOpportunityId(new Set<Id>{oppList[0].Id});
            if(fundings.IsEmpty() ) {
                if( !oplis.IsEmpty() ) {
                
                    for( OpportunityLineItem op : oplis ) {
                        Payment_Item__c pay = new Payment_Item__c(Opportunity_Product_Id__c = op.Id, Product__c = op.Product2Id, Quantity__c = op.Quantity, Rate_per_Quantity__c = op.UnitPrice, Amount__c = op.Quantity * op.UnitPrice); 
                        payItems.add(pay);
                        if(op.Product_Family__c == 'Language Training' || op.Product_Family__c == 'Preparation time')
                            hours += op.Quantity;
                    }
                    
                    Transaction__c funding = new Transaction__c(Transaction_Date__c = System.Today(), Type__c = 'Authorization/PO', Method_of_Payment__c = 'TO Award', Hours_Paid__c = hours, Opportunity__c = oppList[0].Id);
                    if(!payItems.IsEmpty()) {
                        Insert funding;
                        for(Payment_Item__c pay : payItems) {
                            pay.Payment__c = funding.Id;
                        }
                        Insert payItems;
                    }
                } else {
                    return 'Error - Please create Product under Opportunity';
                }
            } else {
                return 'Error - Already we have funding record';
            }
        } else {
            return 'Error - Funding only can be created for DODA Opportunities and DLI-W TO Opportunities';
        }
        return 'Success';
    }
}