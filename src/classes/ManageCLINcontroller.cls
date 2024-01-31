/* Developed by Shalini on June 22 2017 to manage CLIN records. This is refered in "ManageCLIN" page*/

public class ManageCLINcontroller{
    
    public CLIN__c clinRec;
    public Id contractId {get; set;}
    public Id clinId {get; set;} 
    public ManageCLINcontroller(ApexPages.StandardController controller) {
        clinRec = new CLIN__c();
        clinRec = (CLIN__c)controller.getRecord();
        
        clinId = clinRec.Id;
        
        if(clinId != null){
            CLIN__c c = [SELECT Id, Contract__c FROM CLIN__c WHERE Id = :clinId];
            contractId = c.Contract__c;
        } else {
            contractId = clinRec.Contract__c;
        }
        system.debug('::clinId:::'+clinId);
        system.debug('::contractId:::'+contractId);
    }
    
        
    public class ClinValues {
        public String name;
        public String clinName;
        public Decimal amountFunded;
        public Integer clinMaxQty;
        public String clinType;
        public String clinUnit;
        public Decimal clinUnitPrice;
        public String clinStartDate;
        public String clinEndDate;
        public Id parentClinId;
        public Id contractId;
        public String parentClinName;
    }
    
    @RemoteAction
    public static List<CLIN__c> getCLINrecs(Id contractId){
        system.debug('::contractId::'+contractId);
        
        List<CLIN__c> CLINList = new List<CLIN__c>();
        CLINList = [SELECT Id, Name, CLIN_End_Date__c, CLIN_Name__c, CLIN_Start_Date__c,Amount_Funded__c, CLIN_Type__c, Contract__c, CLIN_Max_Amount__c, CLIN_Max_Quantity__c, CLIN_Unit__c, CLIN_Unit_Price__c, Parent_CLIN__c, Parent_CLIN__r.CLIN_Name__c,Parent_CLIN__r.Name,Total_Amount_Invoiced_rollup__c FROM CLIN__c WHERE Contract__c = :contractId ORDER BY Name ASC];
        
        return CLINList;
    }
    @RemoteAction
    public static List<Contract> getContractInfo(Id contractId){
        system.debug('::contractId::'+contractId);
        
        List<Contract> contractInfo = new List<Contract>();
        contractInfo = [SELECT Id, Name, Amount_Funded__c, StartDate, EndDate,Contract_Type__c, Total_Amount_Funded_All_CLINs__c,APXT_Redlining__Contract_Family_Parent__c FROM Contract WHERE Id = :contractId];
        system.debug('::contractInfo::'+contractInfo);
        return contractInfo;
    }
    @RemoteAction
    public static List<Contract> getAllContracts(){
        
        List<Contract> contractInfo = new List<Contract>();
        contractInfo = [SELECT Id, Name, Amount_Funded__c, EndDate, StartDate, Contract_Type__c, Total_Amount_Funded_All_CLINs__c FROM Contract];
        
        return contractInfo;
    }
    @RemoteAction
    public static List<String> picklistvalues(String ObjectName, String PickListName){
        List<String> pickListvalues = new List<String>();
        pickListvalues.addAll(StudentTestResult_ReportPage_Controller.PicklistValues(ObjectName, PickListName));
        return pickListvalues;  
    }
    @RemoteAction
    public static List<CLIN__c> getAllCLINs(Id contractId) {
        
        return [SELECT Id, Name, CLIN_End_Date__c, CLIN_Name__c, CLIN_Start_Date__c, CLIN_Type__c, Contract__c, CLIN_Max_Amount__c, CLIN_Max_Quantity__c, CLIN_Unit__c, CLIN_Unit_Price__c, Parent_CLIN__c, Parent_CLIN__r.CLIN_Name__c,Parent_CLIN__r.Name,Amount_Funded__c,Total_Amount_Invoiced_rollup__c FROM CLIN__c WHERE Contract__c = :contractId ORDER BY Name ASC];
    }
    @RemoteAction
    public static List<CLIN__c> createCLIN(String newclinStr, String updateListStr) { 
        system.debug('::newclinStr::'+newclinStr);
        system.debug('::updateListStr::'+updateListStr);
        List<CLIN__c> updateList = new List<CLIN__c>();
        List<CLIN__c> newClinListToInsert = new List<CLIN__c>();

        
        try {
            if(String.isNotBlank(updateListStr)) {
                updateList = (List<CLIN__c>)JSON.deserialize(updateListStr, List<CLIN__c>.class);
            }
            
            List<ClinValues> newClinList = new List<ClinValues>();
            if(String.isNotBlank(newclinStr)) {
                newClinList = (List<ClinValues>)JSON.deserialize(newclinStr, List<ClinValues>.class);
            }
            System.debug('::newClinList::'+newClinList);
            for(ClinValues clin : newClinList){
                if(clin.clinName != null){
                    CLIN__c clinRec = new CLIN__c(Name=clin.name,CLIN_Name__c=clin.clinName,Amount_Funded__c=clin.amountFunded, CLIN_Type__c=clin.clinType, CLIN_Max_Quantity__c=((clin.clinMaxQty != null) ? Integer.ValueOf(clin.clinMaxQty) : null), CLIN_Unit__c=clin.clinUnit, CLIN_Unit_Price__c=((clin.clinUnitPrice != null) ? clin.clinUnitPrice : null), CLIN_Start_Date__c=((clin.clinStartDate != null) ? Date.ValueOf(clin.clinStartDate) : null), CLIN_End_Date__c=((clin.clinEndDate != null) ? Date.ValueOf(clin.clinEndDate) : null), Parent_CLIN__c=clin.parentClinId, Contract__c=clin.contractId); 
                    newClinListToInsert.add(clinRec);
                }
            }
            if(updateList.size() > 0){
                update updateList;
            }
            if(newClinListToInsert.size() > 0){
                insert newClinListToInsert;
                updateList.addALL(newClinListToInsert);
            }
            System.debug('::updateList::'+updateList);
        } catch(Exception e){
            system.debug('::e::'+e);
            throw new VisualforceException(e.getMessage());
        }
        
        return updateList;
    }
    
    @RemoteAction
    public static List<CLIN__c> deleteCLIN(String deleteListStr) { 
        system.debug('::deleteListStr::'+deleteListStr);
        List<CLIN__c> deleteList = new List<CLIN__c>();
        try{
            if(String.isNotBlank(deleteListStr)) {
                deleteList = (List<CLIN__c>)JSON.deserialize(deleteListStr, List<CLIN__c>.class);
            }
            delete deleteList;
        } catch (Exception e){
            system.debug('::e::'+e);
        }
        return deleteList;
    }
     
}