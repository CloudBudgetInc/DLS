global without sharing Class OpportunityBudjectInfoController {

    global class budgetdetail{
        Public String Requestname;
        Public String oppName;
    }
    @AuraEnabled
    global static List<Payment_Item__c> oppRelatedFundItem(Id opliId, Id oppId){
        List<Payment_Item__c> payItemList = new List<Payment_Item__c>();
        if(opliId != null){
            payItemList = [SELECT Id,Name,Amount__c,Payment__c,Product__c,Project_Task__c,Quantity__c,Rate_per_Quantity__c,Product__r.Name,Project_Task__r.Name,Payment__r.Name,Opportunity_Product_Id__c FROM Payment_Item__c WHERE Payment__r.Opportunity__c = :oppId AND Opportunity_Product_Id__c = :opliId];
        }
        return payItemList;
    }
    @AuraEnabled
    public static List<Field_Id_Mapping__c> getCustomFieldId() {
        List<Field_Id_Mapping__c> fims = SObjectQueryService.getCustomFieldIdMap(new Set<String>{'For Opportunity Budget','For Project Budget'}, new Set<String>{'Materials_Request__c','Transaction__c','AcctSeed__Project_Task__c'});
        return fims;
    } 
    @AuraEnabled
    public static void  deleteRecordById(String id){
        Database.delete(id);
    } 
    
    @AuraEnabled
    public static List<Payment_Item__c> proTaskRelatedFundItem(Id protaskId, Id proId){
        List<Payment_Item__c> payItemList = new List<Payment_Item__c>();
        if(protaskId != null && proId != null){
            payItemList = [SELECT Id,Name,Amount__c,Payment__c,Product__c,Project_Task__c,Quantity__c,Rate_per_Quantity__c,Product__r.Name,Project_Task__r.Name,Payment__r.Name FROM Payment_Item__c WHERE Project_Task__r.AcctSeed__Project__c = :proId AND Project_Task__c = :protaskId];        
        }
        return payItemList;
    }
    @AuraEnabled
    public static List<RecordType> getrecordTypeInfo() {
        List<RecordType> proTasktRecordTypes =  new List<RecordType>([SELECT Id,DeveloperName,Name FROM RecordType WHERE sObjectType = 'AcctSeed__Project_Task__c']);
        return proTasktRecordTypes;
    }
    
    public class RequestSectionWrapper{
        @AuraEnabled 
        public String Id;
        @AuraEnabled 
        public String Name;
        @AuraEnabled 
        public String requestStatus;
        @AuraEnabled 
        public String dateDeliverd;
        @AuraEnabled 
        public String vendorName;
        @AuraEnabled 
        public String materialName;
        @AuraEnabled 
        public String salesTax;
        @AuraEnabled 
        public String qty;
        @AuraEnabled 
        public String vendorTotal;
        @AuraEnabled 
        public String dlsTotal;
        @AuraEnabled 
        public String dlsClassNo;
    }
    @AuraEnabled
    public static ProjectWrapperContainer getWrapperProjectBudgetInfo(String objectName, String projectId){
        List<AcctSeed__Project__c> ProList = SObjectQueryService.SObjectQuery('AcctSeed__Project__c',new Set<Id>{projectId},',RecordType.DeveloperName');
       
        List<MaterialWrapper> serviceWrapperList = new List<MaterialWrapper>();
        List<MaterialWrapper> matterialWrapperList = new List<MaterialWrapper>();
        List<MaterialWrapper> odcWrapperList = new List<MaterialWrapper>();
        List<MaterialWrapper> regularHoursWrapperList = new List<MaterialWrapper>();
        List<MaterialWrapper> fringeWrapperList = new List<MaterialWrapper>();
        List<Materials_Request__c> loanList = new List<Materials_Request__c>();
        List<Materials_Request__c> requestList = new List<Materials_Request__c>();
        ProjectWrapperContainer projWrapper = new ProjectWrapperContainer();
        List<RecordType> proTasktRecordTypes = getrecordTypeInfo();
        List<RecordType> recTypeList = new List<RecordType>();
        List<AcctSeed__Project_Task__c> acctProTaskList = new List<AcctSeed__Project_Task__c>();
        
        recTypeList = SObjectQueryService.getRecTypeListBySobjTypeAndDevName('',objectName,new Set<String>{});
        system.debug('::::::::recTypeList:::::::::::::::'+recTypeList);
        
        List<RecordType> matReqRecTypeList = SObjectQueryService.getRecTypeListBySobjTypeAndDevName('','Materials_Request__c',new Set<String>{});
        
        acctProTaskList = ProjectTaskService.getProjectTasksByProjIdsAndProjTaskTypes(new Set<Id>{projectId}, new Set<String>{}, '',',AcctSeed__Project__r.Name,AcctSeed__Project__r.DLS_Class__c,AcctSeed__Project__r.AcctSeed__Status__c,AcctSeed__Project__r.End_Date__c,AcctSeed__Project__r.Start_Date__c,AcctSeed__Project__r.RecordTypeId,AcctSeed__Project__r.RecordType.DeveloperName,RecordType.DeveloperName,CLIN__r.Name'); 
        system.debug('::::::::acctProTaskList:::::::::::::::'+acctProTaskList);
        
        List<Materials_Request__c> materialRequest = MaterialRequestService.getMaterial(' WHERE Project__c = \''+projectId+'\' ORDER BY CreatedDate DESC','Materials_Name__r.Name,Project_Task__r.AcctSeed__Project__c,Project_Task__r.Name,Vendor_Name__r.Name,RecordType.DeveloperName,Contact__r.Name');
        String profileName = getProfileName();
        
        /* W-006415 - Remove Delete Icon from Budget Materials Detail View*/
        projWrapper.isShowMaterialDelIcon = false;
        if(profileName == 'System Administrator'){
            projWrapper.isShowMaterialDelIcon = true;
        }
        
        if(ProList.size() > 0){
            projWrapper.parentRecordTypeName = ProList[0].RecordType.DeveloperName;
            projWrapper.parentObjectName= ProList[0].Name;
        }   
         Materials_Request__c loanTotal = new Materials_Request__c();
       //Set default value
        RequestSectionWrapper reqTotal = new RequestSectionWrapper();
        reqTotal.salesTax = String.valueOf(0);
        reqTotal.qty = String.valueOf(0);
        reqTotal.vendorTotal = String.valueOf(0);
        reqTotal.dlsTotal = String.valueOf(0);
        
        List<RequestSectionWrapper> requestListWrapper = new List<RequestSectionWrapper>();
        if(materialRequest.size() > 0){
            for(Materials_Request__c mr :materialRequest){
                if(mr.RecordType.DeveloperName == 'Project_Materials_Request'){
                   RequestSectionWrapper rsw = new RequestSectionWrapper();
                    rsw.Name = mr.Name;
                    rsw.Id = mr.Id;
                    rsw.requestStatus = mr.Request_Status__c;
                    rsw.dlsClassNo = mr.DLS_Class_Number__c;
                    rsw.dateDeliverd = String.valueOf(mr.Date_Delivered__c);
                    rsw.vendorName = String.valueOf(mr.Vendor_Name__r.Name);
                    rsw.materialName = String.valueOf(mr.Materials_Name__r.Name);
                    rsw.salesTax = String.valueOf(mr.DLS_Sales_Tax_Formula__c);
                    rsw.qty = String.valueOf(mr.Qty__c);
                    rsw.vendorTotal = String.valueOf(mr.Vendor_Total__c);
                    rsw.dlsTotal = String.valueOf(mr.DLS_Total__c);
                    reqTotal.salesTax = String.valueOf(Decimal.valueOf(reqTotal.salesTax) + (mr.DLS_Sales_Tax_Formula__c != null ? mr.DLS_Sales_Tax_Formula__c : 0));
                    reqTotal.qty = String.valueOf(Integer.valueOf(reqTotal.qty) + (mr.Qty__c != null ? mr.Qty__c : 0));
                    reqTotal.vendorTotal = String.valueOf(Decimal.valueOf(reqTotal.vendorTotal) + (mr.Vendor_Total__c != null ? mr.Vendor_Total__c : 0));
                    reqTotal.dlsTotal = String.valueOf(Decimal.valueOf(reqTotal.dlsTotal) + (mr.DLS_Total__c != null ? mr.DLS_Total__c : 0));
                    requestListWrapper.add(rsw);
                } else if(mr.RecordType.DeveloperName == 'Material_Loan_Request'){
                    
                    loanTotal.Qty__c = (loanTotal.Qty__c != null ? loanTotal.Qty__c : 0) + (mr.Qty__c != null ? mr.Qty__c : 0);
                    loanList.add(mr);
                }
            }
        }
        
        if(loanList.size() > 0){
            loanTotal.Name = 'Total';
            loanList.add(loanTotal);
        }
         if(requestListWrapper.size() > 0){
            reqTotal.Name = 'Total';
            requestListWrapper.add(reqTotal);
        }
            
        
        MaterialWrapper regularHours = initializeMaterialWrapper(); 
        MaterialWrapper fringe = initializeMaterialWrapper();
        MaterialWrapper material = initializeMaterialWrapper(); 
        MaterialWrapper odc = initializeMaterialWrapper();
        MaterialWrapper service = initializeMaterialWrapper(); 
        
        Map<Id,List<MaterialWrapper>> serviceWrappar = new Map<Id,List<MaterialWrapper>>();
        
        for(AcctSeed__Project_Task__c apt :acctProTaskList ){
            
            String type = apt.Project_Task_Type__c;
            Decimal qtyScheduled = (apt.Total_Hours__c != null ? apt.Total_Hours__c : 0.00),
                    qtyUsed = (apt.Total_Qty_Used__c != null ? apt.Total_Qty_Used__c : 0.00),
                    qtyPaid = (apt.Total_Qty_Paid__c != null ? apt.Total_Qty_Paid__c : 0.00),
                    qtyPlanned = (apt.Total_Qty_Planned__c != null ? apt.Total_Qty_Planned__c : 0.00);
            Decimal totalQtyPlannedRemaining = apt.Total_Qty_Planned_Remaining__c;
            Decimal extendedPrice = ((apt.Total_Qty_Planned__c != null && apt.Rate__c != null) ? (apt.Total_Qty_Planned__c * apt.Rate__c).setScale(2) : 0.00);
            Decimal totalQtyPaidRemaining = apt.Total_Qty_Paid_Remaining__c;
            Decimal scheduledHoursDeficit;
            String deficitColor;
            if(apt.Total_Hours__c != null && apt.Total_Qty_Planned__c != null){
                if(apt.Total_Hours__c== 0){
                    scheduledHoursDeficit = 0;
                }else{
                    scheduledHoursDeficit = qtyScheduled - qtyPlanned;
                }
            }else{
                scheduledHoursDeficit = 0;
            }
          
          //  Decimal scheduledHoursDeficit =  (apt.Total_Hours__c != null && apt.Total_Qty_Planned__c != null ? qtyScheduled - qtyPlanned : 0.00);
            
            System.debug('scheduledHoursDeficit :::'+scheduledHoursDeficit );
            // Added by Mohana for scheduledHoursDeficit colour code
            if(scheduledHoursDeficit < 0.00){
                scheduledHoursDeficit = Decimal.valueOf(String.valueOf(scheduledHoursDeficit).split('-')[1]);
                deficitColor = 'red';
            }else if(scheduledHoursDeficit == 0){
                deficitColor = 'green';
            }else if(scheduledHoursDeficit > 0){
                deficitColor = '#FFCC00';
            }
            
            if(apt.Project_Task_Type__c == 'Language Training' || apt.Project_Task_Type__c == 'Language Testing' ||apt.Project_Task_Type__c == 'Interpretation (per hr)' 
               || apt.Project_Task_Type__c == 'Curriculum Development' || apt.Project_Task_Type__c == 'Localization' 
               || apt.Project_Task_Type__c == 'Translation (per hr)' || apt.Project_Task_Type__c == 'Translation' || apt.Project_Task_Type__c == 'Translation (per FFP)'
               || apt.Project_Task_Type__c == 'Preparation time' || apt.Project_Task_Type__c == 'Linguist Support'|| apt.Project_Task_Type__c == 'Interpretation (per FFP)' 
               || apt.Project_Task_Type__c == 'Linguist Support Services' || apt.Project_Task_Type__c == 'Translation (per word)'){
                  
                   MaterialWrapper m = new MaterialWrapper(apt.Id,apt.Name,String.valueOf((apt.Total_Qty_Planned__c != null ? apt.Total_Qty_Planned__c.setScale(2) : 0.00) + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),
                     apt.CLIN__r.Name,apt.CLIN__c,String.valueOf(apt.Rate__c != null ? apt.Rate__c : 0),String.valueOf(extendedPrice.setScale(2)),
                     apt.Description__c,null,apt.Project_Task_Type__c,String.valueOf(qtyPaid.setScale(2) + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),
                                         String.valueOf(qtyScheduled.setScale(2) + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),String.valueOf(qtyUsed + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),
                                         String.valueOf(totalQtyPlannedRemaining.setScale(2) + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),
                                         String.valueOf(totalQtyPaidRemaining.setScale(2) + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),String.valueOf(scheduledHoursDeficit.setScale(2) + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),deficitColor);
                  
                   if(!apt.Name.contains('Additional Student')){ // Each Additional Student
                       if( !apt.Name.contains('Registration Fee')) {
                           if(!(apt.Project_Task_Type__c == 'Preparation time' && (apt.Rate__c == 0 || apt.Billable__c == false))){
                               service.quantityPlanned = String.valueOf(Decimal.valueOf(service.quantityPlanned).setScale(2) + (apt.Total_Qty_Planned__c != null ? apt.Total_Qty_Planned__c.setScale(2) : 0.00 ));
                               service.quantityPlannedRemaining = String.valueOf(Decimal.valueOf(service.quantityPlannedRemaining) + totalQtyPlannedRemaining);
                               service.quantityPaidRemaining = String.valueOf((Decimal.valueOf(service.quantityPaidRemaining) + totalQtyPaidRemaining).setScale(2));
                               service.quantityScheduledDeficit = String.valueOf((Decimal.valueOf(service.quantityScheduledDeficit) + scheduledHoursDeficit).setScale(2));
                           }
                              service.quantityPaid = String.valueOf(Decimal.valueOf(service.quantityPaid) + qtyPaid);
                       }
                       if(!(apt.Project_Task_Type__c == 'Preparation time' && (apt.Rate__c == 0 || apt.Billable__c == false))){
                           service.quantityScheduled = String.valueOf(Decimal.valueOf(service.quantityScheduled) + qtyScheduled);
                       	   service.quantityUsed = String.valueOf((Decimal.valueOf(service.quantityUsed) + qtyUsed).setScale(2));
                       }
                       
                       m.parentTask = apt.Parent_Project_Task__c;
                       serviceWrapperList.add(m);
                   }
                   service.extendedPrice = String.valueOf(Decimal.valueOf(service.extendedPrice) +  extendedPrice);                 
                   
                   if(apt.Parent_Project_Task__c != null){
                       if(serviceWrappar.containsKey(apt.Parent_Project_Task__c)){
                           serviceWrappar.get(apt.Parent_Project_Task__c).add(m);  
                       }else{
                           serviceWrappar.put(apt.Parent_Project_Task__c, new List<MaterialWrapper>{m});
                       }
                   }
            }else if(apt.Project_Task_Type__c == 'Material Budget'){
                    system.debug(':::::apt:::'+apt);
                    system.debug(':::::apt:::'+apt.Total_Qty_Planned__c);
                MaterialWrapper m = new MaterialWrapper(apt.Id,apt.Name,String.valueOf((apt.Total_Qty_Planned__c != null ? apt.Total_Qty_Planned__c.setScale(2) : 0.00) +  (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),
                                                      apt.CLIN__r.Name,apt.CLIN__c, String.valueOf(apt.Rate__c),String.valueOf(extendedPrice.setScale(2)),
                                                      apt.Description__c,null,apt.Project_Task_Type__c,String.valueOf(qtyPaid +  (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),
                                                      String.valueOf(qtyScheduled.setScale(2) +  (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),String.valueOf(qtyUsed.setScale(2) + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),
                                                      String.valueOf(totalQtyPlannedRemaining.setScale(2) +  (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),
                                                      String.valueOf(totalQtyPaidRemaining.setScale(2) +  (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),String.valueOf(scheduledHoursDeficit.setScale(2) +  (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),'' );
                  
                m.totalBudjeted = String.valueOf(apt.Total_Budgeted__c);
                m.totalAmountPaid = String.valueOf(apt.Total_Amount_Paid__c != null ? apt.Total_Amount_Paid__c : 0);
                m.totalSpent = String.valueOf(apt.Total_Spent__c);
                m.totalPaidRemaining = String.valueOf(apt.Total_Amount_Paid_Remaining__c);
                system.debug('::::::apt.Total_Qty_Planned__c::::::::'+String.valueOf(Decimal.valueOf(material.quantityPlanned) + (apt.Total_Qty_Planned__c != null ? apt.Total_Qty_Planned__c : 0 )));
                system.debug('::::::apt.Total_Qty_Planned__c::::::::'+(apt.Total_Qty_Planned__c != null ? apt.Total_Qty_Planned__c : 0 ));
                system.debug('::::::apt.Total_Qty_Planned__c::::::::'+String.valueOf(Decimal.valueOf(material.quantityPlanned) + (apt.Total_Qty_Planned__c != null ? apt.Total_Qty_Planned__c : 0 )));
                
                material.quantityPlanned = String.valueOf(Decimal.valueOf(material.QuantityPlanned).setScale(2) + (apt.Total_Qty_Planned__c != null ? apt.Total_Qty_Planned__c.setScale(2) : 0.00  ));
                system.debug('::::::quantity planned::::::::'+m.quantityPlanned);
                material.extendedPrice = String.valueOf(Decimal.valueOf(material.extendedPrice) + extendedPrice);
                material.quantityPaid = String.valueOf(Decimal.valueOf(material.quantityPaid) + qtyPaid);
                material.quantityScheduled = String.valueOf(Decimal.valueOf(material.quantityScheduled) + qtyScheduled);
                material.quantityPlannedRemaining = String.valueOf(Decimal.valueOf(material.quantityPlannedRemaining) + totalQtyPlannedRemaining);
                material.quantityUsed = String.valueOf(Decimal.valueOf(material.quantityUsed) + qtyUsed);
                material.quantityPaidRemaining = String.valueOf(Decimal.valueOf(material.quantityPaidRemaining) + totalQtyPaidRemaining );
                material.quantityScheduledDeficit = String.valueOf(Decimal.valueOf(material.quantityScheduledDeficit) + scheduledHoursDeficit );
                material.totalBudjeted = String.valueOf(Decimal.valueOf(material.totalBudjeted) + (apt.Total_Budgeted__c != null ? apt.Total_Budgeted__c : 0.00  ));
                material.totalAmountPaid = String.valueOf(Decimal.valueOf(material.totalAmountPaid) +  (apt.Total_Amount_Paid__c != null ? apt.Total_Amount_Paid__c : 0.00  ));
                material.totalSpent = String.valueOf(Decimal.valueOf(material.totalSpent) + (apt.Total_Spent__c != null ? apt.Total_Spent__c : 0.00  ));
                material.totalPaidRemaining = String.valueOf(Decimal.valueOf(material.totalPaidRemaining) +  (apt.Total_Amount_Paid_Remaining__c != null ? apt.Total_Amount_Paid_Remaining__c : 0.00  ));
                system.debug(':::::::::material:::::'+m);
                
                matterialWrapperList.add(m);

            } else if(type =='ODC' || apt.RecordType.DeveloperName == 'Travel_ODCs'){
                 
                 MaterialWrapper m = new MaterialWrapper(apt.Id,apt.Name,String.valueOf((apt.Total_Qty_Planned__c != null ? apt.Total_Qty_Planned__c : 0.00) + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),
                     apt.CLIN__r.Name,apt.CLIN__c, String.valueOf(apt.Rate__c),String.valueOf(extendedPrice.setScale(2)),
                     apt.Description__c,null,apt.Project_Task_Type__c,String.valueOf(qtyPaid + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),
                                         String.valueOf(qtyScheduled + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),String.valueOf(qtyUsed +(apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),
                                         String.valueOf(totalQtyPlannedRemaining + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),
                    String.valueOf(totalQtyPaidRemaining + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),String.valueOf(scheduledHoursDeficit + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),'' );
                    
                    odc.QuantityPlanned = String.valueOf(Decimal.valueOf(odc.QuantityPlanned) + (apt.Total_Qty_Planned__c != null ? apt.Total_Qty_Planned__c : 0  ));
                    odc.extendedPrice = String.valueOf(Decimal.valueOf(odc.extendedPrice) + extendedPrice);
                    odc.quantityPaid = String.valueOf(Decimal.valueOf(odc.quantityPaid) + qtyPaid);
                    odc.quantityScheduled = String.valueOf(Decimal.valueOf(odc.quantityScheduled) + qtyScheduled);
                    odc.quantityPlannedRemaining = String.valueOf(Decimal.valueOf(odc.quantityPlannedRemaining) + totalQtyPlannedRemaining);
                    odc.quantityUsed = String.valueOf(Decimal.valueOf(odc.quantityUsed) + qtyUsed);
                    odc.quantityPaidRemaining = String.valueOf(Decimal.valueOf(odc.quantityPaidRemaining) + totalQtyPaidRemaining );
                    odc.quantityScheduledDeficit = String.valueOf(Decimal.valueOf(odc.quantityScheduledDeficit) + scheduledHoursDeficit );
                    
                    odcWrapperList.add(m);
                    
              } else if(apt.RecordType.DeveloperName == 'Cost' && (apt.Project_Task_Type__c == 'ADMINISTRATIVE' 
                                                                   || apt.Project_Task_Type__c == 'Non-Compensatory')) {
                     MaterialWrapper m = new MaterialWrapper(apt.Id,apt.Name,String.valueOf((apt.Total_Qty_Planned__c != null ? apt.Total_Qty_Planned__c : 0.00)+ (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' ) ),
                     apt.CLIN__r.Name,apt.CLIN__c, String.valueOf(apt.Rate__c),null,
                     apt.Description__c,null,apt.Project_Task_Type__c,String.valueOf(qtyPaid + + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),
                                         String.valueOf(qtyScheduled +  (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),String.valueOf(qtyUsed +  (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),
                                         String.valueOf(totalQtyPlannedRemaining  + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),
                      String.valueOf(totalQtyPaidRemaining + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),String.valueOf(scheduledHoursDeficit +  (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )) ,'');
                    
                   
                                                
                    regularHours.QuantityPlanned = String.valueOf(Decimal.valueOf(regularHours.QuantityPlanned) + (apt.Total_Qty_Planned__c != null ? apt.Total_Qty_Planned__c : 0.00));
                    system.debug('Inside the admin quantity planned:::'+regularHours.quantityPlanned);
                    regularHours.extendedPrice = String.valueOf(Decimal.valueOf(regularHours.extendedPrice) + extendedPrice);
                    regularHours.quantityPaid = String.valueOf(Decimal.valueOf(regularHours.quantityPaid) + qtyPaid);
                    regularHours.quantityScheduled = String.valueOf(Decimal.valueOf(regularHours.quantityScheduled) + qtyScheduled);
                    regularHours.quantityPlannedRemaining = String.valueOf(Decimal.valueOf(regularHours.quantityPlannedRemaining) + totalQtyPlannedRemaining);
                    regularHours.quantityUsed = String.valueOf(Decimal.valueOf(regularHours.quantityUsed) + qtyUsed);
                    regularHours.quantityPaidRemaining = String.valueOf(Decimal.valueOf(regularHours.quantityPaidRemaining) + totalQtyPaidRemaining );
                    regularHours.quantityScheduledDeficit = String.valueOf(Decimal.valueOf(regularHours.quantityScheduledDeficit) + scheduledHoursDeficit );
                    regularHoursWrapperList.add(m);        
                    
                    system.debug('Regular hours wrapper mmmmmm::::'+m);                                       
                  
              } else if(apt.RecordType.DeveloperName == 'Cost' ) {
                     MaterialWrapper m = new MaterialWrapper(apt.Id,apt.Name,String.valueOf((apt.Total_Qty_Planned__c != null ? apt.Total_Qty_Planned__c : 0.00)+ (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),
                     apt.CLIN__r.Name,apt.CLIN__c, String.valueOf(apt.Rate__c),null,
                     apt.Description__c,null,apt.Project_Task_Type__c,String.valueOf(qtyPaid + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),
                                         String.valueOf(qtyScheduled + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),String.valueOf(qtyUsed + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),
                                         String.valueOf(totalQtyPlannedRemaining + (apt.Unit__c != null ? '('+ apt.Unit__c + ')': '' )),
                      String.valueOf(totalQtyPaidRemaining + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),String.valueOf(scheduledHoursDeficit + (apt.Unit__c != null ? '('+apt.Unit__c + ')': '' )),'' );
                    
                    fringe.QuantityPlanned = String.valueOf(Decimal.valueOf(fringe.QuantityPlanned) + (apt.Total_Qty_Planned__c != null ? apt.Total_Qty_Planned__c : 0  ));
                    fringe.extendedPrice = String.valueOf(Decimal.valueOf(fringe.extendedPrice) + extendedPrice);
                    fringe.quantityPaid = String.valueOf(Decimal.valueOf(fringe.quantityPaid) + qtyPaid);
                    fringe.quantityScheduled = String.valueOf(Decimal.valueOf(fringe.quantityScheduled) + qtyScheduled);
                    fringe.quantityPlannedRemaining = String.valueOf(Decimal.valueOf(fringe.quantityPlannedRemaining) + totalQtyPlannedRemaining);
                    fringe.quantityUsed = String.valueOf(Decimal.valueOf(fringe.quantityUsed) + qtyUsed);
                    fringe.quantityPaidRemaining = String.valueOf(Decimal.valueOf(fringe.quantityPaidRemaining) + totalQtyPaidRemaining );
                    fringe.quantityScheduledDeficit = String.valueOf(Decimal.valueOf(fringe.quantityScheduledDeficit) + scheduledHoursDeficit );
                    fringeWrapperList.add(m);                                           
                  
              }
            
        }
        List<MaterialWrapper> serviceTreeWrapperList = new List<MaterialWrapper>();
            system.debug('##'+regularHours);

        for(MaterialWrapper mat : serviceWrapperList){
            if(mat.parentTask == null){
                if(serviceWrappar.get(mat.Id) != null){
                    mat.childrens = serviceWrappar.get(mat.Id);  
                    serviceTreeWrapperList.add(mat);    
                } else {
                    serviceTreeWrapperList.add(mat); 
                }
           }
        }
        if(regularHoursWrapperList.size() > 0){
             regularHoursWrapperList.add(regularHours);
        }
        if(fringeWrapperList.size() > 0){
             fringeWrapperList.add(fringe);
        }
        if(odcWrapperList.size() > 0){
             odcWrapperList.add(odc);
        }
        if(matterialWrapperList.size() > 0){
             matterialWrapperList.add(material);
        }
        system.debug('#######'+serviceTreeWrapperList.size());
        if(serviceTreeWrapperList.size() > 0){
            system.debug('#######'+serviceTreeWrapperList.size());
             serviceTreeWrapperList.add(service);
        }
        system.debug('$$'+serviceTreeWrapperList);
        projWrapper.serviceWrapperList = serviceTreeWrapperList;
        projWrapper.materialWrapperList = matterialWrapperList;
        projWrapper.odcWrapperList = odcWrapperList;
        projWrapper.regularHoursWrapperList = regularHoursWrapperList;
        projWrapper.loanList = loanList;
        projWrapper.requestlist = requestListWrapper;
        projWrapper.fringeWrapperList = fringeWrapperList;
        projWrapper.projectTaskRecordTypes = proTasktRecordTypes;
        
        system.debug('Project regular hour wrapper list::::'+projWrapper.regularHoursWrapperList);
        return projWrapper;
    }
    @AuraEnabled
    public static MaterialWrapper initializeMaterialWrapper(){
        MaterialWrapper m = new MaterialWrapper();
        m.productName = 'Total';
        m.quantityPaid = String.valueOf(0);
        m.quantityScheduled = String.valueOf(0);
        m.quantityUsed = String.valueOf(0);
        m.quantityPlannedRemaining = String.valueOf(0);
        m.quantityPaidRemaining = String.valueOf(0);
        m.quantityScheduledDeficit = String.valueOf(0);
        m.quantityPlanned = String.valueOf(0);
        m.extendedPrice = String.valueOf(0);
        m.totalBudjeted =  String.valueOf(0);
        m.totalAmountPaid =  String.valueOf(0);
        m.totalSpent =  String.valueOf(0);
        m.totalPaidRemaining =  String.valueOf(0);
       
        return m;
    }
    @AuraEnabled
    public static  ProjectWrapperContainer getWrapperOppBudgetInfo(String oppId){
        Set<Id> oppIdSet = new Set<Id>{oppId};
        system.debug('::::::::::::::::');
        
        List<Payment_Item__c> payItemList = new List<Payment_Item__c>();
        List<Schedule__c> scheduleList = new List<Schedule__c>();
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<AcctSeed__Project__c> proList = new List<AcctSeed__Project__c>(); 
        List<MaterialWrapper> serviceWrapperList = new List<MaterialWrapper>();
        List<MaterialWrapper> matterialWrapperList = new List<MaterialWrapper>();
        List<MaterialWrapper> odcWrapperList = new List<MaterialWrapper>();
        ProjectWrapperContainer projWrapper = new ProjectWrapperContainer();

        payItemList = FundingItemService.getPaymentItemsByPaymentOpportunityIds(oppIdSet);
        scheduleList = ScheduleService.getSchedulesByContIds(new Set<Id>{},' WHERE Opportunity__c = \''+oppId+'\'','');
        //oppLineItemList = [SELECT Id,Name,UnitPrice,CLIN_LU__c,CLIN_LU__r.Name,Description,Quantity,Product2.Name,Product2Id,Product2.Family,Product2.Unit_Type__c,Opportunity.RecordType.DeveloperName FROM OpportunityLineItem WHERE OpportunityId IN :oppIdSet]; 
        oppLineItemList = OpportunityLineItemService.getOPLIByOppId(oppIdSet,'',',CLIN_LU__r.Name,Product2.Name,Product2.Family,Product2.Unit_Type__c,Opportunity.RecordType.DeveloperName,Opportunity.Total_Materials_Funded__c');
        oppList = SObjectQueryService.SObjectQuery('Opportunity',new Set<Id>{oppId},',RecordType.DeveloperName');
        
        proList = ProjectService.getproject(' WHERE AcctSeed__Opportunity__c','',new Set<Id>{oppId});  // to store project related to opportunity which is launched currently

        Map<Id,map<String,Decimal>> opportunityProducts = new Map<Id,map<String,Decimal>>();
        Map<Id,map<String,Decimal>> opportunitypayItem = new Map<Id,map<String,Decimal>>();
        MaterialWrapper odc = initializeMaterialWrapper();
        MaterialWrapper service = initializeMaterialWrapper(); 
        MaterialWrapper material = initializeMaterialWrapper(); 
        
        String profileName = getProfileName();
        
        /* W-006415 - Remove Delete Icon from Budget Materials Detail View*/
        projWrapper.isShowMaterialDelIcon = false;
        if(profileName == 'System Administrator'){
            projWrapper.isShowMaterialDelIcon = true;
        }
        
        if(oppList.size() > 0){
            projWrapper.parentRecordTypeName = oppList[0].RecordType.DeveloperName;
            projWrapper.parentObjectName= oppList[0].Name;
        }   
        
        
        system.debug('payItemList'+payItemList);
        for(Schedule__c s : scheduleList) {
            map<String,Decimal> hoursDefinedMap = new  map<String,Decimal>();
            if(opportunityProducts.get(s.Opportunity_Product_Id__c) == null) {
                hoursDefinedMap.put('Hours_Planned', (s.Total_Hours__c != null ? s.Total_Hours__c : 0));
                hoursDefinedMap.put('Hours_Used', (s.Total_Hours_Used__c != null ? s.Total_Hours_Used__c : 0));
                opportunityProducts.put(s.Opportunity_Product_Id__c,hoursDefinedMap);
            } else {
                opportunityProducts.get(s.Opportunity_Product_Id__c).put('Hours_Planned',opportunityProducts.get(s.Opportunity_Product_Id__c).get('Hours_Planned') + (s.Total_Hours__c != null ? s.Total_Hours__c : 0) );
                opportunityProducts.get(s.Opportunity_Product_Id__c).put('Hours_Used',opportunityProducts.get(s.Opportunity_Product_Id__c).get('Hours_Used') + (s.Total_Hours_Used__c != null ? s.Total_Hours_Used__c : 0) );                                  
            }    

        }
         
        for(Payment_Item__c p : payItemList) {
            map<String,Decimal> paymentDefinedMap = new  map<String,Decimal>();
             if(opportunityProducts.get(p.Product__c) == null) {
                 
                 if(opportunitypayItem.containskey(p.Product__c)){
                     opportunitypayItem.get(p.Product__c).put('Amount_Paid',opportunitypayItem.get(p.Product__c).get('Amount_Paid') + p.Amount__c);
                 }else{
                     paymentDefinedMap.put('Amount_Paid', p.Amount__c);
                     opportunitypayItem.put(p.Product__c,paymentDefinedMap); 
                 }
            } else {
                //opportunitypayItem.get(p.Product__c).put('Amount_Paid',opportunitypayItem.get(p.Product__c).get('Amount_Paid') + p.Amount__c );
            }    
        }

        if(oppList.size() > 0){
            projWrapper.parentRecordTypeName = oppList[0].RecordType.DeveloperName;
        }       
        
        for(OpportunityLineItem opli : oppLineItemList){
            system.debug('%%'+opli);

            String type = opli.Product2.Family;
            
           
            Decimal qtyScheduled = 0.00,
                    qtyUsed = 0.00,
                    qtyPaid = 0.00;
             if(opportunityProducts.containsKey(opli.Id) && opportunityProducts.get(opli.Id) != null) {
               qtyScheduled = opportunityProducts.get(opli.Id).get('Hours_Planned');
                qtyUsed =  opportunityProducts.get(opli.Id).get('Hours_Used');
            }
            if(opportunitypayItem.containsKey(opli.Product2Id) && opportunitypayItem.get(opli.Product2Id) != null) {
               qtyPaid = opportunitypayItem.get(opli.Product2Id).get('Amount_Paid') / opli.UnitPrice;
            }
            system.debug('opportunitypayItem'+opportunitypayItem);
            Decimal totalQtyPlannedRemaining = opli.Quantity - qtyUsed;
            Decimal totalQtyPaidRemaining = qtyPaid - qtyUsed;
            Decimal scheduledHoursDeficit = opli.Quantity - qtyScheduled;
            Decimal extendedPrice = ((opli.Quantity != null && opli.UnitPrice  != null) ? (opli.Quantity * opli.UnitPrice).setScale(2) : 0.00);
            String unitType = ( opli.Product2.Unit_Type__c != null ? '(' + opli.Product2.Unit_Type__c + ')' : '');
            
            
            if(type == 'Material Budget'){
                 matterialWrapperList.add(
                     new MaterialWrapper(opli.Id,opli.Product2.Name,String.valueOf(opli.Quantity + unitType),
                     opli.CLIN_LU__r.Name,opli.CLIN_LU__c, String.valueOf(opli.UnitPrice),String.valueOf((opli.UnitPrice * opli.Quantity).setScale(2)),
                     opli.Description,null,opli.Product2.Family,String.valueOf(qtyPaid + unitType),
                                         String.valueOf(qtyScheduled+ unitType),String.valueOf(qtyUsed + unitType),
                                         String.valueOf(totalQtyPlannedRemaining+ unitType),
                   String.valueOf(totalQtyPaidRemaining.setScale(2) + unitType),String.valueOf(scheduledHoursDeficit + unitType),''));  
                   
                   material.quantityPlanned = opli.Quantity != null ? String.valueOf(opli.Quantity) : String.valueOf(0.00);
                   material.extendedPrice = String.valueOf(Decimal.valueOf(material.extendedPrice) + extendedPrice);
                   material.quantityPaid = String.valueOf(Decimal.valueOf(material.quantityPaid).setScale(2) + qtyPaid.setScale(2));
                   material.quantityScheduled = String.valueOf(Decimal.valueOf(material.quantityScheduled) + qtyScheduled);
                   material.quantityPlannedRemaining = String.valueOf(Decimal.valueOf(material.quantityPlannedRemaining) + totalQtyPlannedRemaining);
                   material.quantityUsed = String.valueOf(Decimal.valueOf(material.quantityUsed) + qtyUsed);
                   
                   material.quantityPaidRemaining = String.valueOf(Decimal.valueOf(material.quantityPaidRemaining).setScale(2) + totalQtyPaidRemaining.setScale(2) );
                   material.quantityScheduledDeficit = String.valueOf(Decimal.valueOf(material.quantityScheduledDeficit) + scheduledHoursDeficit );
                
                System.debug('material debug:::::'+material);
            } else if(type == 'Language Training' || type == 'Language Testing' || type == 'Interpretation' || type == 'Localization' || type == 'Curriculum Development' || type == 'Translation'){
                serviceWrapperList.add(
                      new MaterialWrapper(opli.Id,opli.Product2.Name,String.valueOf((opli.Quantity).setScale(2) + unitType),
                     opli.CLIN_LU__r.Name,opli.CLIN_LU__c,String.valueOf(opli.UnitPrice),String.valueOf((opli.UnitPrice * opli.Quantity).setScale(2)),
                     opli.Description,null,opli.Product2.Family,String.valueOf(qtyPaid.setScale(2) + unitType),
                                         String.valueOf(qtyScheduled+ unitType),String.valueOf(qtyUsed + unitType ),
                                         String.valueOf(totalQtyPlannedRemaining+ unitType),
                      String.valueOf(totalQtyPaidRemaining.setScale(2) + unitType),String.valueOf(scheduledHoursDeficit + unitType),''));
               
                if(!opli.Product2.Name.contains('Additional Student')){ // Each Additional Student
                    if( !opli.Product2.Name.contains('Registration Fee')) {
                        service.quantityPlanned = String.valueOf(Decimal.valueOf(service.quantityPlanned) + (opli.Quantity != null ? opli.Quantity : 0.00));
                        service.quantityPaid = String.valueOf(Decimal.valueOf(service.quantityPaid).setScale(2) + qtyPaid.setScale(2));
                        service.quantityPlannedRemaining = String.valueOf(Decimal.valueOf(service.quantityPlannedRemaining) + totalQtyPlannedRemaining);
                        service.quantityPaidRemaining = String.valueOf(Decimal.valueOf(service.quantityPaidRemaining).setScale(2) + totalQtyPaidRemaining.setScale(2));
                        service.quantityScheduledDeficit = String.valueOf(Decimal.valueOf(service.quantityScheduledDeficit) + scheduledHoursDeficit );
                    }
                    service.quantityScheduled = String.valueOf(Decimal.valueOf(service.quantityScheduled) + qtyScheduled);
                    service.quantityUsed = String.valueOf(Decimal.valueOf(service.quantityUsed) + qtyUsed);
                }
                service.extendedPrice = String.valueOf(Decimal.valueOf(service.extendedPrice) + extendedPrice);
            } else if(type =='ODC'){
                odcWrapperList.add(
                      new MaterialWrapper(opli.Id,opli.Product2.Name,String.valueOf(opli.Quantity + unitType),
                     opli.CLIN_LU__r.Name,opli.CLIN_LU__c, String.valueOf(opli.UnitPrice),String.valueOf((opli.UnitPrice * opli.Quantity).setScale(2)),
                     opli.Description,null,opli.Product2.Family,String.valueOf(qtyPaid+ unitType),
                                         String.valueOf(qtyScheduled+ unitType),String.valueOf(qtyUsed+ unitType),
                                         String.valueOf(totalQtyPlannedRemaining+ unitType),
                      String.valueOf(totalQtyPaidRemaining + unitType),String.valueOf(scheduledHoursDeficit + unitType),'')); 
                   odc.quantityPlanned = opli.Quantity != null ? String.valueOf(opli.Quantity) : String.valueOf(0.00);
                   odc.extendedPrice = String.valueOf(Decimal.valueOf(odc.extendedPrice) + extendedPrice);
                   odc.quantityPaid = String.valueOf(Decimal.valueOf(odc.quantityPaid) + qtyPaid);
                   odc.quantityScheduled = String.valueOf(Decimal.valueOf(odc.quantityScheduled) + qtyScheduled);
                   odc.quantityPlannedRemaining = String.valueOf(Decimal.valueOf(odc.quantityPlannedRemaining) + totalQtyPlannedRemaining);
                   odc.quantityUsed = String.valueOf(Decimal.valueOf(odc.quantityUsed) + qtyUsed);
                   
                   odc.quantityPaidRemaining = String.valueOf(Decimal.valueOf(odc.quantityPaidRemaining) + totalQtyPaidRemaining );
                   odc.quantityScheduledDeficit = String.valueOf(Decimal.valueOf(odc.quantityScheduledDeficit) + scheduledHoursDeficit );
            }
        
        }
        
          if(serviceWrapperList.size() > 0){
             serviceWrapperList.add(service);
        }
          if(odcWrapperList.size() > 0){
             odcWrapperList.add(odc);
        }
        
          if(matterialWrapperList.size() > 0){
             matterialWrapperList.add(material);
        }
        projWrapper.serviceWrapperList = serviceWrapperList;
        projWrapper.materialWrapperList = matterialWrapperList;
        projWrapper.projectlist = proList;
        projWrapper.odcWrapperList = odcWrapperList;
        
        List<Materials_Request__c> materialRequest = MaterialRequestService.getMaterial(' WHERE RecordType.DeveloperName = \'Project_Materials_Request\' AND Class_Name__c = \''+oppId+'\'','Materials_Name__r.Name,Class_Name__r.Name,RecordType.DeveloperName,Vendor_Name__r.Name');
        
        proList = ProjectService.getproject(' WHERE AcctSeed__Opportunity__c','',new Set<Id>{oppId});  // to store project related to opportunity which is launched currently
        
        List<RecordType> matReqRecTypeList = SObjectQueryService.getRecTypeListBySobjTypeAndDevName('','Materials_Request__c',new Set<String>{});
        
        OpportunityDomain.WrapperOppBudgetInfo OppBudgetInfo = new OpportunityDomain.WrapperOppBudgetInfo();
        OppBudgetInfo = OpportunityTranslator.OppBudgetInfoMethod(payItemList,scheduleList,oppLineItemList,oppList,materialRequest,proList,matReqRecTypeList );
        
        return projWrapper; 
    }
    

    
    //Added by vinitha march 16
    //This code reffered in UpdateMaterialRequestName trigger for generate the request name.
    
    @RemoteAction
    global static String getMaterialreqName(Id oppId, String recType, Id proId){ 

        system.debug('::::::::::::::::::::::oppId::::::::::'+oppId);
        Map<Id,Integer> oppIdCountMap = new Map<Id,Integer>();
        Map<Id,String> oppIdDlsclassRecMap = new Map<Id,String>();
        String matreqName;
        List<Opportunity> oppolist = new List<Opportunity>();
        List<AcctSeed__Project__c> proolist = new List<AcctSeed__Project__c>(); 
        //Id proId;
        
        if(proId != null){
            proolist = SObjectQueryService.SObjectQuery('AcctSeed__Project__c',new Set<Id>{proId},'');
            for(AcctSeed__Project__c pro : proolist) {
                if(!oppIdDlsclassRecMap.containsKey(pro.Id)) {
                    oppIdDlsclassRecMap.put(pro.Id,pro.DLS_Ref__c);
                }
            }
        } else if(oppId != null){
            oppolist = SObjectQueryService.SObjectQuery('Opportunity',new Set<Id>{oppId},'');
            system.debug(':::::::oppolist::::'+oppolist);
            for(Opportunity opp : oppolist) {
        
                if(!oppIdDlsclassRecMap.containsKey(opp.Id)) {
                    oppIdDlsclassRecMap.put(opp.Id,opp.DLS_Ref__c);
                }
            }
        }
        system.debug(':::::oppIdDlsclassRecMap'+oppIdDlsclassRecMap);
        
        // Added by Shalini on Aug 29 2017 for forming MaterialRequestNames like MR, ML based on RecordTypes

        Map<Id,Map<String,Integer>> matReqCount = MaterialRequestService.getMatReqCountbyOppAndRT(new Set<Id>{oppId}, new Set<Id>{proId}); 
        system.debug(':::matReqCount::'+matReqCount);
        if(proId != null){
            if(oppIdDlsclassRecMap.containsKey(proId)) {
                if(matReqCount.containsKey(proId)) {
                    Integer newCount;
                    if(matReqCount.get(proId).containsKey(recType)){
                        newCount = matReqCount.get(proId).get(recType) + 1;
                        if(recType == 'Project_Materials_Request'){
                            matreqName = oppIdDlsclassRecMap.get(proId)+'-MR'+newCount;
                        } else {
                            matreqName = oppIdDlsclassRecMap.get(proId)+'-ML'+newCount;
                        }
                        matReqCount.get(proId).put(recType,newCount);
                    } 
                }
            }
        } else if(oppId != null){
            if(oppIdDlsclassRecMap.containsKey(oppId)) {
                if(matReqCount.containsKey(oppId)) {
                    Integer newCount;
                    if(matReqCount.get(oppId).containsKey(recType)){
                        newCount = matReqCount.get(oppId).get(recType) + 1;
                        if(recType == 'Project_Materials_Request'){
                            matreqName = oppIdDlsclassRecMap.get(oppId)+'-MR'+newCount;
                        } else {
                            matreqName = oppIdDlsclassRecMap.get(oppId)+'-ML'+newCount;
                        }
                        matReqCount.get(oppId).put(recType,newCount);
                    } 
                }
            }
        }
        return matreqName; 
    }  
     
    /**********************************************************************
        Created by Karthiga on May 20 2017: 
        @recId - Id of OPLI Record to delete   
        return - The output message to display
    ***********************************************************************/ 
    @RemoteAction
    global static String deleteOPLIOrMR(Id recId, Boolean isOPLI){
        String res;
        if(isOPLI) {
            List<OpportunityLineItem> opli = SObjectQueryService.SObjectQuery('OpportunityLineItem', new Set<Id>{recId},'');
            res = OpportunityLineItemService.deleteOPLI(opli);
        } else {
            List<Materials_Request__c> mrList = SObjectQueryService.SObjectQuery('Materials_Request__c', new Set<Id>{recId},'');
            List<Materials_Request__c> del = MaterialRequestService.deleteMaterialrequest(mrList);
            if( del != null && del.size() > 0 ) {
                res = 'Success';
            }
        }
        if(res == 'Success') {
            return 'Deleted Succesfully';
        } else {
            return 'Something went wrong while deleting Record: ' + res;
        }
    }
    
    @RemoteAction
    global static List<Payment_Item__c> productRelatedFundItem(Id opliId, Id oppId){
        List<Payment_Item__c> payItemList = new List<Payment_Item__c>();
        if(opliId != null){
            payItemList = [SELECT Id,Name,Amount__c,Payment__c,Product__c,Project_Task__c,Quantity__c,Rate_per_Quantity__c,Product__r.Name,Project_Task__r.Name,Payment__r.Name,Opportunity_Product_Id__c FROM Payment_Item__c WHERE Payment__r.Opportunity__c = :oppId AND Opportunity_Product_Id__c = :opliId];
        }
        return payItemList;
    }
    
    @AuraEnabled
    public static String getProfileName(){
        Id profileId = userinfo.getProfileId();
        String profileName = null;
        
        if(profileId != null){
            Profile currentprofile = [SELECT Id,Name FROM Profile WHERE Id = :profileId];
            profileName = currentprofile.Name;
        }
        return profileName;
    }
    public class TreeNode {
        @AuraEnabled
        public TreeNode  parent;
        @AuraEnabled
        public Object value; 
        @AuraEnabled
        public TreeNode [] children; 
        
        public TreeNode (TreeNode  p, AcctSeed__Project_Task__c v,TreeNode [] children) {
            parent = p;
            value = v;
            children = children;
        }
    }
    public class ProjectWrapperContainer{
        @AuraEnabled
        public String parentObjectName;
        @AuraEnabled
        public list<MaterialWrapper> serviceWrapperList;
        @AuraEnabled
        public list<MaterialWrapper> materialWrapperList;
        @AuraEnabled
        public list<MaterialWrapper> odcWrapperList;
        @AuraEnabled
        public list<MaterialWrapper> regularHoursWrapperList;
        @AuraEnabled
        public list<MaterialWrapper> fringeWrapperList;
        @AuraEnabled
        public list<Materials_Request__c> loanList;
        @AuraEnabled
        public list<RequestSectionWrapper> requestlist;
        @AuraEnabled
        public list<AcctSeed__Project__c> projectlist;
        @AuraEnabled
        public string parentRecordTypeName;
        @AuraEnabled
        public List<RecordType> projectTaskRecordTypes;
        @AuraEnabled
        public Boolean isShowMaterialDelIcon;
    }
    public class MaterialWrapper{
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public String quantityPaid;
        @AuraEnabled
        public String quantityScheduled;
        @AuraEnabled
        public String quantityUsed;
        @AuraEnabled
        public String quantityPlannedRemaining;
        @AuraEnabled
        public String quantityPaidRemaining;
        @AuraEnabled
        public String quantityScheduledDeficit;
        @AuraEnabled
        public String deficitColor;
        @AuraEnabled
        public String quantityPlanned;
        @AuraEnabled
        public String clin;
        @AuraEnabled
        public String clinId;
        @AuraEnabled
        public String productPrice;
        @AuraEnabled
        public String extendedPrice;
        @AuraEnabled
        public String paidAmount;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String recType;
        @AuraEnabled
        public String totalBudjeted;
        @AuraEnabled
        public String totalAmountPaid;
        @AuraEnabled
        public String totalSpent;
        @AuraEnabled
        public String totalPaidRemaining;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public list<MaterialWrapper> childrens;
        @AuraEnabled
        public String parentTask;
        public MaterialWrapper(){
            
        }
        public MaterialWrapper(String Id,String productName,
                               String quantityPlanned,String clin, String clinId,
                               String productPrice,String extendedPrice,
                               String description,String recType,
                               String type,String quantityPaid,String quantityScheduled,
                               String quantityUsed,String quantityPlannedRemaining,
                               String quantityPaidRemaining,String quantityScheduledDeficit,String deficitColour){
            this.Id = Id;
            this.productName = productName;
            this.quantityPlanned = quantityPlanned;
            this.clin = clin;
            this.clinId = clinId;
            this.productPrice = productPrice;
            this.extendedPrice = extendedPrice;
            this.description = description;
            this.recType = recType;     
            this.type = type;
            this.quantityPaid = quantityPaid;
            this.quantityScheduled = quantityScheduled;
            this.quantityUsed = quantityUsed;
            this.quantityPlannedRemaining = quantityPlannedRemaining;                       
            this.quantityPaidRemaining = quantityPaidRemaining;
            this.quantityScheduledDeficit = quantityScheduledDeficit;
            this.deficitColor = deficitColour;                       
        }
        
    }
}