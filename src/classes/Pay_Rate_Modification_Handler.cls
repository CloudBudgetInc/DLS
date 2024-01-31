/***************************************************************************************
    Developed by GRK, to make use of it in Lightning Action
    Pay Rate Modification - Cost Rate Object
    Conditions - Only by LTS profile user and for Non-SCA LT Rate Type
****************************************************************************************/
public Class Pay_Rate_Modification_Handler{
    //For sending Cost Rate records for approval process
    public static Boolean isFromCRModify = false;
    
    /***********************************************************************************
        Developed by GRK to insert a new version of Cost Rate using the "Pay Rate Modification" action
        @crRec - Originating Cost Rate Record
        @hCost - new hourly cost value
        @effectiveDate - new effective Date value
        @reason - reason for the new version (Notes/ Reason for Change)
        return the newly inserted Cost Rate Id
    ************************************************************************************/
    @AuraEnabled
    public static String modifyCostRates(AcctSeed__Cost_Rates__c crRec, List<Contact> conRecToUpdate, String conId) {
        isFromCRModify = true;
        try {
            List<Contact> conInfo = [SELECT Id,Supervisor_Name__c,Supervisor_Name__r.Name,Title FROM Contact WHERE Id = :conId];
            
            crRec.Status__c = 'Draft';
            crRec.Prior_Version__c = crRec.Id;
            crRec.Id = null;
            
            if(conRecToUpdate.size() > 0 && conInfo.size() > 0){
                if(crRec.Change_in_Reporting_New_Manager__c == true && conInfo[0].Supervisor_Name__c != null){
                    crRec.Prior_Contact_Supervisor__c = conInfo[0].Supervisor_Name__r.Name; 
                }
                
                if(crRec.New_Job_Title__c == true && conInfo[0].Title != null){
                    crRec.Prior_Contact_Title__c = conInfo[0].Title;  
                }
                
                if(crRec.Rate_Type__c == 'FT Salary & Benefits'){
                    conRecToUpdate[0].EE_Pay_Status__c = 'Salary';
                }else if(crRec.Rate_Type__c == 'FT Hourly & Benefits'){
                    conRecToUpdate[0].EE_Pay_Status__c = 'Hourly - FT';
                }else if(crRec.Rate_Type__c == 'PT Hourly (OH & G&A)'){
                    conRecToUpdate[0].EE_Pay_Status__c = 'Hourly - PT';
                }
                
            }
            
            AcctSeed__Cost_Rates__c cr = crRec.clone(false,true,false,false);

            insert cr;
            
            if(conRecToUpdate.size() > 0){
                update conRecToUpdate;
            }
            return cr.Id;
        } catch(Exception e) {
             throw new AuraHandledException(e.getMessage());
        }
    } 
    /*************************************************************
        To return the Profile Name for the logged in User
    **************************************************************/
    @AuraEnabled
    public static costRateInfo getPermissionAccess(String lcrRateType) {
        /*List<User> curUser = UserService.getLoggedInUserInfo(UserInfo.getUserId());
        if(!curUser.isEmpty())
            return curUser[0].Profile.Name;
        else 
            return 'Error';*/
        costRateInfo crInfo = new costRateInfo();
        List<String> showFTPTPickList = new List<String>{'FT Salary & Benefits','FT Hourly & Benefits','PT Hourly (OH & G&A)','International Salary'};
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Pay_Rate_Modification_Access');
        List<SelectOptions> changeinEmployments = new List<SelectOptions>();
        System.debug('hasCustomPermission===='+hasCustomPermission);
        
        crInfo.isPermissionAccess = hasCustomPermission;
        crInfo.isShowFTPTOptions = false;
        crInfo.showJobTitle = false;
        crInfo.showPromotion = false;
        crInfo.showtransferAssignment = false;
        crInfo.showNewManager = false;
        crInfo.showNewDepartment = false;
        crInfo.selectedChangeINSalaryValues = new List<String>();
        crInfo.selectedIncentiveCompValues = new List<String>();
        crInfo.selectedChangeinEmployValues = '';

        crInfo.currentDate = System.Today();
       
        if(showFTPTPickList.contains(lcrRateType)){
            crInfo.showFTPTPickList = showFTPTPickList;
            crInfo.isShowFTPTOptions = true;
            crInfo.changeInSalary = InstructorMyProfileController.objPickListFormation('Change_in_Salary__c','AcctSeed__Cost_Rates__c');
            crInfo.homeDeptPicklist = InstructorMyProfileController.objPickListFormation('Home_Dept__c','Contact');
            crInfo.incentiveComps = InstructorMyProfileController.objPickListFormation('Incentive_Compensation__c','AcctSeed__Cost_Rates__c');
            
            List<String> changeinEmploys = InstructorMyProfileController.objPickListFormation('Change_in_Employment_Category__c','AcctSeed__Cost_Rates__c');
            for(String cIE : changeinEmploys){
                SelectOptions so = new SelectOptions();
                so.label = cIE;
                so.value = cIE;
                changeinEmployments.add(so);
            }
            crInfo.changeinEmployments = changeinEmployments;
        }
        return crInfo;
    }
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return Staff_Daily_Timesheet_Ctrl.search(String.escapeSingleQuotes(searchString),objectName,fieldName,condition,selectedIds);
    }  
    public class costRateInfo{
        @AuraEnabled
        public Boolean isPermissionAccess;
        @AuraEnabled
        public List<String> changeInSalary;
        @AuraEnabled
        public List<String> homeDeptPicklist;
        @AuraEnabled
        public Boolean isShowFTPTOptions;
        @AuraEnabled
        public List<String> showFTPTPickList;
        @AuraEnabled
        public List<String> selectedChangeINSalaryValues;
        @AuraEnabled
        public Boolean showJobTitle;
        @AuraEnabled
        public Boolean showNewManager;
        @AuraEnabled
        public Boolean showNewDepartment;
        @AuraEnabled
        public Boolean showPromotion;
        @AuraEnabled
        public Boolean showtransferAssignment;
        @AuraEnabled
        public Date currentDate;
        @AuraEnabled
        public List<String> incentiveComps;
        @AuraEnabled
        public List<SelectOptions> changeinEmployments;
        @AuraEnabled
        public List<String> selectedIncentiveCompValues;
        @AuraEnabled
        public String selectedChangeinEmployValues;
       
    }
    public class SelectOptions{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
         
         
}