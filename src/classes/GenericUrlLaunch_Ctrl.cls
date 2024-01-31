/**
 * @description       : 
 * @author            : Dhinesh Kumar
 * @group             : 
 * @last modified on  : 10/09/2023
 * @last modified by  : Dhinesh Kumar
**/
public class GenericUrlLaunch_Ctrl {
    
    public static Boolean Perform_Covid_Form_Actions = false; //used to send additional param to Zappier Box Folder creation callout - to update ca & frup rec creation - W-007001
    public static Boolean skipFRUPFolderCheckOrAllowBoxFolderCreation = Boolean.valueOf(Label.skipFRUPFolderCheckOrAllowBoxFolderCreation);
    public static String boxFolderCreationUrl = isSandbox() ? 'b2341j7' : 'o7n4vmg';
    public static Map<String, Contact> folderNameWithContactMap = new Map<String, Contact>();

    public static void formBoxFolderContMap() {
        for( Contact c : [SELECT Id,Name,Email FROM Contact WHERE Name LIKE '%Conga Sign%']){
            folderNameWithContactMap.put(c.Name, c);
        }
    } 
    
    @AuraEnabled 
    public static CongaButtonsController.generateWrapper getCongaUrlInfo(String objName , String objId) {
        Map<string,Id> congaTemplateMap = new Map<String,Id>();
        List<box__FRUP__c> frup = new List<box__FRUP__c>();
        
        String congaUrl;
        Boolean errorMsg = false;
        // Expiration Date is 60 days for Progress Report
        DateTime expDateTime =  System.now().addDays(60);
        DateTime expRemiderDT = System.now().addDays(58);
        String expDate = expDateTime.format('yyyy-MM-dd') + 'T' + expDateTime.format('HH:mm:ss.SSS')+'Z';
        String expReminderDTStr = expRemiderDT.format('yyyy-MM-dd') + 'T' + expRemiderDT.format('HH:mm:ss.SSS')+'Z';
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();

        try {
            if(objName == 'Assessment_Report__c'){
               frup = [SELECT Id,Name,box__Record_ID__c,box__Folder_ID__c FROM box__FRUP__c WHERE box__Record_ID__c = :objId];
               System.debug('::frup::'+frup);

                List<Assessment_Report__c> ar = [SELECT Id, Name, Project__c, Total_Hours_Used__c, Project_Task__r.Total_Hours_Used_For_Language_Training__c, Project_Manager__c, Instructor__c, 
                                                                          RecordTypeId, RecordType.DeveloperName, Project_Manager__r.Name, Instructor__r.Name, Report_Type__c, Student__c, Status__c, Student__r.Name, 
                                                                          Report_File_Name__c, Project__r.DLS_Ref__c, Project__r.AcctSeed__Account__r.Name, Language_Training_Status__c,Total_Hours_Absent__c 
                                                                          FROM Assessment_Report__c WHERE Id = :objId];
                
                for(APXTConga4__Conga_Template__c ct : [SELECT Id,Name,APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Template_Group__c = 'Assessment Report']) {
                    congaTemplateMap.put(ct.APXTConga4__Name__c,ct.Id);
                }
                formBoxFolderContMap();
                if(ar.size() > 0){
                    
                    wrap.assessmentReport = ar[0];
                    Boolean isNew = CongaHelper.checkIsNew( ar[0], true);
                    if(frup.size() > 0 || skipFRUPFolderCheckOrAllowBoxFolderCreation){
                        if(ar[0].RecordTypeId != null && (ar[0].RecordType.DeveloperName == 'Observation_Report' || ar[0].RecordType.DeveloperName == 'DLI_Observation_Report')){
                            wrap.errorMsg = 'This process is not available for Observation Report Record Type.';                 
                        }else if(ar[0].Status__c == 'Submitted to Student' || ar[0].Status__c == 'Completed'){
                            wrap.errorMsg = 'This Progress Report has already been submitted to the Student';                 
                        }else if(ar[0].Student__c == null || ar[0].Project_Manager__c == null || ar[0].Instructor__c == null){
                            String valMessage = 'Please populate ';
                            
                            if(ar[0].Student__c == null && ar[0].Project_Manager__c == null && ar[0].Instructor__c == null){
                                valMessage += 'following fields: Student, Instructor and Manager';
                            }else if(ar[0].Student__c == null && ar[0].Project_Manager__c == null ){
                                valMessage += 'following fields: Student and Manager';
                            }else if(ar[0].Student__c == null && ar[0].Instructor__c == null ){
                                valMessage += 'following fields: Student and Instructor';
                            }else if(ar[0].Project_Manager__c == null && ar[0].Instructor__c == null){
                                valMessage += 'following fields: Manager and Instructor';
                            }else if(ar[0].Student__c == null){
                                valMessage += 'Student';
                            }else if(ar[0].Instructor__c == null ){
                                valMessage += 'Instructor';
                            }else if(ar[0].Project_Manager__c == null){
                                valMessage += 'Manager';
                            }
                            wrap.errorMsg = valMessage + '.';
                        }else{
                            //Modified By Dhinesh - 5/12/2022 - W-007647 - Excluded Total Hrs Used validation for DLI W Monthly Progress report
                            if( ar[0].Project_Task__r.Total_Hours_Used_For_Language_Training__c != ar[0].Total_Hours_Used__c && !(ar[0].RecordType.DeveloperName == 'DLI_W_Progress_2022' && ar[0].Language_Training_Status__c == 'Monthly')){
                                wrap.errorMsg =  'The Total Hours Used on the Progress Report is <b> '+ (ar[0].Total_Hours_Used__c != null ? getDecimalStr(ar[0].Total_Hours_Used__c) : '0.00') +' </b> but the Project Total Hours Used is <b> '+ (ar[0].Project_Task__r.Total_Hours_Used_For_Language_Training__c != null ? getDecimalStr(ar[0].Project_Task__r.Total_Hours_Used_For_Language_Training__c) : '0.00') +' </b> now. Would you like to update the Progress Report field to reflect the new total?';                 
                            }
                            
                            if(ar[0].Report_Type__c == 'DLI' || ar[0].Report_Type__c == 'Language Training' || ar[0].Report_Type__c == 'APMO' || ar[0].Report_Type__c == 'DEA'){
                                errorMsg = false;
                            }else{
                                errorMsg = true;
                            }
                            
                            if(ar[0].Report_Type__c == 'DLI' && congaTemplateMap.containsKey('DLI-W Progress 2022 Report')) {
                                congaUrl = '&id=' + ar[0].Id +
                                    '&templateId=' + congaTemplateMap.get('DLI-W Progress 2022 Report') +
                                    '&queryId=[TS]'+ CongaTranslator.getCongaQuery('Test Score - Assessment Report') + '?pv0=' + ar[0].Id +
                                    ',[AP]' + CongaTranslator.getCongaQuery('Action Plan - Assessment Report') + '?pv0=' + ar[0].Id +
                                    ',[Pro]' + CongaTranslator.getCongaQuery('Material Disposition Project Query') + '?pv0=' + ar[0].Project__c +
                                    '&OFN=' + ar[0].Name  + '--' + ar[0].Report_File_Name__c;
                                    // Naming convention to move the file from the common folder to the AR record specific folder in Zapier
                                
                            } else if (ar[0].Report_Type__c == 'Language Training' && congaTemplateMap.containsKey('Language Training Report')) {
                                congaUrl = '&id=' + ar[0].Id +
                                    '&templateId=' + congaTemplateMap.get('Language Training Report') +
                                    '&OFN=' + ar[0].Name  + '--' + ar[0].Report_File_Name__c;
                                    // Naming convention to move the file from the common folder to the AR record specific folder in Zapier
                            } else if (ar[0].Report_Type__c == 'APMO' && congaTemplateMap.containsKey('APMO Progress Report')) {
                                congaUrl = '&id=' + ar[0].Id +
                                    '&templateId=' + congaTemplateMap.get('APMO Progress Report') +
                                    '&queryId=[TS]'+ CongaTranslator.getCongaQuery('Test Score - Assessment Report') + '?pv0=' + ar[0].Id +
                                    ',[AP]' + CongaTranslator.getCongaQuery('Action Plan - Assessment Report') + '?pv0=' + ar[0].Id +
                                    '&OFN=' + ar[0].Name  + '--' + ar[0].Report_File_Name__c;
                                    // Naming convention to move the file from the common folder to the AR record specific folder in Zapier
                            } else if (ar[0].Report_Type__c == 'DEA' && congaTemplateMap.containsKey('DEA Progress Report')) {
                                List<Contact_Assignments__c> caList = [SELECT Id, Student_Hours_Absent__c FROM Contact_Assignments__c WHERE Project__c = :ar[0].Project__c AND Candidate_Name__c = :ar[0].Student__c];
                                if( caList[0].Student_Hours_Absent__c != ar[0].Total_Hours_Absent__c){
                                    wrap.errorMsg =  'The Total Hours Absent on the Progress Report is <b> '+ (ar[0].Total_Hours_Absent__c != null ? getDecimalStr(ar[0].Total_Hours_Absent__c) : '0.00') +' </b> but the Contact Assignment Total Hours Absent is <b> '+ (caList[0].Student_Hours_Absent__c != null ? getDecimalStr(caList[0].Student_Hours_Absent__c) : '0.00') +' </b> now. Would you like to update the Progress Report field to reflect the new total?';                 
                                    wrap.contactAssignments = caList;
                                }
                                congaUrl = '&id=' + ar[0].Id +
                                    '&templateId=' + congaTemplateMap.get('DEA Progress Report') +
                                    '&queryId=[TS]'+ CongaTranslator.getCongaQuery('Test Score - Assessment Report') + '?pv0=' + ar[0].Id +
                                    ',[AP]' + CongaTranslator.getCongaQuery('Action Plan - Assessment Report') + '?pv0=' + ar[0].Id +
                                    ',[Pro]' + CongaTranslator.getCongaQuery('Material Disposition Project Query') + '?pv0=' + ar[0].Project__c +
                                    '&OFN=' + ar[0].Name  + '--' + ar[0].Report_File_Name__c;
                                    // Naming convention to move the file from the common folder to the AR record specific folder in Zapier
                            }
                            
                            // Added on OCtober 04, 2022 Since the Language Training Reports doesn't need the Student signature
                            if(ar[0].Report_Type__c == 'Language Training') { //&CSRequestReminder=2
                                congaUrl = congaUrl + '&CSVisible=1&CSRoutingType=SERIAL&CSExpiration='+expDate+'&CSRequestReminderFrequency=2&CSExpirationReminder='+expReminderDTStr+'&CSRecipient1='+ar[0].Instructor__c+'&CSRole1=SIGNER'+
                                    '&CSRecipient2='+ar[0].Project_Manager__c+'&CSRole2=SIGNER&CSRecipient3='+ar[0].Student__c+'&CSRole3=CC'+
                                    ((folderNameWithContactMap.size() > 0 && folderNameWithContactMap.containskey('Training Report - Conga Sign')) ? '&CSRecipient4='+folderNameWithContactMap.get('Training Report - Conga Sign').Id+'&CSRole4=CC' : '')+
                                    // To send files after signature to these folders for the DODA Projects W-007552
                                    ((ar[0].Project__r.AcctSeed__Account__r.Name == 'DODA' && folderNameWithContactMap.size() > 0 && folderNameWithContactMap.containskey('DODA Training Report - Conga Sign')) ? '&CSRecipient5='+folderNameWithContactMap.get('DODA Training Report - Conga Sign').Id + '&CSRole5=CC' : '') +
                                    '&CSEmailSubject=Please Sign the Following Training Report&CSEmailMessage=Please review the document and sign&DefaultPDF=1';
                                
                            } else if(ar[0].Report_Type__c == 'APMO') { //Added by Dhinesh - 05/12/2022 - W-007641 - TO remove Student from signing process
                            // commented &CSRequestReminder=2
                                congaUrl = congaUrl + '&CSVisible=1&CSRoutingType=SERIAL&CSExpiration='+expDate+'&CSRequestReminderFrequency=2&CSExpirationReminder='+expReminderDTStr+'&CSRecipient1='+ar[0].Instructor__c+'&CSRole1=SIGNER'+
                                    '&CSRecipient2='+ar[0].Project_Manager__c+'&CSRole2=SIGNER'+
                                    '&CSRecipient3='+ar[0].Student__c+'&CSRole3=CC'+ // Added by GRK W-007843 on July 14 2023
                                    ((folderNameWithContactMap.size() > 0 && folderNameWithContactMap.containskey('Training Report - Conga Sign')) ? '&CSRecipient4='+folderNameWithContactMap.get('Training Report - Conga Sign').Id+'&CSRole4=CC' : '')+                                    
                                    '&CSEmailSubject=Please Sign the Following Training Report&CSEmailMessage=Please review the document and sign&DefaultPDF=1';
                            } else {
                            // &CSRequestReminder=2
                                congaUrl = congaUrl + '&CSVisible=1&CSRoutingType=SERIAL&CSExpiration='+expDate+'&CSRequestReminderFrequency=2&CSExpirationReminder='+expReminderDTStr+'&CSRecipient1='+ar[0].Instructor__c+'&CSRole1=SIGNER'+
                                    '&CSRecipient2='+ar[0].Student__c+'&CSRole2=SIGNER&CSRecipient3='+ar[0].Project_Manager__c+'&CSRole3=SIGNER'+
                                    ((folderNameWithContactMap.size() > 0 && folderNameWithContactMap.containskey('Training Report - Conga Sign')) ? '&CSRecipient4='+folderNameWithContactMap.get('Training Report - Conga Sign').Id+'&CSRole4=CC' : '')+
                                    // To send files after signature to these folders for the DODA Projects W-007552
                                    ((ar[0].Project__r.AcctSeed__Account__r.Name == 'DODA' && folderNameWithContactMap.size() > 0 && folderNameWithContactMap.containskey('DODA Training Report - Conga Sign')) ? '&CSRecipient5='+folderNameWithContactMap.get('DODA Training Report - Conga Sign').Id + '&CSRole5=CC' : '') +
                                    // To send files after signature to these folders for the DLI Projects W-007845
                                    ((ar[0].Project__r.AcctSeed__Account__c != null && ar[0].Project__r.AcctSeed__Account__r.Name.contains('DLI') && folderNameWithContactMap.size() > 0 && folderNameWithContactMap.containskey('DLI Training Report - Conga Sign')) ? '&CSRecipient5='+folderNameWithContactMap.get('DLI Training Report - Conga Sign').Id + '&CSRole5=CC' : '') +
                                    '&CSEmailSubject=Please Sign the Following Training Report&CSEmailMessage=Please review the document and sign&DefaultPDF=1';
                            }
                        }
                        
                        if(errorMsg == true){
                            wrap.errorMsg =  'This process can only be done for DEA, APMO, DLI and Language Training report types';                 
                        }
                        
                        wrap.sessionIdServerURL = CongaButtonsController.getServerUrlSessionId();
                        wrap.congaURL = congaUrl;
                        if(!isNew){
                            wrap.errorMsg = 'If you would like to resend it, please click "Cancel", and delete the corresponding file from the Box Folder for this report before clicking "Proceed".';
                        } 
                    }else {
                        String folderName = ar[0].Name;
                        folderName = folderName.replace('/','_');
                        if(ar[0].Project__c != null){
                            folderName += (+' - '+ar[0].Project__r.DLS_Ref__c);
                        }
                        
                        calloutToCreateBoxRecs(objId , folderName,'Training Reports','Assessment_Report__c'); 
                        // Production refer Training Reports
                        // Sandbox refer to Assessment Reports
                        wrap.errorMsg = 'No Box Record'; 
                    }
            }
        }
        return wrap;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled 
    public static void updateAssesmentReports(String arId) {
        
        if(String.isNotBlank(arId)) {
            List<box__FRUP__c> frup = new List<box__FRUP__c>();
            frup = [SELECT Id,Name,box__Record_ID__c,box__Folder_ID__c FROM box__FRUP__c WHERE box__Record_ID__c = :arId];
            List<Assessment_Report__c> ar = [SELECT Id, Name, Box_Folder_Id__c 
                                                     FROM Assessment_Report__c WHERE Id = :arId];
            if(frup != null && frup.size() > 0 && ar != null && ar.size() > 0 && ar[0].Box_Folder_Id__c != frup[0].box__Folder_ID__c) {
                
                ar[0].Box_Folder_Id__c = frup[0].box__Folder_ID__c;
                update ar;
                System.debug('ar::::::'+ar);
            }
        }
    }
    // update the project/Opportunity with Box Ids
    @AuraEnabled 
    public static void updateOppProjects(String oppProId, String objName) {  
        
        if(String.isNotBlank(oppProId)) {
            List<box__FRUP__c> frup = new List<box__FRUP__c>();
            List<AcctSeed__Project__c> pro = new List<AcctSeed__Project__c>();
            
            if(objName == 'AcctSeed__Project__c'){
                pro = [SELECT Id,AcctSeed__Opportunity__c,Box_Folder_Id__c,AcctSeed__Opportunity__r.Name,AcctSeed__Opportunity__r.Box_Folder_Id__c FROM AcctSeed__Project__c WHERE Id = :oppProId];
                if(pro.size() > 0 && pro[0].AcctSeed__Opportunity__c != null){
                    oppProId = pro[0].AcctSeed__Opportunity__c;
                    objName = 'OpportUnity';
                }
            }
            
            frup = [SELECT Id,Name,box__Record_ID__c,box__Folder_ID__c FROM box__FRUP__c WHERE box__Record_ID__c = :oppProId];
            
            if(objName == 'OpportUnity'){
                List<Opportunity> opp = [SELECT Id, Box_Folder_Id__c FROM Opportunity WHERE Id = :oppProId];
                if(frup != null && frup.size() > 0 && opp != null && opp.size() > 0) { 
                    
                    if(opp[0].Box_Folder_Id__c != frup[0].box__Folder_ID__c){
                        updateBoxIdWithOppsAndProjects(opp[0].Id,frup[0].box__Folder_ID__c,objName);
                    }
                    
                    pro = [SELECT Id,Box_Folder_Id__c FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c = :opp[0].Id];
                    if(pro.size() > 0 && pro[0].Box_Folder_Id__c != frup[0].box__Folder_ID__c){
                        updateBoxIdWithOppsAndProjects(pro[0].Id,frup[0].box__Folder_ID__c,'AcctSeed__Project__c');
                    }
                    
                }   
            }else if(objName == 'AcctSeed__Project__c'){
                if(pro.size() > 0  && frup.size() > 0){
                    if(pro[0].Box_Folder_Id__c != frup[0].box__Folder_ID__c){
                        updateBoxIdWithOppsAndProjects(pro[0].Id ,frup[0].box__Folder_ID__c,objName);
                    }
                }
            }
        }
    }
   
    @AuraEnabled
    public static void updateBoxIdWithOppsAndProjects(Id recordId, String folderId, String objName) {
        if(recordId != null && folderId != null){
            if(objName == 'Opportunity'){
                Opportunity opp = new Opportunity(); 
                opp.Id = recordId;
                opp.Box_Folder_Id__c = folderId;
                update opp;
                System.debug('opp::::::'+opp);
            }else if(objName == 'AcctSeed__Project__c'){
                AcctSeed__Project__c pro = new AcctSeed__Project__c();
                pro.Id = recordId;
                pro.Box_Folder_Id__c = folderId;
                update pro;
            }
        }
    }
    
    @AuraEnabled 
    public static void calloutToCreateBoxRecs(String recordId, String folderName, String boxName, String objectName) {
        List<box__Folder_Details__c> boxDetails = new List<box__Folder_Details__c>();
        System.debug('::boxName::'+boxName);
        System.debug('::folderName::'+folderName);
        boxDetails = [SELECT box__FolderId__c,box__Folder_Name__c,Name FROM box__Folder_Details__c WHERE Name = :boxName];
        System.debug('::boxDetails::'+boxDetails);
        Map<String,String> params = new Map<String,String>{
            'folder_name' => folderName,
            'object_name' => objectName , 
            'record_id' => recordId,
            'user_id' => UserInfo.getUserId(),
            'Perform_Covid_Form_Actions'=> String.valueOf(Perform_Covid_Form_Actions)
        };
        if(String.isNotBlank(folderName)){
            if(boxDetails.size() > 0){                
                params.put('parent_id', boxDetails[0].box__FolderId__c);  
                System.debug('Zapier Callout Params::'+params);
                HttpRequest req = new HttpRequest();
                HttpResponse response = new HttpResponse();
                
                Http http = new Http();
                req.setEndpoint('https://hooks.zapier.com/hooks/catch/7869576/'+boxFolderCreationUrl); //Production
                req.setMethod('POST');
                req.setBody(JSON.serialize(params));
                req.setHeader('Content-Type', 'application/json;charset=UTF-8');
                
                try {
                    if(!skipFRUPFolderCheckOrAllowBoxFolderCreation){
                        response = http.send(req);
                        system.debug('res:::'+response);
                    }
    
                    if(response.getStatusCode() == 201){
                        System.debug(response.getBody());
                        System.debug(response.getStatus());
                    }
                } catch(System.CalloutException e) {
                    System.debug('Callout error: '+ e);
                    System.debug(response.toString());
                    createErrorLog('GenericUrlLaunch_Ctrl', 'Aura Component', 'calloutToCreateBoxRecs', e.getMessage(), response.toString(), null);
                    throw new AuraHandledException(e.getMessage());
                }
            }  
        }else{
            ErrorHandler.publishErrorLog(new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('GenericUrlLaunch_Ctrl','calloutToCreateBoxRecs','Contact_Assignments__c','Folder Name is Empty',JSON.serialize(params),'Aura Component')});
        }
    }
    @AuraEnabled 
    public static void createBoxFRUPRecs(String frupJSON) {
        
        if(String.isNotBlank(frupJSON)) {
            List<box__FRUP__c> frupRecList = new List<box__FRUP__c>();
            List<AcctSeed__Project__c> existingProjects = new  List<AcctSeed__Project__c>();

           try{
               box__FRUP__c frup = (box__FRUP__c) JSON.deserialize(frupJSON , box__FRUP__c.class);
               
               if(frup.box__Folder_ID__c != null && frup.box__Record_ID__c != null){  
                   frupRecList = [SELECT Id,box__Folder_ID__c,box__Object_Name__c FROM box__FRUP__c WHERE box__Folder_ID__c = :frup.box__Folder_ID__c AND box__Record_ID__c = :frup.box__Record_ID__c LIMIT 1];
               }
               
               if(frupRecList.size() == 0){
                   frupRecList.add(frup);
                   insert frupRecList;
                   System.debug('Created FRUP::'+frupRecList);
               }
               
               if(frupRecList.size() > 0 && frupRecList[0].box__Record_ID__c != null && frupRecList[0].box__Folder_ID__c != null){
                   
                   if(frupRecList[0].box__Object_Name__c == 'Assessment_Report__c'){
                       List<Assessment_Report__c>  existingAssesmentRecs = [SELECT Id FROM Assessment_Report__c WHERE Box_Folder_Id__c = :frupRecList[0].box__Folder_ID__c  AND Id = :frupRecList[0].box__Record_ID__c];
                       
                       if(existingAssesmentRecs.size() == 0){
                           Assessment_Report__c updateAr = new Assessment_Report__c();  
                           updateAr.Box_Folder_Id__c = frupRecList[0].box__Folder_ID__c;
                           updateAr.Id = frupRecList[0].box__Record_ID__c;
                           update updateAr;
                           System.debug('updated Assesment Report::'+updateAr);
                       }
                   }else if(frupRecList[0].box__Object_Name__c == 'Opportunity'){
                       
                       List<Opportunity> opport = [SELECT Id,Box_Folder_Id__c FROM Opportunity WHERE Box_Folder_Id__c = :frupRecList[0].box__Folder_ID__c  AND Id = :frupRecList[0].box__Record_ID__c];
                       
                       if(opport.size() == 0){
                           updateBoxIdWithOppsAndProjects(frupRecList[0].box__Record_ID__c,frupRecList[0].box__Folder_ID__c,frupRecList[0].box__Object_Name__c);
                       }
                       
                       existingProjects = [SELECT Id,Name,Box_Folder_Id__c FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c = :frupRecList[0].box__Record_ID__c];
                       if(existingProjects.size() > 0){
                           if(frupRecList[0].box__Folder_ID__c != existingProjects[0].Box_Folder_Id__c){
                               updateBoxIdWithOppsAndProjects(existingProjects[0].Id,frupRecList[0].box__Folder_ID__c,'AcctSeed__Project__c');
                           }
                       }
                   }else if(frupRecList[0].box__Object_Name__c == 'AcctSeed__Project__c'){
                       existingProjects = [SELECT Id,Name,Box_Folder_Id__c FROM AcctSeed__Project__c WHERE Box_Folder_Id__c = :frupRecList[0].box__Folder_ID__c AND Id = :frupRecList[0].box__Record_ID__c];
                       
                       if(existingProjects.size() == 0){
                           updateBoxIdWithOppsAndProjects(frupRecList[0].box__Record_ID__c,frupRecList[0].box__Folder_ID__c,frupRecList[0].box__Object_Name__c);
                       }
                   }
               }
               
           }catch(exception ex){
               createErrorLog('GenericUrlLaunch_Ctrl', 'Aura Component', 'createBoxFRUPRecs', ex.getMessage(),null , 'box__FRUP__c');
               throw new AuraHandledException(ex.getMessage());
           }
        }
    }
    
    @AuraEnabled
    public static String validateOppStartAndEndDateForPolicyAndProcedure(String recId){
        String result = 'success';
        Boolean isOppValid = true;
        Boolean isCAValid = true;
        Boolean isCAAvailable = false;
        Opportunity opp = [SELECT Id, Start_Date__c, End_Date__c FROM Opportunity WHERE Id = :recId LIMIT 1];
        if(opp.Start_Date__c == null || opp.End_Date__c == null){
            isOppValid = false;
        }
        for(Contact_Assignments__c conAssign : [SELECT Id, Start_Date__c, End_Date__c 
                                                   FROM Contact_Assignments__c 
                                                   WHERE Opportunity_Name__c = :recId 
                                                   AND RecordType.DeveloperName = 'Student']){
            isCAAvailable = true;                                           
            if(conAssign.Start_Date__c == null || conAssign.End_Date__c == null){
                isCAValid = false;
            }    
        }
        if(!isOppValid || !isCAValid || !isCAAvailable){
            result = 'Please update the Opportunity and Contact Assignment\'s Start Date and End Date using the Manage Project Dates button.';
        }
        return result;
    }
    
    @AuraEnabled  
    public static CongaButtonsController.generateWrapper getStudentProcedureInfo(String objName , String objId) {
        
        Map<String,Id> congaTemplateMap = new Map<String,Id>();
        List<Quote> quoteRec = new List<Quote>();   
        List<Contact_Assignments__c> conAssignRec = new List<Contact_Assignments__c >();
        List<box__FRUP__c> frup = new List<box__FRUP__c>();
        CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
        List<CongaButtonsController.congaUrlFormationWrapper> congaUrlList = new List<CongaButtonsController.congaUrlFormationWrapper>();
        Map<String, String> conAssignIdWithCongaUrlMap = new Map<String, String>();
        List<String> tdyDate = (String.valueOf(System.today())).split('-');
        String dateString = (tdyDate != null) ? (tdyDate[1]+'_'+tdyDate[2]+'_'+tdyDate[0]) : null;
        String congaFormation = '';
        String templateName = '';
        String folderName = null;
        String projectRelOppId = null;
        String projectRelOppFolderName = null;
        List<Contact> recipient2Cont = new List<Contact>();
        // Expiration Date is 10 days for Progress Report
        DateTime expDateTime =  System.now().addDays(10);
        DateTime expRemiderDT = System.now().addDays(8);
        String expDate = expDateTime.format('yyyy-MM-dd') + 'T' + expDateTime.format('HH:mm:ss.SSS')+'Z';
        String expReminderDTStr = expRemiderDT.format('yyyy-MM-dd') + 'T' + expRemiderDT.format('HH:mm:ss.SSS')+'Z';
        
        if(objId != null){
            Set<Id> recordIds = new Set<Id>();
            recordIds.add(objId);

            if(objName == 'AcctSeed__Project__c'){
                 List <AcctSeed__Project__c>  proList = [SELECT Id,Name,AcctSeed__Opportunity__c,AcctSeed__Opportunity__r.Name, DLS_Ref__c FROM AcctSeed__Project__c WHERE Id =:objId LIMIT 1];
                if(proList.size() > 0 ){
                    folderName = proList[0].Name;
                    if(proList[0].AcctSeed__Opportunity__c != null){
                        recordIds.add(proList[0].AcctSeed__Opportunity__c);
                        projectRelOppId = proList[0].AcctSeed__Opportunity__c;
                        projectRelOppFolderName = proList[0].AcctSeed__Opportunity__r.Name;
                    }
                }
            }else if(objName == 'Opportunity'){
                List<Opportunity>  opp = [SELECT Id,Name, DLS_Class__c FROM Opportunity WHERE Id =:objId LIMIT 1];
                if(opp.size() > 0){
                    folderName = opp[0].Name;
                }                
            }
            
            frup = [SELECT Id,Name,box__Record_ID__c,box__Folder_ID__c FROM box__FRUP__c WHERE box__Record_ID__c IN :recordIds];
            System.debug('::frup::'+frup); 
            
            recipient2Cont = [SELECT Id,Email,Name FROM Contact WHERE Name = 'Opportunity - Conga Sign' LIMIT 1];
            System.debug('recipient2Cont:::'+recipient2Cont);
        }
        
        if(frup.size() > 0 || skipFRUPFolderCheckOrAllowBoxFolderCreation){                        
            
            updateOppProjects(objId, objName);    //Added by Dhinesh - 22/04/2022 - To Update Box Folder Id in Opp/Project
            
            if(objName == 'AcctSeed__Project__c'){
                templateName = 'Student Policies & Procedures';                
            }else{
                templateName = 'PVT Enrollment Form';                 
            }
            
            for(APXTConga4__Conga_Template__c ct : [SELECT Id,Name,APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = :templateName]) {
                congaTemplateMap.put(ct.APXTConga4__Name__c,ct.Id);
            }
            
            if(objName == 'AcctSeed__Project__c'){
                conAssignRec = [SELECT Id, Name, Candidate_Name__r.Name, Candidate_Name__c, Project__c, Project__r.DLS_Ref__c, DLS_P_and_P_Generated_Date__c FROM Contact_Assignments__c WHERE Project__c = :objId AND RecordType.DeveloperName = 'Student' AND Status__c IN ('Active','Planned')]; // updated the status condition from != Transferred to In (Active, Planned) by GRK W-007844
                
                if(conAssignRec.size() > 0){
                        congaFormation = '&templateId=' + congaTemplateMap.get('Student Policies & Procedures');
                        
                        for(Contact_Assignments__c ca : conAssignRec){  
                            String congaUrl = '&id=' + ca.Id + congaFormation +'&OFN=Student Policies and Procedures - '+ca.Candidate_Name__r.Name+' - '+dateString+'--'+ca.Name+'&CSVisible=1&CSRoutingType=SERIAL&CSExpiration='+expDate+'&CSRequestReminder=2&CSExpirationReminder='+expReminderDTStr+'&CSRecipient1='+ca.Candidate_Name__c+'&CSRole1=SIGNER'+
                                ((recipient2Cont.size() > 0) ? '&CSRecipient2='+recipient2Cont[0].Id+'&CSRole2=CC' : '')+
                                '&CSEmailSubject=Please Sign the Following Policies and Procedures&CSEmailMessage=Please review the document and sign&DefaultPDF=1'+
                                '&CSVisible=0&qmode=CongaSign&CSSendonbehalfofname=Diplomatic+Language+Services&CSSendonbehalfofemail=feo@dlsdc.com';   //feo@dlsdc.com                            
                            conAssignIdWithCongaUrlMap.put(ca.Id, congaUrl);                            
                        }
                }else{
                    throw new AuraHandledException('There is no Student Contact under this Project');
                }
            }else if(objName == 'Opportunity'){
                    conAssignRec = [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name,Opportunity_Name__c,Opportunity_Name__r.DLS_Ref__c,Agreed_DLS_Policies_And_Procedures__c,DLS_Policies_and_Procedures_Agreed_Date__c FROM Contact_Assignments__c WHERE Opportunity_Name__c = :objId AND RecordType.DeveloperName = 'Student' AND Status__c IN ('Active','Planned')]; // updated the status condition (Active, Planned) by GRK W-007844
                    if(conAssignRec.size() > 0){
                    
                        quoteRec = [SELECT Id ,Name, Registrar__c FROM Quote WHERE OpportunityId = :objId ORDER BY CreatedDate DESC LIMIT 1];
                        
                        if(quoteRec.size() > 0){
                            
                            congaFormation = '&templateId=' + congaTemplateMap.get('PVT Enrollment Form') +
                                '&queryId=[Quote]' +congaTranslator.getCongaQuery('Quote query')+ '?pv0=' + objId +
                                ',[Qli]'+ CongaTranslator.getCongaQuery('Quote Line Item query') + '?pv0=' + quoteRec[0].Id +
                                ',[Reg]'+ CongaTranslator.getCongaQuery('User Query by Name') + '?pv0=' + quoteRec[0].Registrar__c;
                            
                            for(Contact_Assignments__c ca : conAssignRec){  
                                CongaButtonsController.congaUrlFormationWrapper cf = new CongaButtonsController.congaUrlFormationWrapper();
                                
                                String congaUrl = congaFormation + '&id=' + ca.Id +'&OFN=Student Policies and Procedures - '+ca.Candidate_Name__r.Name+' - '+dateString +'--'+ca.Name+'&CSVisible=1&CSRoutingType=SERIAL&CSExpiration='+expDate+'&CSRequestReminder=2&CSExpirationReminder='+expReminderDTStr+'&CSRecipient1='+ca.Candidate_Name__c+'&CSRole1=SIGNER'+
                                    ((recipient2Cont.size() > 0) ? '&CSRecipient2='+recipient2Cont[0].Id+'&CSRole2=CC' : '')+
                                    '&CSEmailSubject=Please Sign the Following Quote with Policies and Procedures&CSEmailMessage=Please review the document and sign&DefaultPDF=1'+
                                    '&CSsenderreturnurl='+EncodingUtil.urlEncode(System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+ca.Opportunity_Name__c,'UTF-8');  
                                
                                cf.label = ca.Candidate_Name__r.Name;
                                cf.value = ca.Candidate_Name__c;               
                                cf.congaUrl = congaUrl;
                                cf.customMessage = null;
                            
                            
                            if(ca.Agreed_DLS_Policies_And_Procedures__c == true && ca.DLS_Policies_and_Procedures_Agreed_Date__c != null){
                                cf.customMessage = 'A Quote with Policies & Procedures has already been signed by this student for this project, do you still want to send it?';
                            }
                            congaUrlList.add(cf);
                        }
                    }else{
                        throw new AuraHandledException('There is no Quote under this Opportunity');
                    }
                }else{
                    throw new AuraHandledException('There is no Student Contact under this Opportunity');
                }
            }
        }else{
            
            if(projectRelOppId != null && projectRelOppFolderName != null){
                folderName = projectRelOppFolderName;
                objId = projectRelOppId;
                objName = 'Opportunity';
            }
            
            if(String.isNotBlank(folderName)){
                folderName = folderName.replace('/','_');
            }
            System.debug('objId::::'+objId);
            System.debug('objName::::'+objName);
            System.debug('folderName::::'+folderName);
            //calloutToCreateBoxRecs(objId ,folderName ,objName,'Opportunities');
            calloutToCreateBoxRecs(objId ,folderName ,'Opportunities',objName);
            wrap.errorMsg = 'No Box Record';  
        }
        
        wrap.sessionIdServerURL = CongaButtonsController.getServerUrlSessionId();
        wrap.congaUrlInfo = congaUrlList;
        wrap.conAssignIdWithCongaUrlMap = conAssignIdWithCongaUrlMap;
        wrap.objRecordId = objId;
        wrap.contactAssignments = conAssignRec;

        return wrap; 
    }
    
    @future(callout = true)
    public static void calloutToCreateBoxRecsFuture(String recordId, String folderName, String boxName, String objectName, Boolean performCovidFormActions){
        GenericUrlLaunch_Ctrl.Perform_Covid_Form_Actions = performCovidFormActions;            
        GenericUrlLaunch_Ctrl.calloutToCreateBoxRecs(recordId, folderName, boxName, objectName);   
    }
    
    @AuraEnabled 
    public static void createErrorLog(String cmpName, String cmpType, String methodName, String description, String jsonRes, String objName) {
        try{
            Error_Log__c logError = new Error_Log__c(Method_Name__c = methodName, Description__c = description, JSON_Response__c = jsonRes, 
                                                     Component_Name__c = cmpName, Object__c = objName, Component_Type__c = cmpType, User__c = UserInfo.getUserId());
            
            insert logError;
        }catch(exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    @AuraEnabled
    public static CongaButtonsController.generateWrapper getRefundCalculationInfo(String proRecId){
        try{
            List<AcctSeed__Project__c> proRec = [SELECT Id,Name,AcctSeed__Status__c FROM AcctSeed__Project__c WHERE Id = :proRecId];
            CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
            Map<String,Id> congaTemplateMap = new Map<String,Id>();
            List<String> tdyDate = (String.valueOf(System.today())).split('-');
            String dateString = (tdyDate != null) ? (tdyDate[1]+'_'+tdyDate[2]+'_'+tdyDate[0]) : null;

            if(proRec.size() > 0){
                if(proRec[0].AcctSeed__Status__c == 'Canceled' || proRec[0].AcctSeed__Status__c == 'Ended'){
                    for(APXTConga4__Conga_Template__c ct : [SELECT Id,Name,APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'DLS Refund Calculation']) {
                        congaTemplateMap.put(ct.APXTConga4__Name__c,ct.Id);
                    }
                    
                    String congaUrl = '&id=' + proRec[0].Id +'&templateId=' + congaTemplateMap.get('DLS Refund Calculation')+'&TemplateGroup=Refund Calculation';
                    congaUrl += '&QueryId=[PT]'+ CongaTranslator.getCongaQuery('Project Task Qty Planned - Aggregate')+'?pv0='+proRec[0].Id;
                    congaUrl += '&OFN=' + proRec[0].Name  + ' - Refund Calculation Worksheet - '+dateString ;
                    wrap.sessionIdServerURL = CongaButtonsController.getServerUrlSessionId();
                    wrap.congaURL = congaUrl;
                }else{
                    wrap.errorMsg = 'This Process only for Canceled or Ended Projects.'; 
                }
            }
            return wrap;

        }catch(exception ex){
            throw new AuraHandledException(ex.getMessage());
        }        
    }
    
    @AuraEnabled
    public static string validateAndInitiateBoxFolderCreation(Id recordId, String folderName, String boxParentFolderName, String sObjectApiName){
        List<box__FRUP__c> frup = [SELECT Id,Name,box__Record_ID__c,box__Folder_ID__c FROM box__FRUP__c WHERE box__Record_ID__c = :recordId];
        
        if(frup.size() > 0 || skipFRUPFolderCheckOrAllowBoxFolderCreation){            
            if(sObjectApiName == 'AcctSeed__Cost_Rates__c'){
                List<AcctSeed__Cost_Rates__c> costRates = [SELECT Id, Name, Box_Folder_Id__c 
                                                     FROM AcctSeed__Cost_Rates__c WHERE Id = :recordId];
                if(costRates != null && costRates.size() > 0 && frup.size() > 0 && costRates[0].Box_Folder_Id__c != frup[0].box__Folder_ID__c) {
                    
                    costRates[0].Box_Folder_Id__c = frup[0].box__Folder_ID__c;
                    update costRates;
                }
            }
        }else{
            if(String.isNotBlank(folderName)){
                folderName = folderName.replace('/','_');
            }
            GenericUrlLaunch_Ctrl.calloutToCreateBoxRecs(recordId, folderName ,boxParentFolderName,sObjectApiName);  
            return 'No Box Record';
        }
        return '';
    }
    
    // Used in the Sent to Instructor button in Training Report Object
    @AuraEnabled
    public static string validateAssessmentRecBoxFolder(Id assessmentReportId){
        Map<String, String> result = new Map<String, String>{'errorMsg'=>'','congaUrl'=>''};
        String folderName = null;
        String projectRelOppId = null;        
        Set<Id> recordIds = new Set<Id>{assessmentReportId};
        Assessment_Report__c assessmentReport = [SELECT Id, Name, Report_Date__c, Student__c, Instructor__c, Instructor__r.Email, Instructor__r.Name, Supervisor_Name__c, 
                                                                                  RecordType.DeveloperName, Project__c, Observation_Report_Download_Name__c, Report_File_Name__c, Project__r.DLS_Ref__c,
                                                                                 Tester__c, Tester__r.Email, Tester__r.Name, Project__r.AcctSeed__Account__c, Project__r.AcctSeed__Account__r.Name,
                                                                                 Project__r.TO__c, Project__r.Language__r.Name, Student__r.FirstName,  Student__r.LastName, Student__r.Email
                                                                                  FROM Assessment_Report__c 
                                                                                  WHERE Id = :assessmentReportId LIMIT 1];
        List<box__FRUP__c> frup = [SELECT Id,Name,box__Record_ID__c,box__Folder_ID__c FROM box__FRUP__c WHERE box__Record_ID__c IN :recordIds];
        List<Contact> recipient2 = [SELECT Id,Email,Name FROM Contact WHERE Name = 'Annual Report - Conga Sign' LIMIT 1];
        // Expiration Date is 10 days for Progress Report
        DateTime expDateTime =  System.now().addDays(60);
        DateTime expRemiderDT = System.now().addDays(58);
        String expDate = expDateTime.format('yyyy-MM-dd') + 'T' + expDateTime.format('HH:mm:ss.SSS')+'Z';
        String expReminderDTStr = expRemiderDT.format('yyyy-MM-dd') + 'T' + expRemiderDT.format('HH:mm:ss.SSS')+'Z';
        Boolean isNew = CongaHelper.checkIsNew(assessmentReport, assessmentReport.RecordType.DeveloperName == 'Annual_Instructor_Performance_Review');
        
        if(frup.size() > 0 || skipFRUPFolderCheckOrAllowBoxFolderCreation){            
            formBoxFolderContMap();
            if(frup.size() > 0){
                updateAssesmentReports(assessmentReportId);
            }
            
            Id congaTemplateId = CongaHelper.getCongaTemplateId(assessmentReport.RecordType.DeveloperName);
            Id emailTemplateId = CongaHelper.getCongaEmailTemplateId(assessmentReport.RecordType.DeveloperName);            
            
            Map<String, Object> congaSessionMap = new Map<String, Object>();
            if(!Test.isRunningTest()){
                congaSessionMap = (Map<String, Object>) JSON.deserializeUntyped(CongaButtonsController.getServerUrlSessionId());
            }
            
            
            String congaBaseUrl = 'https://composer.congamerge.com?sessionId='+(String)congaSessionMap.get('sessionId') + 
                '&serverUrl='+(String)congaSessionMap.get('serverUrl')+
                '&id='+assessmentReportId+'&DefaultPDF=1'+
                '&templateId='+congaTemplateId+
                '&QueryId=[LTS]'+ CongaTranslator.getCongaQuery('Contact Query for Supervisor in Offer Letter')+'?pv0='+assessmentReport.Supervisor_Name__c;
            
            if(assessmentReport.RecordType.DeveloperName == 'Observation_Report'){

                congaBaseUrl += ',[Project]'+ CongaTranslator.getCongaQuery('Project Query for Job Summary Report')+'?pv0='+assessmentReport.Project__c+
                                '&OFN='+assessmentReport.Observation_Report_Download_Name__c+'--'+assessmentReport.Report_File_Name__c+
                                '&EmailToId='+assessmentReport.Instructor__c+
                                '&EmailRelatedToId='+assessmentReportId+
                                '&emailbcc='+Label.Observation_Report_Conga_Sign+
                                '&CongaEmailTemplateId='+emailTemplateId;
                
            } else if(assessmentReport.RecordType.DeveloperName == 'DLI_Observation_Report'){
            
                congaBaseUrl += ',[Project]'+ CongaTranslator.getCongaQuery('Project Query for Job Summary Report')+'?pv0='+assessmentReport.Project__c+
                                '&OFN='+assessmentReport.Observation_Report_Download_Name__c+'--'+assessmentReport.Report_File_Name__c+
                                '&EmailToId='+assessmentReport.Instructor__c+
                                '&EmailRelatedToId='+assessmentReportId+
                                '&emailbcc='+Label.Observation_Report_Conga_Sign+
                                '&CongaEmailTemplateId='+emailTemplateId;
                
            } else if(assessmentReport.RecordType.DeveloperName == 'Test_Report'){
                String dodaBox = '';
                
                List<String> additionalEmailIds = new List<String>();
                if(assessmentReport.Instructor__c != null && String.isNotBlank(assessmentReport.Instructor__r.Email )){
                    additionalEmailIds.add(assessmentReport.Instructor__r.Email);
                }
                if(assessmentReport.Tester__c != null && String.isNotBlank(assessmentReport.Tester__r.Email )){
                    additionalEmailIds.add(assessmentReport.Tester__r.Email);
                }
                if(assessmentReport.Project__r.AcctSeed__Account__r.Name == 'DODA' && folderNameWithContactMap.size() > 0 && folderNameWithContactMap.containskey('DODA Training Report - Conga Sign')){
                    dodaBox = folderNameWithContactMap.get('DODA Training Report - Conga Sign').Email;
                } 

                congaBaseUrl += ',[Project]'+ CongaTranslator.getCongaQuery('Project Query for Job Summary Report')+'?pv0='+assessmentReport.Project__c+
                                '&OFN='+assessmentReport.Name+'--'+assessmentReport.Report_File_Name__c+
                                '&EmailToId='+assessmentReport.Student__c+
                                (additionalEmailIds.size() > 0 ? ('&EmailAdditionalTo='+String.join( additionalEmailIds, ', ' ) ) : '')+
                                '&EmailRelatedToId='+assessmentReportId+
                                '&emailbcc='+Label.Test_Report_Conga_Sign+ (dodaBox != ''? (','+dodaBox) : '') +
                                '&CongaEmailTemplateId='+emailTemplateId;
                
            } else if(assessmentReport.RecordType.DeveloperName == 'Annual_Instructor_Performance_Review'){
                congaBaseUrl += '&OFN=Instructor Annual Performance Review – '+assessmentReport.Instructor__r.Name+'-'+assessmentReport.Report_Date__c.format()+'--'+assessmentReport.Report_File_Name__c+
                                '&CSVisible=1&CSRoutingType=SERIAL&CSExpiration='+expDate+'&CSRequestReminder=2&CSExpirationReminder='+expReminderDTStr+'&CSRecipient1='+assessmentReport.Instructor__c+'&CSRole1=SIGNER'+
                                ((recipient2.size() > 0) ? '&CSRecipient2='+recipient2[0].Id+'&CSRole2=CC' : '')+
                                '&CSEmailSubject=Please Sign the Following Annual Performance Review&CSEmailMessage=Please review the document and sign.  If you have any questions please contact your LTS.'+
                                '&CSsenderreturnurl='+EncodingUtil.urlEncode(System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+assessmentReport.Id,'UTF-8');                   
            } else if(assessmentReport.RecordType.DeveloperName == 'DLI_W_Test_Report') {
                String dliBox = '';
                List<String> additionalEmailIds = new List<String>();
                if(assessmentReport.Instructor__c != null && String.isNotBlank(assessmentReport.Instructor__r.Email )){
                    additionalEmailIds.add(assessmentReport.Instructor__r.Email);
                }
                /* Modified by Dhinesh - W-007895 - Remove tester from additional to ids
                if(assessmentReport.Tester__c != null && String.isNotBlank(assessmentReport.Tester__r.Email )){
                    additionalEmailIds.add(assessmentReport.Tester__r.Email);
                }*/
                if(assessmentReport.Project__r.AcctSeed__Account__c != null && assessmentReport.Project__r.AcctSeed__Account__r.Name.contains('DLI') && folderNameWithContactMap.size() > 0 && folderNameWithContactMap.containskey('DLI Training Report - Conga Sign')){
                    dliBox = folderNameWithContactMap.get('DLI Training Report - Conga Sign').Email;
                } 
                // OFN {TO#}_ {Student First Name} {Last Name} _Student-Assessment _{Language}_{MM-YYYY}
                congaBaseUrl += ',[Project]'+ CongaTranslator.getCongaQuery('Project Query for Job Summary Report')+'?pv0='+assessmentReport.Project__c+
                                '&OFN='+assessmentReport.Project__r.TO__c+'_'+assessmentReport.Student__r.FirstName + ' '+ assessmentReport.Student__r.LastName+ '_Student-Assessment_'+ assessmentReport.Project__r.Language__r.Name+ assessmentReport.Report_Date__c.month() +'-'+assessmentReport.Report_Date__c.year() +'--'+assessmentReport.Report_File_Name__c+
                                '&EmailToId='+assessmentReport.Student__c+
                                (additionalEmailIds.size() > 0 ? ('&EmailAdditionalTo='+String.join( additionalEmailIds, ', ' ) ) : '')+
                                '&EmailRelatedToId='+assessmentReportId+
                                '&emailbcc='+Label.Test_Report_Conga_Sign + ', ' + dliBox +
                                '&CongaEmailTemplateId='+emailTemplateId;
            } else if(assessmentReport.RecordType.DeveloperName == 'DLI_W_Self_Assessment_Test_Report') {
                String dliBox = '';
                List<String> additionalEmailIds = new List<String>();
                if(assessmentReport.Instructor__c != null && String.isNotBlank(assessmentReport.Instructor__r.Email )){
                    additionalEmailIds.add(assessmentReport.Student__r.Email);
                }
                /* Modified by Dhinesh - W-007895 - Remove tester from additional to ids
                if(assessmentReport.Tester__c != null && String.isNotBlank(assessmentReport.Tester__r.Email )){
                    additionalEmailIds.add(assessmentReport.Tester__r.Email);
                }*/
                if(assessmentReport.Project__r.AcctSeed__Account__c != null && assessmentReport.Project__r.AcctSeed__Account__r.Name.contains('DLI') && folderNameWithContactMap.size() > 0 && folderNameWithContactMap.containskey('DLI Training Report - Conga Sign')){
                    dliBox = folderNameWithContactMap.get('DLI Training Report - Conga Sign').Email;
                } 
                // OFN {TO#}_ {Student First Name} {Last Name} _Student-Assessment _{Language}_{MM-YYYY}
                congaBaseUrl += ',[Project]'+ CongaTranslator.getCongaQuery('Project Query for Job Summary Report')+'?pv0='+assessmentReport.Project__c+
                                '&OFN='+assessmentReport.Project__r.TO__c+'_'+assessmentReport.Student__r.FirstName + ' '+ assessmentReport.Student__r.LastName+ '_Self-Assessment_'+ assessmentReport.Project__r.Language__r.Name+ assessmentReport.Report_Date__c.month() +'-'+assessmentReport.Report_Date__c.year() +'--'+assessmentReport.Report_File_Name__c+
                                '&EmailToId='+assessmentReport.Instructor__c+
                                (additionalEmailIds.size() > 0 ? ('&EmailAdditionalTo='+String.join( additionalEmailIds, ', ' ) ) : '')+
                                '&EmailRelatedToId='+assessmentReportId+
                                '&emailbcc='+Label.Test_Report_Conga_Sign + ', ' + dliBox +
                                '&CongaEmailTemplateId='+emailTemplateId;
            }
            
            result.put('congaUrl',congaBaseUrl);
            if(!isNew){
            
                result.put('errorMsg','If you would like to resend it, please click "Cancel", and delete the corresponding file from the Box Folder for this report before clicking "Proceed".');                
            }
        }else if(frup.size() == 0 && !skipFRUPFolderCheckOrAllowBoxFolderCreation){
            
            folderName = assessmentReport.Name;
            if(String.isNotBlank(folderName)){
                folderName = folderName.replace('/','_');
            }
            GenericUrlLaunch_Ctrl.calloutToCreateBoxRecs(assessmentReportId, folderName ,'Training Reports','Assessment_Report__c');  //Training Reports 
            result.put('errorMsg', 'No Box Record');  
        }
                
        return JSON.serialize(result);
    }
    
    //W-007001 - Used in the Send DLS Office Procedure/Send DLS Covid Procedures button in Project Object
    @AuraEnabled
    public static string getRecordsAndCongaUrlForSendDLSOfficeProcedure(Id projectId){
        Map<string,Id> congaTemplateMap = new Map<String,Id>();
        GenerateCertificateCmp_Ctrl.GenerateCertificateWrap wrapObj = new GenerateCertificateCmp_Ctrl.GenerateCertificateWrap(); 
        // Expiration Date is 10 days for Progress Report
        DateTime expDateTime =  System.now().addDays(10);
        DateTime expRemiderDT = System.now().addDays(8);
        String expDate = expDateTime.format('yyyy-MM-dd') + 'T' + expDateTime.format('HH:mm:ss.SSS')+'Z';
        String expReminderDTStr = expRemiderDT.format('yyyy-MM-dd') + 'T' + expRemiderDT.format('HH:mm:ss.SSS')+'Z';
        
        wrapObj.contactAssignments = new List<Contact_Assignments__c>(); 
        Id ltsId;            
        for(Contact_Assignments__c ca : [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, DLS_Covid_Form_Generated_Date__c, Project__r.Language__r.Name, RecordType.DeveloperName FROM Contact_Assignments__c WHERE Project__c = :projectId AND (RecordType.DeveloperName='Student' OR RecordType.DeveloperName='Instructor') AND Status__c NOT IN ('Transferred', 'Canceled')]){
            wrapObj.contactAssignments.add(ca);                
        }
        List<Contact> recipient2 = [SELECT Id,Email,Name FROM Contact WHERE Name = 'DLS Covid Procedure - Conga Sign' LIMIT 1];
        String fromEmailId = [SELECT Id, Address FROM OrgWideEmailAddress WHERE  Address = 'support@dlsdc.com' LIMIT 1].Id;           
        
        Map<String, Object> congaSessionMap = new Map<String, Object>();
        if(!Test.isRunningTest()){
            congaSessionMap = (Map<String, Object>) JSON.deserializeUntyped(CongaButtonsController.getServerUrlSessionId());
        }
        for(APXTConga4__Conga_Template__c ct : [SELECT Id,Name,APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'DLS Office Procedure']) {
            congaTemplateMap.put(ct.APXTConga4__Name__c,ct.Id);
        }
        
        String congaBaseUrl = 'https://composer.congamerge.com?sessionId='+(String)congaSessionMap.get('sessionId') + 
            '&serverUrl='+(String)congaSessionMap.get('serverUrl')+
            '&id=&DefaultPDF=1'+
            '&templateId=' + congaTemplateMap.get('DLS Office Procedure') +
            '&queryId=[CON]'+ CongaTranslator.getCongaQuery('Contact Query - Generate Certificate') + '?pv0=';
        wrapObj.congaBaseUrl = congaBaseUrl;
        wrapObj.emailParams = '&EmailFromId='+fromEmailId+'&CSVisible=0&qmode=CongaSign&CSRoutingType=SERIAL&CSExpiration='+expDate+'&CSRequestReminder=2&CSExpirationReminder='+expReminderDTStr+'&CSEmailSubject=Please Sign the Following DLS Office Procedure&CSEmailMessage=Please review the document and sign. If you have any questions please contact your LTS.'+                                  
                              ((recipient2.size() > 0) ? '&CSRecipient2='+recipient2[0].Id+'&CSRole2=CC' : '')+'&CSRole1=SIGNER&CSRecipient1=';
               
        return JSON.serialize(wrapObj);
    }
    
    //W-007001 - Used in the Send DLS Office Procedure/Send DLS Covid Procedures button in Project Object
    @AuraEnabled
    public static String updateContactRecords(String conAssignmentStr, Boolean initCAFRUPCheck){
        String result = 'success';        
        try{
            Set<Id> caIds = new Set<Id>();            
            List<Contact_Assignments__c> conAssignments = (List<Contact_Assignments__c>) JSON.deserialize(conAssignmentStr, List<Contact_Assignments__c>.class);
            Map<Id, Contact_Assignments__c> conAssignmentIdWithRecMap = new Map<Id, Contact_Assignments__c>(conAssignments);
            
            if(initCAFRUPCheck){
                for(Contact_Assignments__c ca : conAssignments){
                    caIds.add(ca.Id);
                }
                for(box__FRUP__c frup : [SELECT Id,Name,box__Record_ID__c,box__Folder_ID__c FROM box__FRUP__c WHERE box__Record_ID__c IN :caIds]){
                    conAssignmentIdWithRecMap.get(frup.box__Record_ID__c).Box_Folder_Id__c = frup.box__Folder_ID__c;                         
                    caIds.remove(frup.box__Record_ID__c);
                }
                if(caIds != null && caIds.size() > 0){
                    for( Contact_Assignments__c ca  : [SELECT Id, Name, Project__c, Project__r.DLS_Ref__c, Opportunity_Name__c, Opportunity_Name__r.DLS_Class__c FROM Contact_Assignments__c WHERE Id IN :caIds]){
                       System.enqueueJob(new CalloutBoxFolderCreationQueueable(ca.Id, ca.Name,'Contact Assignments','Contact_Assignments__c', true));
                    }
                }
            }
            
            update conAssignmentIdWithRecMap.values();            
        }catch(exception ex){
            result = ex.getMessage();
        }
        
        return result;        
    }
    
    //W-007424 - Added By Dhinesh  - 18/04/2022 - Update Assessment Report
    @AuraEnabled
    public static String updateAssessmentReportRecord(Assessment_Report__c assessmentReport){
        String result = 'success';        
        try{            
            
            update assessmentReport;            
        }catch(exception ex){
            result = ex.getMessage();
        }
        
        return result;        
    }
    
    public class CalloutBoxFolderCreationQueueable implements Queueable { 
        private String recId;
        private String folderName;
        private String boxName;
        private String objectName;
        private Boolean performCovidFormActions;
    
        public CalloutBoxFolderCreationQueueable(String recordId, String folderName, String boxName, String objectName, Boolean performCovidFormActions) {
            this.recId = recordId;
            this.folderName = folderName;
            this.boxName = boxName;
            this.objectName = objectName;
            this.performCovidFormActions = performCovidFormActions;
        }
    
        public void execute(System.QueueableContext qc) {
            if(String.isNotBlank(folderName)){
                folderName = folderName.replace('/','_');
            }
            GenericUrlLaunch_Ctrl.calloutToCreateBoxRecsFuture(recId, folderName, boxName, objectName, performCovidFormActions);   
        }
    }   
    
    public static Boolean isSandbox() {
        String hostUrl = URL.getSalesforceBaseUrl().getHost();
        return hostUrl.contains('uat') || hostUrl.contains('build');
    }
    
    public static String getDecimalStr(Decimal x){
        String result;
        String y = String.valueOf(x);
        
        if(!y.contains('.'))
            return String.valueOf(x.format()) +  '.00';
        else  
            return y;
    }
}