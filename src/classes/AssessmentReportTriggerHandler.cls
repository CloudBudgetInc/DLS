public class AssessmentReportTriggerHandler{
    
    public static void updateAssessmentReportName(Set<Id> projIds, Set<Id> stdIds, Set<Id> insIds, List<Assessment_Report__c> assessmentReports){
            
        Map<String, Contact_Assignments__c> projIdStdIdAndCARec = new Map<String, Contact_Assignments__c>();
        Map<String, Contact_Assignments__c> projIdInsIdAndCARec = new Map<String, Contact_Assignments__c>();
        Map<Id, String> recordTypeIdAndDevName = new Map<Id, String>();
        
        if(projIds.size() > 0){
            
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c, Candidate_Name__c, Candidate_Name__r.Name, Candidate_Name__r.FirstName, Candidate_Name__r.LastName, RecordType.DeveloperName, Candidate_Name__r.DLS_User__c,Project__r.DLS_Ref__c,
                                                            Project__r.Language__r.Name, Project__r.TO__c, Project__r.Name
                                                        FROM Contact_Assignments__c
                                                        WHERE Project__c IN : projIds AND (Candidate_Name__c IN : stdIds OR Candidate_Name__c IN : insIds)];
                                                        
            for(Contact_Assignments__c ca : conAssigns){ 
            
                String projIdConId = ca.Project__c+'-'+ca.Candidate_Name__c;
                
                if(ca.RecordType.DeveloperName == 'Student'){
                    projIdStdIdAndCARec.put(projIdConId, ca);
                }
                
                if(insIds.contains(ca.Candidate_Name__c) && ca.RecordType.DeveloperName == 'Instructor'){
                    projIdInsIdAndCARec.put(projIdConId, ca);
                }
            }
            
            for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Assessment_Report__c']){
                recordTypeIdAndDevName.put(rt.Id, rt.DeveloperName);
            }
            
            for(Assessment_Report__c assRep : assessmentReports){
                                
                String assRepRTName = recordTypeIdAndDevName.get(assRep.RecordTypeId);
                String reportDateStr = assRep.Report_Date__c != null ? (assRep.Report_Date__c.month() + '_' +  assRep.Report_Date__c.year()) : '';
                
                if(assRep.Student__c != null){
                
                    String projIdAndStdId = assRep.Project__c+'-'+assRep.Student__c;
                    
                    if(projIdStdIdAndCARec.containsKey(projIdAndStdId)){
                    
                        Contact_Assignments__c stdCA = projIdStdIdAndCARec.get(projIdAndStdId);
                        
                        String stdName = stdCA.Candidate_Name__r.FirstName + ' ' + stdCA.Candidate_Name__r.LastName;
                        
                        String languageName = (String.isNotBlank(stdCA.Project__r.Language__r.Name) && stdCA.Project__r.Language__r.Name.contains(' - ')) ? stdCA.Project__r.Language__r.Name.split(' - ')[0] : stdCA.Project__r.Language__r.Name;
                                                                        
                        String nameSuf = '';
                        
                        if(assRepRTName == 'Language_Training_Progress' && assRep.Language_Training_Status__c != 'Monthly'){
                        
                            if(assRep.Language_Training_Status__c == 'Progress'){
                                nameSuf = 'Progress';
                            }
                            if(assRep.Language_Training_Status__c == 'Final'){
                                nameSuf = 'Final';
                            }
                            nameSuf = ' PR '+ nameSuf;
                                                   
                            assRep.Name = stdCA.Project__r.DLS_Ref__c + ' ' + stdName + ' ' + languageName + nameSuf;
                            
                            if(Assessment_Report_Helper.isFromDCAT && Assessment_Report_Helper.projIdAndLPROrder.containsKey(assRep.Project__c) && assRep.Language_Training_Status__c == 'Progress'){
                                String arName = assRep.Name;
                                assRep.Name = arName + ' ' + Assessment_Report_Helper.projIdAndLPROrder.get(assRep.Project__c);
                            }
                        }else if(assRepRTName == 'Test_Report'){
                            
                            if(assRep.Test_Report_Type__c == 'Initial'){
                                nameSuf = 'Test Initial';
                            }
                            if(assRep.Test_Report_Type__c == 'Final'){
                                nameSuf = 'Test Final';
                            }
                            if(assRep.Test_Report_Type__c == 'Progress'){
                                nameSuf = 'Test Progress';
                            }
                            
                            String tempTestReportName = '';
                            tempTestReportName = (nameSuf == 'Test Progress' ? (' ' + nameSuf+ ' '+ reportDateStr + ' ' + stdCA.Project__r.DLS_Ref__c) : (' ' + nameSuf+ ' '+ stdCA.Project__r.DLS_Ref__c));
                            
                            assRep.Name = stdName + ' ' + languageName + tempTestReportName;
                            
                        }else if(assRepRTName == 'DLI_W_Test_Report'){
                        
                            nameSuf = ' - Assessment by Instructor - ';  
                            assRep.Name = stdName  + nameSuf  + languageName + ' ' + reportDateStr + '-' + stdCA.Project__r.TO__c;   
                        }else if(assRepRTName == 'DLI_W_Self_Assessment_Test_Report'){
                        
                            nameSuf = ' - Self-Assessment - ';    
                            assRep.Name = stdName  + nameSuf  + languageName + ' ' + reportDateStr + '-' + stdCA.Project__r.TO__c;
                        }else if(assRepRTName == 'APMO_Progress'){
                        
                            assRep.Name = stdName + '_APMO Monthly Student Report_' + reportDateStr;
                        }else if(assRepRTName == 'DEA_Progress'){
                        
                            assRep.Name = stdName + '_DEA Monthly Student Report_' + reportDateStr;
                        }else if(assRepRTName == 'Language_Training_Progress' && assRep.Language_Training_Status__c == 'Monthly'){
                            
                            assRep.Name = stdCA.Project__r.DLS_Ref__c + ' ' + stdName + ' Monthly Student Report_' + reportDateStr;
                        }else{
                            // Added DLS Class No on Dec 01 2023 : W-007937 - Training Report Auto-Creation & Rollup Helper Issue on DODA (ILP) Projects
                            // To prevent duplicate report name formation 
                            assRep.Name = stdName + (assRep.Report_Type__c == 'DLI'? ' DLI' : '') + ' Monthly Student Report_' + reportDateStr;
                        }
                    }
                }
                if(assRep.Student__c == null && assRep.Instructor__c != null){
                    
                    Contact_Assignments__c insCA = projIdInsIdAndCARec.containsKey(assRep.Project__c+'-'+assRep.Instructor__c) ? projIdInsIdAndCARec.get(assRep.Project__c+'-'+assRep.Instructor__c) : null;
                    
                    if(insCA != null){
                    
                        if(assRepRTName == 'Observation_Report'){
                        
                            assRep.Name = insCA.Project__r.Name + '-' + insCA.Candidate_Name__r.Name + '-' + reportDateStr;
                        }else if(assRepRTName == 'DLI_Observation_Report'){
                        
                            // Added on Nov 29 2023 : W-007938 - Remove the Instructors Name from the Observation Training Report Name - DLI Only
                            assRep.Name = insCA.Project__r.Name + '-' + reportDateStr;
                        }
                    }
                }
                System.debug(':::assRep.Name::::'+assRep.Name+':::::assRep.RecordTypeId:::::'+assRep.RecordTypeId);
            }
        }
    }
    
    public static void updateAnnualReportsName(Set<Id> insIds, List<Assessment_Report__c> annualReports){
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, FirstName, LastName FROM Contact WHERE Id IN : insIds]);
        
        for(Assessment_Report__c ar : annualReports){
            
            Contact con = contactMap.get(ar.Instructor__c);
            String insName = (String.isNotBlank(con.FirstName) && String.isNotBlank(con.LastName)) ? (con.FirstName + ' ' + con.LastName) : con.LastName;
            ar.Name = 'Instructor Annual Review – ' + insName + '_' + ar.Report_Date__c.year();
        }
    }
    
    /**********
        - Added on Nov 16 2023
        - W-007921 : Update to Observation Report and Annual Review Process (NOV-17-2023)
        - To update contact's Observation_Completed_This_Year__c and Annual_Review_Completed_This_Year__c fields when Observation Report or Annual Review Report is completed
        ************/
    public static void updateObservationAndAnnualCompletedFlag(List<Assessment_Report__c> completedReports, Set<Id> insIds){
        
        if(!completedReports.isEmpty()){
            
            Map<Id, Contact> updateContacts = new Map<Id, Contact>();
            
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id,Observation_Completed_This_Year__c,Annual_Review_Completed_This_Year__c FROM Contact WHERE Id IN : insIds AND (Observation_Completed_This_Year__c = false OR Annual_Review_Completed_This_Year__c = false)]);
            
            for(Assessment_Report__c ar : completedReports){
            
                if(contactMap.containsKey(ar.Instructor__c)){
                    
                    Contact oldConRec = contactMap.get(ar.Instructor__c);
                    
                    Contact con = new Contact();
                    con.Id = ar.Instructor__c;
                    
                    if((ar.RecordType_Name__c == 'Observation_Report' || ar.RecordType_Name__c == 'DLI_Observation_Report') && !oldConRec.Observation_Completed_This_Year__c){
                        con.Observation_Completed_This_Year__c = true;
                        updateContacts.put(con.Id, con);
                    }
                    
                    if((ar.RecordType_Name__c == 'Annual_Instructor_Performance_Review' || ar.RecordType_Name__c == 'Observation_Report') && !oldConRec.Annual_Review_Completed_This_Year__c){
                        con.Annual_Review_Completed_This_Year__c = true;
                        updateContacts.put(con.Id, con);
                    }
                }
            }       
            System.debug(':::updateContacts:::'+updateContacts);
            
            if(!updateContacts.isEmpty()){
                update updateContacts.values();
            }             
        }
    }
}