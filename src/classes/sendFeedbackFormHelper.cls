public with sharing class sendFeedbackFormHelper {
    
    public static Boolean triggerExecution = true;
    public static Date monthlyFeedbackSentDate;
    public static Set<Id> duplicateEndedId = new Set<Id>();
    public static Set<Id> duplicateEndedInsId = new Set<Id>();
    
    public static void sendEmail(Set<Id> proIds, List<AcctSeed__Project__c> proList) { // to send Email for Weekly Feedback form
        System.debug(':::proIds111:::' + proIds);
        List<Messaging.SingleEmailMessage> sendEmailListForWeekly = new List<Messaging.SingleEmailMessage>();
        
        if(proIds != null && proIds.size() > 0) {
                        
            try {
                String res = checkForBouncedEmail(proIds);
                if( res != '' && !Test.isRunningTest()) {                   
                    if(proList != null && proList.size() > 0) {                         
                        proList[0].addError('The following Email address is currently marked as bounced: '+res);                             
                    }
                } else {
                    sendEmailAndUpdConAss(proIds,'weeklyGetfeedbackEmailTemplate', 'Weekly');
                }
                
            } catch(EmailException e) {
                System.debug(':::Exception Part for sendEmailListForWeekly:::');
            }
        }
    }
    
    public static void sendEmailForCompleted(Set<Id> proIds, List<AcctSeed__Project__c> proList) { 
        
        System.debug(':::proIds:::' + proIds + '\n:::proList:::' + proList);
                
        if(proIds != null && proIds.size() > 0) {           
            try {
                String res = checkForBouncedEmail(proIds);
                System.debug('res::::::'+res);
                if(res != '' && !Test.isRunningTest()) {
                    if(proList != null && proList.size() > 0) { 
                        proList[0].addError('The following Email address is currently marked as bounced: '+ res ); 
                    }
                } else {
                    sendEmailAndUpdConAssFtr(proIds,'CourseEndGetfeedback', true);
                }
            } catch(EmailException e) {               
                System.debug(':::Exception Part for sendEmailList:::'+e);                            
            } 
        }
    }
    /*
    * Created to Send Monthly Email to Students by Karthiga on 17 May 2017
    * 1) Send on 1st Business Day of each month (never on a Saturday, Sunday, or Federal Holiday)
    * 2) If a Two-Week survey has been sent out within the last 14 days, do not send the Monthly Feedback Survey
    * 3) Do not send a Monthly Feedback Survey if the End Date is scheduled in that month
    * @proIds - set of Project Id
    */
    
    public static void sendMonthlyEmail(Set<Id> proIds, List<AcctSeed__Project__c> proList) { // to send Email for Monthly Feedback form
        System.debug(':::proIds111:::' + proIds);
        List<Messaging.SingleEmailMessage> sendEmailListForWeekly = new List<Messaging.SingleEmailMessage>();
        Set<Id> filtProSet = new Set<Id>(); // Filtered Project ID Sets 
        if(proIds != null && proIds.size() > 0) {
                        
            try {
                Date wFSDate = system.today().addDays(-14); // If a Two-Week survey has been sent out within the last 14 days, do not send the Monthly Feedback Survey
                System.debug('wFSDate ::::'+wFSDate);
                
                // Query is modified to handle when the Weekly_Getfeedback_sent__c is null. It is handled based on the Project Start date
                // for(Contact_Assignments__c ca : [SELECT Id,Name,Weekly_Getfeedback_sent__c,Project__c FROM Contact_Assignments__c WHERE Project__c IN: proIds AND Weekly_Getfeedback_sent__c <: wFSDate AND RecordType.DeveloperName = 'Student']) {
               
                for(Contact_Assignments__c ca : [SELECT Id,Name,Candidate_Name__r.Email, Weekly_Getfeedback_sent__c,Project__c FROM Contact_Assignments__c WHERE Project__c IN: proIds AND RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.Recordtype.DeveloperName != 'Testing_Projects' AND (Weekly_Getfeedback_sent__c <: wFSDate OR (Weekly_Getfeedback_sent__c = Null AND Project__r.Start_Date__c < :wFSDate.addDays(-14)))]) {
                    filtProSet.add(ca.Project__c);
                }
                
                if( filtProSet != null && filtProSet.size() > 0 ) {
                    String res = checkForBouncedEmail(filtProSet);
                    if( res != '' && !Test.isRunningTest()) {                   
                        if(proList != null && proList.size() > 0 && Trigger.isExecuting) { 
                            proList[0].addError('The following Email address is currently marked as bounced: '+res);                             
                        } else if(!Trigger.isExecuting){
                            List<Messaging.SingleEmailMessage> ErrorMailMsg = new List<Messaging.SingleEmailMessage>();
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                            mail.setToAddresses(new String[] {'abellas@dlsdc.com'});
                         //   mail.setToAddresses(new List<String> {'keerthika@softsquare.biz'/*'karthiga@softsquare.biz'*/});
                            mail.setSubject('Bounched Email Address'); 
                            mail.setPlainTextBody('The following Email address is currently marked as bounced: '+res);
                            ErrorMailMsg.add(mail);
                            if( ErrorMailMsg != null && ErrorMailMsg.size() > 0 ){
                                Messaging.sendEmail(ErrorMailMsg); 
                            }
                            sendEmailAndUpdConAss(filtProSet, 'MonthlyGetfeedbackEmailTemplate', 'Monthly');
                        }
                    } else {
                        sendEmailAndUpdConAss(filtProSet, 'MonthlyGetfeedbackEmailTemplate', 'Monthly');
                    }
                }
                
            } catch(EmailException e) {
                System.debug(':::Exception Part for sendEmailListForMonthly:::'+e);
            }
        }
    }
    
    /*
    * Created to check whether the Contacts Email in Project Contact Assignment is bounced or not
    * @proId - set of Project Id
    */
    public static String checkForBouncedEmail(Set<Id> proId) {
        List<Contact_Assignments__c> conAssignment = new List<Contact_Assignments__c>();
        String emailStr = '';
            
        for(Contact_Assignments__c con : [SELECT Id,Name,Candidate_Name__c,Candidate_Name__r.Email,Candidate_Name__r.IsEmailBounced,Email__c,Project__c FROM Contact_Assignments__c WHERE Project__c IN :proId AND RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName != 'Testing_Projects']) {
            if(con.Email__c != null) {
                if(con.Candidate_Name__r.IsEmailBounced) { 
                    if(emailStr == '') {
                        emailStr = con.Candidate_Name__r.Email;
                    } else {
                        emailStr += ','+con.Candidate_Name__r.Email;
                    }
                } 
            }
        }
        return emailStr;
    }
    
    @future // To call this only when it called from Trigger and for Course Completion Feedback
    public static void sendEmailAndUpdConAssFtr(Set<Id> proId, String emailTempName, Boolean isComplete) {
        // To send the Course End Feedback only on the first status change.
        /*Set<Id> proIds = new Set<Id>(proId);
        System.debug('before proIds size:::'+proIds.size());
        for( AcctSeed__Project__History ph : [SELECT Id,OldValue,NewValue,parentId,Field FROM AcctSeed__Project__History where parentId IN :proId and Field ='AcctSeed__Status__c']) {
            if(ph.NewValue == 'Ended') {
                proIds.remove(ph.parentId);
            }
        }*/
        System.debug('after proId size:::'+proId.size());
        sendEmailAndUpdConAss(proId,'CourseEndGetfeedback', 'Completed');
    }
    
    /*
    * Created method to send Notification about the student who will receive mail for GetFeedback
    * @dt - a Date value from Weekly or Monthly Sch
    * @opt - 'Weekly' || 'Monthly' 
    * @holSet - Set of dates from Holiday Object
    */
    public static void sendNotificationEmailCheck(Date dt, String opt) {
        Boolean sendNoti = false;
        Map<Id,List<Contact_Assignments__c>> proIdCAs = new Map<Id,List<Contact_Assignments__c>>();
        Set<Date> weeklyDatSet = new set<Date>();
        Integer sub = -13;
        Set<String> workingDays = new Set<String>{'Monday','Tuesday','Wednesday','Thursday','Friday'};
        String msg;
        Date dtToNotify;
        String dateToSendMail; // Next mail send date - to display the date on Notification Mail
        Date nextMailSend = System.Today().addDays(1);  // date on which next weekly mail send
        Date dt0 = dt;
        Set<Date> holSet = new Set<Date>(); // Holiday Set
        
        /*for (Holiday h : [SELECT Id, Name, ActivityDate FROM Holiday WHERE ActivityDate = THIS_YEAR]) {
            holSet.add(h.ActivityDate);
        }*/
        
        //Recurrence method call to get correct holiday dates for these date interval
        // Modified by NS on Jan 07 2019
        holSet = HolidayService.getHolidaysWithRecurrence(Date.newInstance(system.today().year(),01,01),Date.newInstance(system.today().year(),12,31));
        
        if(opt == 'Monthly') {

            Date dt1 = monthlySendDate(dt.addDays(-1), -1); // to find last working day of month
            
            if(dt1 != Null && dt1 == System.today()) {
                dtToNotify = dt1;  // date on which notification email will send
                sendNoti = true;
            }
            
            dt0 = monthlySendDate(dt0, 1); // to find first working day of month
            monthlyFeedbackSentDate = dt0;

            dateToSendMail = dt0.month()+'/'+dt0.day()+'/'+dt0.year();
            system.debug(':dt0::'+dt0);
            
        } else if (opt == 'Weekly') {
            
            //dt = dt.addDays(-1); Commented since it is not correct by GRK (4/4/2018)
            while( !holSet.contains(dt) ) {  // to form weeklyDateSet to query students to receive feedback form
                DateTime dtTim1 = DateTime.newInstance(dt, Time.newInstance(0, 0, 0, 0)); 
                String dayOfWeek = dtTim1.format('EEEE');
                if(dayOfWeek != 'Saturday' && dayOfWeek != 'Sunday') {
                    sendNoti = true;
                    dtToNotify = dt;  // date on which notification email will send
                    weeklyDatSet.add(dt.addDays(sub));
                    dt = dt.addDays(1);
                    DateTime dtTim = DateTime.newInstance(dt, Time.newInstance(0, 0, 0, 0)); 
                    String dow = dtTim.format('EEEE');
                    system.debug('dtt:::'+dt+'::Day:'+dow);
                    while( !workingDays.contains(dow) && !holSet.contains(dt)) {
                        weeklyDatSet.add(dt.addDays(sub));
                        dt = dt.addDays(1);
                        dtTim = DateTime.newInstance(dt, Time.newInstance(0, 0, 0, 0)); 
                        dow = dtTim.format('EEEE');
                    }
                    if(holSet.contains(dt)) {
                        weeklyDatSet.add(dt.addDays(sub));
                    }
                    
                    break;
                }
                break;
            }
            
            nextMailSend = monthlySendDate(nextMailSend, 1);  // to find the next Working day     
            dateToSendMail = nextMailSend.month()+'/'+nextMailSend.day()+'/'+nextMailSend.year();
        }
        
        if(sendNoti && opt == 'Monthly') {
            Date wFSDate = dt0.addDays(-14);
            
            // Query is modified to handle when the Weekly_Getfeedback_sent__c is null. It is handled based on the Project Start date
            // for(AcctSeed__Project__c pro :[SELECT Id,Name,Start_Date__c,End_Date__c,(SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Candidate_Name__r.Email, Candidate_Name__r.IsEmailBounced,Email__c, Do_not_send_feedback_One_time__c, Project__c, Project__r.Name, Project__r.Start_Date__c, Project__r.End_Date__c FROM Contact_Assignments__r WHERE RecordType.DeveloperName = 'Student' AND Weekly_Getfeedback_sent__c <: wFSDate) FROM AcctSeed__Project__c WHERE End_Date__c != NEXT_MONTH AND ( AcctSeed__Status__c = 'Active') AND End_Date__c >= NEXT_MONTH AND Start_Date__c <= NEXT_MONTH]) {
            for(AcctSeed__Project__c pro :[SELECT Id,Name,Start_Date__c,End_Date__c,(SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Candidate_Name__r.Email, Candidate_Name__r.IsEmailBounced, Candidate_Name__r.Opt_Out_From_All_Surveys_Forever__c, Opt_Out_From_All_Surveys_for_This_Projec__c, Opt_Out_for_Weekly_Survey__c, Opt_Out_Monthly_Survey_Date__c, Email__c, Do_not_send_feedback_One_time__c, Project__c, Project__r.Name, Project__r.Start_Date__c, Project__r.End_Date__c FROM Contact_Assignments__r WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName != 'Testing_Projects' AND (Weekly_Getfeedback_sent__c <: wFSDate OR (Weekly_Getfeedback_sent__c = Null AND Project__r.Start_Date__c < :wFSDate.addDays(-14)))) FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active' AND End_Date__c > NEXT_MONTH AND Start_Date__c <= NEXT_MONTH]) {
                if( pro.Contact_Assignments__r != null && pro.Contact_Assignments__r.size() > 0 ){
                    if(!proIdCAs.containskey(pro.Id)){
                        proIdCAs.put(pro.Id, new List<Contact_Assignments__c>{});
                    }
                    proIdCAs.get(pro.Id).addAll(pro.Contact_Assignments__r);
                }   
            }
            msg = 'How is your language training going? - 1 Month';
            
        } else if(sendNoti && opt == 'Weekly') {
            for(AcctSeed__Project__c pro :[SELECT Id,Name,Start_Date__c,End_Date__c,(SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Candidate_Name__r.Email, Candidate_Name__r.IsEmailBounced, Candidate_Name__r.Opt_Out_From_All_Surveys_Forever__c, Opt_Out_From_All_Surveys_for_This_Projec__c, Opt_Out_for_Weekly_Survey__c, Opt_Out_Monthly_Survey_Date__c, Email__c, Do_not_send_feedback_One_time__c, Project__c, Project__r.Name, Project__r.Start_Date__c, Project__r.End_Date__c FROM Contact_Assignments__r WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active') FROM AcctSeed__Project__c WHERE Start_Date__c IN : weeklyDatSet AND RecordType.DeveloperName != 'Testing_Projects']) {
                if( pro.Contact_Assignments__r != null && pro.Contact_Assignments__r.size() > 0 ) {
                   if(!proIdCAs.containskey(pro.Id)){
                        proIdCAs.put(pro.Id, new List<Contact_Assignments__c>{});
                    }
                    proIdCAs.get(pro.Id).addAll(pro.Contact_Assignments__r);
                }   
            }
            msg = 'Tell us how we are doing so far! - 2 Week';
        }
        if( proIdCAs != null && proIdCAs.size() > 0 ) {
            SendNotification(proIdCAs,msg,opt,dtToNotify,dateToSendMail);
        }
    }
    
    /*
    * Created method to avoid recursive error while sending getFeedBack Form
    * from trigger side handling to future method call
    * @proId - set of Project Id
    * @emailTempName - Developer Name of the Email Template 
    * @range - 'Weekly' || 'Completed' || 'Monthly'
    */
    public static void sendEmailAndUpdConAss(Set<Id> proId, String emailTempName, String range) {
        System.debug(':::proIds:::' + proId);
        
        List<Contact_Assignments__c> conAssignRecs = getConAssignRecs(proId, range, System.Today());
        
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
        
        if(proId != null && proId.size() > 0) {
        
            List<Contact_Assignments__c> conAssignment = new List<Contact_Assignments__c>();
            Set<String> emailTemplateNames = new Set<String>();
            Map<String, Id> emailTemplateNameAndId = new Map<String, Id>();
            List<OrgWideEmailAddress> orgWideAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'surveys@dlsdc.com'];
            
            emailTemplateNames.add(emailTempName);
            // Work Item: W-007410 - Update Instructor EOT Survey Email #2
            // For instructor EOT survey email need different subject
            if(range == 'Completed'){
                emailTemplateNames.add('CourseEndGetfeedback_To_Instructor');
            }            
            
            for(EmailTemplate et : [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName IN : emailTemplateNames]){
                emailTemplateNameAndId.put(et.DeveloperName, et.Id); 
            }            
            
            try {
                if( emailTemplateNameAndId.size() > 0 && conAssignRecs != NULL && conAssignRecs.size() > 0) {
                    
                    for(Contact_Assignments__c con : conAssignRecs) {
                    
                        if(con.Email__c != null && !con.Candidate_Name__r.IsEmailBounced) {                                                       
                            
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            
                            if ( orgWideAddress.size() > 0 ) {
                                mail.setOrgWideEmailAddressId(orgWideAddress.get(0).Id);
                            }
                            
                            //mail.setToAddresses(new List<String> { con.Email__c }); 
                            //mail.setToAddresses(new List<String> {'karthiga@softsquare.biz'});
                            
                            mail.setWhatId(con.Project__c);
                            mail.setTargetObjectId(con.Candidate_Name__c); 
                            if(con.RecordType.DeveloperName == 'Student'){
                                mail.setTemplateId(emailTemplateNameAndId.get(emailTempName));
                            }else if(con.RecordType.DeveloperName == 'Instructor'){
                               mail.setTemplateId(emailTemplateNameAndId.get('CourseEndGetfeedback_To_Instructor'));
                            }
                            
                            sendEmailList.add(mail);
                            
                            if(range == 'Completed') {
                                con.Close_Getfeedback_sent__c = System.today();
                                con.Iscoursecompletefeedsend__c = true;
                                conAssignment.add(con);
                            } else if(range == 'Weekly') {
                                con.Weekly_Getfeedback_sent__c = System.today();
                                con.Isfeedbacksent__c = true;
                                conAssignment.add(con);
                            }
                        }
                    }
                }
                System.debug(':::conAssignment222:::' + conAssignment);
                System.debug(':::sendEmailList222:::' + sendEmailList);
                if(conAssignment.size() > 0) { 
                    update conAssignment; 
                }
                if(sendEmailList.size() > 0) { 
                    Messaging.sendEmail(sendEmailList); 
                }
                if(range == 'Monthly') {
                    System_Values__c mDt = System_Values__c.getValues('Send FeedBack Monthly');// Monthly Email Date
                    if(mDt != null){
                        mDt.Value__c = String.ValueOf(System.today());
                        update mDt;
                    }
                }
            } catch(EmailException e) {
                
                System.debug(':::Exception Part for sendEmailList:::'+e);                               
            }
        }
    }
    
    public static void SendNotification(Map<Id,List<Contact_Assignments__c>> proIdCA, String msg, String feedbackType, Date dateToNotify, String mailSendDate) {
         System_Values__c sysValues = new System_Values__c();
         String excluded = '';
         
         if( proIdCA != null && proIdCA.size() > 0 ) {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            String mailContent = '<html>Dear Molly,<br/><br/>The following Students will get email for \"' + msg + '\" GetFeedback on '+mailSendDate+', 08.00AM. You can exclude the students before '+mailSendDate+', 6.00AM :'; 
            mailContent += '<br/><table border="1" style="border-collapse: collapse"><thead><th>Project Name</th><th>Student Name</th><th>Email</th><th>Start Date</th><th>End Date</th><th>Excluded</th></thead><tbody>';    
            String orgUrl = URL.getSalesforceBaseUrl().toExternalForm();
                       
            for(Id oId: proIdCA.keyset()) {
                for(Contact_Assignments__c ca : proIdCA.get(oId)) {
                    
                    if(feedbackType == 'Weekly'){ 
                        if(ca.Candidate_Name__r.Opt_Out_From_All_Surveys_Forever__c == true || ca.Opt_Out_From_All_Surveys_for_This_Projec__c == true || ca.Opt_Out_for_Weekly_Survey__c == true) {
                            excluded = 'checked';
                        } else {
                            excluded = '';
                        }
                    } else if (feedbackType == 'Monthly') { 
                        //System.debug('ca.Candidate_Name__r.Opt_Out_From_All_Surveys_Forever__c:::'+ca.Candidate_Name__r.Opt_Out_From_All_Surveys_Forever__c);
                        //System.debug('ca.Opt_Out_From_All_Surveys_for_This_Projec__c::::'+ca.Opt_Out_From_All_Surveys_for_This_Projec__c);
                        //System.debug('ca.Opt_Out_Monthly_Survey_Date__c:::::'+ca.Opt_Out_Monthly_Survey_Date__c);
                        //System.debug('monthlyFeedbackSentDate:::::'+monthlyFeedbackSentDate);
                        if(ca.Candidate_Name__r.Opt_Out_From_All_Surveys_Forever__c == true || ca.Opt_Out_From_All_Surveys_for_This_Projec__c == true || ca.Opt_Out_Monthly_Survey_Date__c >= monthlyFeedbackSentDate) {
                            excluded = 'checked';
                        } else {
                            excluded = '';
                        }
                    }
                    System.debug('excluded::::'+excluded);
                    /*if(feedbackType == 'Weekly'){ 
                        sysValues = ( sysValuesMap.containskey('TwoWeeksFeedback') ? sysValuesMap.get('TwoWeeksFeedback') : null);
                        if(sysValues != null && ca.Do_not_send_feedback_One_time__c == sysValues.Name+'/'+String.ValueOf(ca.Project__r.Start_Date__c.addDays(14))) {
                            excluded = 'checked';
                        } else {
                            excluded = '';
                        }
                    } else if (feedbackType == 'Monthly') { 
                        sysValues = ( sysValuesMap.containskey('MonthlyFeedback') ? sysValuesMap.get('MonthlyFeedback') : null);
                        if(sysValues != null && ca.Do_not_send_feedback_One_time__c == sysValues.Name+'/'+String.ValueOf(monthlyFeedbackSentDate)) {
                            excluded = 'checked';
                        } else {
                            excluded = '';
                        }
                    }*/
                    
                    List<String> stDatelist = String.ValueOf(ca.Project__r.Start_Date__c).split('-');
                    String stDate = stDatelist[1]+'/'+stDatelist[2]+'/'+stDatelist[0];
                    
                    List<String> endDatelist = String.ValueOf(ca.Project__r.End_Date__c).split('-');
                    String endDate = endDatelist[1]+'/'+endDatelist[2]+'/'+endDatelist[0];
                    
                    if(ca.Project__r.Start_Date__c == null) { stDate = '';}
                    if(ca.Project__r.End_Date__c == null) { endDate = '';}
                        
                    mailContent += '<tr><td width="15%"><a href="'+orgUrl+'/'+oId+'">'+((ca.Project__r.Name != null) ? ca.Project__r.Name : '')+'</a></td><td width="15%"><a href="'+orgUrl+'/'+ca.Candidate_Name__c+'">'+((ca.Candidate_Name__r.Name != null) ? ca.Candidate_Name__r.Name: '')+'</a></td><td width="15%">'+((ca.Email__c != null) ? ca.Email__c : '') +'</td><td width="15%">'+stDate+'</td><td width="15%">'+endDate+'</td><td width="15%"><input disabled name="checkbox" type="checkbox" '+excluded+'/></td></tr>'; 
                }
            }
            mailContent += '</tbody></table><br/><p>This e-mail was auto generated. Please do not respond.</p><p>If you have questions, contact your Salesforce Administrator.</p>';
            mailContent += '</html>';
            mailContent += '<br/><a target="_blank" href="'+orgUrl+'/apex/notSendFeedback?FeedbackType='+feedbackType+'%20Date='+dateToNotify+'">Click here to View or Edit Students for GetFeedback </a>';

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();      
            System_Values__c sysVal = System_Values__c.getValues('GetFeedBack Notification Email');            
            if (sysVal != null && sysVal.Value__c != null) {
                for (String st : sysVal.Value__c.split(',')) {
                    sendTo.add(st);
                }
            }
            System.debug('sendTo:::::'+sendTo);
            mail.setToAddresses(sendTo);
            //mail.setToAddresses(new List<String> {'karthiga@softsquare.biz'});
            mail.setSubject('Students notified for \"'+msg+'\" GetFeedback '+ mailSendDate);
            mail.sethtmlBody(mailContent);
            mails.add(mail);
            system.debug('mails::::size'+mails.size());
            //System.debug('mails::::'+mails);
            System.debug('mailContent :::::'+mailContent);
            if( mails != null && mails.size() > 0 && !Test.isRunningTest()) {
                Messaging.sendEmail(mails);
            }
        }
    }
    
    // To fiind the first/last working day
    public static date monthlySendDate(Date dt0, integer i) {
    
        Set<Date> holSet = new Set<Date>(); // Holiday Set
        /*for (Holiday h : [SELECT Id, Name, ActivityDate FROM Holiday WHERE ActivityDate = THIS_YEAR]) {
            holSet.add(h.ActivityDate);
        }*/
        
        //Recurrence method call to get correct holiday dates for these date interval
        // Modified by NS on Jan 07 2019
        holSet = HolidayService.getHolidaysWithRecurrence(Date.newInstance(system.today().year(),01,01),Date.newInstance(system.today().year(),12,31));
        
        while(holSet.contains(dt0) ) { // to find day is an holiday
            dt0 = dt0.addDays(i);
        }
        
        while( !holSet.contains(dt0) ) {  // If the next/previous day is not an holiday, check if it falls on Sat/ Sun

            DateTime dtTim1 = DateTime.newInstance(dt0, Time.newInstance(0, 0, 0, 0)); 
            String dayOfWeek = dtTim1.format('EEEE');
            if(dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday') {  // If Yes then add 1/-1 day to it and check for the next/previous working Day
                dt0 = dt0.addDays(i);
            } else { // If No the loop breaks
                break;
            }
            if(holSet.contains(dt0)) {
                dt0 = dt0.addDays(i);
            }
        }   
        return dt0;
    }
    
    //Added by HL on Jan 23 2020
    // W-004562 : Urgent: Exclude from sending GetFeedback Survey
    public static List<Contact_Assignments__c> getConAssignRecs(Set<Id> proId, String range, Date mailSendingDate) {
    
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>();
        
        if(proId != NULL && proId.size() > 0 && String.isNotBlank(range)){
        
            String qryStr = 'SELECT Id,Name,Candidate_Name__c,Candidate_Name__r.Email,Candidate_Name__r.IsEmailBounced,';
            qryStr += ' Email__c,Project__c,Project__r.Start_Date__c, RecordType.DeveloperName';
            qryStr += ' FROM Contact_Assignments__c';
            //Added by HL on Feb 15 2022 - Work Item: W-007337 - Send Getfeedback Survey to Instructors when the Project is Ended - ACCET (MAR-1-2022)
            //Send Course completed email to Instructors also
            if(range == 'Completed'){
                qryStr += ' WHERE Project__c IN :proId AND RecordType.DeveloperName IN (\'Student\',\'Instructor\') AND Project__r.RecordType.DeveloperName != \'Testing_Projects\' AND Assignment_Position__c != \'Tester\''; 
            }else{
                qryStr += ' WHERE Project__c IN :proId AND RecordType.DeveloperName = \'Student\' AND Project__r.RecordType.DeveloperName != \'Testing_Projects\''; 
            }   
            qryStr += ' AND Candidate_Name__r.Opt_Out_From_All_Surveys_Forever__c = FALSE AND Opt_Out_From_All_Surveys_for_This_Projec__c = FALSE';
            
            if(range == 'Completed'){
                qryStr += ' AND Status__c = \'Ended\' AND Iscoursecompletefeedsend__c = FALSE AND Close_Getfeedback_sent__c = null';
            }else {
                qryStr += ' AND Status__c = \'Active\'';
            }
                        
            if(range == 'Weekly') {
                qryStr += ' AND Opt_Out_for_Weekly_Survey__c = FALSE';
            } else if(range == 'Monthly' && mailSendingDate != NULL) {
                qryStr += ' AND ((Opt_Out_Monthly_Survey_Date__c != NULL AND Opt_Out_Monthly_Survey_Date__c < :mailSendingDate) OR Opt_Out_Monthly_Survey_Date__c = NULL)';
            }
            
            conAssignRecs = Database.query(qryStr);
        }
        
        return conAssignRecs;
    }    
    
    /***********
        - Modified on May 10 2023
        - W-007788 - Changes to Instructor GetFeedback Survey
        - Instructor GetFeedback survey email will send when the Contact Assignment is Ended
        ************/   
    public static void sendInstructorCompletedFeedback(List<Contact_Assignments__c> conAssigns, Set<Id> conIds, String emailTempName, String range){        
        
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
        
        if(conAssigns.size() > 0) {
        
            try {
                List<OrgWideEmailAddress> orgWideAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'surveys@dlsdc.com'];
                EmailTemplate template = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName = : emailTempName];
                
                Map<Id, Contact> conIdRec = new Map<Id, Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :conIds AND Email != null]);
                List<Contact_Assignments__c> updateCAs = new List<Contact_Assignments__c>();
                
                String mailContent = '';
                Boolean hasBouncedEmail = FALSE;
                
                for(Contact_Assignments__c ca : conAssigns){
                
                    if(conIdRec.containsKey(ca.Candidate_Name__c)){
                    
                        if(!conIdRec.get(ca.Candidate_Name__c).IsEmailBounced){ 
                                                       
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            
                            if (orgWideAddress.size() > 0){
                                mail.setOrgWideEmailAddressId(orgWideAddress.get(0).Id);
                            }
                            
                            mail.setWhatId(ca.Project__c);
                            mail.setTargetObjectId(ca.Candidate_Name__c); 
                            mail.setTemplateId(template.Id);
                            
                            sendEmailList.add(mail);
                            
                            if(range == 'Completed') {
                                // To fix "System.FinalException: Record is read-only"
                                Contact_Assignments__c updateCARec = new Contact_Assignments__c();
                                updateCARec.Id = ca.Id;
                                updateCARec.Close_Getfeedback_sent__c = System.Today();
                                updateCARec.Iscoursecompletefeedsend__c = True;
                                updateCAs.add(updateCARec);
                            }
                        }else{
                                
                            mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdRec.get(ca.Candidate_Name__c).Id+'" target="_blank">'+conIdRec.get(ca.Candidate_Name__c).Name+'</a><br/>';
                            hasBouncedEmail = TRUE;
                        }
                    }
                }
                if(hasBouncedEmail || Test.isRunningTest()){
                    
                    Messaging.SingleEmailMessage bouncedmail = ErrorHandler.getBouncedEmail(mailContent);
                    sendEmailList.add(bouncedmail);
                }
                if(sendEmailList.size() > 0){ 
                    Messaging.sendEmail(sendEmailList); 
                }
                if(updateCAs.size() > 0){ 
                    update updateCAs; 
                }
            } catch(EmailException e){
                
                String errorMessage = '';
                errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Sending Instructor Completed Get Feedback Email');
            }
        }
    }
}