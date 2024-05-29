/*************************
Developed by Shalini to update Dates of CAs, Schedules, Project Task and to create Planned_Day_Off records based on changed dates of Project
**************************/

global class ManageProjectDatescontroller {
    
    public String parentId {get; set;}
    public String projectStatus {get; set;}
    public static Boolean skipCAStatusUpdate = false;
    
    public static Boolean isFromManageProjectDate_Status = False;
    public static List<Opportunity> opp_MPD = new List<Opportunity>();
    public static List<Contact_Assignments__c> conAssign_MPD = new List<Contact_Assignments__c>();
    public static List<AcctSeed__Project_Task__c> projTask_MPD = new List<AcctSeed__Project_Task__c>();
    public static List<Schedule__c> schedule_MPD = new List<Schedule__c>();
    public static List<Planned_Days_Off__c> insertPDO_MPD = new List<Planned_Days_Off__c>();
    public static List<Planned_Days_Off__c> deletePDO_MPD = new List<Planned_Days_Off__c>();
    public static List<Assessment_Report__c> assessRep_MPD = new List<Assessment_Report__c>();
    
    public ManageProjectDatescontroller() {
        parentId = ApexPages.currentPage().getParameters().get('id');
        projectStatus = null;
        
        String[] parentInfo = (parentId != '' & parentId != null) ? parentId.split('_'): new List<String>{};
        if(parentInfo.size() > 1){
            parentId = parentInfo[0];
            projectStatus = parentInfo[1];
        }
    }
    

    global class ConAssign_Sch_PlannedDay {
        public List<Contact_Assignments__c> conAssign;
        public List<Contact_Assignments__c> endedCAFromOnHoldForInActiveLCR;
        public List<Schedule__c> schedules;
        public List<Days_Off_Wrapper> planDaysOff;
        public List<AcctSeed__Project_Task__c> projectTask;
        public AcctSeed__Project__c pro;
        public Opportunity opp;
        public String parentType;
        public List<Assessment_Report__c> finalAssessmentReports; //Added By Dhinesh - 12/10/2021
        public Boolean allowFinalReportsDateUpdate; //Added By Dhinesh -  W-007683 - 18/1/2023 - to restrict change the report date for DODA with SLP-FT / SLP-PT / JMAS / PLP
    }
    
    global class Days_Off_Wrapper {
        public Planned_Days_Off__c dayOff;
        public Boolean selected;
        public String contactName;
    }
    
    global class CARecords {
        public List<Contact_Assignments__c> conAssign;
        public List<Contact_Assignments__c> endedCAFromOnHoldForInActiveLCR;
    }
    
    public static Boolean makeStatusAsEnded = false;
    public static Boolean makeStatusAsActive = false;
    
    @RemoteAction
    
    global static ConAssign_Sch_PlannedDay getChilDetails(String parentId, String proStatus, String returnType){
        system.debug('::parentId::'+parentId);
        system.debug('::proStatus::'+proStatus);
        system.debug('::returnType::'+returnType);
        
        if(String.isBlank(parentId)){
            parentId = ApexPages.currentPage().getParameters().get('id');
        }
        
        // Get the Key Prefix for Opportunity, Project Object
        Schema.DescribeSObjectResult r = AcctSeed__Project__c.sObjectType.getDescribe();
        String projectKeyPrefix = r.getKeyPrefix();
        
        Schema.DescribeSObjectResult opp = Opportunity.sObjectType.getDescribe();
        String opportunityKeyPrefix = opp.getKeyPrefix();
        
        ConAssign_Sch_PlannedDay childDetails = new ConAssign_Sch_PlannedDay();
        List<AcctSeed__Project__c> proj = new List<AcctSeed__Project__c>();
        //Added
        List<AcctSeed__Project_Task__c> projTask = new List<AcctSeed__Project_Task__c>();
        //Ended
        List<Opportunity> oppo = new List<Opportunity>();
        List<Contact_Assignments__c> conass = new List<Contact_Assignments__c>();
        List<Schedule__c> sch = new List<Schedule__c>();
        List<Planned_Days_Off__c> plan = new List<Planned_Days_Off__c>();
        List<Days_Off_Wrapper> daysWrap = new List<Days_Off_Wrapper>();
        List<Assessment_Report__c> finalAssessmentReports = new List<Assessment_Report__c>(); //Added By Dhinesh - 12/10/2021
        Boolean allowFinalReportsDateUpdate = true;
        
        if(String.IsNotBlank(parentId)) {
            if(parentId.subString(0,3) == projectKeyPrefix) {
                childDetails.parentType = 'Project';
                //conass = [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Project__c, Project__r.Name, Project_Task__c, Project_Task__r.Name, Start_Date__c, End_Date__c, Assignment_Position__c, Status__c,RecordType.DeveloperName FROM Contact_Assignments__c WHERE Status__c != 'Ended' AND Project__c = :parentId];
                /************
                    - W-008028 : Manage Project Status Button Action Reverts Withdrawn Student CA's back to Updated Project Status
                    - Canceled & Withdrawn status condition added on Apr 22 2024
                    - To prevent updating the status of Canceled and Withdrawn CAs when updating the project's status via the Manage Project Status button.
                    *************/
                conass = ContactAssignmentService.getContactassignmentByprojectId(' WHERE Status__c  NOT IN (\'Ended\',\'Transferred\',\'Canceled\',\'Withdrawn\') AND Rate_Card_Rate__r.Expiration_Date__c = null AND Project__c ','Project__r.Name,Project__r.End_Date__c,Candidate_Name__r.Name,Project_Task__r.Name,RecordType.DeveloperName,Rate_Card_Rate__r.Cost_Rate_Name__c, Rate_Card_Rate__r.Status__c',new Set<Id>{parentId},'');
                //sch = [SELECT Id, Name, Project__c, Project_Task__c,Room__c,Room__r.Name, Project_Task__r.Name, Days__c, Start_Date__c, Start_Time__c, End_Date__c, End_Time__c, Status__c, Instructor__c, Instructor__r.Name FROM Schedule__c WHERE Status__c NOT IN ('Canceled','Completed') AND Project__c = :parentId];
                sch = ScheduleService.getScheduleRec(' WHERE Status__c NOT IN (\'Canceled\',\'Canceled\',\'Completed\') AND Project__c ',',Project__r.Name,Project_Task__r.Name,Instructor__r.Name,Room__r.Name',new Set<Id>{parentId});
                //proj = SObjectQueryService.SObjectQuery('AcctSeed__Project__c',new Set<Id>{parentId},',RecordType.DeveloperName,AcctSeed__Account__r.Name,Program_Iteration__r.Project_Type__c');
                proj = [SELECT Id, Name,Program_Iteration__c,AcctSeed__Account__c,Start_Date__c,End_Date__c,AcctSeed__Status__c,RecordType.DeveloperName,AcctSeed__Account__r.Name,Program_Iteration__r.Project_Type__c FROM AcctSeed__Project__c WHERE Id = :parentId];

                
                if(proj.size() > 0){
                    if(proj[0].RecordType.DeveloperName == 'DLI_W_LT_Projects'){
                        plan = [SELECT Id, Name, Date__c,Type__c, Project__c,Opportunity__c,Contact__c, Contact__r.Name,Description__c,Requested_Reschedule_Date__c FROM Planned_Days_Off__c WHERE Project__c = :parentId ORDER BY Name DESC];
                    }
                    childDetails.pro = proj[0];
                    
                    //Added By Dhinesh -  W-007683 - 18/1/2023 - to restrict change the report date for DODA with SLP-FT / SLP-PT / JMAS / PLP
                    if(proj[0].AcctSeed__Account__r.Name.contains('DODA') && ( proj[0].Program_Iteration__c != null && (proj[0].Program_Iteration__r.Project_Type__c == 'SLP-FT' || proj[0].Program_Iteration__r.Project_Type__c == 'SLP-PT' || proj[0].Program_Iteration__r.Project_Type__c == 'JMAS' || proj[0].Program_Iteration__r.Project_Type__c == 'PLP'))){
                        allowFinalReportsDateUpdate = false;
                    }
                }

                //Added
                // Query the related Project task records to dispaly it on Manage Project Date Page - added by E.Keerthika on 20/04/2018
                projTask = ProjectTaskService.getProjectTaskRecbyParentId(', Parent_Project_Task__r.Name',' WHERE AcctSeed__Project__c ',new Set<Id> {parentId},'');
                //Ended
                AssessmentReportService.sortByReportDate = true;
                finalAssessmentReports = AssessmentReportService.getAssessmentReports('Project__c = \''+parentId+'\'', '');  // Modified By Dhinesh - 11/2/2022 - removed filter "Language_Training_Status__c = \'Final\' AND " - to show all reports on project date change - W-007204 
                
            } else if(parentId.subString(0,3) == opportunityKeyPrefix) {
                childDetails.parentType = 'Opportunity';
                //conass = [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Project__c, Project__r.Name, Project_Task__c, Project_Task__r.Name, Start_Date__c, End_Date__c, Assignment_Position__c, Status__c,Opportunity_Name__c,Opportunity_Name__r.Name,RecordType.DeveloperName FROM Contact_Assignments__c WHERE Status__c != 'Ended' AND Opportunity_Name__c = :parentId];
                conass = ContactAssignmentService.getContactassignmentByprojectId(' WHERE Status__c != \'Ended\' AND Opportunity_Name__c ','Project__r.Name,Candidate_Name__r.Name,Project_Task__r.Name,RecordType.DeveloperName,Opportunity_Name__r.Name,Rate_Card_Rate__r.Cost_Rate_Name__c, Rate_Card_Rate__r.Status__c',new Set<Id>{parentId},'');
                //sch = [SELECT Id, Name, Project__c, Project_Task__c,Room__c,Room__r.Name, Project_Task__r.Name, Days__c, Start_Date__c, Start_Time__c, End_Date__c, End_Time__c, Status__c, Instructor__c, Instructor__r.Name,Opportunity__c,Opportunity__r.Name FROM Schedule__c WHERE Status__c NOT IN ('Canceled','Completed') AND Opportunity__c = :parentId];
                sch = ScheduleService.getScheduleRec(' WHERE Status__c NOT IN (\'Canceled\',\'Canceled\',\'Completed\') AND Opportunity__c ',',Project__r.Name,Instructor__r.Name,Project_Task__r.Name,Opportunity__r.Name,Room__r.Name',new Set<Id>{parentId});
                //oppo = [SELECT Id,Name,StageName,Start_Date__c,End_Date__c,RecordType.DeveloperName,Project_Type__c FROM Opportunity WHERE Id = :parentId];
                oppo = SObjectQueryService.SObjectQuery('Opportunity',new Set<Id>{parentId},',RecordType.DeveloperName');
                if(oppo.size() > 0){
                    if(oppo[0].RecordType.DeveloperName == 'DLI_W_TO_Opportunities' && (oppo[0].Project_Type__c == 'AFPAK' || oppo[0].Project_Type__c == 'Resident LT')){
                        plan = [SELECT Id, Name, Date__c, Type__c,Project__c,Opportunity__c,Contact__c, Contact__r.Name,Description__c,Requested_Reschedule_Date__c FROM Planned_Days_Off__c WHERE RecordType.DeveloperName = 'Project_Planned_Days_Off' AND Opportunity__c = :parentId ORDER BY Name DESC];
                    }
                    childDetails.opp = oppo[0];
                }
            }
        }    
        System.debug('conass::::'+conass);
        if(parentId.subString(0,3) == projectKeyPrefix) {
            
            if(proStatus == 'Active' || (String.isBlank(proStatus) && returnType == 'ToDetailPage' && proj.size() > 0 && proj[0].AcctSeed__Status__c == 'Active')){
                CARecords caRec = checkCACostRateIsINActive(conass);
                childDetails.conAssign = caRec.conAssign;
                childDetails.endedCAFromOnHoldForInActiveLCR = caRec.endedCAFromOnHoldForInActiveLCR;
            }else{
                childDetails.conAssign = conass;
                childDetails.endedCAFromOnHoldForInActiveLCR = new List<Contact_Assignments__c>();
            }
        }else{
            childDetails.conAssign = conass;
            childDetails.endedCAFromOnHoldForInActiveLCR = new List<Contact_Assignments__c>();

        }
        
        childDetails.schedules = sch;
        for(Planned_Days_Off__c p : plan){
            Days_Off_Wrapper da = new Days_Off_Wrapper();
            da.dayOff = p;
            da.contactName = p.Contact__r.Name;
            da.selected = true;
            daysWrap.add(da);
        }
        childDetails.planDaysOff = daysWrap;
        childDetails.projectTask = projTask;
        childDetails.finalAssessmentReports = finalAssessmentReports;
        childDetails.allowFinalReportsDateUpdate = allowFinalReportsDateUpdate; //Added By Dhinesh -  W-007683 - 18/1/2023 - to restrict change the report date for DODA with SLP-FT / SLP-PT / JMAS / PLP
        
        return childDetails;
    }
    /* this method to check whether CAs has Inactive LCR or not
       if CAs has Inactive LCR, then create Active CA with assign the recent LCR of parent LCR to CA costRate field*/
    public static CARecords checkCACostRateIsINActive(List<Contact_Assignments__c> conAssigns){
        List<Contact_Assignments__c> otherCAs = new List<Contact_Assignments__c>();
        List<Contact_Assignments__c> inActiveCRRelCAToNewCA = new List<Contact_Assignments__c>();
        List<Contact_Assignments__c> endedCAFromOnHoldForInActiveLCR = new List<Contact_Assignments__c>();
        Map<Id,AcctSeed__Cost_Rates__c> oldCRWirthNewCRMap = new Map<Id,AcctSeed__Cost_Rates__c>();
        Set<Id> inActiveCRSet = new Set<Id>();
        Set<Id> inActiveLCRRelCAIdSet = new Set<Id>();
        
        CARecords caRec = new CARecords();
        for(Contact_Assignments__c ca : conAssigns){
            if(ca.Rate_Card_Rate__c != null && ca.Rate_Card_Rate__r.Status__c == 'Inactive' && ca.RecordType.DeveloperName == 'Instructor'){
                inActiveCRSet.add(ca.Rate_Card_Rate__c);
                inActiveLCRRelCAIdSet.add(ca.Id);

                /* Modified by Siva Prasanth , assign the old CA Status as Ended if CA has Inactive LCR and Status equal to On Hold*/
                if(ca.Status__c == 'On Hold'){
                    Contact_Assignments__c caIns = new Contact_Assignments__c();
                    caIns.Status__c = 'Ended';
                    caIns.Id = ca.Id;
                    endedCAFromOnHoldForInActiveLCR.add(caIns);
                }
            } else {
                otherCAs.add(ca);   
            }
        }
        
        if(inActiveLCRRelCAIdSet.size() > 0) {
            inActiveCRRelCAToNewCA = SObjectQueryService.SObjectQuery('Contact_Assignments__c',inActiveLCRRelCAIdSet,',Candidate_Name__r.Name,Project__r.End_Date__c,RecordType.DeveloperName,Project_Task__r.Name');
            
            /* get the recent Child LCR of parent(Prior_Version__c) LCR and its assign to new CA*/
            for(AcctSeed__Cost_Rates__c cr : CostRateService.getCostRateByParentId(' WHERE Status__c != \'Inactive\' AND Prior_Version__c','',inActiveCRSet,' Order By Effective_Date__c Desc')){
                if(!oldCRWirthNewCRMap.containsKey(cr.Prior_Version__c)){
                    oldCRWirthNewCRMap.put(cr.Prior_Version__c,cr);  
                }
            }
            
            for(Contact_Assignments__c ca : inActiveCRRelCAToNewCA){
                             
                ca.Id = null;
                ca.Start_Date__c = System.Today();
                ca.Status__c = 'Active';
               
                if(ca.Project__r.End_Date__c != null){
                    ca.End_Date__c = ca.Project__r.End_Date__c;
                }
                
                //System.debug('ca.Rate_Card_Rate__c::::'+ca.Rate_Card_Rate__c);
                if(oldCRWirthNewCRMap.containsKey(ca.Rate_Card_Rate__c)){
                    AcctSeed__Cost_Rates__c lcr = oldCRWirthNewCRMap.get(ca.Rate_Card_Rate__c);
                    ca.Rate_Card_Rate__c = null;

                    if(lcr.Status__c == 'Approved'){
                        ca.Rate_Card_Rate__c = lcr.Id;
                    }else{
                        ca.Drafted_Labor_Cost_Rate__c = lcr.Id;
                    }
                }else{
                    ca.Rate_Card_Rate__c = null;
                }
            }
            otherCAs.addAll(inActiveCRRelCAToNewCA);
        }
            
        caRec.conAssign = otherCAs;
        caRec.endedCAFromOnHoldForInActiveLCR = endedCAFromOnHoldForInActiveLCR;
        
        return caRec;
    }
    @RemoteAction 
    global static String saveAllDetails(String proStr,String oppStr,String ptStr, String caStr,String scStr,String daysInsStr,String daysDelStr, String assessmentReportsStr, String proStatus){
         
        skipCAStatusUpdate = true;
        String status;
         
        List<AcctSeed__Project__c> pro = new List<AcctSeed__Project__c>();
        if(String.isNotBlank(proStr)) {
            pro = (List<AcctSeed__Project__c>)JSON.deserialize(proStr, List<AcctSeed__Project__c>.class);
        }
        
        List<Schedule__c> scList = new List<Schedule__c>();
        if(String.isNotBlank(scStr)) {
            scList = (List<Schedule__c>)JSON.deserialize(scStr, List<Schedule__c>.class);
        }
        
        List<Contact_Assignments__c> caList = new List<Contact_Assignments__c>();
        if(String.isNotBlank(caStr)) {
            caList = (List<Contact_Assignments__c>)JSON.deserialize(caStr, List<Contact_Assignments__c>.class);            
        }
        
        try {
            if(pro.size() > 0){
               
                //W-007662 - to fix the &amp; issue in Default_Cost_Rate_Rate_Type__c value

               /*if(pro[0].Default_Cost_Rate_Rate_Type__c != null){
                    String defaulTCRRT =  pro[0].Default_Cost_Rate_Rate_Type__c;
                    pro[0].Default_Cost_Rate_Rate_Type__c = defaulTCRRT.replaceFirst('&amp;', '&');
                }*/
                
                if(proStatus == 'Ended') {
                   for(AcctSeed__Project__c proj : pro) {
                       makeStatusAsEnded = true;
                       if(proj.AcctSeed__Status__c == 'On Hold'){
                           proj.Last_Date_on_Hold__c = proj.End_Date__c;
                       }
                       proj.AcctSeed__Status__c = 'Ended';
                   }
                }else if(proStatus == 'Active'){
                    for(AcctSeed__Project__c proj : pro) {
                       makeStatusAsActive = true;
                       proj.AcctSeed__Status__c = 'Active';
                       if(proj.On_Hold_Date__c != null) {
                           proj.On_Hold_Date__c = null;
                       }
                   }
                }
                
                //update pro;                
           }
           
            System.debug(':::caList:::'+caList);
            if(caList.size() > 0 && pro.size() < 1){
                upsert caList;
            }
            
            if(scList.size() > 0){
                if(proStatus == 'Ended') {
                    for(Schedule__c sch : scList){
                        sch.Status__c = 'Completed';
                    }
                }else if(proStatus == 'Active'){
                    for(Schedule__c sch : scList){
                        sch.Status__c = 'Active';
                    }
                    CustomButtonService.isFromManageProjectStatus = true;
                    //skipCAStatusUpdate = true;
                }
                
                if(pro.size() < 1){
                    update scList;
                }
            }
            
            List<Opportunity> opp = new List<Opportunity>();
            if(String.isNotBlank(oppStr)) {
                opp = (List<Opportunity>)JSON.deserialize(oppStr, List<Opportunity>.class);
            }
            
            // To update the Start/End date modified Project Task records - added by E.Keerthika on 20/04/2018
            List<AcctSeed__Project_Task__c> ptList = new List<AcctSeed__Project_Task__c>();
            if(String.isNotBlank(ptStr))
                ptList = (List<AcctSeed__Project_Task__c>)JSON.deserialize(ptStr, List<AcctSeed__Project_Task__c>.class);
            
            List<Planned_Days_Off__c> daysInsList = new List<Planned_Days_Off__c>();
            if(String.isNotBlank(daysInsStr)) {
                daysInsList = (List<Planned_Days_Off__c>)JSON.deserialize(daysInsStr, List<Planned_Days_Off__c>.class);
                
                // Populate Contact related user values
                Set<Id> contactIds = new Set<Id>();
                
                for(Planned_Days_Off__c off : daysInsList){
                    contactIds.add(off.Contact__c);
                }
                
                if(contactIds.size() > 0) {
                    Map<Id,Id> conIdUserId = new Map<Id,Id>();
                    conIdUserId = PlannedDaysOffHandler.getContactRelatedUsers(contactIds);
                    
                    for(Planned_Days_Off__c off : daysInsList){
                        if(conIdUserId.containsKey(off.Contact__c))
                            off.User__c = conIdUserId.get(off.Contact__c);
                    }
                }
            }
            
            List<Planned_Days_Off__c> daysDelList = new List<Planned_Days_Off__c>();
            if(String.isNotBlank(daysDelStr)) {
                daysDelList = (List<Planned_Days_Off__c>)JSON.deserialize(daysDelStr, List<Planned_Days_Off__c>.class);
            }
            
            List<Assessment_Report__c> assessmentReports = new List<Assessment_Report__c>();
            if(String.isNotBlank(assessmentReportsStr)){
                assessmentReports = (List<Assessment_Report__c>)JSON.deserialize(assessmentReportsStr, List<Assessment_Report__c>.class);
            }
            
            opp_MPD = opp;
            conAssign_MPD = caList;
            projTask_MPD = ptList;
            schedule_MPD = scList;
            insertPDO_MPD = daysInsList;
            deletePDO_MPD = daysDelList;
            assessRep_MPD = assessmentReports;
            
            isFromManageProjectDate_Status = True;                        
           
            if(pro.size() > 0){
                update pro;
            }else{
                update opp;
                update daysInsList;
                update daysDelList;
            }
            
            return null;
        }catch(Exception e) {
            system.debug(':::Error::'+e.getMessage());
            //status = 'Failure';
            return e.getMessage();
        } 
        //return status;
    }
    
    @RemoteAction
    global static List<Days_Off_Wrapper> clonePlannedDaysOff(String oldParentStr,String parentStr,String daysOffStr,String parentType,List<Id> conIdList){
        System.Debug('::::::::Enter Clone:::::::::');
        List<Days_Off_Wrapper> days = new List<Days_Off_Wrapper>();
        List<AcctSeed__Project__c> pro = new List<AcctSeed__Project__c>();
        List<AcctSeed__Project__c> oldPro = new List<AcctSeed__Project__c>();
        List<Opportunity> opp = new List<Opportunity>();
        List<Opportunity> oldOpp = new List<Opportunity>();
        Map<Date,Days_Off_Wrapper> oldDate_DaysOffMap = new Map<Date,Days_Off_Wrapper>();
        Map<Date,Planned_Days_Off__c> newDate_DaysOffMap = new Map<Date,Planned_Days_Off__c>();
        List<Days_Off_Wrapper> newCreationList = new List<Days_Off_Wrapper>();
        Set<Id> conIdSet = new Set<Id>();
        
        String defaultQuery = 'SELECT Id,Name,Date__c,Type__c,Contact__c,Contact__r.Name,RecordTypeId,Description__c,RecordType.DeveloperName,Requested_Reschedule_Date__c FROM Planned_Days_Off__c';
        String dliCondition = ' WHERE RecordType.DeveloperName = \'DLI_W_LT_Training_Holidays\' AND Contact__c = NULL AND Opportunity__c = NULL AND Project__c = NULL';
        String contactCondition = ' WHERE (RecordType.DeveloperName = \'Instructor_Planned_Days_Off\' OR RecordType.DeveloperName = \'Staff_Planned_Days_Off\' OR RecordType.DeveloperName = \'Student_Planned_Days_Off\') AND Contact__c IN :conIdSet';
        
        if(String.isNotBlank(daysOffStr)){
            days = (List<Days_Off_Wrapper>)JSON.deserialize(daysOffStr, List<Days_Off_Wrapper>.class);
        }
        
        for(Id con : conIdList){
            conIdSet.add(con);
        }
        for(Days_Off_Wrapper da : days){
            oldDate_DaysOffMap.put(da.dayOff.Date__c, da);
        }
        for(Planned_Days_Off__c daysOff : database.query(defaultQuery+dliCondition)) {
     
            if(daysOff.Date__c != null && !newDate_DaysOffMap.containsKey(daysOff.Date__c)){
                newDate_DaysOffMap.put(daysOff.Date__c,daysOff);
            }
        }
        for(Planned_Days_Off__c daysOff : database.query(defaultQuery+contactCondition)) {
          
            if(daysOff.Date__c != null && !newDate_DaysOffMap.containsKey(daysOff.Date__c)) {
                newDate_DaysOffMap.put(daysOff.Date__c,daysOff);
            }
        } 
       
        // Qry Planned days off related Record Type Ids
        Id projectPDO_RTId;
        RecordType rt = [SELECT Id,Name,DeveloperName 
                                FROM RecordType 
                                WHERE SobjectType = 'Planned_Days_Off__c' AND DeveloperName = 'Project_Planned_Days_Off'];
        projectPDO_RTId = rt.Id;
        
        if(String.isNotBlank(oldParentStr) && String.isNotBlank(parentStr)) {
            if(parentType == 'Project'){
                pro = (List<AcctSeed__Project__c>)JSON.deserialize(parentStr, List<AcctSeed__Project__c>.class);
                oldPro = (List<AcctSeed__Project__c>)JSON.deserialize(oldParentStr, List<AcctSeed__Project__c>.class);
                if(oldPro[0].Start_Date__c <= pro[0].Start_Date__c && pro[0].End_Date__c <= oldPro[0].End_Date__c){
                    
                    for(Days_Off_Wrapper da : days){
                        if(pro[0].Start_Date__c <= da.dayOff.Date__c && da.dayOff.Date__c <= pro[0].End_Date__c){                 
                            da.selected = true;
                        } else {
                            da.selected = false;
                        }
                    }
                } else {
                    for(Date dt : newDate_DaysOffMap.keySet()){
                        
                        if(pro[0].Start_Date__c <= dt && dt <= pro[0].End_Date__c ){
                            if(!oldDate_DaysOffMap.containsKey(dt)){
                                Planned_Days_Off__c newOff = new Planned_Days_Off__c();
                                newOff.Id = null;
                                newOff.Date__c = newDate_DaysOffMap.get(dt).Date__c;
                                newOff.RecordTypeId = projectPDO_RTId;
                                newOff.Description__c = newDate_DaysOffMap.get(dt).Description__c;
                                newOff.Requested_Reschedule_Date__c = newDate_DaysOffMap.get(dt).Requested_Reschedule_Date__c;
                                newOff.Opportunity__c = oldPro[0].AcctSeed__Opportunity__c;
                                                                
                                if(newDate_DaysOffMap.get(dt).RecordType.DeveloperName == 'DLI_W_LT_Training_Holidays'){
                                    newOff.Type__c = 'DLI-W LT';
                                } else if(newDate_DaysOffMap.get(dt).RecordType.DeveloperName == 'Instructor_Planned_Days_Off'){
                                    newOff.Type__c = 'Instructor';
                                } else if(newDate_DaysOffMap.get(dt).RecordType.DeveloperName == 'Student_Planned_Days_Off'){
                                    newOff.Type__c = 'Student';
                                } else if(newDate_DaysOffMap.get(dt).RecordType.DeveloperName == 'Staff_Planned_Days_Off'){
                                    newOff.Type__c = 'Staff';
                                }
                                if(newDate_DaysOffMap.get(dt).Contact__c != null){
                                    newOff.Contact__c = newDate_DaysOffMap.get(dt).Contact__c;
                                }
                                Days_Off_Wrapper newwrap = new Days_Off_Wrapper();
                                newwrap.dayOff = newOff;
                                newwrap.selected = true;
                                newwrap.contactName = newDate_DaysOffMap.get(dt).Contact__r.Name;
                                newCreationList.add(newwrap);
                            } 
                        }
                    }
                    for(Days_Off_Wrapper da : days){
                        if(pro[0].Start_Date__c <= da.dayOff.Date__c && da.dayOff.Date__c <= pro[0].End_Date__c){                 
                            da.selected = true;
                        } else {
                            da.selected =false;
                        }
                        newCreationList.add(da);
                    }
                    days = newCreationList;
                }
            } else {
            
                opp = (List<Opportunity>)JSON.deserialize(parentStr, List<Opportunity>.class);
                oldOpp = (List<Opportunity>)JSON.deserialize(oldParentStr, List<Opportunity>.class);
                if(oldOpp[0].Start_Date__c <= opp[0].Start_Date__c && opp[0].End_Date__c <= oldOpp[0].End_Date__c){
                    for(Days_Off_Wrapper da : days){
                        if(opp[0].Start_Date__c <= da.dayOff.Date__c && da.dayOff.Date__c <= opp[0].End_Date__c){                 
                            da.selected = true;
                        } else {
                            da.selected =false;
                        }
                    }
                } else {
                    for(Date dt : newDate_DaysOffMap.keySet()){
                        if(opp[0].Start_Date__c <= dt && dt <= opp[0].End_Date__c ){
                            if(!oldDate_DaysOffMap.containsKey(dt)){
                                Planned_Days_Off__c newOff = new Planned_Days_Off__c();
                                newOff.Date__c = newDate_DaysOffMap.get(dt).Date__c;
                                newOff.RecordTypeId = projectPDO_RTId;
                                newOff.Description__c = newDate_DaysOffMap.get(dt).Description__c;
                                newOff.Requested_Reschedule_Date__c = newDate_DaysOffMap.get(dt).Requested_Reschedule_Date__c;
                                newOff.Opportunity__c = oldOpp[0].Id;
                                if(newDate_DaysOffMap.get(dt).RecordType.DeveloperName == 'DLI_W_LT_Training_Holidays'){
                                    newOff.Type__c = 'DLI-W LT';
                                } else if(newDate_DaysOffMap.get(dt).RecordType.DeveloperName == 'Instructor_Planned_Days_Off'){
                                    newOff.Type__c = 'Instructor';
                                } else if(newDate_DaysOffMap.get(dt).RecordType.DeveloperName == 'Student_Planned_Days_Off'){
                                    newOff.Type__c = 'Student';
                                } else if(newDate_DaysOffMap.get(dt).RecordType.DeveloperName == 'Staff_Planned_Days_Off'){
                                    newOff.Type__c = 'Staff';
                                }
                                if(newDate_DaysOffMap.get(dt).Contact__c != null){
                                    newOff.Contact__c = newDate_DaysOffMap.get(dt).Contact__c;
                                }
                                Days_Off_Wrapper newwrap = new Days_Off_Wrapper();
                                newwrap.dayOff = newOff;
                                newwrap.selected = true;
                                newwrap.contactName = newDate_DaysOffMap.get(dt).Contact__r.Name;
                                newCreationList.add(newwrap);
                            } 
                        }
                    }
                    for(Days_Off_Wrapper da : days){
                        if(opp[0].Start_Date__c <= da.dayOff.Date__c && da.dayOff.Date__c <= opp[0].End_Date__c){                 
                            da.selected = true;
                        } else {
                            da.selected =false;
                        }
                        newCreationList.add(da);
                    }
                    days = newCreationList;
                }
            }
        }
        
        return days;
    }
    
    @AuraEnabled
    webservice static String isProjectExist(Id oppId) {
        
        List<AcctSeed__Project__c> pro = [SELECT Id,Name FROM AcctSeed__Project__c WHERE (AcctSeed__Opportunity__c = :oppId OR Id = :oppId)];
        if(pro.size() > 0){
            return pro[0].Id; 
        } else {
            return 'No';  
        } 
    }
        
    @RemoteAction
    global static string updateContactRecords(String caListStr){
        return GenerateCertificateCmp_Ctrl.updateContactRecords(caListStr);
    }
}