/* Used to convert an Opportunity to Project with the Opportunity data
*  update Project and Project Task id for opp child records like Schedule,Event,Contact Assignment,Billing,Billing Line.  
*  Update on October and November of 2016 
*  converted Material Requests, TimeLog, Language Testing, Get Feed back Objects under Projects.
*/
public with Sharing class ConvertToProject{
      
    // Getter Setter Variables used in Pages
    Public Opportunity oppRec {get; set;}
    Public AcctSeed__Project__c newProject{get; set;}
    //Public List<AcctSeed__Project__c> newProject{get; set;}
    //Public List<SelectOption> quoteNameList {get; set;} on 01 November
    Public List<SelectOption> projectTaskNameList {get; set;} // Excludes the Registration fee Product
    Public List<SelectOption> pTNameList {get; set;} // Name list for Payment Line records which include all the Products
    Public List<SelectOption> positionList {get; set;}
    Public List<SelectOption> instructorNameList {get; set;}
    Public List<ScheduleUpdateInnerClass> scheduleList {get; set;}
    Public List<ProjectTaskInsertInnerClass> projectTaskInnserClassList {get; set;}
    Public List<InstructorAssignInnerClass> instructorCAList {get; set;}
    Public List<StudentAssignInnerClass> studentCAList {get; set;}
    Public List<AcctSeed__Project_Task__c> projectTaskListToInsert; // {get; set;} on 01 November
    Public List<PaymentLineInnerClass> paymentLineList {get; set;}
    Public List<UtilDomain.EventInnerClass> eventList {get; set;}
    //List<tcdInnerCls> tcdL {get; set;}
    Public List<TimeLogInnerClass> tlList {get; set;}
    Public Boolean projectExist {get; set;}
    Public String oldProjectId {get; set;}
    Public Map<String,List<Events__c>> oldEventDateSTETWithIdNameMap {get; set;}
    //Public boolean showInstructorsConflictsModal {get; set;} on 01 November
    Public List<MatReqInnerClass> matReqs {get; set;}
    Public List<LTInnerClass> lTList {get; set;}
    Public Integer noOfGetFeedBack {get; set;}
    Public Boolean lTProductNotExist {get; set;}
    Public Set<String> unAvailableProd {get; set;}
    Public String msgForProductNotExist {get; set;}
    Public Boolean hasPrepTime {get; set;}
    Set<String> additionalPT = new Set<String>(); 
    
    Public Boolean materialNotExist {get; set;}
    Public String msgForMaterialNotExist {get; set;}
    Public String msgForTestOppStudentCANotExist {get; set;}
    Public Boolean testOppStudentCANotExist {get; set;}
    public Boolean isShowCostRateColumn {get; set;}
    
    // Common Variables
    string oppId;
    String errorMsg;
    String instructorRecTypeId;
    String studentRecTypeId;
    String staffRecTypeId;
    String cArecTypeName;
    String newProjectId;
    List<Schedule__c> scheduleListToUpdate = new List<Schedule__c>();
    List<Contact_Assignments__c> instructorListToUpdate = new List<Contact_Assignments__c>();
    List<Payment_Item__c> paymentItemListToUpdate = new List<Payment_Item__c>();
    List<Transaction__c> paymentListToUpdate = new List<Transaction__c>();
    List<Materials_Request__c> matReqsUpd = new List<Materials_Request__c>();
    //List<AcctSeed__Time_Card_Line__c> tcls = new List<AcctSeed__Time_Card_Line__c>();
    //List<AcctSeed__Time_Card__c> tcs = new List<AcctSeed__Time_Card__c>();
    Map<Id,Id> contactIdUserIdMap = new Map<Id,Id>();
    List<AcctSeed__Time_Card__c> timeCardList = new List<AcctSeed__Time_Card__c >();
    //Set<Date> accountPeriodstartDtSet = new Set<Date>(); on 01 November
    Map<Date,AcctSeed__Accounting_Period__c> accPRdstDtandAccPrdIdMap = new Map<Date,AcctSeed__Accounting_Period__c>();
    List<AcctSeed__Accounting_Period__c> acctPrdList = new List<AcctSeed__Accounting_Period__c>();
    List<AcctSeed__Time_Card_Period__c> timeCardPerdList = new List<AcctSeed__Time_Card_Period__c>();
    Set<Id> contIds = new Set<Id>();
    Set<Id> timePeriodIdSet = new Set<Id>();
    Set<Date> startdtSet = new Set<Date>();      // For Time Card Period Query Week Start Date Set
    Set<Date> enddtSet = new Set<Date>();        // For Time Card Period Query Week End Date Set

    Set<Date> timePrdStartdateSet = new Set<Date>();
    Set<Date> timePrdEnddateSet = new Set<Date>();
    Map<Id,Set<Id>> contIdTcIdMap = new Map<Id,Set<Id>>();
    List<Get_Feedback__c> feedBackList = new List<Get_Feedback__c>();
    Map<String,RecordType> projTaskRTMap = new Map<String,RecordType>();
    Map<Id,Map<Date,Date>> contIdWithStAndEndDateMap = new Map<Id,Map<Date,Date>>();
    Map<String,Map<String,Decimal>> contIdPtNameHoursMap = new Map<String,Map<String,Decimal>>();
    List<AcctSeed__Billing__c> billingList = new List<AcctSeed__Billing__c>();
    List<AcctSeed__Billing_Line__c> billingLineList = new List<AcctSeed__Billing_Line__c>();
    
    // For Event Date Conflicts due to Planned days off
    Map<Id,String> contactIdWithRecordTypeMap = new Map<Id,String>(); 
    Map<String,String> oppStageAndProjStageMap = new Map<String,String>();
    Map<String,List<Opportunity_Project_Mapping__c>> oppRecTypeAndProjRecTypeMap = new Map<String,List<Opportunity_Project_Mapping__c>>();
    Map<Date,Date> dayOffDateWithReschedDateMap = new Map<Date,Date>();
    Set<Id> eventIdSet = new Set<Id>();
    Map<Date,String> plannedDaysOffDateWithCARecordTypeMap = new Map<Date,String>();
    Map<Id,String> oPLIIdKeyProductNameValueMap = new Map<Id,String>();
    Map<Id,String> oPLIIdKeyProTaskNameValueMap = new Map<Id,String>();
    //Added
    Opportunity oppQBJobTypeUp = new Opportunity();
    List<Opportunity> opp = new List<Opportunity>();
    //Ended

    // Added on Jan 30 2020
    Id childPVTAccId;
    // Added on Feb 03 2020
    Id conId;
    
    Map<Date,Date> stdateandEnddtMap = new Map<Date,Date>();
    List<Date> tlDateSet = new List<Date>();     // Time Log Dates     
    Set<Date> monthStartdtSet = new Set<Date>(); // For Accounting Period 
    Set<Date> monthEnddtSet = new Set<Date>();   // For Accounting Period
    Set<String> projectTskNames = new Set<String>();
    // To avoid the same name conflict on Project Task Creation.
    Map<String, Decimal> projNameCountMap = new Map<String, Decimal>();
    
    // Added on Sep 02 2021
    public Boolean is_class_Sec_Required {get; set;}
    // For Testing_Opportunities RecorType Changes
    public Boolean isSDEDReq {get; set;} // SD = Start Date, ED = End Date
    public Boolean isRequired {get; set;} // Requested Hours/Week and "Program Type" requirements
    public Boolean isMtt {get; set;} 
    public Boolean isShowCRColumn {get; set;} 
    public Boolean showMttErrorMsg{get; set;}
    public Boolean isSupAndLocReq {get; set;} // When the Project Manager/ Supervisor and Training Location is Required
    
    Map<String,Decimal> timeAndDecimalMap = new Map<String,Decimal> {
        '7:30 AM' => 7.5,'8:00 AM' => 8,'8:30 AM' => 8.5,'9:00 AM' => 9,'9:30 AM' => 9.5,'10:00 AM' => 10,
        '10:30 AM' => 10.5,'11:00 AM' => 11,'11:30 AM' => 11.5,'12:00 PM' => 12,'12:30 PM' => 12.5,'1:00 PM' => 13,
        '1:30 PM' => 13.5,'2:00 PM' => 14,'2:30 PM' => 14.5,'3:00 PM' => 15,'3:30 PM' => 15.5,'4:00 PM' => 16,
        '4:30 PM' => 16.5,'5:00 PM' => 17,'5:30 PM' => 17.5,'6:00 PM' => 18,'6:30 PM' => 18.5,'7:00 PM' => 19,
        '7:30 PM' => 19.5,'8:00 PM' => 20        
    };
    
    Map<String,String> payRollValuesMap = new Map<String,String>{'S' => 'Sick', 'V' => 'Vacation', 'HOL' => 'Holiday', 'OTH' => 'Other Pay', 'BLE' => 'Bonus Leave Earned', 'BLT' => 'Bonus Leave Taken'};
    Map<String,String> langMap = new Map<String,String>{'Chinese (Mandarin)'=>'Chinese - Mandarin','Chinese (Cantonese)'=>'Chinese - Cantonese','Azerbaijani'=>'Azeri (Azerbaijani)','Slovene (Slovenian)'=>'Slovene','Persian Farsi'=>'Farsi (Persian)','Kurdish-Kurmanji'=>'Kurdish - Kurmanji','Kurdish-Sorani'=>'Kurdish - Sorani', 'Pashto (Pakistani dialect)' => 'Pashto', 'Khirghiz' => 'Kyrgyz', 'Malaysian' => 'Malay', 'Tadjik' => 'Tajik', 'Syrian' => 'Arabic - Levantine'};
    Map<String,String> dialectsMap = new Map<String,String>{'Arabic- Egyptian' => 'Arabic - Egyptian', 'Arabic - Iraqi' => 'Arabic - Iraqi', 'Arabic- Levantine' => 'Arabic - Levantine', 'Arabic- Maghrebi' => 'Arabic - Maghrebi', 'Arabic- Gulf' => 'Arabic - Saudi/Gulf', 'Arabic- MSA' => 'Arabic - MSA', 'Portuguese- Brazilian' => 'Portuguese â€“ Brazilian', 'Portuguese- European' => 'Portuguese â€“ Continental'};
    
    Map<String,String> productNameStaticMap = new Map<String,String>{'Language Training- Arabic' => 'Language Training- Arabic (MSA and all dialects)', 'Language Training- Vietnamese' => 'Language Training- Vietnamese (all dialects)', 'Language Training- Mandarin' => 'Language Training- Chinese (Mandarin)', 'Language Training- Portuguese' => 'Language Training- Portuguese (all dialects)', 'Language Training- Cantonese' => 'Language Training- Chinese (Cantonese)'};
    Set<String> acctSpecificProdSet = new Set<String>{'MPO ELT III LT - Full-Time', 'MPO ELT III LT - Part-Time'};
    Integer studCount = 0;
    Map<String, String> stdCAPositionStaticMap = new Map<String, String>{'Student' => 'Student', 'Class Leader' => 'Class Leader'};
    
    //Added By HL on Oct 19 2020
    Set<String> lmsProjectTypes = new Set<String>{'SLP-PT', 'SLP-FT'};
    Set<String> lmsFreeProjectTypes = new Set<String>{'IND', 'JMAS'};
        
    // Convert to Project button restriction to users
    Id usrId = UserInfo.getUserId(); 
    Id profileId = UserInfo.getProfileId();
    
    List<User> usrRec = [SELECT Id,Name,Convert_to_Project_Access__c,ProfileId,Profile.Name FROM User  WHERE Id = :usrId];
    //List<Profile> profileRec = [SELECT Id,Name FROM Profile WHERE Id = :profileId];
    
    // Added on Mar 27 2023 - W-007735 - Auto Create Initial Language Testing Records for Beginner Projects (May-1-2023)
    Set<Id> stdIds_InitialLT = new Set<Id>();
    Set<String> programTypesToCreateInitialLTs = new Set<String>{'Familiarization', 'Initial acquisition', 'Basic Course - Full Time', 'Basic Course - Part Time'};
    Public List<LTInnerClass> lTList_Temp = new List<LTInnerClass>();
    Public List<LTInnerClass> lTList_actual = new List<LTInnerClass>();
    public static Boolean isFromConvertToProject = False;
    
    public Class ScheduleUpdateInnerClass {
        public Schedule__c schRec {get; set;}  
        public String productNameAsProjectTask {get; set;}
        //public String instructorId {get; set;} 
        public Boolean error {get; set;}
        public ScheduleUpdateInnerClass(Schedule__c schedule,String prodName) {
            schRec = schedule;
            error = false;
            productNameAsProjectTask = prodName; // To populate the selected product in sch level
        }      
    }
    
    public Class ProjectTaskInsertInnerClass {
        public AcctSeed__Project_Task__c projTask{get; set;}  
        public Decimal totalPrice{get; set;} 
        public String productNameAsProjectTask {get; set;}
        public List<SelectOption> parentPTList {get; set;}
        public Boolean error {get; set;}
        
        public ProjectTaskInsertInnerClass(AcctSeed__Project_Task__c projectTsk,Decimal total, String projTaskName) {
            projTask = projectTsk;
            totalPrice = total.setScale(2);
            productNameAsProjectTask = projTaskName;
            parentPTList = new List<SelectOption>();
            error = false;
        }      
    }
    
    public Class InstructorAssignInnerClass {
        public Contact_Assignments__c instructorCA{get; set;}  
        public String productNameAsProjectTask {get; set;} 
        public Boolean error {get; set;}
        public Boolean isShowHourlyCR {get; set;}
        public String crHourlyCost {get; set;}
        public Boolean crHourlyReqError {get; set;}
        public List<SelectOption> costRateOption {get; set;}
        public String selectedCR {get; set;} 
        public Boolean isShowCostRate {get; set;} 
        public Boolean isShowCostRateReqError {get; set;} 

        public InstructorAssignInnerClass(Contact_Assignments__c iCA, String projName) {
            instructorCA = iCA;
            error = false;
            productNameAsProjectTask = projName;
            isShowHourlyCR = false; 
            crHourlyCost = null;
            crHourlyReqError = false;
            costRateOption = new List<SelectOption>(); 
            isShowCostRateReqError = false;
            isShowCostRate = false;
            selectedCR = '';
       }      
    }
    
    public Class StudentAssignInnerClass{
        public Contact_Assignments__c studentCA{get; set;}  
        public String position {get; set;} 
        public Boolean error {get; set;}
        
        public StudentAssignInnerClass(Contact_Assignments__c sCA, String pos) {
            studentCA = sCA;
            error = false;
            position = pos;
        }      
    }
  
    public Class PaymentLineInnerClass {
       public Payment_Item__c payment{get; set;}  
       public String productNameAsProjectTask {get; set;} 
       public Boolean error {get; set;}
        
        public PaymentLineInnerClass(Payment_Item__c PI,String prodName) {
            payment = PI;
            productNameAsProjectTask = prodName;
            error = false;
       }      
    } 
    
    public Class MatReqInnerClass {
       public Materials_Request__c mrq {get; set;}  
       public String productNameAsProjectTask {get; set;} 
       public Boolean error {get; set;}
        
       public MatReqInnerClass(Materials_Request__c mr, String prT) {
            mrq = mr;
            productNameAsProjectTask = prT;
            error = false;
       }      
    } 
    
    public Class LTInnerClass {
       public Language_Testing__c obj {get; set;}  
       public String ptName {get; set;} 
       public Boolean error {get; set;}
       public Boolean isNew {get; set;}
       public Id studentId {get; set;} 
       public String studentName {get; set;} 
       public String goal_SLRW {get; set;} 
       public String score_SLRW {get; set;} 
       
       public LTInnerClass (Language_Testing__c o, String prT, Boolean isNewVal, Id stdId, String stdName, String goal_SLRW_Val, String score_SLRW_Val) {
            obj = o;
            ptName = prT;
            error = false;
            isNew = isNewVal;
            studentId = stdId;
            studentName = stdName;
            goal_SLRW = goal_SLRW_Val;
            score_SLRW = score_SLRW_Val;
       }      
    }
    
    // Added to show the Summary view for Time Log
    public Class TimeLogInnerClass {
        public String contactId {get; set;}
        public String contName {get; set;}
        public Decimal hours {get; set;}
        public String oldProjectTask {get; set;}
        public String newProjectTask {get; set;}
        public Boolean error {get; set;}
        
        public TimeLogInnerClass(String con,String conNam,Decimal hrs,String pt) {
            contactId = con;
            contName = conNam;
            hours = hrs;
            oldProjectTask = pt;
            newProjectTask = pt;
            error = false;
        }
    }
    
    public ConvertToProject(ApexPages.StandardController stdControllerParam) {
    
        oppId = stdControllerParam.getId(); 
        //quoteNameList = new List<SelectOption>{new SelectOption('','---None---')};
        projectTaskNameList = new List<SelectOption>{new SelectOption('','---None---')};
        pTNameList = new List<SelectOption>{new SelectOption('','---None---')};
        positionList = new List<SelectOption>{new SelectOption('','---None---')};
        positionList.add(new SelectOption('Student','Student'));
        positionList.add(new SelectOption('Class Leader','Class Leader'));
        instructorNameList = new List<SelectOption>{new SelectOption('','---None---')};
        //quoteLineItemList = new List<QuoteLineItem>();
        scheduleList = new List<ScheduleUpdateInnerClass>();
        projectTaskInnserClassList = new List<ProjectTaskInsertInnerClass>();
        projectTaskListToInsert = new List<AcctSeed__Project_Task__c>();
        instructorCAList = new List<InstructorAssignInnerClass>();
        studentCAList = new List<StudentAssignInnerClass>();
        paymentLineList = new List<PaymentLineInnerClass>();
        eventList = new List<UtilDomain.EventInnerClass>();
        matReqs = new List<MatReqInnerClass>();
        lTList = new List<LTInnerClass>();
        unAvailableProd = new Set<String>();
        isMtt = false;
        showMttErrorMsg = false;
        String mPOAccountId;
        System_Values__c mPOAccount = System_Values__c.getValues('ConvertToProject_MPOAccount');
        mPOAccountId = mPOAccount.Value__c;
        hasPrepTime = false;
        isShowCRColumn = false;
        // Collections for Time card Day creation
        
        noOfGetFeedBack = 0;       
        Date stDate;
        Date endDate;
        tlList = new List<TimeLogInnerClass>();
        
        // For Testing_Opportunities Changes
        isSDEDReq = true;                 // Defaultly Required for All Opp RT except "Testing_Opportunities"
        isRequired = false;
        isSupAndLocReq = false;
        is_class_Sec_Required = false;
        
        for( Opportunity_Project_Mapping__c oppProjCS : [SELECT Id,Name,Opportunity_Value__c,Project_Type__c,Training_Location_Type__c,Project_Value__c,Value_Type__c FROM Opportunity_Project_Mapping__c]) {
            /*if(oppProjCS.Value_Type__c == 'Stage') {
                oppStageAndProjStageMap.put(oppProjCS.Name,oppProjCS.Project_Value__c);
            } else Commented since all the Projects are set as Order */
             
            if(oppProjCS.Value_Type__c == 'RT') {
                if(!oppRecTypeAndProjRecTypeMap.containskey(oppProjCS.Opportunity_Value__c)) {
                    oppRecTypeAndProjRecTypeMap.put(oppProjCS.Opportunity_Value__c, new List<Opportunity_Project_Mapping__c>{oppProjCS});
                } else {
                    oppRecTypeAndProjRecTypeMap.get(oppProjCS.Opportunity_Value__c).add(oppProjCS);
                }
            } 
        }
        if(string.isNotBlank(oppId)) {
            
            // Convert to Project button restriction to users
            Boolean performConversion = false;
            
            /*if((profileRec.size() > 0 && (profileRec[0].Name == 'Power User' || profileRec[0].Name == 'System Administrator')) 
                || (usrRec.size() > 0 && usrRec[0].Convert_to_Project_Access__c)
            ) {
                performConversion = true;
            }*/
            
            if(usrRec.size() > 0 && (usrRec[0].Convert_to_Project_Access__c || usrRec[0].Profile.Name == 'Power User' || usrRec[0].Profile.Name == 'System Administrator') ) {
                performConversion = true;
            }
            
            if(performConversion) {
                List<AcctSeed__Project__c> oldProjectList = ProjectService.getproject(' WHERE AcctSeed__Opportunity__c','',new Set<Id>{oppId});
                if( oldProjectList != null && oldProjectList.size() > 0 ) {
                    projectExist = TRUE;
                    oldProjectId =  oldProjectList[0].Id;   
                } else {
                                        
                    List<OpportunityLineItem> opliList = [SELECT Id,Name,UnitPrice,Quantity,Product2Id,Product2.Name,Product2.Family, Product_Family__c,
                                                          Product2.Unit_Type__c,Product2.Language_LU__c,OpportunityId,CLIN_LU__c,Description, Unit__c, Opportunity.RecordTypeId, Language__c
                                                          //Product2.AcctSeed__Inventory_GL_Account__c,Product2.AcctSeed__Revenue_GL_Account__c
                                                          FROM OpportunityLineItem 
                                                          WHERE OpportunityId = :oppId ORDER BY CreatedDate];
                    
                    opp = SObjectQueryService.SObjectQuery('Opportunity',new Set<Id>{oppId},',Account.Name, RecordType.DeveloperName,Location__r.RecordType.DeveloperName, Location__r.Name');
                     
                    // Added by Siva Prasanth on 12/03/2020
                    // W-004986 - Create PVT Student Child Account on Convert to Project for Testing Projects
                    // Show error message "Please create at least one Student Contact Assignment in order to convert this Opportunity to a Project" if Testing Opportunity has no Student CA with status of 'Active' or 'Planned'. 
                    // Added By HL on May 11 2020
                    // Work Item : W-005333 - Convert to Project Contact Assignment Issue
                    // Don't show this validation message for Ended/ On Hold Opportunity while converting it in to Project
                    if((opp[0].RecordType.DeveloperName == 'Testing_Opportunities' || (opp[0].RecordType.DeveloperName == 'New_Classes_Opportunities' && opp[0].Account.Name == 'PVT')) && 
                        String.isNotBlank(opp[0].StageName) && opp[0].StageName != 'Ended'){  // && opp[0].StageName != 'On Hold'
                        List<Contact_assignments__c> conAssign = ContactAssignmentService.getContactassignmentByparentIds(new Set<Id>{oppId},new Set<String>{'Active','Planned'},new Set<String>{'Student'},'');
                        
                        if(conAssign.size() == 0){
                            testOppStudentCANotExist = TRUE;
                            msgForTestOppStudentCANotExist = 'Please create at least one Student Contact Assignment in order to convert this Opportunity to a Project';
                        }else {
                            testOppStudentCANotExist = FALSE;
                        }
                    }
                    
                    msgForProductNotExist = checkOrderContract(null);
                    
                    if(opliList.size() > 0 && (msgForProductNotExist == '' || msgForProductNotExist == null)){
                        msgForProductNotExist = 'Please create required Products inorder to Convert Opportunity to Project for the following,';
                        List<RecordType> recTypeList = SObjectQueryService.getRecTypeListBySobjTypeAndDevName('','AcctSeed__Project_Task__c',new Set<String>{});
                        
                        for(RecordType rt : recTypeList) {
                            projTaskRTMap.put(rt.Name,rt);
                        } 
                                                
                        String conAssingQry = 'SELECT '+SObjectQueryService.getSObjectFieldsBySObjectName('Contact_Assignments__c')+',Candidate_Name__r.Name,RecordType.Name,RecordType.DeveloperName FROM Contact_assignments__c WHERE Opportunity_Name__c = :oppId';
                        List<Contact_assignments__c> conAssignments = Database.query(conAssingQry);
                        oppRec = opp[0];
                        // To update the QB_Contract_Type__c, Project_Type__c, To__c and Order__c on Opportunity
                        // To store the old values before updation
                        oppQBJobTypeUp.Id = opp[0].Id; 
                        oppQBJobTypeUp.QB_Contract_Type__c = opp[0].QB_Contract_Type__c;
                        oppQBJobTypeUp.Order__c = opp[0].Order__c;
                        oppQBJobTypeUp.Project_Type__c = opp[0].Project_Type__c;
                        oppQBJobTypeUp.To__c = opp[0].To__c;   
                        oppQBJobTypeUp.Enrollment_Date__c = opp[0].Enrollment_Date__c;  
                        oppQBJobTypeUp.Default_Cost_Rate_Rate_Type__c = opp[0].Default_Cost_Rate_Rate_Type__c;
                        oppQBJobTypeUp.Supervisor__c = opp[0].Supervisor__c;
                        oppQBJobTypeUp.Hours__c = opp[0].Hours__c;
                        oppQBJobTypeUp.Location__c = opp[0].Location__c;
                        oppQBJobTypeUp.Program_type__c = opp[0].Program_type__c;
                        
                        newProject = new AcctSeed__Project__c(Name=opp[0].Name,DLS_Class__c = opp[0].DLS_Class__c,Program_type__c = opp[0].Program_type__c,AcctSeed__Opportunity__c = oppId,Start_Date__c=opp[0].Start_Date__c,End_Date__c =opp[0].End_Date__c,Delivery_Account__c = opp[0].Delivery_Account__c,End_User_Account__c = opp[0].End_User_Account__c,AcctSeed__Account__c = opp[0].AccountId,Payment_Term__c = opp[0].Payment_Term__c,TO__c = opp[0].TO__c,QB_Classification__c = opp[0].Classification__c,Section__c = opp[0].Section__c,QB_Cust_Job__c = opp[0].QB_Cust_Job__c,Service_Item__c = opp[0].Service_Item__c,Payroll_Item__c = opp[0].Payroll_Item__c,PC_Cust_Job__c = opp[0].PC_Cust_Job__c, PC_GL_Code__c = opp[0].PC_GL_Code__c, ILR_S_Goal__c = opp[0].ILR_S_Goal__c, ILR_R_Goal__c = opp[0].ILR_R_Goal__c, ILR_L_Goal__c = opp[0].ILR_L_Goal__c, ILR_Midterm_Date__c = opp[0].ILR_Midterm_Date__c, ILR_Final_Date__c = opp[0].ILR_Final_Date__c, Contract__c = opp[0].ContractId, Travel_In_Date__c = opp[0].Travel_In_Date__c,Travel_Out_Date__c = opp[0].Travel_Out_Date__c, Training_Location__c = opp[0].Location__c,
                                                            Previous_Stage__c = opp[0].Previous_Stage__c, SLP_Iteration__c = opp[0].CLP_Iteration__c, Billing_Type__c = opp[0].A_R_Type__c, Refund_Type__c = opp[0].Refund_Type__c, Number_of_students__c = opp[0].Student_Count__c, Dialects__c = opp[0].Dialects__c, Country_Map__c = opp[0].Country_Map__c, Accounting_Notes__c = opp[0].Accounting_Notes__c, S_Goal_Score_Applicable__c = opp[0].S_Goal_Score_Applicable__c, R_Goal_Score_Applicable__c = opp[0].R_Goal_Score_Applicable__c, L_Goal_Score_Applicable__c = opp[0].L_Goal_Score_Applicable__c, End_of_Training_Goals__c = opp[0]. End_of_Training_Goals__c, Auth_Start_Date__c = opp[0].Auth_Start_Date__c , Auth_End_Date__c = opp[0].Auth_End_Date__c, Total_Program_Hours__c = opp[0].Hours__c, Totals_Hours_Paid_Auth__c = opp[0].Total_Hours_Paid_Auth_New__c, Hourly_Rate__c = opp[0].Hourly_Rate__c, Materials_Budget_Requested__c = opp[0].Materials_Budget_Requested__c, CLIN__c = opp[0].CLIN__c,
                                                            Order__c = opp[0].Order__c, Close_Date__c = opp[0].CloseDate, QB_Contract_Type__c = opp[0].QB_Contract_Type__c , Hours_Week__c = opp[0].Hours_Week__c, LTS_Notes__c = opp[0].LTS_Notes__c, Project_Description__c = opp[0].Project_Description__c, Proficiency_Testing__c = opp[0].Proficiency_Testing_New__c,Project_Manager__c = opp[0].Supervisor__c,Oral_Exam_Date_Time__c = opp[0].Oral_Exam__c,Language__c = opp[0].Language_LU__c,Test_Type__c = opp[0].Test_Type__c, Background_Summary__c = opp[0].Background_Summary__c, Default_Cost_Rate_Rate_Type__c = opp[0].Default_Cost_Rate_Rate_Type__c,Source_Language_s__c = opp[0].Source_Language_s__c,Target_Language_s__c = opp[0].Target_Language_s__c,Description__c = opp[0].Description__c, Project_Type__c = opp[0].Project_Type__c, Program_Iteration__c = opp[0].Program_Iteration__c, DLI_Project_Type__c = opp[0].DLI_Project_Type__c, Initial_End_Date__c = opp[0].End_Date__c, Box_Folder_Id__c = opp[0].Box_Folder_Id__c);
                                                                                    
                        //newProject = new List<AcctSeed__Project__c>{new AcctSeed__Project__c(Name=opp.Name,DLS_Class__c = opp.DLS_Class__c,Program_type__c = opp.Program_type__c,AcctSeed__Opportunity__c = oppId,Start_Date__c=opp.Start_Date__c,End_Date__c =opp.End_Date__c,Delivery_Account__c = opp.Delivery_Account__c,End_User_Account__c = opp.End_User_Account__c,AcctSeed__Account__c = opp.AccountId,Payment_Term__c = opp.Payment_Term__c,TO__c = opp.TO__c, QB_Classification__c = opp.Classification__c,QB_Cust_Job__c = opp.QB_Cust_Job__c,Service_Item__c = opp.Service_Item__c,Payroll_Item__c = opp.Payroll_Item__c,PC_Cust_Job__c = opp.PC_Cust_Job__c, PC_GL_Code__c = opp.PC_GL_Code__c)};
                        /*for(Quote qt : [SELECT Id,Name,OpportunityId FROM Quote WHERE OpportunityId =: oppId]) {
                            quoteNameList.add(new SelectOption(qt.Id,qt.Name));
                        }*/
                        
                        //commented by shalini for moving costrate changes
                        /*List<Project_Task_Master__c> masterPTList = [Select Id,Name,Project_Type__c, Unit__c, Project_Task_Type__c, Project_Task_Record_Type__c, Display_In_Time_Card__c, Sort_Order__c, Project_Record_Type__c, Billable__c, OH_Applied__c, G_A_Applied__c From Project_Task_Master__c]; 
                        Map<String,Project_Task_Master__c> proTaskName = new Map<String,Project_Task_Master__c>();
                        for(Project_Task_Master__c pt : masterPTList){
                            proTaskName.put(pt.Name,pt);                
                        }
                        // changed to qry to avoid "Aggregate query has too many rows for direct assignment, use FOR loop" this error on inner qry  
                        for(OpportunityLineItem oLI : [SELECT Id,Name,UnitPrice,Quantity,Product2Id,Product2.Name,Product2.Family,
                                                            Product2.Unit_Type__c,Product2.Language_LU__c,OpportunityId,CLIN_LU__c,Description 
                                                        FROM OpportunityLineItem 
                                                        WHERE OpportunityId = :oppId]) {
                            
                            if(proTaskName.containsKey(oLI.Product2.Name)){
                                projectTaskInnserClassList.add(new ProjectTaskInsertInnerClass(new AcctSeed__Project_Task__c(Rate__c = oLI.UnitPrice,Total_Qty_Planned__c = oLI.Quantity,Name = oLI.Product2.Name,Project_Task_Type__c = oLI.Product2.Family,Unit__c = oLI.Product2.Unit_Type__c,Product__c = oLI.Product2Id,Language_LU__c = oLI.Product2.Language_LU__c,CLIN__c = oLI.CLIN_LU__c,Description__c = oLI.Description,G_A_Applied__c=(proTaskName.get(oLI.Product2.Name).G_A_Applied__c != null ? proTaskName.get(oLI.Product2.Name).G_A_Applied__c : 0),OH_Applied__c=(proTaskName.get(oLI.Product2.Name).OH_Applied__c != null ? proTaskName.get(oLI.Product2.Name).OH_Applied__c : 0)),oLI.UnitPrice * oLI.Quantity));
                            } else if(oLI.Product2.Name.contains('Language Training-') && !oLI.Product2.Name.contains('Language Training- Preparation Hours') && !oLI.Product2.Name.contains('Language Training-Each Additional Stud')){
                                if(proTaskName.containsKey('Language Training- {Language}')){
                                    projectTaskInnserClassList.add(new ProjectTaskInsertInnerClass(new AcctSeed__Project_Task__c(Rate__c = oLI.UnitPrice,Total_Qty_Planned__c = oLI.Quantity,Name = oLI.Product2.Name,Project_Task_Type__c = oLI.Product2.Family,Unit__c = oLI.Product2.Unit_Type__c,Product__c = oLI.Product2Id,Language_LU__c = oLI.Product2.Language_LU__c,CLIN__c = oLI.CLIN_LU__c,Description__c = oLI.Description,G_A_Applied__c=(proTaskName.get('Language Training- {Language}').G_A_Applied__c != null ? proTaskName.get('Language Training- {Language}').G_A_Applied__c : 0),OH_Applied__c=(proTaskName.get('Language Training- {Language}').OH_Applied__c != null ? proTaskName.get('Language Training- {Language}').OH_Applied__c : 0)),oLI.UnitPrice * oLI.Quantity));
                                }
                            }
                            projectTaskNameList.add(new SelectOption(oLI.Product2.Name,oLI.Product2.Name));
                            oPLIIdKeyProductNameValueMap.put(oLI.Id,oLI.Product2.Name); // To populate the selected product in sch level
                        }*/
                        Map<String, String> opliFamilyUnitAndTaskType = new Map<String, String>();
                        opliFamilyUnitAndTaskType.put('Translation+Hrs','Translation (per hr)');
                        opliFamilyUnitAndTaskType.put('Translation+Word','Translation (per word)');
                        opliFamilyUnitAndTaskType.put('Transcription+Hrs','Transcription (per hr)');
                        opliFamilyUnitAndTaskType.put('Interpretation+Hrs','Interpretation (per hr)');
                        opliFamilyUnitAndTaskType.put('Translation+FFP','Translation (per FFP)');
                        opliFamilyUnitAndTaskType.put('Interpretation+FFP','Interpretation (per FFP)');
                        Id interOppRTId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Interpretation_Opportunities').getRecordTypeId();
                        Id transOppRTId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Translation_Opportunities').getRecordTypeId();
                        for(OpportunityLineItem oLI : opliList) {
                            String ptName = oLI.Product2.Name;
                            if(projNameCountMap.containskey(oLI.Product2.Name)) {
                                projNameCountMap.put(oLI.Product2.Name, projNameCountMap.get(oLI.Product2.Name) + 1);
                                ptName = ptName + ' ' + projNameCountMap.get(oLI.Product2.Name); 
                            } else {
                                projNameCountMap.put(oLI.Product2.Name, 1);
                            }
                            String taskType = '';
                            if(oLI.Opportunity.RecordTypeId == interOppRTId || oLI.Opportunity.RecordTypeId == transOppRTId){
                                if(opliFamilyUnitAndTaskType.containsKey(oLI.Product_Family__c+'+'+oLI.Unit__c)){
                                    taskType = opliFamilyUnitAndTaskType.get(oLI.Product_Family__c+'+'+oLI.Unit__c);
                                }else if( ptName == 'Language Training- Preparation'){
                                    taskType = 'Preparation time';
                                }else{
                                    taskType = oLI.Product2.Family;
                                }
                            }else if( ptName == 'Language Training- Preparation'){
                                taskType = 'Preparation time';
                            }else{
                                taskType = oLI.Product2.Family;
                            }
                            // Work Item: W-006145 - Service Item on Project Task for Billable Tests is Blank
                            // To populate Service Item on the Project Task for Testing Opportunity
                            projectTaskInnserClassList.add(new ProjectTaskInsertInnerClass(new AcctSeed__Project_Task__c(Billable__c = True, Rate__c = oLI.UnitPrice,Total_Qty_Planned__c = oLI.Quantity,Name = ptName, Project_Task_Type__c = taskType, Unit__c = oLI.Product2.Unit_Type__c, Product__c = oLI.Product2Id,Language_LU__c = (acctSpecificProdSet.contains(oLI.Product2.Name) ? opp[0].Language_LU__c : oLI.Language__c),CLIN__c = oLI.CLIN_LU__c,Description__c = oLI.Description,Service_Item__c = (oLI.Product2.Family == 'Language Training' ? opp[0].Service_Item__c : (oLI.Product2.Family == 'Language Testing' ? 'SVC:Language Testing' : '')), AcctSeed__Start_Date__c = opp[0].Start_Date__c, AcctSeed__End_Date__c = opp[0].End_Date__c),oLI.UnitPrice * oLI.Quantity, ''));
                            if(ptName != 'Registration Fee - On-Site') {
                                projectTaskNameList.add(new SelectOption(ptName ,ptName ));
                            }
                            pTNameList.add(new SelectOption(ptName ,ptName ));
                            if(!ptName.contains('Additional') && !ptName.contains('Preparation')) { // Added conditions to not include the Additional and Prep Project Task in Parent List
                                projectTskNames.add(ptName);
                            }
                            oPLIIdKeyProductNameValueMap.put(oLI.Id,oLI.Product2.Name); // To populate the selected product in sch level
                            oPLIIdKeyProTaskNameValueMap.put(oLI.Id,ptName);
                            if(ptName.contains('Additional') || ptName.contains('Preparation')) {
                                additionalPT.add(ptName);
                            }
                        }
                        if(additionalPT.size() > 0) {
                            hasPrepTime = true;
                        }
                        for(Schedule__c sch : [SELECT Id,Name,End_Date__c,End_Time__c,Opportunity__c,Start_Date__c,
                                                    Start_Time__c,Project_Task__c,Instructor__c,Timezone__c,Opportunity_Product_Id__c 
                                                FROM Schedule__c 
                                                WHERE Opportunity__c = :oppId]) {
                            
                            scheduleList.add(new ScheduleUpdateInnerClass(sch,oPLIIdKeyProTaskNameValueMap.containskey(sch.Opportunity_Product_Id__c) ? oPLIIdKeyProTaskNameValueMap.get(sch.Opportunity_Product_Id__c):''));     // To populate the selected product in sch level           
                        }
                        
                        for(RecordType rType : [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType = 'Contact_Assignments__c']) {
                            
                            if(rType.DeveloperName == 'Instructor') instructorRecTypeId = rType.Id;
                            if(rType.DeveloperName == 'Student') studentRecTypeId = rType.Id;
                            if(rType.DeveloperName == 'Staff') staffRecTypeId = rType.Id;
                        }
                        
                        for(Language_Testing__c lt : [SELECT Id,Name,Opportunity__c,Project_Task__c,Examiner__r.Name,Examiner__c,Goal_SLRW__c,Score_SLRW__c,
                                                            Target_Language_LU__r.Name,Testee__c,Testee__r.Name,Tester__c,Tester__r.Name,Date_Time_Scheduled__c, Project__c,
                                                            Test_Type__c 
                                                        FROM Language_Testing__c
                                                        WHERE Opportunity__c = :oppId AND Opportunity__r.RecordType.DeveloperName != 'Testing_Opportunities']) {
                            if(lt.Test_Type__c == 'Initial'){
                                stdIds_InitialLT.add(lt.Testee__c);
                            }
                            lTList.add(new LTInnerClass(lt,'Language Testing', False, lt.Testee__c, lt.Testee__r.Name, lt.Goal_SLRW__c, lt.Score_SLRW__c));
                            lTList_actual.add(new LTInnerClass(lt,'Language Testing', False, lt.Testee__c, lt.Testee__r.Name, lt.Goal_SLRW__c, lt.Score_SLRW__c));
                        }
                        
                        for(Contact_Assignments__c cA : conAssignments) {
                            if(cA.RecordTypeId == studentRecTypeId) {
                                // For event date conflicts that occure due to Planned Days Off
                                contactIdWithRecordTypeMap.put(cA.Candidate_Name__c,cA.RecordType.Name);
                                studentCAList.add(new StudentAssignInnerClass(cA,(cA.Assignment_Position__c != null && stdCAPositionStaticMap.containskey(cA.Assignment_Position__c)) ? stdCAPositionStaticMap.get(cA.Assignment_Position__c) : ''));
                                
                                if(!stdIds_InitialLT.contains(cA.Candidate_Name__c) && opp[0].RecordType.DeveloperName != 'Testing_Opportunities'){
                                
                                    Language_Testing__c initial_LT = new Language_Testing__c(Opportunity__c = opp[0].Id, Account_Name__c = opp[0].AccountId, Target_Language_LU__c = opp[0].Language_LU__c, Testee__c = cA.Candidate_Name__c, Source__c = 'Student (External)', Test_Type__c = 'Initial', Test_Format__c = 'Unknown', L_Score__c = '0', R_Score__c = '0', S_Score__c = '0', W_Score__c = 'N/A', Stage__c = 'Completed', Contact_Assignment__c = cA.Id, L_Goal__c = cA.L_Score_Final__c, R_Goal__c = cA.R_Score_Final__c, S_Goal__c = cA.S_Score_Final__c, W_Goal__c = cA.W_Score_Goal__c);     
                                    
                                    String sgoal = (String.isNotBlank(cA.S_Score_Final__c) && cA.S_Score_Final__c != 'N/A') ? cA.S_Score_Final__c : '-';
                                    String lgoal = (String.isNotBlank(cA.L_Score_Final__c) && cA.L_Score_Final__c != 'N/A') ? cA.L_Score_Final__c : '-';
                                    String rgoal = (String.isNotBlank(cA.R_Score_Final__c) && cA.R_Score_Final__c != 'N/A') ? cA.R_Score_Final__c : '-';
                                    String wgoal = (String.isNotBlank(cA.W_Score_Goal__c) && cA.W_Score_Goal__c != 'N/A') ? cA.W_Score_Goal__c : '-';

                                    String goal_SLRW = sgoal+'/'+lgoal+'/'+rgoal+'/'+wgoal; // Values from CA
                                    String score_SLRW = '0/0/0/-';  // Static values
                                    
                                    if(programTypesToCreateInitialLTs.contains(newProject.Program_type__c)){
                                      
                                        lTList.add(new LTInnerClass(initial_LT,'Language Testing', True, cA.Candidate_Name__c, cA.Candidate_Name__r.Name, goal_SLRW, score_SLRW));
                                    }
                                    lTList_Temp.add(new LTInnerClass(initial_LT,'Language Testing', True, cA.Candidate_Name__c, cA.Candidate_Name__r.Name, goal_SLRW, score_SLRW));    
                                }
                                
                                if(cA.Status__c != 'Cancelled')
                                    studCount +=1;
                            } else if(cA.RecordTypeId == instructorRecTypeId && (cA.Status__c == 'Active' || cA.Status__c  == 'Planned' || cA.Status__c == 'Ended' || cA.Status__c == 'Awarded')) {
                                // For event date conflicts that occure due to Planned Days Off
                                contactIdWithRecordTypeMap.put(cA.Candidate_Name__c,cA.RecordType.Name);
                                
                                instructorCAList.add(new InstructorAssignInnerClass(cA,(cA.Opportunity_Product_Id__c != null && oPLIIdKeyProTaskNameValueMap.containskey(cA.Opportunity_Product_Id__c)) ? oPLIIdKeyProTaskNameValueMap.get(cA.Opportunity_Product_Id__c) : ''));
                                instructorNameList.add(new SelectOption(cA.Candidate_Name__c,cA.Candidate_Name__r.Name));
                            } 
                        }
                        
                        Set<Id> oppIdSet = new Set<Id>();
                        oppIdSet.add(oppId);
                        List<Payment_Item__c> paymentItemList = FundingItemService.getPaymentItemsByPaymentOpportunityIds(oppIdSet);
                        for(Payment_Item__c PI : paymentItemList /*[SELECT Id,Name,Amount__c,Payment__c,Project_Task__c,payment__r.Name,Product__c,Product__r.Name FROM Payment_Item__c WHERE Payment__r.Opportunity__c =: oppId]*/) {
                            paymentLineList.add(new PaymentLineInnerClass(PI,((PI.Opportunity_Product_Id__c != null && oPLIIdKeyProTaskNameValueMap.containskey(PI.Opportunity_Product_Id__c)) ? oPLIIdKeyProTaskNameValueMap.get(PI.Opportunity_Product_Id__c) : '')));                    
                        }
                                       
                        /*for(Materials_Request__c mr : [SELECT Id, Name, Class_Name__c, Materials_Name__c, Materials_Name__r.Name, Project_Task__c, Date_Delivered__c, Contact__c, Contact__r.Name, DLS_Total__c, Qty__c, Language__c, Date_Ordered__c, Request_Status__c, Due_Date__c, Request_Notes__c FROM Materials_Request__c WHERE Class_Name__c =: oppId]){
                            matReqs.add(new MatReqInnerClass(mr,'Language Materials'));
                        }*/
                        
                        List<Materials_Request__c> materialReqList = MaterialRequestService.getMaterial(' WHERE Class_Name__c = \''+oppId+'\'',' Materials_Name__r.Name, Contact__r.Name, RecordType.DeveloperName');
                        Integer newCount = 1;
                        
                        for(Materials_Request__c mr : materialReqList){
                            matReqs.add(new MatReqInnerClass(mr,'Language Materials'));
                            if (mr.RecordType.DeveloperName == 'Project_Materials_Request') {
                                newCount++;
                            }
                        }
                        
                        Set<Id> acctIdSet = new Set<Id>();
                        System_Values__c sv = System_Values__c.getValues('MR - Account Id Set');
                        if(sv != null && sv.Value__c != null) {
                            for (String s : sv.Value__c.split(',')) {
                                acctIdSet.add(s);
                            }
                        }                                                
                        if(studCount > 0 && String.isNotBlank(opp[0].StageName) && opp[0].StageName != 'On Hold' && 
                            opp[0].StageName != 'Ended' && opp[0].RecordType.DeveloperName != 'Partner_School'){
                        
                            // Added 'DLI_Project_Type__c - EI' condition on Nov 16 2023
                            // W-007926 - Request to Not Auto Create LMS Course for EI Projects
                            
                            if((opp[0].RecordType.DeveloperName == 'ODNI_CLP_Opportunities' && 
                                lmsFreeProjectTypes.contains(opp[0].Project_Type__c) && opp[0].Location__r.Name != 'ICA - Rosslyn' && 
                                opp[0].Location__r.Name != 'ICLS - Washington, DC') ||
                                opp[0].RecordType.DeveloperName == 'New_Classes_Opportunities' || 
                                (opp[0].RecordType.DeveloperName == 'DLI_W_TO_Opportunities' && opp[0].DLI_Project_Type__c != 'EI')){
                                
                                System_Values__c sysVal = System_Values__c.getValues('Convert to Project - LMS Enroll Free');
                                if (sysVal != null && sysVal.Value__c != null) {
                                    List<Materials__c> materials = [SELECT Id,Name FROM Materials__c WHERE Name =: sysVal.Value__c]; // Old Name = 'LMS Enrollment (Free)'
                                    if(materials.size() > 0) {
                                        Materials_Request__c mr = new Materials_Request__c();
                                        mr.Name = opp[0].DLS_Class__c + '-MR'+ newCount;
                                        mr.Materials_Name__c = materials[0].Id;
                                        //mr.Class_Name__c = opp[0].Id;  // Commented to delete the Materials Req on Project Deletion.
                                        mr.Date_Ordered__c = System.Today();
                                        mr.Request_type__c = 'Student';
                                        mr.Vendor_Total__c = 0;
                                        mr.Request_Status__c = 'Ordered';
                                        mr.Qty__c = studCount;
                                        mr.Location__c = opp[0].Location__c;
                                        mr.Vendor_Name__c = System_Values__c.getValues('MR - D2L Ltd Account Id - LMS Enroll').Value__c;
                                        mr.RecordTypeId = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByName().get('Project Materials Request').getRecordTypeId();
                                        matReqs.add(new MatReqInnerClass(mr,'Language Materials'));
                                    } else {
                                        materialNotExist = TRUE;
                                        msgForMaterialNotExist = 'No "'+ sysVal.Value__c + '" Material found, Please contact your Salesforce Admin for help';
    
                                    }  
                                }                         
                            }else if(opp[0].RecordType.DeveloperName == 'ODNI_CLP_Opportunities' && lmsProjectTypes.contains(opp[0].Project_Type__c) && 
                                opp[0].Location__r.Name != 'ICA - Rosslyn' && opp[0].Location__r.Name != 'ICLS - Washington, DC') {
                            
                                System_Values__c sysVal = System_Values__c.getValues('Convert to Project - LMS Enrollment');
                                if (sysVal != null && sysVal.Value__c != null) {
                                    List<Materials__c> mat = [SELECT Id,Name FROM Materials__c WHERE Name =: sysVal.Value__c]; // Old Name = 'LMS Enrollment'
                                    if(mat.size() > 0) {
                                        Materials_Request__c mr = new Materials_Request__c();
                                        mr.Name = opp[0].DLS_Class__c + '-MR'+ newCount;
                                        mr.Materials_Name__c = mat[0].Id;
                                        //mr.Class_Name__c = opp[0].Id;  // Commented to delete the MAterials Req on Project Deletion.
                                        mr.Date_Ordered__c = System.Today();
                                        mr.Request_type__c = 'Student';
                                        mr.Vendor_Total__c = 49.00 * studCount;
                                        mr.Request_Status__c = 'Ordered';
                                        mr.Qty__c = studCount;
                                        mr.Location__c = opp[0].Location__c;
                                        mr.Vendor_Name__c = System_Values__c.getValues('MR - D2L Ltd Account Id - LMS Enroll').Value__c;
                                        mr.RecordTypeId = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByName().get('Project Materials Request').getRecordTypeId();
                                        matReqs.add(new MatReqInnerClass(mr,'Language Materials'));
                                    } else {
                                        materialNotExist = TRUE;
                                        msgForMaterialNotExist = 'No "'+ sysVal.Value__c + '" Material found, Please contact your Salesforce Admin for help';
                                    } 
                               }
                                //newCount++;
                            }
                        }
                        
                        List<Get_Feedback__c> oppGetFeedBack = [SELECT Id,Name FROM Get_Feedback__c WHERE Opportunity__c = :oppId];
                        
                        if( oppGetFeedBack != null && oppGetFeedBack.size() > 0 ) {
                            noOfGetFeedBack = oppGetFeedBack.size();
                            feedBackList.addall(oppGetFeedBack);
                        }
                        Set<String> tempProjTaskAddSet = new Set<String>();
                        Set<String> oldPtNAmeSet = new Set<String>();
                        oldPtNAmeSet.addAll(oPLIIdKeyProductNameValueMap.Values());                        
                        if(opp[0].RecordType.DeveloperName == 'DLI_W_TO_Opportunities' || opp[0].RecordType.DeveloperName == 'ODNI_CLP_Opportunities' || opp[0].RecordType.DeveloperName == 'New_Classes_Opportunities'){
                            isRequired = true;
                        } else {
                            isRequired = false;
                        }
                        // Work Item: W-006993 - Make Classification and Section Required on Conversion
                        if((opp[0].RecordType.DeveloperName == 'DLI_W_TO_Opportunities' && ( opp[0].Project_Type__c != 'HUB' && opp[0].Project_Type__c != 'MTT' && opp[0].Project_Type__c != 'Overseas MTT')) || 
                            opp[0].RecordType.DeveloperName == 'ODNI_CLP_Opportunities' || opp[0].RecordType.DeveloperName == 'New_Classes_Opportunities' || opp[0].RecordType.DeveloperName == 'Testing_Opportunities'){
                            is_class_Sec_Required = true;
                        }
                        
                        if(opp[0].RecordType.DeveloperName == 'New_Classes_Opportunities' || opp[0].RecordType.DeveloperName == 'EFL_Opportunities' || opp[0].RecordType.DeveloperName == 'MTT_Opportunities' || opp[0].RecordType.DeveloperName == 'Testing_Opportunities' ||
                            opp[0].RecordType.DeveloperName == 'DLI_W_TO_Opportunities' || opp[0].RecordType.DeveloperName == 'ODNI_CLP_Opportunities') {
                            isSupAndLocReq = true;
                        }
                        
                        if((opp[0].RecordType.DeveloperName == 'DLI_W_TO_Opportunities' && ( opp[0].Project_Type__c == 'HUB' || opp[0].Project_Type__c == 'MTT' || opp[0].Project_Type__c == 'Overseas MTT')) || (opp[0].RecordType.DeveloperName == 'MTT_Opportunities') ) {
                            isMtt = True;
                            List<RecordType> rtypeList = [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType = 'AcctSeed__Project__c' AND DeveloperName = 'MTT_Projects' ];
                            if(rtypeList != null && rtypeList.size() > 0) {
                                newProject.RecordTypeId = rtypeList[0].Id;
                            }
                            
                        } else if(opp[0].RecordType.DeveloperName == 'Testing_Opportunities') {
                            isSDEDReq = false;
                            newProject.End_Date__c = opp[0].Oral_Exam__c != null ? opp[0].Oral_Exam__c.date() : null;
                        } 
                        
                        for(Time_Log__c tl : [SELECT Contact__c,Contact__r.Name,Notes__c,Hours__c,Date__c,First_Name__c,Last_Name__c,Name,Opportunity__c,Service_Item__c,Billable_Work__c,Classification__c,Unposted__c,Payroll_Item__c FROM Time_Log__c WHERE Opportunity__c =: oppId AND Unposted__c = False Order By Date__c Asc]) {
                            String ProjTaskName = 'Language Training- ';
                            // to check whether their is time entered for Preparation
                            if((opp[0].RecordType.DeveloperName == 'DLI_W_TO_Opportunities' || opp[0].RecordType.DeveloperName == 'ODNI_CLP_Opportunities') && tl.Notes__c != null && tl.Notes__c.contains('prep')) {
                                hasPrepTime = true;
                                if(!oldPtNAmeSet.contains('Language Training- Preparation')){
                                    lTProductNotExist = True;
                                    unAvailableProd.add('Language Training- Preparation');
                                }
                            }
                            
                            if( tl.Service_Item__c != null && tl.Service_Item__c.contains('SVC:Language Training:')) {
                                List<String> serStrList = tl.Service_Item__c.split('SVC:Language Training:');
                                if(serStrList != null && serStrList.size() > 1) {
                                    ProjTaskName += serStrList[1];
                                    
                                    if(productNameStaticMap.containsKey(ProjTaskName)){
                                        ProjTaskName = productNameStaticMap.get(ProjTaskName);
                                    }
                                    
                                    // Added condition to Check for Different Product when the Account name is "MPO" 
                                    if ( ( !isMtt && (!oldPtNAmeSet.Contains(ProjTaskName) && ( String.isNotBlank(mPOAccountId) && opp[0].AccountId == mPOAccountId && !oldPtNAmeSet.contains('MPO ELT III LT - Part-Time') && !oldPtNAmeSet.contains('MPO ELT III LT - Full-Time' ) ) || !oldPtNAmeSet.Contains(ProjTaskName) ) ) || ( isMtt && !oldPtNAmeSet.Contains('MTT Remote Training') && !oldPtNAmeSet.Contains(ProjTaskName) ) ){
                                        lTProductNotExist = True;
                                        unAvailableProd.add(ProjTaskName);
                                    }
                                } 
                            } else if(tl.Service_Item__c != null && tl.Service_Item__c.contains('SVC:Preparation time')) {
                                if(!oldPtNAmeSet.contains('Language Training- Preparation')){
                                    lTProductNotExist = True;
                                    unAvailableProd.add('Language Training- Preparation');
                                }
                            } else if ( tl.Service_Item__c != null && tl.Service_Item__c.contains('SVC:')) {
                                List<String> siStrList = tl.Service_Item__c.split('SVC:');
                                if(siStrList != null && siStrList.size() > 1) {
                                    ProjTaskName = siStrList[1];
                                } else {
                                    ProjTaskName = tl.Service_Item__c;  
                                }
                                if ( !oldPtNAmeSet.Contains(ProjTaskName)) {
                                    lTProductNotExist = True;
                                    unAvailableProd.add(ProjTaskName);
                                }
                                /*if(!tempProjTaskAddSet.contains(ProjTaskName )) {
                                    projectTaskInnserClassList.add(new ProjectTaskInsertInnerClass(new AcctSeed__Project_Task__c(Rate__c = 00,Total_Qty_Planned__c=1,Name = ProjTaskName ,Project_Task_Type__c = ProjTaskName /*,Unit__c=oLI.Product2.Unit_Type__c,Product__c=oLI.Product2Id,Language_LU__c=oLI.Product2.Language_LU__c*//*), 0));
                                    projectTaskNameList.add(new SelectOption(ProjTaskName ,ProjTaskName));
                                    tempProjTaskAddSet.add(ProjTaskName);
                                } Commented by GRK inorder to allow Project Conversion only if a corresponding Product is Available*/
                            } else if ( tl.Service_Item__c != null) {
                                ProjTaskName = tl.Service_Item__c;
                                if((tl.Service_Item__c != 'Fringe' || (tl.Service_Item__c == 'Fringe' && tl.Payroll_Item__c != null && !PayRollValuesMap.Containskey(tl.Payroll_Item__c))) && !tempProjTaskAddSet.contains(tl.Service_Item__c)) {
                                    if ( !oldPtNAmeSet.Contains(ProjTaskName)) {
                                        lTProductNotExist = True;
                                        unAvailableProd.add(ProjTaskName);
                                    }
                                    //Commented by GRK inorder to allow Project Conversion
                                    //projectTaskInnserClassList.add(new ProjectTaskInsertInnerClass(new AcctSeed__Project_Task__c(Rate__c = 00,Total_Qty_Planned__c=1,Name = tl.Service_Item__c,Project_Task_Type__c = tl.Service_Item__c,Payroll_Item__c = tl.Payroll_Item__c/*,Unit__c=oLI.Product2.Unit_Type__c,Product__c=oLI.Product2Id,Language_LU__c=oLI.Product2.Language_LU__c*/), 0));
                                    /*projectTaskNameList.add(new SelectOption(tl.Service_Item__c,tl.Service_Item__c));
                                    tempProjTaskAddSet.add(tl.Service_Item__c);*/
                                    
                                // For Admin Opp with Holidays, Sick, Vacation, Other Pay as Project Task    
                                } else if(tl.Service_Item__c == 'Fringe' && tl.Payroll_Item__c != null && payRollValuesMap.Containskey(tl.Payroll_Item__c)) {
                                    String tempPT = tl.Service_Item__c+'-'+payRollValuesMap.get(tl.Payroll_Item__c);
                                    ProjTaskName = tl.Service_Item__c+'-'+payRollValuesMap.get(tl.Payroll_Item__c);
                                    if ( !oldPtNAmeSet.Contains(ProjTaskName)) {
                                        lTProductNotExist = True;
                                        unAvailableProd.add(ProjTaskName);
                                    }
                                    //Commented by GRK inorder to allow Project Conversion
                                    /*if(!tempProjTaskAddSet.contains(tl.Service_Item__c+'-'+payRollValuesMap.get(tl.Payroll_Item__c))) {
                                        projectTaskInnserClassList.add(new ProjectTaskInsertInnerClass(new AcctSeed__Project_Task__c(Rate__c = 00,Total_Qty_Planned__c=1,Name = tempPT,Project_Task_Type__c = tl.Service_Item__c,Payroll_Item__c = tl.Payroll_Item__c/*,Unit__c=oLI.Product2.Unit_Type__c,Product__c=oLI.Product2Id,Language_LU__c=oLI.Product2.Language_LU__c*//*), 0));
                                        projectTaskNameList.add(new SelectOption(tempPT ,tempPT ));
                                        tempProjTaskAddSet.add(tempPT);
                                    }*/
                                }
                            }
                            //if(tl.Service_Item__c != null) {
                                //tcdL.add(new tcdInnerCls(new AcctSeed__Time_Card_Day__c(AcctSeed__Date__c = tl.Date__c,Status__c = 'Approved',Total_Hours_Before_Approved__c = tl.Hours__c,AcctSeed__Hours__c = tl.Hours__c),tl.Contact__c,tl.Contact__r.Name,tl.Billable_Work__c,ProjTaskName,tl));
                            //}
                            
                            if(tl.Contact__c != null) {
                                contIds.add(tl.Contact__c);
                                // Added to show the Summary view for Time Log
                                string contIdName = tl.Contact__c + '-' + tl.Contact__r.Name;
                                if(!contIdPtNameHoursMap.Containskey(contIdName) && tl.Service_Item__c != null) {
                                    contIdPtNameHoursMap.put(contIdName, new Map<String,Decimal>());   
                                    contIdPtNameHoursMap.get(contIdName).put(ProjTaskName,tl.Hours__c);
                                } else if(contIdPtNameHoursMap.get(contIdName) != null && tl.Service_Item__c != null && !contIdPtNameHoursMap.get(contIdName).containskey(ProjTaskName)) {
                                    contIdPtNameHoursMap.get(contIdName).put(ProjTaskName,tl.Hours__c);
                                } else if(contIdPtNameHoursMap.get(contIdName) != null && tl.Service_Item__c != null && contIdPtNameHoursMap.get(contIdName).containskey(ProjTaskName)) {
                                    Decimal hourTotal = (contIdPtNameHoursMap.get(contIdName).get(ProjTaskName) != null ? contIdPtNameHoursMap.get(contIdName).get(ProjTaskName) : 0) + (tl.Hours__c != null ? tl.Hours__c: 0);
                                    contIdPtNameHoursMap.get(contIdName).put(ProjTaskName,hourTotal);
                                }
                                
                            }
                            
                            Date sDate;
                            Date eDate;
                            if(tl.Date__c != null) {
                                tlDateSet.add(tl.Date__c);
                                
                                if(tl.Date__c.toStartofWeek().addDays(1) < tl.Date__c) {
                                    sDate = tl.Date__c.toStartofWeek()+1;
                                } else {
                                    sDate = tl.Date__c.addDays(-1).toStartofWeek().addDays(1);
                                }
                                    
                                eDate = sDate.addDays(6);
                            }
                            
                            if(tl.Contact__c != null && !contIdWithStAndEndDateMap.Containskey(tl.Contact__c)) {
                                contIdWithStAndEndDateMap.put(tl.Contact__c, new Map<Date,Date>());
                            } 
                            
                            if(contIdWithStAndEndDateMap != null && contIdWithStAndEndDateMap.containskey(tl.Contact__c) && !contIdWithStAndEndDateMap.get(tl.Contact__c).containskey(sDate)) {
                                contIdWithStAndEndDateMap.get(tl.Contact__c).put(sDate,eDate);
                            }                    
                            
                        }
                        
                        // To Display the Parent Project Task as a picklist. ADded by GRK on Nov 6 for LT - Prep Times. 
                        if(hasPrepTime) {
                            for(ProjectTaskInsertInnerClass pti: projectTaskInnserClassList) {
                                pti.parentPTList.add(new SelectOption('','---None---'));
                                Set<String> tempPT = new Set<String>(projectTskNames);
                                tempPT.remove(pti.projTask.Name);
                                for(String ptN : tempPT) {
                                    pti.parentPTList.add(new SelectOption(ptN,ptN));
                                }
                            }
                        }
                        
                        // Added to show the Summary view for Time Log
                        for(String conId : contIdPtNameHoursMap.keyset()) {
                            List<String> conIdAndName = conId.split('-');
                            if(conIdAndName != null && conIdAndName.size() > 1) {
                                for(String pt : contIdPtNameHoursMap.get(conId).Keyset()) {
                                    tlList.add(new TimeLogInnerClass(conIdAndName[0],conIdAndName[1],contIdPtNameHoursMap.get(conId).get(pt),pt));
                                }
                            }
                        }
                        
                        // Modified by Siva Prasanth on 16/6/21. show the Hourly cost input in ConvertToProject screen for CR creation for DODA if  contact  does n't have below ratetype combination
                        Set<String> crStatus = new Set<String>{'Approved','Draft','Submitted for Approval'};
                        Set<Id> insCons = new Set<Id>();
                        Set<Id> conRelCR = new Set<Id>();
                        Map<Id,List<SelectOption>> contactWithCRMap = new Map<Id,List<SelectOption>>();
                        
                        if(opp[0].RecordType.DeveloperName != null && opp[0].RecordType.DeveloperName == 'ODNI_CLP_Opportunities' && opp[0].Default_Cost_Rate_Rate_Type__c != null) {   
                            
                            for(InstructorAssignInnerClass iA : instructorCAList) {
                                Contact_Assignments__c cAs = iA.instructorCA;
                                if(cAs.Candidate_Name__c != null && (cAs.Status__c == 'Active' || cAs.Status__c == 'Planned') && cAs.Drafted_Labor_Cost_Rate__c == null && cAs.Rate_Card_Rate__c == null){
                                    insCons.add(cAs.Candidate_Name__c);  
                                }
                            }
                            
                            for(AcctSeed__Cost_Rates__c cR : [Select Id ,Status__c,Contact__c,Cost_Rate_Name__c FROM AcctSeed__Cost_Rates__c WHERE  Contact__c IN :insCons  AND Rate_Type__c = :opp[0].Default_Cost_Rate_Rate_Type__c AND Status__c IN :crStatus Order by CreatedDate Desc]){
                                
                                if(!conRelCR.contains(cR.Contact__c)){
                                    conRelCR.add(cR.Contact__c);
                                }
                                
                                if(cR.Status__c == 'Approved'){
                                    if(contactWithCRMap.containsKey(cR.Contact__c)){
                                        contactWithCRMap.get(cR.Contact__c).add(new SelectOption(cR.Id+'~'+cR.Status__c,cR.Cost_Rate_Name__c));
                                    }else{
                                        contactWithCRMap.put(cR.Contact__c,new List<SelectOption>{new SelectOption('','---None---'),new SelectOption(cR.Id+'~'+cR.Status__c,cR.Cost_Rate_Name__c)});
                                    }
                                }
                            }
                                 
                                 for(InstructorAssignInnerClass iA : instructorCAList) {
                                     Contact_Assignments__c cAs = iA.instructorCA;
                                     if(cAs.Candidate_Name__c != null && (cAs.Status__c == 'Active' || cAs.Status__c == 'Planned') && cAs.Drafted_Labor_Cost_Rate__c == null && cAs.Rate_Card_Rate__c == null){
                                         if(!conRelCR.contains(cAs.Candidate_Name__c)){
                                             isShowCRColumn = true; 
                                             iA.isShowHourlyCR = true;
                                         }else if(contactWithCRMap.containsKey(cAs.Candidate_Name__c)){
                                             List<SelectOption> crOptions = contactWithCRMap.get(cAs.Candidate_Name__c);
                                             if(crOptions.size() > 0){
                                                 if(crOptions.size() > 2){
                                                     iA.isShowCostRate = true;
                                                     isShowCRColumn = true;
                                                     iA.costRateOption = crOptions; 
                                                 }else{
                                                     iA.selectedCR =  crOptions[1].getValue();
                                                 }
                                             }
                                         }
                                     }
                                 }
                             }
                        // End
                        
                        if( tlDateSet != null && tlDateSet.size() > 0 ) {
                            
                            stDate = tlDateSet[0];
                            endDate = tlDateSet[tlDateSet.size()-1];
                            Date finalEndDate = endDate.toStartofWeek()+7;
                           
                            Date weekstdate;
                            Date weekenddate;
                            
                            if(stDate.toStartofWeek().addDays(1) < stDate)
                                weekstdate = stDate.toStartofWeek().addDays(1);
                            else
                                weekstdate = stDate.addDays(-1).toStartofWeek().addDays(1);
                                
                            weekenddate = weekstdate.addDays(6);
                            
                            while(weekstdate <= finalEndDate && weekenddate <= finalEndDate) {
                                startdtSet.add(weekstdate);
                                enddtSet.add(weekenddate);  
                                
                                if(!stdateandEnddtMap.containsKey(weekstdate)) {
                                    stdateandEnddtMap.put(weekstdate,weekenddate);
                                }
                                                        
                                Date monthStart = weekstdate.toStartofMonth();
                                Date monthEnd = weekstdate.addMonths(1).toStartofMonth().addDays(-1);
                                
                                monthStartdtSet.add(monthStart);
                                monthEnddtSet.add(monthEnd);
                                
                                weekstdate = weekstdate.addDays(7);
                                weekenddate = weekenddate.addDays(7); 
                            }
                        }
                        
                        for(AcctSeed__Billing__c ab : [SELECT Id,Name,Project__c,AcctSeed__Opportunity__c,AcctSeed__Customer__c,AcctSeed__Status__c,(SELECT Id,Name,AcctSeed__Product__c,AcctSeed__Product__r.Name,AcctSeed__Project__c,AcctSeed__Project_Task__c FROM AcctSeed__Project_Billing_Lines__r) FROM AcctSeed__Billing__c WHERE AcctSeed__Opportunity__c =: oppId]) {
                            billingList.add(ab);
                        }
                        
                        // to handle the event date conflicts
                        
                        if( contactIdWithRecordTypeMap != null && contactIdWithRecordTypeMap.size() > 0 ) {
                                                     
                            // this code commented by sukanya
                            
                            /*for(Planned_Days_Off__c daysOff : [Select Id,Contact__c,Date__c,Description__c,Requested_Reschedule_Date__c FROM Planned_Days_Off__c WHERE Contact__c IN: contactIdWithRecordTypeMap.keySet()]) {
                                plannedDaysOffDateWithCARecordTypeMap.put(daysOff.Date__c,contactIdWithRecordTypeMap.containskey(daysOff.Contact__c)?contactIdWithRecordTypeMap.get(daysOff.Contact__c):'');
                                dayOffDateWithReschedDateMap.put(daysOff.Date__c,daysOff.Requested_Reschedule_Date__c);
                            }*/
                            //USed Service method for planned days records get
                            List<Planned_Days_Off__c> plannedList = PlannedDaysOffService.getPlanneddaysBycontact(' WHERE',contactIdWithRecordTypeMap.keySet(),new Set<Date>{},'',false,'');
                            for(Planned_Days_Off__c daysOff : plannedList) {
                                plannedDaysOffDateWithCARecordTypeMap.put(daysOff.Date__c,contactIdWithRecordTypeMap.containskey(daysOff.Contact__c)?contactIdWithRecordTypeMap.get(daysOff.Contact__c):'');
                                dayOffDateWithReschedDateMap.put(daysOff.Date__c,daysOff.Requested_Reschedule_Date__c);
                            }
                        }
                        
                        if( plannedDaysOffDateWithCARecordTypeMap != null && plannedDaysOffDateWithCARecordTypeMap.size() > 0 ) {
                            Date temp;
                           /* for(Events__c evnt : [SELECT Id,Name,Date__c,Duration__c,End_Time__c,Event_Agenda__c,Status__c,Start_Time__c FROM Events__c WHERE Date__c IN: plannedDaysOffDateWithCARecordTypeMap.keyset() AND Schedule__r.Opportunity__c =: oppId AND Status__c = 'Scheduled']) {
                                eventIdSet.add(evnt.Id);
                                temp = evnt.Date__c;
                                String contactType = plannedDaysOffDateWithCARecordTypeMap.containskey(evnt.Date__c)?plannedDaysOffDateWithCARecordTypeMap.get(evnt.Date__c):'';
                                
                                if(dayOffDateWithReschedDateMap != null && dayOffDateWithReschedDateMap.size() > 0) {
                                    evnt.Date__c = dayOffDateWithReschedDateMap.get(evnt.Date__c);                           
                                }
                                eventList.add(new UtilDomain.EventInnerClass(evnt,contactType,temp));
        
                            }*/
                            List<Events__c> eveList = new List<Events__c>();
                            
                            Set<Date> dateSet = new Set<date>();
                            dateSet = plannedDaysOffDateWithCARecordTypeMap.keyset();
                            
                            if(oppId != null && dateSet != null){
                                eveList = EventService.getEventsByDateANDScheduleId(' WHERE  Schedule__r.Opportunity__c = \''+oppId+'\'  AND Status__c = \'Scheduled\' AND Date__c ',dateSet,new Set<Id>{},new Set<Id>{},'','');
                            }
                            
                            for(Events__c evnt : eveList) {
                                eventIdSet.add(evnt.Id);
                                temp = evnt.Date__c;
                                String contactType = plannedDaysOffDateWithCARecordTypeMap.containskey(evnt.Date__c)?plannedDaysOffDateWithCARecordTypeMap.get(evnt.Date__c):'';
                                
                                if(dayOffDateWithReschedDateMap != null && dayOffDateWithReschedDateMap.size() > 0) {
                                    evnt.Date__c = dayOffDateWithReschedDateMap.get(evnt.Date__c);                           
                                }
                                eventList.add(new UtilDomain.EventInnerClass(evnt,contactType,temp));
        
                            }
                        }
                    } else {
                        lTProductNotExist = True;
                        if(opliList.size() == 0 || opliList == null) {
                            if(msgForProductNotExist != null && msgForProductNotExist != '') {
                                msgForProductNotExist += ' \n Please create at least one Product in order to convert this Opportunity to a Project';
                            } else {
                                msgForProductNotExist = 'Please create at least one Product in order to convert this Opportunity to a Project';
                            }
                        }
                    }
                    //}
                }
            }else {
                lTProductNotExist = True;
                msgForProductNotExist = 'Insufficient Privilege';
            }
        }  
    }  
    public pageReference createProjectAndProjectTask() {
                
        Map<String,Id> projectTaskNameWithProjectTaskId = new Map<String,Id>();
        Map<Id,Id> schIdWithInstructorIdMap = new Map<Id,Id>();
        List<Contact_Assignments__c> contactAssignmentListToUpdate = new List<Contact_Assignments__c>();
        List<Contact_Assignments__c> contactAssignmentListToUpdateStudent = new List<Contact_Assignments__c>();
        List<Contact_Assignments__c> contactAssignmentListToUpdateStaff = new List<Contact_Assignments__c>();
        List<Events__c> eventListToUpdate = new List<Events__c>();
        List<Language_Testing__c> lTListToUpd = new List<Language_Testing__c>();
        Set<Id> scheduleIdSet = new Set<Id>();
        //Map<Date,Id> evntDateIdMap = new Map<Date,Id>();
        Set<Id> schErrorIdSet = new Set<Id>(); 
        Set<Id> insErrorIdSet = new Set<Id>(); 
        Map<String,String> contServItemPtName = new Map<String,String>();
        Set<Id> cardTimePeriodIdSet = new Set<Id>();
       //Transient List<tcdInnerCls> tcdL = new List<tcdInnerCls>();
        Map<Id,AcctSeed__Time_Card_Period__c> acctTimePrdMap = new Map<Id,AcctSeed__Time_Card_Period__c>();  
        //Map<String,Decimal> accCARelHourlyCostRateMap = new Map<String,Decimal>();
        
        List<AcctSeed__Time_Card_Day__c> tcdays = new List<AcctSeed__Time_Card_Day__c>();
        if( oppRec != null ) {
            Savepoint sp = Database.setSavepoint();
            try {
                
                /*if(newProject.Project_Type__c != null && (newProject.Project_Type__c == 'MTT' || newProject.Project_Type__c != 'HUB' || newProject.Project_Type__c != 'Overseas MTT')) {
                   showMttErrorMsg = true;
                }*/
                
                for(ScheduleUpdateInnerClass sch : scheduleList) {
                    scheduleIdSet.add(sch.schRec.Id); 
                    if( sch.productNameAsProjectTask == null && !Test.isRunningTest()) {
                        sch.error = TRUE;
                        schErrorIdSet.add(sch.schRec.Id);
                    } else {
                        sch.error = FALSE;
                    }
                }
                Map<Id,Decimal> conRelCRHourlyCostMap = new Map<Id,Decimal>();
                for(InstructorAssignInnerClass iA : instructorCAList) {
                    
                    if( iA.productNameAsProjectTask == null && !Test.isRunningTest() ) {
                        iA.error = TRUE;
                        insErrorIdSet.add(iA.instructorCA.Id);
                    } else {
                        iA.error = FALSE;
                    }
                    
                    if((String.isBlank(iA.crHourlyCost) && iA.isShowHourlyCR == true) && !Test.isRunningTest() ) {
                        iA.crHourlyReqError = TRUE;
                        insErrorIdSet.add(iA.instructorCA.Id); 
                    }else{
                        iA.crHourlyReqError = FALSE;
                    }

                    if((String.isBlank(iA.selectedCR) && iA.isShowCostRate == true) && !Test.isRunningTest() ) {
                        iA.isShowCostRateReqError = TRUE;
                        insErrorIdSet.add(iA.instructorCA.Id);
                    }else{
                        iA.isShowCostRateReqError = FALSE;
                    }
                                        
                    if((iA.isShowCostRate == true && String.isNotBlank(iA.selectedCR)) || String.isNotBlank(iA.selectedCR)){
                        List<String> selCR = (iA.selectedCR).split('~'); 
                        if(selCR.size() > 0){
                            if(selCR[1] == 'Approved'){
                                iA.instructorCA.Rate_Card_Rate__c = selCR[0]; 
                            }else{
                                iA.instructorCA.Drafted_Labor_Cost_Rate__c =  selCR[0];  
                            }
                        }
                    }
                    
                    // store the hourlycost value in conRelCRHourlyCostMap for CR creation
                    if(iA.isShowHourlyCR == true && String.isNotBlank(iA.crHourlyCost)){
                        if(iA.instructorCA.Candidate_Name__c != null && iA.instructorCA.Drafted_Labor_Cost_Rate__c == null && iA.instructorCA.Rate_Card_Rate__c == null){ 
                            if(!conRelCRHourlyCostMap.containsKey(iA.instructorCA.Candidate_Name__c)){
                                String hc = iA.crHourlyCost;
                                conRelCRHourlyCostMap.put(iA.instructorCA.Candidate_Name__c,Decimal.valueOf((hc).replaceAll('[^.\\d]',''))); 
                            }
                        }
                    }
                }
                for(StudentAssignInnerClass sA : studentCAList) {
                    
                    Contact_Assignments__c studentCA = sA.studentCA;
                    
                    if(studentCAList.size() > 1){
                        if(sA.position == 'Class Leader'){
                            conId = studentCA.Candidate_Name__c;
                        }
                    }else{
                        conId = studentCA.Candidate_Name__c;
                    }
                    
                    if( sA.position == null && !Test.isRunningTest() ) {
                        sA.error = TRUE;
                        insErrorIdSet.add(sA.studentCA.Id);
                    } else {
                        sA.error = FALSE;
                    }
                }
                
                for(PaymentLineInnerClass pLL : paymentLineList) {
                    
                    if( pLL.productNameAsProjectTask == null  && !Test.isRunningTest() ) {
                        pLL.error = TRUE;
                        insErrorIdSet.add(pLL.Payment.Id);
                    } else {
                        pLL.error = FALSE;
                    }
                }
                for( ProjectTaskInsertInnerClass proTask : projectTaskInnserClassList) {
                    if(proTask.projTask != null && proTask.productNameAsProjectTask == null && (proTask.projTask.Name.contains('Preparation') || proTask.projTask.Name.contains('Additional'))) {
                        proTask.error = True;
                        insErrorIdSet.add(proTask.projTask.Product__c);
                    } else {
                        proTask.error = false;
                    }
                }
               
                for(MatReqInnerClass mr : matReqs) {                   
                    if( mr.productNameAsProjectTask == null && !Test.isRunningTest() ) {
                        mr.error = TRUE;
                        insErrorIdSet.add(mr.mrq.Id);
                    } else {
                        mr.error = FALSE;
                    }
                }                
                
                for(LTInnerClass gi : lTList) {                   
                    if( gi.ptName == null && !Test.isRunningTest() ) {
                        gi.error = TRUE;
                        insErrorIdSet.add(gi.obj.Id);
                    } else {
                        gi.error = FALSE;
                    }
                }
                
                // Added to show the Summary view for Time Log
                for(TimeLogInnerClass ti : tlList) {                
                    if( ti.newProjectTask == null && !Test.isRunningTest()) {
                        ti.error = TRUE;
                        insErrorIdSet.add(ti.contactId);
                    } else {
                        ti.error = FALSE;                       
                        contServItemPtName.put(ti.contactId+ti.oldProjectTask, ti.newProjectTask);
                    }
                }
                Map<Date,String> eventDateWithStartAndEndTimeMap = new Map<Date,String>();
                Map<String,List<String>> oldEventSchDateWithSTAndETMap = new Map<String,List<String>>();
                oldEventDateSTETWithIdNameMap = new Map<String,List<Events__c>>();
                Set<String> newEventSchDateWithSTAndET = new Set<String>(); // ST - Start Time ,ET- End Time
                // To show error when the start time and end time conflict occurs in event
                if( scheduleIdSet != null && scheduleIdSet.size() > 0 ) {
                    
                    for(UtilDomain.EventInnerClass e : eventList) {
                        //newEventSchDate.add(e.Date__c);
                        eventDateWithStartAndEndTimeMap.put(e.evt.Date__c,e.evt.Start_Time__c+'-'+e.evt.End_Time__c);

                    } 
                    
                    /*for(Events__c evt : [SELECT Id,Name,Project__c,Start_Time__c,End_Time__c,Date__c FROM Events__c WHERE Schedule__c In: scheduleIdSet AND Id NOT IN: eventIdSet ]) {
                        code as below 
                    }*/
                    
                    for(Events__c evt : EventService.getEventsByDateANDScheduleId(' WHERE Schedule__c',null,scheduleIdSet,eventIdSet,'Id','')) {
                        if( eventDateWithStartAndEndTimeMap != null && eventDateWithStartAndEndTimeMap.containsKey(evt.Date__c)) {  
                        
                            if( eventDateWithStartAndEndTimeMap.get(evt.Date__c) != null ) {
                                List<String> startTimeAndEndTime = eventDateWithStartAndEndTimeMap.get(evt.Date__c).split('-');
                                if(startTimeAndEndTime != null && startTimeAndEndTime.size() > 0) {
                                    if(timeAndDecimalMap != null && ((timeAndDecimalMap.get(evt.Start_Time__c) <= timeAndDecimalMap.get(startTimeAndEndTime[0]) && timeAndDecimalMap.get(evt.End_Time__c) > timeAndDecimalMap.get(startTimeAndEndTime[0])) || (timeAndDecimalMap.get(evt.Start_Time__c) >= timeAndDecimalMap.get(startTimeAndEndTime[0]) && timeAndDecimalMap.get(evt.Start_Time__c) <= timeAndDecimalMap.get(startTimeAndEndTime[1])))) {
                                        //newEventSchDateWithSTAndET.add(evt.Date__c+startTimeAndEndTime[0]+startTimeAndEndTime[1]);
                             
                                        if(oldEventSchDateWithSTAndETMap != null && oldEventSchDateWithSTAndETMap.size() > 0 && oldEventSchDateWithSTAndETMap.containsKey(evt.Date__c+startTimeAndEndTime[0]+startTimeAndEndTime[1])) {
                                            oldEventSchDateWithSTAndETMap.get(evt.Date__c+startTimeAndEndTime[0]+startTimeAndEndTime[1]).add(evt.Start_Time__c+'-'+evt.End_Time__c);
                                        } else {
                                            oldEventSchDateWithSTAndETMap.put(evt.Date__c+startTimeAndEndTime[0]+startTimeAndEndTime[1],new List<String>{evt.Start_Time__c+'-'+evt.End_Time__c});

                                        }
                                        
                                        if(oldEventDateSTETWithIdNameMap != null && oldEventDateSTETWithIdNameMap.containskey(evt.Date__c+startTimeAndEndTime[0]+startTimeAndEndTime[1])) {
                                            oldEventDateSTETWithIdNameMap.get(evt.Date__c+startTimeAndEndTime[0]+startTimeAndEndTime[1]).add(evt);
                                            
                                        } else {   
                                            
                                            oldEventDateSTETWithIdNameMap.put(evt.Date__c+startTimeAndEndTime[0]+startTimeAndEndTime[1],new List<Events__c>{evt});
                                        }
                                    }                                   
                                }
                            }
                        }
                    }
                    Integer i = 0;
                    for(UtilDomain.EventInnerClass e : eventList) {
                        if( oldEventSchDateWithSTAndETMap != null && oldEventSchDateWithSTAndETMap.containskey(e.evt.Date__c+e.evt.Start_Time__c+e.evt.End_Time__c)) {
                            e.error = True;
                            e.errorMsg = 'Already you have an Event around the specified Date, Start time and End Time '+oldEventSchDateWithSTAndETMap.get(e.evt.Date__c+e.evt.Start_Time__c+e.evt.End_Time__c);
                            if(oldEventDateSTETWithIdNameMap != null && oldEventDateSTETWithIdNameMap.size() > 0 && oldEventDateSTETWithIdNameMap.containsKey(e.evt.Date__c+e.evt.Start_Time__c+e.evt.End_Time__c)) {
                                e.evntList.addAll(oldEventDateSTETWithIdNameMap.get(e.evt.Date__c+e.evt.Start_Time__c+e.evt.End_Time__c));
                            }
                            i++;
                        } else {
                            e.error = False;
                        }
                        
                    }
                    if(i>0){
                        //Database.rollback(sp);
                        return null;
                    }
                }
                if( schErrorIdSet.size() > 0 || insErrorIdSet.size() > 0  ) {
                    
                    return null;    
                } else {
                    String tempProjRec;  
                    
                    if( oppRecTypeAndProjRecTypeMap != null && oppRecTypeAndProjRecTypeMap.size() > 0 && oppRecTypeAndProjRecTypeMap.containsKey(oppRec.RecordType.DeveloperName) ) {
                        
                        for( Opportunity_Project_Mapping__c opm : oppRecTypeAndProjRecTypeMap.get(oppRec.RecordType.DeveloperName)) {
                            
                            if(oppRecTypeAndProjRecTypeMap.get(oppRec.RecordType.DeveloperName).size() > 1) {
                                if(opm.Project_Type__c != null && opm.Project_Type__c == oppRec.Project_Type__c ) {
                                    tempProjRec = opm.Project_Value__c;
                                }
                                if(opm.Training_Location_Type__c != null && oppRec.Location__c != null && opm.Training_Location_Type__c == oppRec.Location__r.RecordType.DeveloperName) {
                                    tempProjRec = opm.Project_Value__c;
                                }
                            } else if(oppRecTypeAndProjRecTypeMap.get(oppRec.RecordType.DeveloperName).size() == 1) {
                                tempProjRec = opm.Project_Value__c;
                            }
                        }
                        
                        if(tempProjRec != null && tempProjRec != '' && isMTT != true) {
                            //List<RecordType> rtList = SObjectQueryService.getRecTypeListBySobjTypeAndDevName(' AND DeveloperName ','AcctSeed__Project__c', new Set<String>{tempProjRec});
                            List<RecordType> rtList = [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType = 'AcctSeed__Project__c' AND DeveloperName =: tempProjRec ];
                            if( rtList != null && rtList.size() > 0 ) {
                                newProject.RecordTypeId = rtList[0].Id;
                            }
                        }
                    }
                    // Commented Since the ongoing Conversion will set "Order" as the status.
                    //if(oppStageAndProjStageMap != null && oppStageAndProjStageMap.size() > 0 && oppStageAndProjStageMap.containsKey(oppRec.StageName)) {
                        //newProject.AcctSeed__Status__c = oppStageAndProjStageMap.get(oppRec.StageName);
                    //}
                    
                    // Set to Order based on the Requirement, Have time based workflow to udpate this field
                    newProject.AcctSeed__Status__c = 'Order';
                                        
                    String errormessage = checkOrderContract(newProject);
                    
                    if(errormessage == null || errormessage == '') {
                        
                        // Added by HL on Jan 31 2020
                        // Work Item : W-004721 - PVT Student Child Account Creation
                        // Added By HL on May 11 2020
                        // Work Item : W-005333 - Convert to Project Contact Assignment Issue
                        // Don't create child PVT account for Ended Opportunity while converting it in to Project
                        if(oppRec.Account.Name == 'PVT' && String.isNotBlank(oppRec.StageName) && oppRec.StageName != 'Ended'){
                            childPVTAccId = AccountUtil.createChildPVT(conId);
                        }
                        String newDefaultCR = '';
                        
                        if(oppQBJobTypeUp != Null && (oppQBJobTypeUp.QB_Contract_Type__c != newProject.QB_Contract_Type__c || oppQBJobTypeUp.Order__c != newProject.Order__c || 
                           oppQBJobTypeUp.Project_Type__c != newProject.Project_Type__c || oppQBJobTypeUp.To__c != newProject.To__c || oppQBJobTypeUp.Enrollment_Date__c != oppRec.Enrollment_Date__c ||
                           (oppRec.Account.Name == 'PVT' && childPVTAccId != NULL) || oppQBJobTypeUp.Supervisor__c != newProject.Project_Manager__c || oppQBJobTypeUp.Location__c != newProject.Training_Location__c || 
                           newProject.Default_Cost_Rate_Rate_Type__c != oppQBJobTypeUp.Default_Cost_Rate_Rate_Type__c || oppQBJobTypeUp.Hours__c != newProject.Total_Program_Hours__c ||
                           oppQBJobTypeUp.Program_type__c != newProject.Program_type__c)) {
                           
                            oppQBJobTypeUp.QB_Contract_Type__c = newProject.QB_Contract_Type__c;
                            oppQBJobTypeUp.Order__c = newProject.Order__c;
                            oppQBJobTypeUp.Project_Type__c = newProject.Project_Type__c;
                            oppQBJobTypeUp.To__c = newProject.To__c;
                            oppQBJobTypeUp.A_R_Type__c = newProject.Billing_Type__c;
                            oppQBJobTypeUp.Program_type__c = newProject.Program_type__c;
                            
                            // To update the Opportunities Rate Type when it is updated in the Convertion screen
                            oppQBJobTypeUp.Default_Cost_Rate_Rate_Type__c = newProject.Default_Cost_Rate_Rate_Type__c;
                            // To update the Default Cost Rate Rate Type when Award date is populated for the DLI W TO Opp on conversion
                            // Since formula field is available in PRoject, we are referring the Opp's Award Date field in Page
                            // Award Date is required for the DLI-W TO Opp
                            oppQBJobTypeUp.Enrollment_Date__c = oppRec.Enrollment_Date__c;
                            // Commented below condition to override the Rate Type based on the Award date
                            // Commented as the new rates are used without the enrollment condition
                            /*if(oppRec.Enrollment_date__c != null && oppRec.RecordType.DeveloperName == 'DLI_W_TO_Opportunities') { // && oppRec.Default_Cost_Rate_Rate_Type__c == null
                                string ratVal = '';
                                if(oppRec.Enrollment_Date__c <= date.newinstance(2019,09,30)) {
                                    ratVal = '16';
                                } else if(oppRec.Enrollment_Date__c >= date.newinstance(2019,10,01) && oppRec.Enrollment_Date__c <= date.newinstance(2020,09,30)) {
                                    ratVal = '20';
                                } else if(oppRec.Enrollment_Date__c >= date.newinstance(2020,10,01)){
                                    ratVal = '21';
                                }
                                if(oppQBJobTypeUp.Project_Type__c == 'Resident LT' || oppQBJobTypeUp.Project_Type__c == 'AFPAK') {
                                    newDefaultCR = 'DLI-' + ratVal + ' SCA LT';
                                } else if(oppQBJobTypeUp.Project_Type__c == 'CD') {
                                    newDefaultCR = 'DLI-' + ratVal + ' SCA CD';
                                } else if(oppQBJobTypeUp.Project_Type__c == 'MTT' || oppQBJobTypeUp.Project_Type__c == 'Hub' || oppQBJobTypeUp.Project_Type__c == 'Overseas MTT') {
                                    newDefaultCR = 'DLI-' + ratVal + ' SCA MTT';
                                }
                                if(String.isNotBlank(newDefaultCR) && newProject.Default_Cost_Rate_Rate_Type__c != 'SubK-LT') {
                                    oppQBJobTypeUp.Default_Cost_Rate_Rate_Type__c = newDefaultCR;
                                    newProject.Default_Cost_Rate_Rate_Type__c = newDefaultCR;
                                    opp[0].Default_Cost_Rate_Rate_Type__c = newDefaultCR;
                                }
                                
                            }*/
                            // To make the below fields not required in Opportunity Layout and to make it Required during Project conversion
                            if(oppQBJobTypeUp.Supervisor__c != newProject.Project_Manager__c) {
                                oppQBJobTypeUp.Supervisor__c = newProject.Project_Manager__c;
                            }
                            if(oppQBJobTypeUp.Location__c != newProject.Training_Location__c) {
                                oppQBJobTypeUp.Location__c = newProject.Training_Location__c;
                            }
                            
                            if(oppQBJobTypeUp.Hours__c != newProject.Total_Program_Hours__c) {
                                oppQBJobTypeUp.Hours__c = newProject.Total_Program_Hours__c;
                            }
                            // Work Item : W-004721 - PVT Student Child Account Creation
                            if(oppRec.Account.Name == 'PVT' && childPVTAccId != NULL) {
                                oppQBJobTypeUp.AccountId = childPVTAccId;
                                newProject.AcctSeed__Account__c = childPVTAccId;
                            }
                            update oppQBJobTypeUp;
                        }                        
                                                
                        isFromConvertToProject = True;
                        // Moved after Opportunity update is for Default Cost Rate Population
                        Insert newProject;
                        newProjectId = newProject.Id;
                        List<ProjectTaskInsertInnerClass> childProjectTaskInList = new List<ProjectTaskInsertInnerClass>();
                        Set<String> recordTypes = new Set<String>{'Translation', 'Transcription (per hr)', 'Translation (per hr)', 'Translation (per word)', 'Interpretation (per hr)','Interpretation (per FFP)', 'Translation (per FFP)', 'Language Training:Translation/Interpretation'};
                        
                        for(ProjectTaskInsertInnerClass ptl: projectTaskInnserClassList ) {
                        
                            ptl.projTask.AcctSeed__Project__c = newProjectId;
                            
                            // Work Item :W-002222 - Lookup Search Filter for CLIN assignment on Project Task
                            ptl.projTask.Contract__c = newProject.Contract__c;
                           
                            if(projTaskRTMap != null && ptl.projTask.Project_Task_Type__c != null) {
                                if( (ptl.projTask.Project_Task_Type__c == 'Language Training' || ptl.projTask.Project_Task_Type__c == 'Language Testing' || ptl.projTask.Project_Task_Type__c == 'Material budget' || ptl.projTask.Project_Task_Type__c == 'Curriculum Development' ) && projTaskRTMap.containsKey(ptl.projTask.Project_Task_Type__c)) {
                                    ptl.projTask.RecordTypeId = projTaskRTMap.get(ptl.projTask.Project_Task_Type__c).Id;
                                } else if( ( ptl.projTask.Project_Task_Type__c == 'Accommodations' || ptl.projTask.Project_Task_Type__c == 'Admin Fee' || ptl.projTask.Project_Task_Type__c == 'Air Fare' || ptl.projTask.Project_Task_Type__c == 'Change Fee' || ptl.projTask.Project_Task_Type__c == 'Gas' || ptl.projTask.Project_Task_Type__c == 'Misc' || ptl.projTask.Project_Task_Type__c == 'Location' || ptl.projTask.Project_Task_Type__c == 'Per Diem' || ptl.projTask.Project_Task_Type__c == 'Rental Car' || ptl.projTask.Project_Task_Type__c == 'Labor' || ptl.projTask.Project_Task_Type__c == 'ODC' || ptl.projTask.Project_Task_Type__c == 'Travel' || ptl.projTask.Project_Task_Type__c == 'Overtime') && projTaskRTMap.containsKey('Travel & ODCs')) {
                                    ptl.projTask.RecordTypeId = projTaskRTMap.get('Travel & ODCs').Id;
                                } else if( ( ptl.projTask.Project_Task_Type__c == 'ADMINISTRATIVE' || ptl.projTask.Project_Task_Type__c == 'FMLA' || ptl.projTask.Project_Task_Type__c == 'FMLA Compensatory' || ptl.projTask.Project_Task_Type__c == 'FMLA Non-Compensatory' || ptl.projTask.Project_Task_Type__c == 'Fringe' || ptl.projTask.Project_Task_Type__c == 'Non-Compensatory') && projTaskRTMap.containsKey('Cost') ) {
                                    ptl.projTask.RecordTypeId = projTaskRTMap.get('Cost').Id;
                                } else if( ( ptl.projTask.Project_Task_Type__c == 'ELC Language Training' || ptl.projTask.Project_Task_Type__c == 'Preparation time') && projTaskRTMap.containsKey('Language Training') ) {
                                    ptl.projTask.RecordTypeId = projTaskRTMap.get('Language Training').Id;
                                } else if( ( ptl.projTask.Project_Task_Type__c == 'RT' || ptl.projTask.Project_Task_Type__c == 'RT:Overtime' || ptl.projTask.Project_Task_Type__c == 'RT:Regular') && projTaskRTMap.containsKey('MTT') ) {
                                    ptl.projTask.RecordTypeId = projTaskRTMap.get('MTT').Id;
                                } else if( ptl.projTask.Project_Task_Type__c == 'In House Testing-LT' && projTaskRTMap.containsKey('Language Testing') ) {
                                    ptl.projTask.RecordTypeId = projTaskRTMap.get('Language Testing').Id;
                                } else if( ( ptl.projTask.Project_Task_Type__c == 'Linguist Support Services' || ptl.projTask.Project_Task_Type__c == 'Subject Matter Expert') && projTaskRTMap.containsKey('Linguist Support') ) {
                                    ptl.projTask.RecordTypeId = projTaskRTMap.get('Linguist Support').Id;
                                } else if( recordTypes.contains(ptl.projTask.Project_Task_Type__c) && projTaskRTMap.containsKey('Translation') ) {
                                    ptl.projTask.RecordTypeId = projTaskRTMap.get('Translation').Id;
                                }
                            }
                            projectTaskListToInsert.add(ptl.projTask);  
                            if(String.isNotBlank(ptl.productNameAsProjectTask)) {
                                childProjectTaskInList.add(ptl);
                            }  
                        }
                        
                        List<AcctSeed__Project_Task__c> toUpdatePT = new List<AcctSeed__Project_Task__c>();
                        if( projectTaskListToInsert != null && projectTaskListToInsert.size() > 0 ) {
                            system.debug('projectTaskListToInsert::::'+projectTaskListToInsert);
                            Insert projectTaskListToInsert;
                            for(AcctSeed__Project_Task__c pt: projectTaskListToInsert){
                                projectTaskNameWithProjectTaskId.put(pt.Name,pt.Id);    
                            }
                            if( childProjectTaskInList != null && childProjectTaskInList.size() > 0 ) {
                                for(ProjectTaskInsertInnerClass cpt: childProjectTaskInList) {
                                    cpt.projTask.Parent_Project_Task__c = (String.isNotBlank(cpt.productNameAsProjectTask) && projectTaskNameWithProjectTaskId != null && projectTaskNameWithProjectTaskId.size() > 0 && projectTaskNameWithProjectTaskId.containsKey(cpt.productNameAsProjectTask))? projectTaskNameWithProjectTaskId.get(cpt.productNameAsProjectTask):null;
                                    toUpdatePT.add(cpt.projTask);
                                }
                                if( toUpdatePT.size() > 0 ) {
                                    update toUpdatePT;
                                }
                            }
                            
                            for(ScheduleUpdateInnerClass sch : scheduleList) {
                                sch.schRec.Project__c = newProjectId;
                                sch.schRec.Project_Task__c = (projectTaskNameWithProjectTaskId != null && projectTaskNameWithProjectTaskId.size() > 0 && projectTaskNameWithProjectTaskId.containsKey(sch.productNameAsProjectTask))? projectTaskNameWithProjectTaskId.get(sch.productNameAsProjectTask):null;
                                
                                scheduleListToUpdate.add(sch.schRec);
                                if( sch.schRec.Instructor__c != null )
                                    schIdWithInstructorIdMap.put(sch.schRec.Id,sch.schRec.Instructor__c); // To update the event with the instructor based on the sch Instuctor
                            }
                            if( scheduleListToUpdate != null && scheduleListToUpdate.size() > 0 ) {
                                //Update scheduleListToUpdate;
                                scheduleListToUpdate = ScheduleService.updateSchedule(scheduleListToUpdate);
                                
                            }
                            
                            for(InstructorAssignInnerClass iA : instructorCAList) {
                                iA.instructorCA.Project_Task__c = (projectTaskNameWithProjectTaskId != null && projectTaskNameWithProjectTaskId.size() > 0 && projectTaskNameWithProjectTaskId.containsKey(iA.productNameAsProjectTask))? projectTaskNameWithProjectTaskId.get(iA.productNameAsProjectTask):null;
                                iA.instructorCA.Project__c = newProjectId;
                                if(iA.instructorCA.Start_Date__c == null && newProject.Start_Date__c != null) {
                                    iA.instructorCA.Start_Date__c = newProject.Start_Date__c;
                                }
                                
                                if(iA.instructorCA.End_Date__c == null && newProject.End_Date__c != null) {
                                    iA.instructorCA.End_Date__c = newProject.End_Date__c;
                                }
                                if(iA.instructorCA.Status__c == 'Awarded') { // To update the ins Status to Planned if it is Awarded
                                    iA.instructorCA.Status__c = 'Planned';
                                }
                                //instructorListToUpdate.add(iA.instructorCA);     
                                contactAssignmentListToUpdate.add(iA.instructorCA);
                            }
                            
                            // W-002038 - Assign Student Assignment Position
                            for(StudentAssignInnerClass sA : studentCAList) {
                                sA.studentCA.Assignment_Position__c = (stdCAPositionStaticMap != null && stdCAPositionStaticMap.size() > 0 && stdCAPositionStaticMap.containsKey(sA.position))? stdCAPositionStaticMap.get(sA.position):null;
                                sA.studentCA.Project__c = newProjectId;
                                
                                contactAssignmentListToUpdateStudent.add(sA.studentCA);
                            }                                               
                            
                            if(!Test.isRunningTest() && scheduleIdSet != null && scheduleIdSet.size() > 0 ) {
                                                    
                                // Calling events records updation batch to avoid CPU limit exceeded exception
                                // Added by Sukanya on June 8 2017
                                EventUpdation_FromCTP eventBatch = new EventUpdation_FromCTP(scheduleIdSet,eventIdSet,eventList,schIdWithInstructorIdMap,newProjectId);
                                database.executeBatch(eventBatch,1);
                            }
                            List<Transaction__c> fundingList = new List<Transaction__c>();
                            fundingList = FundingService.getTransactionsByOpportunityId(new Set<Id>{oppId}); 
                            for(Transaction__c fund : fundingList){
                                paymentListToUpdate.add(new Transaction__c(Id = fund.Id,Project__c = newProjectId));                        
                            }
                            
                            //Set<Id> paymentIdSet = new Set<Id>();
                            //Commented on July 11 for Billing update.--uncommanded on August 17 2016 for full SB moving purphase
                            for(PaymentLineInnerClass pLL : paymentLineList) {
                                pLL.Payment.Project_Task__c = (projectTaskNameWithProjectTaskId != null && projectTaskNameWithProjectTaskId.size() > 0 && projectTaskNameWithProjectTaskId.containsKey(PLL.productNameAsProjectTask))? projectTaskNameWithProjectTaskId.get(PLL.productNameAsProjectTask):null;                              
                                paymentItemListToUpdate.add(pLL.Payment);     
                            }
                            
                            if ( paymentListToUpdate != null && paymentListToUpdate.size() > 0 ) {
                                List<Transaction__c> updatedTransactions = FundingService.updateTransactions(paymentListToUpdate);
                                //Update paymentListToUpdate;
                            }
                            
                            if ( paymentItemListToUpdate != null && paymentItemListToUpdate.size() > 0 ) {
                                List<Payment_Item__c> updatedPaymentItems = FundingItemService.updatePaymentItems(paymentItemListToUpdate); 
                                //Update paymentItemListToUpdate;
                            } 
                            
                            for (MatReqInnerClass mrc : matReqs) {
                                mrc.mrq.Project_Task__c = (projectTaskNameWithProjectTaskId != null && projectTaskNameWithProjectTaskId.size() > 0 && projectTaskNameWithProjectTaskId.containsKey(mrc.productNameAsProjectTask))? projectTaskNameWithProjectTaskId.get(mrc.productNameAsProjectTask):null;
                                mrc.mrq.Project__c = newProjectId;
                                
                                //if(opp[0].RecordType.DeveloperName == 'ODNI_CLP_Opportunities'){ //W-002033 - Have the due date automatically filled in for DODA LMS enrollments as the start date of the project/class
                                    // W-002814 - LMS request "Due Date" filled in as the "Start Date" of the project
                                    mrc.mrq.Due_Date__c = newProject.Start_Date__c;
                                //}
                                matReqsUpd.add(mrc.mrq);
                            }
                            if ( matReqsUpd != null && matReqsUpd.size() > 0 ) {
                                //update matReqsUpd;
                                upsert matReqsUpd;
                            }
                            
                            if(programTypesToCreateInitialLTs.contains(newProject.Program_type__c) && !programTypesToCreateInitialLTs.contains(opp[0].Program_type__c)){
                                
                                lTList.addAll(lTList_Temp);
                            }else if(!programTypesToCreateInitialLTs.contains(newProject.Program_type__c) && lTList_Temp.size() > 0){
                            
                                lTList = lTList_actual;
                            }
                             
                            for(LTInnerClass gi : lTList) {                   
                                gi.obj.Project_Task__c = (projectTaskNameWithProjectTaskId != null && projectTaskNameWithProjectTaskId.size() > 0 && projectTaskNameWithProjectTaskId.containsKey(gi.ptName))? projectTaskNameWithProjectTaskId.get(gi.ptName):null;
                                gi.obj.Project__c = newProject.Id;
                                gi.obj.Date_Time_Scheduled__c = DateTime.newInstance(newProject.Start_Date__c.year(), newProject.Start_Date__c.month(), newProject.Start_Date__c.day());
                                lTListToUpd.add(gi.obj);
                            }
                            
                            // User creation batch calling 
                            
                            UtilDomain.batchParameters batchParam = new UtilDomain.batchParameters();
                            batchParam.oppId  = oppId;
                            batchParam.contServItemPtName = contServItemPtName;
                            batchParam.projectTaskNameWithProjectTaskId = projectTaskNameWithProjectTaskId;
                            batchParam.startdtSet = startdtSet;
                            batchParam.enddtSet = enddtSet;
                            batchParam.stdateandEnddtMap = stdateandEnddtMap;
                            batchParam.tlDateSet = tlDateSet;
                            batchParam.monthStartdtSet = monthStartdtSet;
                            batchParam.monthEnddtSet = monthEnddtSet;
                            batchParam.contIdWithStAndEndDateMap = contIdWithStAndEndDateMap;
                            batchParam.contIds = contIds;
                            batchParam.payRollValuesMap = payRollValuesMap;
                            batchParam.newProjectId = newProjectId;
                            batchParam.existingTLIds = new Set<Id>();
                                                        
                            /*timeCard_Creation_FromCTP  timeCTP = new timeCard_Creation_FromCTP(batchParam);
                            database.executeBatch(timeCTP,1);*/
                            if(!Test.isRunningTest() && tlDateSet != null && tlDateSet.size() > 0){
                                UserCreation_FrmContact usrContactBatch = new UserCreation_FrmContact(batchParam);
                                database.executeBatch(usrContactBatch);
                            }
                            for (AcctSeed__Billing__c b: billingList) {
                                
                                b.Project__c = newProjectId;
                                if(b.AcctSeed__Customer__c != newProject.AcctSeed__Account__c) {
                                    b.AcctSeed__Customer__c = newProject.AcctSeed__Account__c;
                                }
                                for (AcctSeed__Billing_Line__c bl : b.AcctSeed__Project_Billing_Lines__r) {
                                    bl.AcctSeed__Project__c = newProjectId;
                                    bl.AcctSeed__Project_Task__c = (projectTaskNameWithProjectTaskId != null && projectTaskNameWithProjectTaskId.size() > 0 && projectTaskNameWithProjectTaskId.containsKey(bl.AcctSeed__Product__r.Name))? projectTaskNameWithProjectTaskId.get(bl.AcctSeed__Product__r.Name):null;
                                    billingLineList.add(bl); 
                                }
                                
                            }
                                                        
                            if (billingList.size() > 0 && billingLineList.size() > 0) {
                                
                                update billingList;
                                
                                update billingLineList;
                                
                                //Post the billing after the project & project task poluation in billing & line level for Create Prepayment Invoice action
                                //Added by NS on May 27 2021
                                AcctSeed.PostResult[] postResults = AcctSeed.BillingPostService.postBillings(billingList);
                                for (AcctSeed.PostResult theResult : postResults) {
                                    if (theResult.isSuccess) {
                                        System.debug('Successfully posted billing: ' + theResult.id);
                                    } 
                                    else {
                                        System.debug('Error posting billing ' + theResult.id);
                                        for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
                                            System.debug('Error status code ' + errorResult.statusCode);
                                            System.debug('Error message ' + errorResult.message);                                            
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Moved this code from Top to bottom to update atleast the Project Id if thr is no Project Task 
                        list<Contact_Assignments__c> contactAssignments = ContactAssignmentService.getContactassignmentByprojectId(' WHERE RecordTypeId != \''+instructorRecTypeId+'\' AND Opportunity_Name__c ','',new Set<Id>{oppId},'');
                        
                        //updated by siva prasanth on 6/2/19
                        //If there is no CR for that contact and Rate Type combination, automatically create CR based on LCR Master custom setting and Assign CR to CA for DODA
                          Set<String> crRateTypeSet = new Set<String>{'LT with Prep','LT without Prep','DODA PS','DLI-W LT','Non-SCA CD','DLI-16 SCA CD','DLI-16 SCA MTT','DLI-16 SCA LT','Non-SCA LT-S','Non-SCA CD (1099)','DLI-22 SCA CD','DLI-22 SCA LT','DLI-22 SCA MTT','Non-SCA MTT (1099)','Non-SCA Testing'}; // Non-SCA LT
                          Set<String> crStatus = new Set<String>{'Approved','Draft','Submitted for Approval'};

                           if(opp[0].RecordType.DeveloperName != null && opp[0].RecordType.DeveloperName != 'Translation_Opportunities' 
                                && opp[0].RecordType.DeveloperName != 'Interpretation_Opportunities' && opp[0].Default_Cost_Rate_Rate_Type__c != null && (crRateTypeSet.contains(opp[0].Default_Cost_Rate_Rate_Type__c))) {   
                                    
                            String  defaultCR = opp[0].Default_Cost_Rate_Rate_Type__c;
                            map<Id,AcctSeed__Cost_Rates__c> costRateMap = new  map<Id,AcctSeed__Cost_Rates__c>();
                            set<Id> conIds = new set<Id>(); 
                            
                            for(Contact_Assignments__c cAs : contactAssignmentListToUpdate) {
                                if(cAs.Project_Task__c != null  && cAs.Candidate_Name__c != null && (cAs.Status__c == 'Active' || cAs.Status__c == 'Planned') && cAs.Drafted_Labor_Cost_Rate__c == null && cAs.Rate_Card_Rate__c == null){
                                    conIds.add(cAs.Candidate_Name__c);
                                }
                            }
                            
                            for(AcctSeed__Cost_Rates__c cR : [Select Id ,Status__c,Contact__c FROM AcctSeed__Cost_Rates__c WHERE  Contact__c IN :conIds  AND Rate_Type__c =: defaultCR AND Status__c IN :crStatus Order by CreatedDate Desc]){
                                if(!costRateMap.containskey(cR.Contact__c)){
                                    costRateMap.put(cR.Contact__c,cR);
                                }
                            }
                            Map<Id,AcctSeed__Cost_Rates__c> newCRInsertedMap = new Map<Id,AcctSeed__Cost_Rates__c>();
                            String profileName = null;
                            
                            if(usrRec.size() > 0){
                                profileName = usrRec[0].Profile.Name; //profileRec[0].Name;
                            }
                           // CR creation only for DODA
                           if(opp[0].RecordType.DeveloperName == 'ODNI_CLP_Opportunities' || opp[0].RecordType.DeveloperName == 'DLI_W_TO_Opportunities'){
                               for(Id cId : conIds) {
                                   if(!costRateMap.containskey(cId)) {
                                       AcctSeed__Cost_Rates__c crToInsertLT = new AcctSeed__Cost_Rates__c();
                                       crToInsertLT.contact__c = cId;
                                       crToInsertLT.Rate_Type__c = defaultCR;
                                       
                                       if(conRelCRHourlyCostMap.containsKey(cId)){
                                           if(conRelCRHourlyCostMap.get(cId) != null){
                                               crToInsertLT.AcctSeed__Hourly_Cost__c = conRelCRHourlyCostMap.get(cId); 
                                           }
                                       }
                                       
                                       if(profileName == 'HR'){
                                           crToInsertLT.Status__c = 'Approved';
                                       }
                                       newCRInsertedMap.put(cId, crToInsertLT);
                                   }
                               }
                               if(newCRInsertedMap.size() > 0 ) {
                                   // For new LCR creation we need to initiate the approval process
                                   ContactAssignmentLightningCtrl.isFromCA = true;
                                   
                                   insert newCRInsertedMap.Values();
                                   
                                   for(AcctSeed__Cost_Rates__c crs : [Select Id ,Status__c,Contact__c FROM AcctSeed__Cost_Rates__c WHERE  Contact__c IN :newCRInsertedMap.keySet()  AND Rate_Type__c =: defaultCR Order by CreatedDate Desc]){
                                       if(!costRateMap.containskey(crs.Contact__c)){
                                           costRateMap.put(crs.Contact__c,crs);
                                       }
                                   }
                               }
                           }
                           for(Contact_Assignments__c cAs : contactAssignmentListToUpdate) {
                                
                               if(cAs.Project_Task__c != null  && cAs.Candidate_Name__c != null && (cAs.Status__c == 'Active' || cAs.Status__c == 'Planned') && cAs.Drafted_Labor_Cost_Rate__c == null && cAs.Rate_Card_Rate__c == null){
                                   if(costRateMap.containsKey(cAs.Candidate_Name__c)){
                                       AcctSeed__Cost_Rates__c costrateRelatedCon =  costRateMap.get(cAs.Candidate_Name__c);
                                       if(costrateRelatedCon.Status__c == 'Submitted for Approval' || costrateRelatedCon.Status__c == 'Draft' && cAs.Drafted_Labor_Cost_Rate__c == null ){
                                            cAs.Drafted_Labor_Cost_Rate__c = costrateRelatedCon.Id;
                                        }else if(cAs.Rate_Card_Rate__c == null &&  costrateRelatedCon.Status__c == 'Approved'){
                                            cAs.Rate_Card_Rate__c = costrateRelatedCon.Id;
                                        }
                                    }
                                }
                            }
                          }
                        //End of CR creation for Opportunity RTs
                        
                        //updated by siva prasanth on 10/5/19
                        Set<Id> contactIds = new Set<Id>();  
                        map<String,AcctSeed__Cost_Rates__c> costRateMapForStaff = new  map<String,AcctSeed__Cost_Rates__c>();
                        
                        if(opp[0].RecordType.DeveloperName == 'Testing_Opportunities') {
                            for(Contact_Assignments__c ca : contactAssignments) {
                                //If there is no CR for that contact for Staff/Supervisor and assign CR to Contact if anyone CostRate have ( FT Salary & Benefits,FT Hourly & Benefit ,PT Hourly (OH & G&A) for Testing Opportunity RT                        
                                if(ca.RecordTypeId == staffRecTypeId){
                                    contactIds.add(ca.Candidate_Name__c);
                                }
                            }
                            for(AcctSeed__Cost_Rates__c cRRecord : [Select Id ,Status__c,Contact__c,Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE  Contact__c IN :contactIds AND Rate_Type__c IN ('FT Salary & Benefits','FT Hourly & Benefits','PT Hourly (OH & G&A)') AND Status__c IN ('Submitted for Approval','Approved','Draft') Order by Effective_Date__c Desc]){
                                if(!costRateMapForStaff.containskey(cRRecord.Contact__c+'-'+cRRecord.Rate_Type__c)) {
                                    costRateMapForStaff.put(cRRecord.Contact__c+'-'+cRRecord.Rate_Type__c,cRRecord);
                                }
                            }
                        }
                        
                        for(Contact_Assignments__c cA : contactAssignments) {
                            String staffpTName = '';
                            
                            // Added to avoid start date required validation error on conversion except instructor recordTypes
                            if(cA.Start_Date__c == null && newProject.Start_Date__c != null)
                                cA.Start_Date__c = newProject.Start_Date__c;
                            
                            if(cA.End_Date__c == null && newProject.End_Date__c != null)
                                cA.End_Date__c = newProject.End_Date__c;
                            
                            cA.Project__c = newProjectId;
                            
                            if(cA.RecordTypeId == staffRecTypeId && cA.Opportunity_Product_Id__c != null) { 
                                
                                staffpTName = ((cA.Opportunity_Product_Id__c != null && oPLIIdKeyProTaskNameValueMap.containskey(cA.Opportunity_Product_Id__c)) ? oPLIIdKeyProTaskNameValueMap.get(cA.Opportunity_Product_Id__c) : '');
                                cA.Project_Task__c = (projectTaskNameWithProjectTaskId != null && projectTaskNameWithProjectTaskId.size() > 0 && projectTaskNameWithProjectTaskId.containsKey(staffpTName)) ? projectTaskNameWithProjectTaskId.get(staffpTName):null;
                                
                                if(opp[0].RecordType.DeveloperName == 'Testing_Opportunities'){
                                
                                    if(cA.Rate_Card_Rate__c == null && cA.Drafted_Labor_Cost_Rate__c == null){
                                        AcctSeed__Cost_Rates__c crIdWithStatus = new AcctSeed__Cost_Rates__c();
                                        
                                        if(costRateMapForStaff.containskey(cA.Candidate_Name__c+'-'+'FT Salary & Benefits')){
                                            
                                            crIdWithStatus = costRateMapForStaff.get(cA.Candidate_Name__c+'-'+'FT Salary & Benefits');
                                            if(crIdWithStatus.Status__c == 'Approved'){
                                                cA.Rate_Card_Rate__c = crIdWithStatus.Id;
                                            }else if(crIdWithStatus.Status__c == 'Submitted for Approval' || crIdWithStatus.Status__c == 'Draft'){
                                                cA.Drafted_Labor_Cost_Rate__c = crIdWithStatus.Id;
                                            }
                                        }else if(costRateMapForStaff.containskey(cA.Candidate_Name__c+'-'+'FT Hourly & Benefits')){
                                            
                                            crIdWithStatus = costRateMapForStaff.get(cA.Candidate_Name__c+'-'+'FT Hourly & Benefits');
                                            if(crIdWithStatus.Status__c == 'Approved'){
                                                cA.Rate_Card_Rate__c = crIdWithStatus.Id;
                                            }else if(crIdWithStatus.Status__c == 'Submitted for Approval' || crIdWithStatus.Status__c == 'Draft'){
                                                cA.Drafted_Labor_Cost_Rate__c = crIdWithStatus.Id;
                                            }
                                        }else if(costRateMapForStaff.containskey(cA.Candidate_Name__c+'-'+'PT Hourly (OH & G&A)')){
                                            
                                            crIdWithStatus = costRateMapForStaff.get(cA.Candidate_Name__c+'-'+'PT Hourly (OH & G&A)');
                                            if(crIdWithStatus.Status__c == 'Approved'){
                                                cA.Rate_Card_Rate__c = crIdWithStatus.Id;
                                            }else if(crIdWithStatus.Status__c == 'Submitted for Approval' || crIdWithStatus.Status__c == 'Draft'){
                                                cA.Drafted_Labor_Cost_Rate__c = crIdWithStatus.Id;
                                            }
                                        }
                                    }
                                }
                            }
                            contactAssignmentListToUpdate.add(cA);
                        }
                        if( contactAssignmentListToUpdate != null && contactAssignmentListToUpdate.size() > 0 ) {
                            contactAssignmentListToUpdate = ContactAssignmentService.updateContactAssignments(contactAssignmentListToUpdate);
                        }
                        
                        if(contactAssignmentListToUpdateStudent.size() > 0){
                            contactAssignmentListToUpdate = ContactAssignmentService.updateContactAssignments(contactAssignmentListToUpdateStudent);
                        }
                        
                        // W-007767 - Initial Language Testing Records Creation is not Updating Student CA Initial Score Record Checkbox to True
                        // To fix "Initial Score Record" field updation issue, contact assignments should be updated before language testing creation / updation
                        List<Language_Testing__c> langtestList = new List<Language_Testing__c>();
                        if( lTListToUpd != null && lTListToUpd.size() > 0 ) {
                            //langtestList = LanguageTestingService.upsertLanguageTesting(lTListToUpd);
                            upsert lTListToUpd;
                        }
                            
                        // To update the Project Id for Get Feedback
                        for( Get_Feedback__c fb : feedBackList ) {
                            fb.Project__c = newProjectId;
                        }
                        
                        //List<Get_Feedback__c> feedBacklist = new List<Get_Feedback__c>();
                        if( feedBackList != null && feedBackList.size() > 0 ) {
                            feedBacklist = GetFeedbackService.updateGetfeedback(feedBackList);
                        }
                        
                        // Qry new project related Contact Assingment with Staff record type
                        // To send email to Supervisor/LTS regarding new project creation
                        
                        List<Messaging.SingleEmailMessage> emailTosupervisor = new List<Messaging.SingleEmailMessage>();
                        Set<Id> supervisorIds = new Set<Id>();
                        Map<Id,String> contactIdNameMap = new Map<Id,String>();
                        
                        // Work Item : W-004142 - Turn off Notifications for Project Conversion for Ended Opportunties
                        //Added year condition, because some of the old opportunity does not have ended stage name
                        Date lastYear = Date.newInstance((system.today().year() - 1),01,01);
                        if(String.isNotBlank(oppRec.StageName) && oppRec.StageName != 'Ended' && ((opp[0].RecordType.DeveloperName != 'Testing_Opportunities' && oppRec.Start_Date__c != NULL && oppRec.Start_Date__c >= lastYear) || opp[0].RecordType.DeveloperName == 'Testing_Opportunities')){
                        
                            try {
                                for(Contact_Assignments__c conAss : [SELECT Id,Name,Project__c,Candidate_Name__c,Candidate_Name__r.Email FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Project__c = :newProjectId AND Status__c IN ('Active','Planned')]){  
                                    
                                    if(conAss.Candidate_Name__c != null)
                                        supervisorIds.add(conAss.Candidate_Name__c);
                                    
                                    if(!contactIdNameMap.containsKey(conAss.Candidate_Name__c))
                                        contactIdNameMap.put(conAss.Candidate_Name__c,conAss.Candidate_Name__r.Email);
                                }
                                
                                EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CTP_supervisor_LTS_email_notification'];
                                
                                if(supervisorIds != null && supervisorIds.size() > 0 && template != null){
                                    
                                    for(Id supId :supervisorIds){
                                        
                                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                        
                                        mail.setTargetObjectId(supId);
                                        mail.setWhatId(newProjectId);
                                        mail.setTemplateID(template.Id);
                                        
                                        // Set CC address for Simona Westlund project manager
                                        if(contactIdNameMap.containsKey(supId) && contactIdNameMap.get(supId) == 'swestlund@dlsdc.com')
                                            mail.setCcAddresses(new String[] {'sgentile@dlsdc.com'});
                                        
                                        mail.setSaveAsActivity(true);
                                        emailTosupervisor.add(mail);                                        
                                    }
                                }
                                                                
                                if(emailTosupervisor != null && emailTosupervisor.size() > 0) {
                                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emailTosupervisor);
                                }
                            }catch(Exception e) {
                                
                                List<Messaging.SingleEmailMessage> ErrorMailMsg = new List<Messaging.SingleEmailMessage>();
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                                mail.setToAddresses(new String[] {system.Label.TimeCardDayEmail});
                                mail.setSubject('Error on Supervisor/LTS email on opp to project conversion notification'); 
                                mail.setPlainTextBody(e.getMessage());
                                ErrorMailMsg.add(mail);
                                try{
                                    if( ErrorMailMsg != null && ErrorMailMsg.size() > 0 ){
                                        Messaging.sendEmail(ErrorMailMsg); 
                                    }
                                } catch (Exception ex){
                                    system.debug('Ex::::'+ex);
                                }    
                            }
                        }
                        
                        // Qry Opp related Planned days off & update the Project value on that
                        // Added by Sukanya on Dec 21 2017
                        List<Planned_Days_Off__c> updateDaysOffList = new List<Planned_Days_Off__c>();
                        if(oppRec.RecordType.DeveloperName == 'DLI_W_TO_Opportunities' && (oppRec.Project_Type__c == 'AFPAK' || oppRec.Project_Type__c == 'Resident LT')) {
                            for(Planned_Days_Off__c daysOff : [SELECT Id,Name,Date__c,Opportunity__c,Project__c 
                                                               FROM Planned_Days_Off__c 
                                                               WHERE Opportunity__c = :oppRec.Id AND Project__c = NULL AND RecordType.DeveloperName = 'Project_Planned_Days_Off']) {
                                                                   daysOff.Project__c = newProjectId;
                                                                   updateDaysOffList.add(daysOff);
                                                               }     
                            
                            if(updateDaysOffList.size() > 0) {
                                update updateDaysOffList;
                            }
                        }  
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errormessage));
                    }                           
                }
                
                System.debug(':::getQueries::::'+Limits.getQueries());
                System.debug(':::getCpuTime::::'+Limits.getCpuTime());
                System.debug(':::getDMLStatements::::'+Limits.getDMLStatements());
                
            } catch (DMLException dex) {
                
                System.debug('DML Error::::'+dex);
                Database.rollback( sp );
                //system.debug(dex.linenumber());
                errorMsg = dex.getMessage();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dex.getMessage()));
                return null;
            } catch (Exception ex) {
                
                System.debug('Error::::'+ex);
                Database.rollback( sp );
                errorMsg = ex.getMessage();  
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                return null; 
            }             
        }  
        if( errorMsg != null && errorMsg != '' ) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
            ApexPages.addMessage(myMsg);
        }
        if(newProjectId != null) {
           
            PageReference pgRef = new PageReference('/'+newProjectId);
            return pgRef;
        }
        System.debug('errorMsg '+errorMsg );
        
        return null; 
    }
    public PageReference toOpportunity() {
        PageReference pgRef = new PageReference('/'+oppId);
        return pgRef; 
    }
    
    // Created by Melbin 2016-02-29 
    //    Opens a window to select an instructor.
    //
    @RemoteAction
    public static List<InstructorConflicts> getInstructorConflicts(Id instructorId, Id scheduleId) {
        List<InstructorConflicts> conflicts = new List<InstructorConflicts>();
       // List<Events__c> eventList = [SELECT Id, Name, Date__c, Start_Time__c, End_Time__c FROM Events__c WHERE Schedule__c = :scheduleId];
        List<Events__c> eventList = EventService.getEventByparentIds(NULL,' WHERE Schedule__c = \''+scheduleId+'\'','','');
        if(eventList.size() == 0)
            return conflicts;
        Set<Date> possibleDates = new Set<Date>();
        for(Events__c ev : eventList) {
            possibleDates.add(ev.Date__c);
        }
        //List<Planned_Days_Off__c> plannedOffs = [SELECT Date__c FROM Planned_Days_Off__c WHERE Date__c IN :possibleDates AND Contact__c = :instructorId];
        // User Service method to get Planned dys offf values
        List<Planned_Days_Off__c> plannedOffs = PlannedDaysOffService.getPlanneddaysByconDates(new Set<Id>{instructorId},possibleDates);
        for(Planned_Days_Off__c day : plannedOffs) {
            conflicts.add(new InstructorConflicts('Planned Day Off', day.Date__c));
        }
        
        //List<Holiday> holidayList = [SELECT ActivityDate FROM Holiday WHERE ActivityDate IN :possibleDates];
        
        List<Holiday> holidayList = HolidayService.getHolidayBydate(possibleDates);
        for(Holiday h : holidayList) {
            conflicts.add(new InstructorConflicts('Holiday', h.ActivityDate));
        }
        
        //List<Events__c> existingEventsList = [SELECT Id, Start_Time__c, End_Time__c, Date__c FROM Events__c WHERE Instructor__c = :instructorId AND Date__c IN :possibleDates];
        List<Events__c> existingEventsList = EventService.getEventsByDateANDInstructorId(' WHERE Instructor__c = \''+instructorId+'\'',possibleDates,NULL,'','');
        for(Events__c currentEvent : eventList) {
            Integer startTime = EventManagementController.convertToMinutes(currentEvent.Start_Time__c), endTime = EventManagementController.convertToMinutes(currentEvent.End_Time__c);
            for(Events__c existingEvent : existingEventsList) {
                if(currentEvent.Date__c == existingEvent.Date__c) {
                    Integer startTime1 = EventManagementController.convertToMinutes(existingEvent.Start_Time__c), endTime1 = EventManagementController.convertToMinutes(existingEvent.End_Time__c);
                    if((startTime1 >= startTime && startTime1 <= endTime) || (endTime1 >= startTime && endTime1 <= endTime)) {
                        conflicts.add(new InstructorConflicts('Event', existingEvent.Date__c));
                    }
                }
            }
        }
        return conflicts;
    }
    
    public class InstructorConflicts {
        String type;
        Date conflictedDate;
        public InstructorConflicts(String type, Date conflictedDate) {
            this.type = type;
            this.conflictedDate = conflictedDate;
        }
    }
    
    public string checkOrderContract(AcctSeed__Project__c pro) {
        String errorMsg;
        
        String contractType;
        String order;
        
        if(pro == null) {
            contractType = opp[0].QB_Contract_Type__c;
            order = opp[0].Order__c;
        } else {
            contractType = pro.QB_Contract_Type__c;
            order = pro.Order__c;
        }
        
        if(contractType == 'FED:GSA' || contractType == 'STATE:GSA') {   
                        
            if(order == null || order == '') {
                errorMsg = 'For FED:GSA or STATE:GSA QB Contract type, Order #';
            }
            if(opp[0].ContractId == null && pro == null) {
                if(errorMsg != null && errorMsg != '')
                    errorMsg += ' and Contract';
                else 
                    errorMsg = 'For FED:GSA or STATE:GSA QB Contract type, Contract';
            }
            
            if(errorMsg != null && errorMsg != '' ) 
                errorMsg += ' is Required';
        }
        return errorMsg;
    }       
}