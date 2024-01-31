public class NewOrderLoanController {
    /******************************************************
     - Get Lookup search related records
     - Added by NS on August 27 2018
    *******************************************************/
    @AuraEnabled
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return Staff_Daily_Timesheet_Ctrl.search(String.escapeSingleQuotes(searchString),objectName,fieldName,condition,selectedIds);
    }  
    
    /****************************************************
     - Get Contact related project records information
     - Added by NS on August 27 2018
     ****************************************************/
    @AuraEnabled
    public static List<AcctSeed__Project__c> contactRelatedProjects(String contactId) {
        return LibraryContentSearch.projectsBasedonContact(contactId);
    }
    
    /***************************************************
     - Method to insert the Material Request records
    - Added by NS on August 29 2018
     **************************************************/
    @AuraEnabled
    public static String materialsRequestCreation(String type,String requestJson,List<String> studentCAIds){
        List<Materials_Request__c> materialsRequestList = (List<Materials_Request__c>) System.JSON.deserialize(requestJson, List<Materials_Request__c>.class);
        
        Id loanRTId;
        Id OrderRTId;
        for(RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Materials_Request__c']){
            if(rt.DeveloperName == 'Project_Materials_Request'){
                OrderRTId = rt.Id;
            }else if(rt.DeveloperName == 'Material_Loan_Request'){
                loanRTId = rt.Id;
            }
        }
        
        /*W-005442 - Materials Request - Delivery Location Autofill*/
        /*For Projects with Location " DLS - Online" fill in the "Delivery Location" field with the address from the Students Contact*/
        Map<Id, String> contactIdWithMailingLocation = new Map<Id, String>();
        if(studentCAIds != null && studentCAIds.size() > 0 && type == 'Order'){
            for(Contact con : [SELECT Id,MailingCountry, MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact WHERE Id IN :studentCAIds]){
                String matLocation = '';
                if(con.MailingStreet != null){
                    matLocation += con.MailingStreet+',';
                }
                if(con.MailingCity != null){
                    matLocation += con.MailingCity+',';                    
                }
                if(con.MailingState != null){
                    matLocation += con.MailingState+',';                    
                }
                if(con.MailingPostalCode != null){
                    matLocation += con.MailingPostalCode+',';                    
                }
                if(con.MailingCountry != null){
                    matLocation += con.MailingCountry+'.';                    
                }
                contactIdWithMailingLocation.put(con.Id, matLocation);
            }
        }
        
        //W-006969 - Added By Dhinesh - 30-07-2021 - Fill Delivery Address on Material Request for DLS Locations
        Map<Id, String> locationIdWithDeliveryLocation = new Map<Id, String>();
        if(type == 'Order' && (studentCAIds == null || studentCAIds.size() == 0 )){
            Set<Id> locationIds = new Set<Id>();
            for(Materials_Request__c mr : materialsRequestList){
                if(String.isNotEmpty(mr.Location__c)){
                    locationIds.add(mr.Location__c);
                }
            }
            
            for(MTT_Location__c loc : [SELECT Id, Street__c, City_and_State__c, State__c, Zip_Code__c, Country__c FROM MTT_Location__c WHERE Id IN :locationIds AND Name IN ('DLS - Rosslyn','DLS - Herndon','DLS - Elkridge')]){
                String matLocation = '';
                if(loc.Street__c != null){
                    matLocation += loc.Street__c+',';
                }
                if(loc.City_and_State__c != null){
                    matLocation += loc.City_and_State__c+',';                    
                }
                if(loc.State__c != null){
                    matLocation += loc.State__c+',';                    
                }
                if(loc.Zip_Code__c != null){
                    matLocation += loc.Zip_Code__c+',';                    
                }
                if(loc.Country__c != null){
                    matLocation += loc.Country__c+'.';                    
                }
                locationIdWithDeliveryLocation.put(loc.Id, matLocation);
            }
        }
        
        // Qry the Stock Account record to set the Vendor Name as Stock when the Material Source value = 'DLS Stock'
        // For Order Material Request records
        // Added by NS on Dec 7 2018
        List<Account> stockAcc = [SELECT Id,Name FROM Account WHERE Name = 'Stock'];
        //W-007578 Added by Dinesh on 30.09.2022
        List<System_Values__c> systemValuesList = [SELECT Id , Name , Value__c FROM System_Values__c WHERE Name = 'MR Reimbursements Account Name'];
        
        List<Account> reimbursementAccount;
        if(systemValuesList.size() > 0){
            reimbursementAccount = [SELECT Id , Name FROM Account WHERE Name = :systemValuesList[0].Value__c];
        }
        
        for(Materials_Request__c mr : materialsRequestList){
            
            if(type == 'Order'){
                mr.RecordTypeId = OrderRTId;
                mr.Delivery_Location__c = mr.Contact__c != null && contactIdWithMailingLocation.get(mr.Contact__c) != null ? contactIdWithMailingLocation.get(mr.Contact__c) : ((mr.Location__c != null && locationIdWithDeliveryLocation.get(mr.Location__c) != null) ? locationIdWithDeliveryLocation.get(mr.Location__c) : null);
                //W-007578 Added by Dinesh on 30.09.2022
                if(mr.Reimbursements__c){
                    mr.Vendor_Name__c = reimbursementAccount.size() > 0 ? reimbursementAccount[0].Id : null;
                }
                else if(mr.Materials_Source__c == 'DLS Stock'){
                    mr.Vendor_Name__c = stockAcc.size() > 0 ? stockAcc[0].Id : null;
                }
            }else if(type == 'Loan'){
                mr.RecordTypeId = loanRTId;
                // For Lost / Write - Off status change, we need source inventory type value to rollup the qty to Disposed Qty Library field in Materials Stock
                mr.Source_Inventory_Type__c = 'Library';
            }
        }
                
        system.debug('::::::::::::materialsRequestList:::::'+materialsRequestList);
        try {
            return LibraryContentSearch.CreateMaterialsRequests(JSON.serialize(materialsRequestList));
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /***************************************************
     - To get project information for prepopulation
     - Added by NS on August 31 2018
    ****************************************************/
    @AuraEnabled
    public static List<AcctSeed__Project__c> getProjectInfo(String projectId){
        return [SELECT Id,Name,Start_Date__c,Training_Location__r.Name FROM AcctSeed__Project__c WHERE Id = :projectId];
    }
    
    /***************************************************
     - To get Student Contact Assignment based on projectId(if project location is DLS Online)
     - Added by SivaPrasanth on May 21 2020
    ****************************************************/
    @AuraEnabled
    public static List<Contact> getStudentCAInfo(Id projectId){
        
        List<Contact> conList = new List<Contact>();
        //W-007578 Modified by Dinesh on 30.09.2022 . Needed contact Name
        Set<Id> contactIds = new Set<Id>();
        for(Contact_Assignments__c ca : [SELECT Id,Candidate_Name__r.Name,Candidate_Name__c FROM Contact_Assignments__c WHERE Project__c = :projectId AND RecordType.DeveloperName = 'Student' AND Status__c IN ('Active','Planned') AND Candidate_Name__c != null]){
            contactIds.add(ca.Candidate_Name__c);
        }
        conList = [SELECT Id,Name FROM Contact WHERE Id IN :contactIds];
        return conList;
    }
    
   /***************************************************
     - To get material information for prepopulation
     - Added by NS on August 31 2018
    ****************************************************/
    @AuraEnabled
    public static List<Materials__c> getMaterialInfo(Id materialId){
        return [SELECT Id,Name FROM Materials__c WHERE Id = :materialId];
    }
    
    /**********************************************
     - Method to get project related material budget task information for order creation
     - Added by NS on August 31 2018
    **********************************************/
    @AuraEnabled
    public static List<AcctSeed__Project_Task__c> getTaskInfomation(String projectId){
        return LibraryContentSearch.projectTasksBasedOnProject(projectId);
    }
}