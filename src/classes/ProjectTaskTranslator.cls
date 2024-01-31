/**********************************************************************
Created by Shalini on Jan 30 2017: Translator class used for Project Task object inner class formation
***********************************************************************/

global class ProjectTaskTranslator {
    
    /**********************************************************************
Modified by Shalini on Jan 30 2017: Translator class used for ProjectBudgetInfoComponent_Ctrl inner class formation
***********************************************************************/
    
    global static ProjectTaskDomain.WrapperrecTypeProjectInfo recTypeProjectInfoMethod(List<RecordType> recTypeList,List<AcctSeed__Project_Task__c> acctProTaskList,List<Materials_Request__c> materialRequests,List<RecordType> matReqRecTypeList) {
        
        ProjectTaskDomain.WrapperrecTypeProjectInfo recTypeProjectInfo = new ProjectTaskDomain.WrapperrecTypeProjectInfo();
        recTypeProjectInfo.recTypes = recTypeList;
        recTypeProjectInfo.projectTasks = acctProTaskList;
        recTypeProjectInfo.materialRequestList = materialRequests;
        recTypeProjectInfo.matReqRecTypes = matReqRecTypeList;
        
        return recTypeProjectInfo;
        
    }
    /**********************************************************************
Modified by Siva Prasanth on Apr 06 2019: ProjectTaskTranslator class used for BudgetCommunityListView_Controller Methods
***********************************************************************/ 
    public static String getBudgetInfoRecords(String projectId, List<AcctSeed__Project_Task__c> serviceproTaskList,List<AcctSeed__Project_Task__c> materialProTaskList, List<Materials_Request__c> matReqlist, List<Materials_Request__c> matLoanList,String projectRTName){
        
        ProjectTaskDomain.BudgetInformation budgetInfo = new ProjectTaskDomain.BudgetInformation();
        
        budgetInfo.projectRTName = projectRTName;
        
        // for Service Table
        if(serviceproTaskList.size() > 0){
            List<ProjectTaskDomain.ServiceInformation> serviceInfoList = new List<ProjectTaskDomain.ServiceInformation>();
            ProjectTaskDomain.ServiceInformation serviceTotalInfo = new ProjectTaskDomain.ServiceInformation();
            for(AcctSeed__Project_Task__c service : serviceproTaskList){
                ProjectTaskDomain.ServiceInformation serviceInfo = new ProjectTaskDomain.ServiceInformation();
                
                Decimal qtyScheduled = (service.Total_Hours__c != null ? service.Total_Hours__c : 0.00);
                Decimal qtyUsed = (service.Total_Qty_Used__c != null ? service.Total_Qty_Used__c : 0.00);
                Decimal qtyPlanned = (service.Total_Qty_Planned__c != null ? service.Total_Qty_Planned__c : 0.00);
                Decimal qtyPlannedRemaining = (service.Total_Qty_Planned_Remaining__c != null ? service.Total_Qty_Planned_Remaining__c : 0.00);
                
                Decimal qtyPaid = (service.Total_Qty_Paid_Formula__c != null ? service.Total_Qty_Paid_Formula__c : 0.00);
                Decimal qtyPaidRemaining = (service.Total_Qty_Paid_Remaining__c != null ? service.Total_Qty_Paid_Remaining__c : 0.00);
                
                Decimal scheduledHoursDeficit;
                String deficitColor;
                
                if(service.Total_Hours__c != null && service.Total_Qty_Planned__c != null){
                    if(service.Total_Hours__c == 0){
                        scheduledHoursDeficit = 0;
                    }else{
                        scheduledHoursDeficit = qtyScheduled - qtyPlanned;
                    }
                }else{
                    scheduledHoursDeficit = 0;
                }
                
                serviceInfo.productName = service.Name;
                serviceInfo.qtyPlanned = String.valueOf(qtyPlanned + (service.Unit__c != null ? '('+service.Unit__c+')' : ''));
                serviceInfo.qtyScheduled = String.valueOf(qtyScheduled + + (service.Unit__c != null ? '('+service.Unit__c+')' : ''));
                serviceInfo.qtyUsed = String.valueOf(qtyUsed + (service.Unit__c != null ? '('+service.Unit__c+')' : ''));
                serviceInfo.qtyPlannedRemaining = String.valueOf(qtyPlannedRemaining + (service.Unit__c != null ? '('+service.Unit__c+')' : ''));
                serviceInfo.remainingHourstobeScheduled = String.valueOf(scheduledHoursDeficit + (service.Unit__c != null ? '('+service.Unit__c+')' : ''));
                
                serviceInfo.qtyPaid = String.valueOf(qtyPaid + (service.Unit__c != null ? '('+service.Unit__c+')' : ''));
                serviceInfo.qtyPaidRemaining = String.valueOf(qtyPaidRemaining+ (service.Unit__c != null ? '('+service.Unit__c+')' : ''));
                
                serviceInfoList.add(serviceInfo);
                
                if(serviceproTaskList.size() > 1){
                
                    serviceTotalInfo.productName = 'Total';
                    serviceTotalInfo.qtyPlanned = String.valueOf(serviceTotalInfo.qtyPlanned != null ? Decimal.valueOf(serviceTotalInfo.qtyPlanned) + qtyPlanned : qtyPlanned);
                    serviceTotalInfo.qtyScheduled =  String.valueOf(serviceTotalInfo.qtyScheduled != null ? Decimal.valueOf(serviceTotalInfo.qtyScheduled ) + qtyScheduled : qtyScheduled);
                    serviceTotalInfo.qtyUsed =  String.valueOf(serviceTotalInfo.qtyUsed != null ? Decimal.valueOf(serviceTotalInfo.qtyUsed) + qtyUsed : qtyUsed);
                    serviceTotalInfo.qtyPlannedRemaining =  String.valueOf(serviceTotalInfo.qtyPlannedRemaining != null ? Decimal.valueOf(serviceTotalInfo.qtyPlannedRemaining) + qtyPlannedRemaining : qtyPlannedRemaining);
                    serviceTotalInfo.remainingHourstobeScheduled =  String.valueOf(serviceTotalInfo.remainingHourstobeScheduled != null ? Decimal.valueOf(serviceTotalInfo.remainingHourstobeScheduled) + scheduledHoursDeficit : scheduledHoursDeficit);
                    
                    serviceTotalInfo.qtyPaid =  String.valueOf(serviceTotalInfo.qtyPaid != null ? Decimal.valueOf(serviceTotalInfo.qtyPaid) + qtyPaid : qtyPaid);
                    serviceTotalInfo.qtyPaidRemaining =  String.valueOf(serviceTotalInfo.qtyPaidRemaining != null ? Decimal.valueOf(serviceTotalInfo.qtyPaidRemaining) + qtyPaidRemaining : qtyPaidRemaining);
                }
            }
            if(serviceproTaskList.size() > 1){
                serviceInfoList.add(serviceTotalInfo);
            }
            budgetInfo.serviceSectionInfo = serviceInfoList;
        }
        // Material table
        if(materialProTaskList.size() > 0){
            
            List<ProjectTaskDomain.MaterialInformation> materialInfoList = new List<ProjectTaskDomain.MaterialInformation>();
            ProjectTaskDomain.MaterialInformation matFieldTotalWrap = new ProjectTaskDomain.MaterialInformation(); 
            for(AcctSeed__Project_Task__c material : materialProTaskList){
                
                ProjectTaskDomain.MaterialInformation materialInfo = new ProjectTaskDomain.MaterialInformation();
                materialInfo.productName = material.Name;
                materialInfo.qtyPlanned = String.valueOf((material.Total_Qty_Planned__c != null ? material.Total_Qty_Planned__c : 0.00) + (material.Unit__c != null ? '('+material.Unit__c+')' : ''));
                materialInfo.price = String.valueOf(material.Rate__c != null ? material.Rate__c : 0.00);
                materialInfo.extendedPrice = String.valueOf((material.Total_Qty_Planned__c != null && material.Rate__c != null) ? (material.Total_Qty_Planned__c * material.Rate__c).setScale(2) : 0.00);
                materialInfo.materialBudgetRequested =  String.valueOf(material.Total_Budgeted__c != null ? material.Total_Budgeted__c : 0.00);
                materialInfo.materialBudgetPaid =  String.valueOf(material.Total_Amount_Paid__c != null ? material.Total_Amount_Paid__c : 0.00);
                materialInfo.materialBudgetUsed = String.valueOf(material.Total_Spent__c != null ? material.Total_Spent__c : 0.00);
                materialInfo.materialPaidRemaining = String.valueOf(material.Total_Amount_Paid_Remaining__c != null ? material.Total_Amount_Paid_Remaining__c : 0.00);
                materialInfoList.add(materialInfo);
                
                if(materialProTaskList.size() > 1){
                    matFieldTotalWrap.productName = 'Total';
                    matFieldTotalWrap.qtyPlanned = String.valueOf(matFieldTotalWrap.qtyPlanned != null ? Decimal.valueOf(matFieldTotalWrap.qtyPlanned) + Decimal.valueOf(String.valueOf(material.Total_Qty_Planned__c != null ? material.Total_Qty_Planned__c : 0.00)) : Decimal.valueOf(String.valueOf(material.Total_Qty_Planned__c != null ? material.Total_Qty_Planned__c : 0.00)));
                    matFieldTotalWrap.extendedPrice = String.valueOf(matFieldTotalWrap.extendedPrice != null ? Decimal.valueOf(matFieldTotalWrap.extendedPrice) + Decimal.valueOf(materialInfo.extendedPrice) : Decimal.valueOf(materialInfo.extendedPrice));
                    matFieldTotalWrap.price = String.valueOf(matFieldTotalWrap.price != null ? Decimal.valueOf(matFieldTotalWrap.price) + Decimal.valueOf(materialInfo.price) : Decimal.valueOf(materialInfo.price));
                    matFieldTotalWrap.materialBudgetRequested = String.valueOf(matFieldTotalWrap.materialBudgetRequested != null ? Decimal.valueOf(matFieldTotalWrap.materialBudgetRequested) + Decimal.valueOf(materialInfo.materialBudgetRequested) : Decimal.valueOf(materialInfo.materialBudgetRequested));
                    matFieldTotalWrap.materialBudgetPaid = String.valueOf(matFieldTotalWrap.materialBudgetPaid != null ? Decimal.valueOf(matFieldTotalWrap.materialBudgetPaid) + Decimal.valueOf(materialInfo.materialBudgetPaid) : Decimal.valueOf(materialInfo.materialBudgetPaid));
                    matFieldTotalWrap.materialBudgetUsed = String.valueOf(matFieldTotalWrap.materialBudgetUsed != null ? Decimal.valueOf(matFieldTotalWrap.materialBudgetUsed) + Decimal.valueOf(materialInfo.materialBudgetUsed) : Decimal.valueOf(materialInfo.materialBudgetUsed));
                    matFieldTotalWrap.materialPaidRemaining = String.valueOf(matFieldTotalWrap.materialPaidRemaining != null ? Decimal.valueOf(matFieldTotalWrap.materialPaidRemaining) + Decimal.valueOf(materialInfo.materialPaidRemaining) : Decimal.valueOf(materialInfo.materialPaidRemaining));
                }
            }
            if(materialProTaskList.size() > 1){
                materialInfoList.add(matFieldTotalWrap);
            }
            budgetInfo.materialSectionInfo = materialInfoList;
        }
        
        //for Material Request Table
        if(matReqlist.size() > 0){
            List<ProjectTaskDomain.MaterialRequestInformation> materailReqInfoList = new List<ProjectTaskDomain.MaterialRequestInformation>();
            ProjectTaskDomain.MaterialRequestInformation materialReqTotalInfo = new ProjectTaskDomain.MaterialRequestInformation();
            for(Materials_Request__c mr : matReqlist){
                ProjectTaskDomain.MaterialRequestInformation materialReqInfo = new ProjectTaskDomain.MaterialRequestInformation();
                materialReqInfo.request = mr.Name;
                materialReqInfo.requestStatus = mr.Request_Status__c;
                materialReqInfo.dateDelivered = String.ValueOf(mr.Date_Delivered__c);
                materialReqInfo.materialTitle = mr.Materials_Name__r.Name;
                materialReqInfo.materialSalesTax = String.valueOf(mr.DLS_Sales_Tax_Formula__c != null ? mr.DLS_Sales_Tax_Formula__c :0.00);
                materialReqInfo.qty = String.valueOf(mr.Qty__c != null ? mr.Qty__c :0.00);
                materialReqInfo.dlsTotal = String.valueOf(mr.DLS_Total__c != null ? mr.DLS_Total__c :0.00);
                materailReqInfoList.add(materialReqInfo);
                
                if(matReqlist.size() > 1){
                    materialReqTotalInfo.request = 'Total';
                    materialReqTotalInfo.materialSalesTax = String.valueOf(materialReqTotalInfo.materialSalesTax != null ? Decimal.valueOf(materialReqTotalInfo.materialSalesTax) + Decimal.valueOf(materialReqInfo.materialSalesTax) : Decimal.valueOf(materialReqInfo.materialSalesTax));
                    materialReqTotalInfo.qty = String.valueOf(materialReqTotalInfo.qty != null ? Decimal.valueOf(materialReqTotalInfo.qty) + Decimal.valueOf(materialReqInfo.qty) : Decimal.valueOf(materialReqInfo.qty));
                    materialReqTotalInfo.dlsTotal = String.valueOf(materialReqTotalInfo.dlsTotal != null ? Decimal.valueOf(materialReqTotalInfo.dlsTotal) + Decimal.valueOf(materialReqInfo.dlsTotal) : Decimal.valueOf(materialReqInfo.dlsTotal));
                }
            }
            if(matReqlist.size() > 1){
                materailReqInfoList.add(materialReqTotalInfo);
            }
            budgetInfo.materialRequestSectionInfo = materailReqInfoList;
        }
        //for Material Loan Table
        if(matLoanList.size() > 0){
            List<ProjectTaskDomain.MaterialRequestInformation> materialLoanInfoList = new List<ProjectTaskDomain.MaterialRequestInformation>();
            ProjectTaskDomain.MaterialRequestInformation materialLoanTotalInfo = new ProjectTaskDomain.MaterialRequestInformation();
            for(Materials_Request__c ml : matLoanList){
                ProjectTaskDomain.MaterialRequestInformation materialLoanInfo = new ProjectTaskDomain.MaterialRequestInformation();
                
                materialLoanInfo.request = ml.Name;
                materialLoanInfo.materialTitle = ml.Materials_Name__r.Name;
                materialLoanInfo.contact = ml.Contact__r.Name;
                materialLoanInfo.loanStatus = ml.Request_Status__c;
                materialLoanInfo.dateLoanedOut = String.valueOf(ml.Date_Loaned_Out__c);
                materialLoanInfo.dateReturned = String.valueOf(ml.Date_Returned__c);
                materialLoanInfo.qty = String.valueOf(ml.Qty__c);
                materialLoanInfoList.add(materialLoanInfo);
                
                if(matLoanList.size() > 1){
                    materialLoanTotalInfo.request = 'Total';
                    materialLoanTotalInfo.qty = String.valueOf(materialLoanTotalInfo.qty != null ? (Decimal.valueOf(materialLoanTotalInfo.qty) + Decimal.valueOf(materialLoanInfo.qty)) :   Decimal.valueOf(materialLoanInfo.qty));
                }
            }
            if(matLoanList.size() > 1){
                materialLoanInfoList.add(materialLoanTotalInfo);
            }
            budgetInfo.materialLoanSectionInfo = materialLoanInfoList;
        }
        
        return JSON.serialize(budgetInfo);
    }
}