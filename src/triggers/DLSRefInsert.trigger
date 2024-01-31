trigger DLSRefInsert on Opportunity (before insert, before update) {
      
    ID rtId, newOppRt, dodaRT;  
    String contId;
    
    Set<String> oppRTNames = new Set<String>{'Testing_Opportunities','CD_Opportunities','MTT_Opportunities','Translation_Opportunities','Interpretation_Opportunities'};
    
    // Variables to populate Default Cost Rate Rate Type
    Set<String> oppRTNamesForDCRRTPopulation = new Set<String>{'CD_Opportunities','New_Classes_Opportunities','Partner_School','FBI_WO','ESL_LT_Opportunities','EFL_Opportunities','Interpretation_Opportunities','MTT_Opportunities','Testing_Opportunities','DLI_W_TO_Opportunities','ODNI_CLP_Opportunities','FSI_Opportunities'};
    Set<Id> oppRTIdsForDCRRTPopulation = new Set<Id>();
    Set<String> rtNamesForLTRT = new Set<String>{'New_Classes_Opportunities','Partner_School','FBI_WO','ESL_LT_Opportunities'};
    Set<Id> rtIdsForLTRT = new Set<Id>();
    Date enrollment_Date = Date.newinstance(2020, 10, 1);    
    Id DLI_W_PS_Group_3_ContractId;   
    Id DLI_W_PS_Group_4_ContractId;    
    System_Values__c dLI_W_PS_Group3 = System_Values__c.getValues('DLI-W PS - Group 3_ContractId');
    if(dLI_W_PS_Group3 != NULL && dLI_W_PS_Group3.Value__c != NULL){
        DLI_W_PS_Group_3_ContractId = dLI_W_PS_Group3.Value__c;
    }
    System_Values__c dLI_W_PS_Group4 = System_Values__c.getValues('DLI-W PS - Group 4_ContractId');
    if(dLI_W_PS_Group4 != NULL && dLI_W_PS_Group4.Value__c != NULL){
        DLI_W_PS_Group_4_ContractId = dLI_W_PS_Group4.Value__c;
    }
    
    Set<Id> oppRTIds = new Set<Id>();
    Map<String,Id> oppRecTypeMapTemp = new Map<String,Id>();
    Map<Id, Account> accIdaccMap = new Map<Id, Account>();
    //Set<Id> accId = new Set<Id>();
    Set<Id> pbId = new Set<Id>();
    String PVTacc;
    List<Opportunity> oppRecs = new List<Opportunity>();
    
    System_Values__c QB_sysVal = System_Values__c.getValues('Opp QB type - COMM:INDV Acct');
    if(QB_sysVal != null && QB_sysVal.Value__c != null)
        PVTacc = QB_sysVal.Value__c;
    
    OpportunityTrigger_Handler oTH = new OpportunityTrigger_Handler();
    Map<Id,PriceBook2> pbIds = new Map<Id,PriceBook2>();
    PriceBook2 GSALTPB = new PriceBook2();
    PriceBook2 GSATransPB = new PriceBook2();
    
    
    Map<String, Map<String,String>> defaultValMap = new Map<String,Map<String,String>>();
    if(OpportunityTrigger_Handler.loadResource == false) {
        OpportunityTrigger_Handler.loadResource = true;
        OpportunityTrigger_Handler.getSobjectMasterRecord();
        OpportunityTrigger_Handler.getProgramIteration();
        OpportunityTrigger_Handler.getPriceBook();
    }
    
    if( OpportunityTrigger_Handler.oppRecTypeMap != null && OpportunityTrigger_Handler.oppRecTypeMap.size() > 0 ) {
        oppRecTypeMapTemp = OpportunityTrigger_Handler.oppRecTypeMap;        
    } else {
        oTH.getRecordTypeMap();
        oppRecTypeMapTemp = OpportunityTrigger_Handler.oppRecTypeMap;
    }
    
    if( oppRecTypeMapTemp != null && oppRecTypeMapTemp.size() > 0 ) {
        for(String s : oppRecTypeMapTemp.keyset()) {
            if(s == 'DLI_W_TO_Opportunities' && oppRecTypeMapTemp.containskey(s)) {
                rtId = oppRecTypeMapTemp.get(s);  
            } else if(oppRTNames.contains(s)) {
                oppRTIds.add(oppRecTypeMapTemp.get(s));
            } 
            
            if(oppRecTypeMapTemp.containskey(s) && s == 'New_Classes_Opportunities') {
                newOppRt = oppRecTypeMapTemp.get(s);
            }
            
            if(oppRTNamesForDCRRTPopulation.contains(s)){
            
                oppRTIdsForDCRRTPopulation.add(oppRecTypeMapTemp.get(s));
                if(rtNamesForLTRT.contains(s)){
                    rtIdsForLTRT.add(oppRecTypeMapTemp.get(s));
                }
            }
        }
        dodaRT = oppRecTypeMapTemp.containskey('ODNI_CLP_Opportunities') ? oppRecTypeMapTemp.get('ODNI_CLP_Opportunities') : null;
    }
    
    System_Values__c sysVal = System_Values__c.getValues('DLI-W TO Opportunity ContractID');
     
    if(sysVal != null && sysVal.Value__c != null) {
        contId = sysVal.Value__c;
    }
    
    // Variables to populate DCRRT for DODA Opportunities
    Set<Id> programIterationIds = new Set<Id>();
    Map<Id, Program_Iteration__c> programIterationMap = new Map<Id, Program_Iteration__c>();
    Set<String> projectTypes = new Set<String>{'SLP-PT', 'SLP-FT', 'IND', 'PLP'};
    
    if(Trigger.isInsert && Trigger.isBefore) {
        Map<String, Integer> countMap = oTH.getHighestNoForDLSClass(false, true, false, false, false);  
        Integer count = (countMap != null && countMap.size() > 0 && countMap.containsKey('otherRecCount')) ? countMap.get('otherRecCount') : 0;     
        
        for (Opportunity op: Trigger.new) {
            
            Boolean populateDlsClassName = true;
            
            // rtId - DLI_W_TO_Opportunities Record Type Id
            if(oppRTIds.contains(op.RecordTypeId) || (op.RecordTypeId == rtId && (op.Project_Type__c == 'HUB' || op.Project_Type__c == 'Overseas MTT' || op.Project_Type__c == 'CD'))) {
                populateDlsClassName = false;
            } 
            
            if(populateDlsClassName) {
            
                count = count +1;
                Integer Year = Date.Today().Year();
                String str1 = String.valueof(Year).substring(2,4);
                integer n= count,i;
                for(i=0;n!=0;i++){
                   n=n/10;
                }
                String sizeList;
                if(i <=5 && i >= 1) {
                    if(i == 1) sizeList = '0000'+String.ValueOf(count);
                    if(i == 2) sizeList = '000'+String.ValueOf(count);
                    if(i == 3) sizeList = '00'+String.ValueOf(count);
                    if(i == 4) sizeList = '0'+String.ValueOf(count);
                }
                String refValue = str1 + sizeList;
                
                op.DLS_Class__c = refValue ;
            }
            
            // It's default field update only for "DLI_W_TO_Opportunities" Record Type.        
            if(rtId == op.RecordTypeId && op.ContractId == null) {
                op.ContractId = contId; 
            }
        }
    }
    
    // Added on Oct 25 2023
    // W-007913 - Change LCR Names and Default Cost Rate Rate Type on Opportunity- (OCT-27-2023)
    // For DODA Opportunities we have to consider Program Iteration's project type., So that this logic added here
    if(Trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate){
            for(Opportunity opp : Trigger.new){
                if(opp.RecordTypeId == dodaRT && opp.Program_Iteration__c != null && (Trigger.IsInsert || (Trigger.isUpdate && (opp.RecordTypeId != Trigger.oldMap.get(opp.Id).RecordTypeId || 
                    opp.Classification__c != Trigger.oldMap.get(opp.Id).Classification__c || opp.Program_Iteration__c != Trigger.oldMap.get(opp.Id).Program_Iteration__c)))){
                    programIterationIds.add(opp.Program_Iteration__c);                    
                }
            }
        }
        if(!programIterationIds.isEmpty()){
            programIterationMap = new Map<Id, Program_Iteration__c>([SELECT Id, Project_Type__c FROM Program_Iteration__c WHERE Id IN : programIterationIds]);
        }
    }
    System.debug(':::::programIterationMap::::'+programIterationMap);
        
    //Added by Vinitha On June 14,2017       
    //Below process only for DLI_W_TO_Opportunities record type.
    Id contrId, eltContrId, eltIIIAccId;
    if(Trigger.isBefore && ( Trigger.isInsert || Trigger.isUpdate)) { 
        /*for (Opportunity op: Trigger.new) {
            if(rtId == op.RecordTypeId) {
                if(op.Project_Type__c == 'Resident LT') {
                    op.Default_Cost_Rate_Rate_Type__c = 'DLI-16 SCA LT';
                } else if(op.Project_Type__c == 'MTT' || op.Project_Type__c == 'Hub') {
                    op.Default_Cost_Rate_Rate_Type__c = 'DLI-16 SCA MTT';
                } else if(op.Project_Type__c == 'CD') {
                    op.Default_Cost_Rate_Rate_Type__c = 'DLI-16 SCA CD';
                } 
                //Commented Since the logic is moved to the Process Builder
            }
            accId.add(op.AccountId);
        }*/
        
        //Below process only to auto-update QB_Contract_Type__c based on Account Name, Account RecordType and PriceBook
        
        System_Values__c ctrName = System_Values__c.getValues('QB Contract - FED/STATE GSA');
        System_Values__c ctrNumber = System_Values__c.getValues('ELT III Account - Contract');
        System_Values__c eltIIIAccName = System_Values__c.getValues('ELT III AccountId');
        
        // By GRK on 27/06/2018 to defaultly populate the field values on creation for DODA Opp
        for( Sobject_Master_Field_Mapping__c fm : OpportunityTrigger_Handler.masterMap) {
            if(!defaultValMap.containskey(fm.RecordType_Name__c)) {
                defaultValMap.put(fm.RecordType_Name__c, new Map<String,String>{fm.Field_Name__c => fm.Default_Field_Value__c});
            } else {
                defaultValMap.get(fm.RecordType_Name__c).put(fm.Field_Name__c,fm.Default_Field_Value__c);
            }
        }
        
        // For the Program Iteration record 
        Map<Id, Program_Iteration__c> iterationMap = new Map<Id, Program_Iteration__c>(OpportunityTrigger_Handler.piList);
        
        if(ctrName != null && ctrNumber != null && eltIIIAccName != null) {
            for(Contract ct : [SELECT Id, Name, ContractNumber FROM Contract WHERE Name = :ctrName.Value__c OR ContractNumber = :ctrNumber.Value__c]) {
                if(ctrName.Value__c == ct.Name)
                    contrId = ct.Id;
                else if(ctrNumber.Value__c == ct.ContractNumber)
                    eltContrId = ct.Id;
            }
            for(Account acc : [SELECT Id, Name FROM Account WHERE Name = :eltIIIAccName.Value__c]) {
                eltIIIAccId = acc.Id;
            }
            
        }
        
        for(PriceBook2 pb : OpportunityTrigger_Handler.pbs) {
            pbIds.put(pb.Id, pb);
            if(pb.Name == 'GSA Language Training Price Book') {
                GSALTPB = pb;
            } else if(pb.Name == 'GSA Translation Price Book') {
                GSATransPB = pb;
            }
            if(pb.Name == 'GSA Language Training Price Book' || pb.Name == 'GSA Translation Price Book' || pb.Name == 'DODA Price Book') {
                pbId.add(pb.Id);
            }
        }    
        System.debug(':::pbId:'+pbId);   
                
        for (Opportunity opp: Trigger.new) {
        
            if( opp.RecordTypeId == dodaRT ){
                // By GRK on 27/06/2018 to defaultly populate the field values on creation for DODA Opp
                
                if( trigger.isInsert && defaultValMap.containskey('ODNI_CLP_Opportunities')) {
                    Map<String,String> tempMap = defaultValMap.get('ODNI_CLP_Opportunities');
                    
                    if(tempMap != null) {
                        opp.Agency_Contact__c = ( opp.Agency_Contact__c == null && tempMap.containskey('Agency_Contact__c')) ? tempMap.get('Agency_Contact__c') : opp.Agency_Contact__c;
                        opp.A_R_Type__c = ( opp.A_R_Type__c == null && tempMap.containskey('A_R_Type__c')) ? tempMap.get('A_R_Type__c') : opp.A_R_Type__c;
                        opp.ContractId = ( opp.ContractId == null && tempMap.containskey('ContractId')) ? tempMap.get('ContractId') : opp.ContractId;
                        opp.Order__c = ( opp.Order__c == null && tempMap.containskey('Order__c')) ? tempMap.get('Order__c') : opp.Order__c;
                        opp.QB_Contract_Type__c = 'FED:GSA';
                    }
                }
                
                // BY GRK on 19/07/2018, Based on the Iterations selected, populate the default values from the Iteration record to the Opportunity record for DODA
                if( ( ( trigger.isInsert && opp.Program_Iteration__c != null) || ( trigger.isUpdate && opp.Program_Iteration__c != null && Trigger.OldMap.get(opp.Id).Program_Iteration__c != opp.Program_Iteration__c) ) && iterationMap.containskey(opp.Program_Iteration__c)) {
                    Program_Iteration__c progIt = iterationMap.get(opp.Program_Iteration__c);
                    if(opp.Start_Date__c == null && progIt.Start_Date__c != null) opp.Start_Date__c = progIt.Start_Date__c;
                    if(opp.End_Date__c == null && progIt.End_Date__c != null) opp.End_Date__c = progIt.End_Date__c;
                    if(opp.Enrollment_Date__c == null && progIt.Enrollment_Date__c != null) opp.Enrollment_Date__c = progIt.Enrollment_Date__c;
                    if(opp.Hours_Week__c == null && progIt.Hours_Week__c != null) opp.Hours_Week__c = progIt.Hours_Week__c;
                    if(opp.Program_Type__c == null && progIt.Program_Type__c != null) opp.Program_Type__c = progIt.Program_Type__c;
                    if(opp.Project_Type__c == null && progIt.Project_Type__c != null) opp.Project_Type__c = progIt.Project_Type__c;
                    if(opp.Hours__c == null && progIt.Total_Program_Hours__c != null) opp.Hours__c = progIt.Total_Program_Hours__c;                    
                    if(opp.Classification__c == null && progIt.Classification__c != null) opp.Classification__c = progIt.Classification__c;
                }
            }
            
            if(Trigger.isInsert || (Trigger.isUpdate && (Trigger.oldMap.get(opp.Id).AccountId != opp.AccountId ||
                Trigger.oldMap.get(opp.Id).Pricebook2Id != opp.Pricebook2Id))) {                
                        
                //Auto-update Opportunity.QB Contract Type to "COMM:INDV" if Opportunity.Account is "PVT" 
                if( opp.Acct_Name__c == PVTacc) {
                    if(opp.QB_Contract_Type__c == null)
                        opp.QB_Contract_Type__c = 'COMM:INDV';
                    
                    if(opp.A_R_Type__c == null)
                        opp.A_R_Type__c = '11005-Prepayment';
                        
                    if(opp.Order__c == null) 
                        opp.Order__c = 'PVT';
                   
                //Auto-update Opportunity.QB Contract Type to "COMM:ORG" if Opportunity.Account's Record Type is "Commercial Clients" and is any Account record other than: "PVT" 
                } else if(opp.Acct_Name__c != PVTacc && opp.Acct_Record_Type_Name__c == 'Commercial_Clients' && opp.QB_Contract_Type__c == null) {
                    opp.QB_Contract_Type__c = 'COMM:ORG';
                }
                
                System.debug('opp.Pricebook2Id::::'+opp.Pricebook2Id);
                System.debug('pbId ::::'+pbId);
                System.debug('opp.QB_Contract_Type__c:::'+opp.QB_Contract_Type__c);
                System.debug('opp.Acct_Record_Type_Name__c::::'+opp.Acct_Record_Type_Name__c);
                if(opp.Pricebook2Id != Null && pbId != Null && pbId.size() > 0 && opp.QB_Contract_Type__c == null) {
                    System.debug('Inside QB assign::::');
                    //Auto-update Opportunity.QB Contract Type to "FED:GSA" if Opportunity.Account's Record Type is "USG Clients"
                    // and Price Book used on Opportunity is GSA Language Training or Translation Price Book or DODA Price book
                                        
                    if(opp.Acct_Record_Type_Name__c == 'Accounts' && pbId.contains(opp.Pricebook2Id)){
                        opp.QB_Contract_Type__c = 'FED:GSA';
                    
                    //Auto-update Opportunity.QB Contract Type to "FED:nonGSA" if Opportunity.Account's Record Type is "USG Clients"
                    //and Price Book used on Opportunity is not GSA Language Training or Translation Price Book
                    
                    } else if(opp.Acct_Record_Type_Name__c == 'Accounts' && !pbId.contains(opp.Pricebook2Id)){
                        opp.QB_Contract_Type__c = 'FED:nonGSA';
                    }
                } 
            } 
            
            // To Populate the Min Education and Experience values from the related Pricebooks - by GRK (03/04/2018)
            if(opp.Pricebook2Id != null && ( trigger.isInsert || (trigger.isUpdate && trigger.OldMap.get(opp.Id).Pricebook2Id != opp.Pricebook2Id))) {
                
                if(pbIds.containskey(opp.Pricebook2Id)) {
                    opp.Min_Education__c = pbIds.get(opp.Pricebook2Id).Min_Education__c;
                    opp.Min_Experience__c = pbIds.get(opp.Pricebook2Id).Min_Experience__c;
                    
                    if(pbIds.get(opp.Pricebook2Id).Name.contains('Translation') && GSATransPB != null) {
                        opp.GSA_Min_Education__c = GSATransPB.Min_Education__c;
                        opp.GSA_Min_Experience__c = GSATransPB.Min_Experience__c;
                    } else if (!pbIds.get(opp.Pricebook2Id).Name.contains('Translation') && GSALTPB != null) {
                        opp.GSA_Min_Education__c = GSALTPB.Min_Education__c;
                        opp.GSA_Min_Experience__c = GSALTPB.Min_Experience__c;
                    }
                }
            } 
            
            // When QB Contract Type is updated to "FED:GSA", or "STATE:GSA" auto-update Contract lookup field on Opportunity to Contract record: ("800600000012NYt" / Contract Name: GSA BPA (GS-10F-0225J) - This is old contract), New Contract Name: (GSA) 47QRAA19D003M
            if( opp.ContractId == null && ( Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(opp.Id).QB_Contract_Type__c != opp.QB_Contract_Type__c) ) && ( opp.QB_Contract_Type__c == 'FED:GSA' || opp.QB_Contract_Type__c == 'STATE:GSA' ))  {
                opp.ContractId = contrId;
            }
            
            // When Account is equal to 'ELT III' auto-update the contract on opportunity with the record contract number is '00022540' - Modified by E.Keerthika on 24th, May 2018
            if(opp.ContractId == null && (Trigger.isInsert || (Trigger.isUpdate && (Trigger.oldMap.get(opp.Id).AccountId != opp.AccountId))) && opp.AccountId == eltIIIAccId && opp.RecordTypeId == newOppRt) {
                opp.ContractId = eltContrId;
            }
            System.debug(':::opp::::'+opp);
            
            // Added by HL on Oct 06 2021 - For Pardot purpose this field gets populated
            if(String.isNotBlank(opp.GCLID__c) && (Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(opp.Id).GCLID__c != opp.GCLID__c))){
                 oppRecs.add(opp);       
            }
            // Added By HL on Nov 25 2021 - Work Item: W-007184 - Unable to convert Test Opportunity to Project
            // To fix the "Duplicate value found:DLS_Class__c" issue
            if(Trigger.isUpdate && opp.RecordTypeId != Trigger.oldMap.get(opp.Id).RecordTypeId && oppRecTypeMapTemp.containskey('Testing_Opportunities') && oppRecTypeMapTemp.get('Testing_Opportunities') == opp.RecordTypeId){
                opp.DLS_Class__c = '';    
            }
            
            // Added By HL - May 25 2022
            // To populate Default Cost Rate Rate Type field
            if(oppRTIdsForDCRRTPopulation.contains(opp.RecordTypeId) && (Trigger.isInsert || (Trigger.isUpdate && 
                (opp.RecordTypeId != Trigger.oldMap.get(opp.Id).RecordTypeId || ((opp.RecordTypeId == rtId && (opp.Project_Type__c != Trigger.oldMap.get(opp.Id).Project_Type__c ||
                opp.DLI_Project_Type__c != Trigger.oldMap.get(opp.Id).DLI_Project_Type__c || opp.ContractId != Trigger.oldMap.get(opp.Id).ContractId)) || 
                (opp.RecordTypeId == dodaRT && (opp.Classification__c != Trigger.oldMap.get(opp.Id).Classification__c || opp.Program_Iteration__c != Trigger.oldMap.get(opp.Id).Program_Iteration__c))))))){
                
                if(oppRecTypeMapTemp.containskey('CD_Opportunities') && oppRecTypeMapTemp.get('CD_Opportunities') == opp.RecordTypeId && opp.Default_Cost_Rate_Rate_Type__c != 'Non-SCA CD'){
                    
                    opp.Default_Cost_Rate_Rate_Type__c = 'Non-SCA CD';
                
                }else if(rtIdsForLTRT.contains(opp.RecordTypeId) && opp.Default_Cost_Rate_Rate_Type__c != 'LT without Billable Prep'){
                    
                    opp.Default_Cost_Rate_Rate_Type__c = 'LT without Billable Prep';
                    
                }else if(oppRecTypeMapTemp.containskey('EFL_Opportunities') && oppRecTypeMapTemp.get('EFL_Opportunities') == opp.RecordTypeId && opp.Default_Cost_Rate_Rate_Type__c != 'International Salary'){
                    
                    opp.Default_Cost_Rate_Rate_Type__c = 'International Salary'; 
                    
                }else if(oppRecTypeMapTemp.containskey('Interpretation_Opportunities') && oppRecTypeMapTemp.get('Interpretation_Opportunities') == opp.RecordTypeId && opp.Default_Cost_Rate_Rate_Type__c != 'Non-SCA Interpretation (Per Hour)'){
                    
                    opp.Default_Cost_Rate_Rate_Type__c = 'Non-SCA Interpretation (Per Hour)'; 
                    
                }else if(oppRecTypeMapTemp.containskey('MTT_Opportunities') && oppRecTypeMapTemp.get('MTT_Opportunities') == opp.RecordTypeId && opp.Default_Cost_Rate_Rate_Type__c != 'Non-SCA MTT (1099)'){
                    
                    opp.Default_Cost_Rate_Rate_Type__c = 'Non-SCA MTT (1099)'; 
                    
                }else if(oppRecTypeMapTemp.containskey('Testing_Opportunities') && oppRecTypeMapTemp.get('Testing_Opportunities') == opp.RecordTypeId && opp.Default_Cost_Rate_Rate_Type__c != 'Non-SCA Testing'){
                
                    opp.Default_Cost_Rate_Rate_Type__c = 'Non-SCA Testing'; 
                    
                }else if(opp.RecordTypeId == rtId){
                    
                    if(opp.DLI_Project_Type__c == 'Partner School'){
                        
                        if(opp.Classification__c == 'OF0MTT0PS' && DLI_W_PS_Group_3_ContractId != null && opp.ContractId == DLI_W_PS_Group_3_ContractId && opp.Default_Cost_Rate_Rate_Type__c != 'DLI-W PS - Group 3'){
                            
                            opp.Default_Cost_Rate_Rate_Type__c = 'DLI-W PS - Group 3';    
                        
                        }else if(opp.Classification__c == 'OF0MTT0PS' && DLI_W_PS_Group_4_ContractId != null && opp.ContractId == DLI_W_PS_Group_4_ContractId && opp.Default_Cost_Rate_Rate_Type__c != 'DLI-W PS - Group 4'){
                        
                            opp.Default_Cost_Rate_Rate_Type__c = 'DLI-W PS - Group 4';
                        
                        }else  if(opp.Default_Cost_Rate_Rate_Type__c != 'SubK-LT'){
                        
                            opp.Default_Cost_Rate_Rate_Type__c = 'SubK-LT'; 
                        }
                            
                    }else if(opp.DLI_Project_Type__c != 'Partner School' && opp.Enrollment_Date__c >= enrollment_Date){
                        
                        if(((DLI_W_PS_Group_3_ContractId != null && opp.ContractId == DLI_W_PS_Group_3_ContractId) || (DLI_W_PS_Group_4_ContractId != null && opp.ContractId == DLI_W_PS_Group_4_ContractId)) && opp.Default_Cost_Rate_Rate_Type__c != 'DLI-W LT'){
                        
                            opp.Default_Cost_Rate_Rate_Type__c = 'DLI-W LT';
                                
                        }else if((opp.Project_Type__c == 'Resident LT' || opp.Project_Type__c == 'AFPAK') && opp.Default_Cost_Rate_Rate_Type__c != 'DLI-21 SCA LT'){
                            
                            opp.Default_Cost_Rate_Rate_Type__c = 'DLI-21 SCA LT'; 
                            
                        }else if(opp.Project_Type__c == 'CD' && opp.Default_Cost_Rate_Rate_Type__c != 'DLI-21 SCA CD'){
                        
                            opp.Default_Cost_Rate_Rate_Type__c = 'DLI-21 SCA CD';
                            
                        }else if((opp.Project_Type__c == 'MTT' || opp.Project_Type__c == 'Overseas MTT' || opp.Project_Type__c == 'Hub') && opp.Default_Cost_Rate_Rate_Type__c != 'DLI-21 SCA MTT'){
                        
                            opp.Default_Cost_Rate_Rate_Type__c = 'DLI-21 SCA MTT';
                            
                        }
                    }
                }else if(opp.RecordTypeId == dodaRT){
                
                    if(opp.Classification__c == 'OF0MTT0PS' && opp.Default_Cost_Rate_Rate_Type__c != 'DODA PS'){
                        
                        opp.Default_Cost_Rate_Rate_Type__c = 'DODA PS';
                        
                    }else if(opp.Classification__c != 'OF0MTT0PS'){
                    
                        if(opp.Program_Iteration__c != null || opp.Project_Type__c != null){
                        
                            Program_Iteration__c pi = programIterationMap.containsKey(opp.Program_Iteration__c) ? programIterationMap.get(opp.Program_Iteration__c) : null;
                            
                            // Modified Project Type condition on Dec 14 2023 : W-007913 - Change LCR Names and Default Cost Rate Rate Type on Opportunity- (NOV-3-2023) - Deployed (NOV-20-2023)
                            if(((pi != null && projectTypes.contains(pi.Project_Type__c)) || projectTypes.contains(opp.Project_Type__c)) && opp.Default_Cost_Rate_Rate_Type__c != 'LT with Billable Prep'){
                                opp.Default_Cost_Rate_Rate_Type__c = 'LT with Billable Prep';
                            }else if(pi.Project_Type__c == 'JMAS' && opp.Default_Cost_Rate_Rate_Type__c != 'LT without Billable Prep'){
                                opp.Default_Cost_Rate_Rate_Type__c = 'LT without Billable Prep';
                            }                        
                        }else if(opp.Default_Cost_Rate_Rate_Type__c != 'LT without Billable Prep'){
                            opp.Default_Cost_Rate_Rate_Type__c = 'LT without Billable Prep';
                        }
                    }
                }else if(oppRecTypeMapTemp.containskey('FSI_Opportunities') && oppRecTypeMapTemp.get('FSI_Opportunities') == opp.RecordTypeId && opp.Default_Cost_Rate_Rate_Type__c != 'FSI'){
                    opp.Default_Cost_Rate_Rate_Type__c = 'FSI';
                }
            }
        }  
        if(oppRecs.size() > 0){
            Id primaryCampaignSource_Id = [SELECT Id, Name FROM Campaign WHERE Name = 'Campaign - Child - Advertising - Google/YouTube Ads' LIMIT 1].Id;
            if(primaryCampaignSource_Id != null){
                for(Opportunity opp : oppRecs){
                    if(opp.CampaignId == null || (opp.CampaignId != null && opp.CampaignId != primaryCampaignSource_Id)){
                        opp.CampaignId = primaryCampaignSource_Id;
                    }    
                }
            }
        }
    }
}