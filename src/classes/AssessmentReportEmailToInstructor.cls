/**********
    - Created By HL on Jul 15 2020
    - Work Item : W-005524 - Progress Reports in DLS Online
    - To send an email notification to the Instructors to review the Assessment Reports before 7 days of Its Report_Date__c
    - This class is invoked from "Assessment Report Instructor Email Notification" flow
    - Dynamic HTML Email template
    *********/

public class AssessmentReportEmailToInstructor{

    // This method is called from flow, so annotated with @InvocableMethod
    @InvocableMethod
    public static void sendAnEmailInstructor(){
    
        // Send an email before 7 days of Report Date
        Date reportDate = Date.Today()+7;
        
        Date projStartDate = Date.Today();
                
        List<Assessment_Report__c> reports = [SELECT Id, Name, Project__c, Project__r.DLS_Ref__c, Project_Manager__r.Name, Instructor__c,
                                                    Student__r.Name, Report_Date__c, Report_Type__c, Evaluation_Period_From__c, 
                                                    Evaluation_Period_To__c, RecordType_Name__c, Test_Report_Type__c, Tester__c, Account_Name__c
                                                FROM Assessment_Report__c 
                                                WHERE Status__c = 'Scheduled' AND ((RecordType_Name__c != 'Test_Report' AND Instructor__c != NULL) OR 
                                                    (RecordType_Name__c = 'Test_Report' AND Tester__c != NULL) OR (RecordType_Name__c = 'DLI_W_Self_Assessment_Test_Report' AND Student__c != NULL)) AND 
                                                    ((Report_Date__c = :reportDate AND (RecordType_Name__c IN ('DLI_W_Progress', 'DLI_W_Progress_2022', 'DLI_W_Test_Report', 'DLI_W_Self_Assessment_Test_Report', 'Language_Training_Progress', 'APMO_Progress', 'DEA_Progress') OR 
                                                    (RecordType_Name__c = 'Test_Report' AND Test_Report_Type__c IN ('Progress','Final')))) OR
                                                    (Project__r.Start_Date__c = :projStartDate AND RecordType_Name__c = 'Test_Report' AND 
                                                    Test_Report_Type__c = 'Initial'))];        
        if(reports.size() > 0){
            
            List<Assessment_Report__c> trainingReports = new List<Assessment_Report__c>();
            
            for(Assessment_Report__c ar : reports){
                
                if(ar.RecordType_Name__c != 'Test_Report' || (ar.RecordType_Name__c == 'Test_Report' && ar.Account_Name__c != null && !ar.Account_Name__c.contains('PGLS'))){
                    
                    trainingReports.add(ar);
                }
            }
            sendAnEmailToInstructor_Tester(trainingReports, reportDate);
        }
    }
    
    public static void sendAnEmailToInstructor_Tester(List<Assessment_Report__c> reports, Date reportDate){
        
        if(reports != NULL && reports.size() > 0){
        
            Map<Id, String> insIdAndDLSClassNos = new Map<Id, String>();
            Map<Id, List<Assessment_Report__c>> insIdAndAssRepRecs = new Map<Id, List<Assessment_Report__c>>();
            Map<Id, String> conIdAndCommunitySitePrefix = new Map<Id, String>();
            
            for(Assessment_Report__c ar : reports){
            
                String dlsClassNos = '';
                
                Id insId;
                
                if(ar.RecordType_Name__c != 'DLI_W_Self_Assessment_Test_Report'){
                    insId = ar.RecordType_Name__c != 'Test_Report' ? ar.Instructor__c : ar.Tester__c;
                    conIdAndCommunitySitePrefix.put(insId, 'Instructor');
                }else{
                
                    // Added on Mar 25 2024 : W-008014 - Request to Send Email Notification to Students When DLI Self Assessment Report Status = Scheduled
                    // To send an email notification to the students to complete their DLI W Self Assessment Test Report(s) before 7 days of Its Report_Date__c
                    insId = ar.Student__c;
                    conIdAndCommunitySitePrefix.put(insId, 'Student');
                }
                
                // Map to store all related DLS Class # for instructors
                if(!insIdAndDLSClassNos.containsKey(insId)){
                    
                    dlsClassNos = ar.Project__r.DLS_Ref__c;
                    insIdAndDLSClassNos.put(insId, dlsClassNos);
                }else{    // if the instructor has more than one project's Assessment Report, need to include its DLS Class # by comma separated
                    
                    dlsClassNos = insIdAndDLSClassNos.get(insId);
                    if(!dlsClassNos.contains(ar.Project__r.DLS_Ref__c)){    // if one project has more than one Assessment Report under single Instructor, need to ignore its DLS Class # instead of showing at multiple times
                        dlsClassNos += ', '+ ar.Project__r.DLS_Ref__c;
                    }
                    insIdAndDLSClassNos.put(insId, dlsClassNos);
                }
                
                // Map to store all related Assessment Reports for instructors
                if(!insIdAndAssRepRecs.containsKey(insId)){
                
                    insIdAndAssRepRecs.put(insId, new List<Assessment_Report__c>());
                }
                insIdAndAssRepRecs.get(insId).add(ar);
            }
            
            if(insIdAndAssRepRecs.size() > 0){
            
                Map<Id, Contact> conIdRec = new Map<Id, Contact>([SELECT Id, FirstName, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :insIdAndAssRepRecs.keySet() AND Email != NULL]);
                
                List<Messaging.SingleEmailMessage> sendEmailToInstructors = new List<Messaging.SingleEmailMessage>();
                
                String mailContent = '<html>Hi Chris and April <br/>The following contacts have bounced email ids, Please correct them: <br/>';
                Boolean hasBouncedEmail = FALSE;
                    
                try{
                    
                   String orgWideEmailId = ProjectTrigger_Handler.getOrgWideEmailId('support@dlsdc.com');
                
                    // One email (consolidated email) per instructor for all the Assessment Reports he/she is related to
                    for(Id insId : insIdAndAssRepRecs.keySet()){
                    
                        if(conIdRec.containsKey(insId)){
                        
                            if(!conIdRec.get(insId).IsEmailBounced){
                                
                                String dlsClassNos = '';
                                if(insIdAndDLSClassNos.containsKey(insId)){
                                    dlsClassNos = insIdAndDLSClassNos.get(insId);
                                }
                                String dueDate = String.valueOf(reportDate);
                                String dueDateStr = dueDate.split('-')[1]+'/'+dueDate.split('-')[2]+'/'+dueDate.split('-')[0];
                                
                                String communitySitePrefix = '';
                                if(conIdAndCommunitySitePrefix.containsKey(insId)){
                                    
                                    communitySitePrefix = conIdAndCommunitySitePrefix.get(insId) == 'Instructor' ? System.Label.Instructor_Community_Site_Prefix : System.Label.Student_Community_Site_Prefix;
                                }
                                                
                                String htmlBody = '';
                                htmlBody += 'Dear '+ conIdRec.get(insId).FirstName + ', <br/><br/>';
                                htmlBody += 'Please complete the following Training Report for Class # ' + dlsClassNos + ' which is due on '+dueDateStr+'.<br/>';
                                htmlBody += '<br/><br/><table border="1" style="border-collapse: collapse"><tr><th width="15%" style="text-align: center; vertical-align: middle;">Student Name</th><th width="15%" style="text-align: center; vertical-align: middle;">DLS class #</th><th width="15%" style="text-align: center; vertical-align: middle;">Report Date</th><th width="15%" style="text-align: center; vertical-align: middle;">Report Type</th><th width="15%" style="text-align: center; vertical-align: middle;">Evaluation Period From</th><th width="15%" style="text-align: center; vertical-align: middle;">Evaluation Period To</th></tr>';
                                    
                                for(Assessment_Report__c ar : insIdAndAssRepRecs.get(insId)){
                                
                                    String repDate = String.valueOf(ar.Report_Date__c);
                                    String repDateStr = repDate.split('-')[1]+'/'+repDate.split('-')[2]+'/'+repDate.split('-')[0];
                                    
                                    String evaPeriodFrom = '';
                                    String evaPeriodFromStr = '';
                                    
                                    String evaPeriodTo = '';
                                    String evaPeriodToStr = '';

                                    String assRepDetPageLink = '<a href="'+ communitySitePrefix +'/s/assessment-report/'+ ar.Id +'/'+ ar.Name+'" target="_blank">'+ ar.Student__r.Name +'</a>';
                                    
                                    String reportType = '';
                                    if(ar.RecordType_Name__c != 'Test_Report'){
                                    
                                        reportType = (ar.Report_Type__c != null ? ar.Report_Type__c : '');
                                        
                                        if(ar.Evaluation_Period_From__c != null){
                                            evaPeriodFrom = String.valueOf(ar.Evaluation_Period_From__c);
                                            evaPeriodFromStr = evaPeriodFrom.split('-')[1]+'/'+evaPeriodFrom.split('-')[2]+'/'+evaPeriodFrom.split('-')[0];
                                        }
                                        if(ar.Evaluation_Period_To__c != null){
                                            evaPeriodTo = String.valueOf(ar.Evaluation_Period_To__c);
                                            evaPeriodToStr = evaPeriodTo.split('-')[1]+'/'+evaPeriodTo.split('-')[2]+'/'+evaPeriodTo.split('-')[0];
                                        }
                                    }else{
                                        reportType = (ar.Test_Report_Type__c != null ? ar.Test_Report_Type__c : '');
                                        evaPeriodFromStr = 'N/A';
                                        evaPeriodToStr = 'N/A';
                                    }
                                    htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + assRepDetPageLink + '</td><td style="text-align: center; vertical-align: middle;">' + ar.Project__r.DLS_Ref__c + '</td><td style="text-align: center; vertical-align: middle;">' + repDateStr + '</td><td style="text-align: center; vertical-align: middle;">' + reportType + '</td><td style="text-align: center; vertical-align: middle;">' + evaPeriodFromStr + '</td><td style="text-align: center; vertical-align: middle;">' + evaPeriodToStr + '</td></tr>';    
                                }
                                htmlBody += '</table><br/>';
                                
                                String urlLink = '<a href="'+ communitySitePrefix +'/s/reports'+ '" target="_blank"> Click Here </a>';
                                htmlBody += '<br/>Please '+ urlLink +' to view the Training Reports.';
                                htmlBody += '<br/><br/>Thanks,<br/>DLS Team';
                                
                                String subjectStr = 'Complete DLS Training Report for Class # '+dlsClassNos;
                                
                                Messaging.SingleEmailMessage mail = ProjectTrigger_Handler.getSingleEmail(orgWideEmailId, String.valueOf(insId), new List<String>(), new List<String>(), '', '', htmlBody, subjectStr, true, true);
                                sendEmailToInstructors.add(mail);
                            }else{
                            
                                mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdRec.get(insId).Id+'" target="_blank">'+conIdRec.get(insId).Name+'</a><br/>';
                                hasBouncedEmail = TRUE;
                            }
                        }
                    }
                    mailContent += '<br/><p>This e-mail was auto generated. Please do not respond.</p>';
                    mailContent += '</html>';    
                    
                    if(hasBouncedEmail || Test.isRunningTest()){
                    
                        // Custom setting to hold the exception recipients email ids
                        List<String> toAddresses = ProjectTrigger_Handler.getSystemValuesList('Contact Bounced Exception Email Ids');
                        Messaging.SingleEmailMessage bouncedmail = ProjectTrigger_Handler.getSingleEmail('', '', toAddresses, new List<String>(), '', '', mailContent, 'Bounced email contact information', false, false);
                        
                        sendEmailToInstructors.add(bouncedmail);
                    }
            
                    if(sendEmailToInstructors.size() > 0){
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailToInstructors);
                    }
                }catch(Exception e){
                    
                    String errorMessage = '';
                    errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                    ErrorHandler errHandler = new ErrorHandler(); 
                    errHandler.sendExceptionEmail(errorMessage,System.Label.TimeCardDayEmail,'Error on Training Report Email To Instructor');
                } 
            }
        }
    }
}