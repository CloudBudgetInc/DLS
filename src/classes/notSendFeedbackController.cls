/* Developed by Shalini on June 5 2017 to allow user to select students who don't need to receive Feedback form. This is refered in "notSendFeedback" page*/

public class notSendFeedbackController{
    
    public static Set<Date> weeklydatesToNeglect = new Set<Date>(); // to store dates which are in past 
    public static Date reviewdt;
    public static Date mailSendDate;
    
    @RemoteAction
    public static studentInfo getStudents(String feedbackType, String datetobesent){ // @datetobesent - Date of Notification email sent 
        system.debug('::feedbackType::'+feedbackType);
        system.debug('::datetobesent::'+datetobesent);
        System_Values__c sysValues = new System_Values__c();
        Map<Id,List<Contact_Assignments__c>> proIdCAs = new Map<Id,List<Contact_Assignments__c>>();
        Map<String,List<Contact_Assignments__c>> dateCAs = new Map<String,List<Contact_Assignments__c>>();
        Map<String, String> userIdNameMap = new Map<String, String>();
        String feedbackformlink;
        String sendReportLink;
        Date dt0;
        
        List<Contact_Assignments__c> caList = new List<Contact_Assignments__c>();
        Set<Date> holSet = new Set<Date>(); // Holiday Set
        
        /*for (Holiday h : [SELECT Id, Name, ActivityDate FROM Holiday WHERE ActivityDate = THIS_YEAR]) {
            holSet.add(h.ActivityDate);
        }*/
        //Recurrence method call to get correct holiday dates for these date interval
        // Modified by NS on Jan 07 2019
        holSet = HolidayService.getHolidaysWithRecurrence(Date.newInstance(system.today().year(),01,01),Date.newInstance(system.today().year(),12,31));
        
        // User Id and Name are Stored on the Map 
        userIdNameMap.put(null, '');
        for(User ur : [SELECT Id, Name FROM User]) {
            userIdNameMap.put(ur.Id, ur.Name);
        }
      
        proIdCAs = getStudentsToSendEmail(Date.ValueOf(datetobesent),feedbackType,holSet); // Map for Total Students List to receive Feedback form.
        
        if(proIdCAs.size() > 0) {
            if(feedbackType == '2 Week') {  // Map formation of Date of WeeklyFeedback form and Students list 
               
                sysValues = System_Values__c.getValues('TwoWeeksFeedback');
                //[SELECT Id,Name,Value__c FROM System_Values__c WHERE Name='TwoWeeksFeedback'];
                feedbackformlink = (sysValues != null && sysValues.Value__c != null)? sysValues.Value__c : ''; 
                
                if(System_Values__c.getValues('Weekly Sent Report Link') != null) {
                    sendReportLink = System_Values__c.getValues('Weekly Sent Report Link').Value__c;
                }
    
                for(Id oId: proIdCAs.keyset()) {
                    for(Contact_Assignments__c ca : proIdCAs.get(oId)) {
                        caList.add(ca);
                        if(!dateCAs.containskey(ca.Project__r.Project_Manager__c)) {
                            dateCAs.put(ca.Project__r.Project_Manager__c, new List<Contact_Assignments__c>());
                        }
                        dateCAs.get(ca.Project__r.Project_Manager__c).add(ca);
                    }
                }
            } else if (feedbackType == 'Monthly') { // Map formation of Date of MonthlyFeedback form and Students list 
                sysValues = System_Values__c.getValues('MonthlyFeedback');
                //[SELECT Id,Name,Value__c FROM System_Values__c WHERE Name='MonthlyFeedback'];
                feedbackformlink = sysValues != null ? sysValues.Value__c : ''; 
                
                if(System_Values__c.getValues('Monthly Sent Report Link') != Null) {
                    sendReportLink = System_Values__c.getValues('Monthly Sent Report Link').Value__c;
                }
                
                // To get the next month start date based on the selected date
                dt0 = Date.ValueOf(datetobesent).addMonths(1).toStartOfMonth(); 
                
                for(Id oId: proIdCAs.keyset()) {
                    for(Contact_Assignments__c ca : proIdCAs.get(oId)) {
                        caList.add(ca);
                          
                        // To dispaly the Records based on Project Manager
                        
                        if(!dateCAs.containskey(ca.Project__r.Project_Manager__c)){
                            dateCAs.put(ca.Project__r.Project_Manager__c, new List<Contact_Assignments__c>());
                        }
                        dateCAs.get(ca.Project__r.Project_Manager__c).add(ca); 
                    }
                }
            }
        }
        List<String> expdts = new List<String>();
        String dtex, dtDay, dtMonth;
       
        // To allow the admin to edit the student list to send feedback until 6.00 AM
        
        DateTime curDtandTime = System.now();
        Boolean displaymsg = false;
        Date curDt = System.today();
                       
        if(curDtandTime.hour() >= 6 && curDtandTime.minute() >= 0 && curDt == mailSendDate) {
            displaymsg = true;
        } else if(feedbackType == 'Monthly' && Date.valueOf(System_Values__c.getValues('Send FeedBack Monthly').Value__c) > mailSendDate) {
            displaymsg = true;
        } else if(feedbackType == '2 Week' && curDt > mailSendDate) {
            displaymsg = true;
        }
        System.debug('displaymsg :::::'+displaymsg);
        // Changed the date format from YYYY-MM-DD to MM/DD/YY
        
        if(displaymsg == true && weeklydatesToNeglect != Null && weeklydatesToNeglect.size() > 0) {
            for(Date dt : weeklydatesToNeglect){
                
                if(dt.day() < 10) {
                    dtDay = '0'+String.valueOf(dt.day());
                } else {
                    dtDay = String.valueOf(dt.day());
                }
                if(dt.Month() < 10) {
                    dtMonth = '0'+String.valueOf(dt.month());
                } else {
                    dtMonth = String.valueOf(dt.month());
                }
                
                dtex = dtMonth+'/'+dtDay+'/'+String.valueOf(dt.year()).right(2); //Date.valueOf(String.valueOf(dt.year())+'-'+dtMonth+'-'+dtDay)                
                expdts.add(dtex);  
            }
        }
        
        studentInfo stu = new studentInfo();
        stu.userMap = userIdNameMap;
        stu.expiryDates = expdts;
        stu.reviewdate = reviewdt;
        stu.dateWithCAs = dateCAs;
        stu.feedbacklink = feedbackformlink;
        stu.sndReportLink = sendReportLink;
        stu.nextMonthMailSendDate = mailSendDate;//dt0;
        stu.feedbackNameWithLink = sysValues;
        return stu;
    }
    
    @RemoteAction
    //public static String updateCAs(List<Contact_Assignments__c> conAssign, List<Contact> contacts){ 
    public static String updateCAs(String conAssign, String contacts){
        String retStr;
        try{
            List<Contact> cons = (List<Contact>) JSON.deserialize(contacts, List<Contact>.class);
            if(cons.size() > 0) {
                System.debug('cons:::'+cons);
                update cons;
            }
            List<Contact_Assignments__c> conAssignList = (List<Contact_Assignments__c>) JSON.deserialize(conAssign, List<Contact_Assignments__c>.class);
            if(conAssignList.size() > 0) {
                ContactAssignmentService.updateContactAssignments(conAssignList);
            }
            retStr = 'Success';
            System.debug('conAssign:::'+conAssign);
        } Catch(Exception ex) {
            System.debug('Exception::::'+ex);
            retStr = 'Failed';
        }
        return retStr;  // to update "Do_not_send_feedback_One_time__c" of rejected students
    }
    
    public static Map<Id,List<Contact_Assignments__c>> getStudentsToSendEmail(Date dt, String opt, Set<Date> holSet) {
        // To find the next month last date based on the selected date 
        Date nextMonthEnDate = dt.addMonths(2).toStartOfMonth().addDays(-1);
                
        Boolean sendNoti = false;
        Map<Id,List<Contact_Assignments__c>> proIdCAs = new Map<Id,List<Contact_Assignments__c>>();
        Set<Date> weeklyDatSet = new set<Date>();
        Set<Date> dateExpired = new Set<Date>();
        Integer sub = -13;
        Set<String> workingDays = new Set<String>{'Monday','Tuesday','Wednesday','Thursday','Friday'};
        String msg;
        Date dt0;
        
        DateTime curDtandTime = System.now();
        Boolean displaymsg = false;
        Date curDt = System.today();
        
        
        if(opt == 'Monthly') {
            
            dt0 = dt.addMonths(1).toStartOfMonth();
            Date dt1 = dt0.addDays(-1);            
            reviewdt = sendFeedbackFormHelper.monthlySendDate(dt1, -1); //to find last working day of month
            dt0 = sendFeedbackFormHelper.monthlySendDate(dt0, 1); //to find first working day of month
            
            mailSendDate = dt0; 
           
            // To check whether the Feedback emails are sent for the selected date
            System_Values__c sfmDate = System_Values__c.getValues('Send FeedBack Monthly');
            if(sfmDate != null && sfmDate.Value__c != null && Date.valueOf(sfmDate.Value__c) >= dt0) {
                weeklydatesToNeglect.add(dt0);
            }

            if(system.today() < dt0) {    // to check notification email reviewed date is less than Monthly feedback form sent date
                system.debug(':dt::'+dt);
                sendNoti = true;
            }

        } else if (opt == '2 Week') {  
        
            mailSendDate = dt.addDays(1);            
            mailSendDate = sendFeedbackFormHelper.monthlySendDate(mailSendDate, 1); // to find next working day
            dt = sendFeedbackFormHelper.monthlySendDate(dt, -1);  // to prepopulate previous working day of selected holiday
            System.debug('weeklyDatSet::::'+weeklyDatSet);  
            if(curDtandTime.hour() >= 6 && curDtandTime.minute() >= 0 && curDt == mailSendDate) {
                displaymsg = true;
            } else if(opt  == '2 Week' && curDt > mailSendDate) {
                displaymsg = true;
            }          
            reviewdt = dt;            
            while( !holSet.contains(dt) ) {  // to form weeklydate set
                DateTime dtTim1 = DateTime.newInstance(dt, Time.newInstance(0, 0, 0, 0)); 
                String dayOfWeek = dtTim1.format('EEEE');
                if(dayOfWeek != 'Saturday' && dayOfWeek != 'Sunday') {
                    sendNoti = true;
                    if(system.today() >= dt.addDays(1) ){
                        weeklydatesToNeglect.add(dt.addDays(1));
                        if(displaymsg == true) {
                            dateExpired.add(dt.addDays(sub));
                        }
                    }
                    weeklyDatSet.add(dt.addDays(sub));
                    dt = dt.addDays(1);
                    DateTime dtTim = DateTime.newInstance(dt, Time.newInstance(0, 0, 0, 0)); 
                    String dow = dtTim.format('EEEE');
                    while( !workingDays.contains(dow) && !holSet.contains(dt)) {
                        if(system.today() >= dt.addDays(1)){
                            weeklydatesToNeglect.add(dt.addDays(1));
                            if(displaymsg == true) {
                                dateExpired.add(dt.addDays(sub));
                            }
                        }                        
                        weeklyDatSet.add(dt.addDays(sub));
                        dt = dt.addDays(1);
                        dtTim = DateTime.newInstance(dt, Time.newInstance(0, 0, 0, 0)); 
                        dow = dtTim.format('EEEE');
                    }
                    if(holSet.contains(dt)) {
                        if(system.today() >= dt.addDays(1)) {
                            weeklydatesToNeglect.add(dt.addDays(1));
                            if(displaymsg == true) {
                                dateExpired.add(dt.addDays(sub));
                            }
                        }
                        weeklyDatSet.add(dt.addDays(sub));
                    }
                    break;
                }
                break;
            }
            System.debug('weeklyDatSet::::'+weeklyDatSet);
            System.debug('dateExpired::::'+dateExpired);
        }
        if(sendNoti && opt == 'Monthly') { // to get students list for receiving Monthly feedback form
                       
            Date wFSDate = dt0.addDays(-14);
            
            // If the Weekly_Getfeedback_sent__c field of Con Ass is null then the related record is not Queried but now it is changed to query the records based on the project start date when the Weekly_Getfeedback_sent__c is null
            //for(AcctSeed__Project__c pro :[SELECT Id,Name,Start_Date__c,End_Date__c,Project_Manager__c,(SELECT Id, Name, Do_not_send_feedback_One_time__c, Project__r.Project_Manager__c, Candidate_Name__c, Candidate_Name__r.Name, Candidate_Name__r.Email, Candidate_Name__r.IsEmailBounced,Email__c, Project__c, Project__r.Name,Project__r.Start_Date__c, Project__r.End_Date__c FROM Contact_Assignments__r WHERE RecordType.DeveloperName = 'Student' AND Weekly_Getfeedback_sent__c <: wFSDate) FROM AcctSeed__Project__c WHERE End_Date__c != NEXT_MONTH AND ( Acctseed__Status__c = 'Active') AND End_Date__c >= NEXT_MONTH AND Start_Date__c <= NEXT_MONTH]) {
           
            for(AcctSeed__Project__c pro :[SELECT Id,Name,Start_Date__c,End_Date__c,Project_Manager__c,(SELECT Id, Name, Do_not_send_feedback_One_time__c, Project__r.Project_Manager__c, Candidate_Name__c, Candidate_Name__r.Name, Candidate_Name__r.Email, Candidate_Name__r.IsEmailBounced,Email__c, Project__c, Project__r.Name,Project__r.Start_Date__c, Project__r.End_Date__c,Opt_Out_for_Weekly_Survey__c,Opt_Out_From_All_Surveys_for_This_Projec__c,Opt_Out_Monthly_Survey_Date__c,Candidate_Name__r.Opt_Out_From_All_Surveys_Forever__c FROM Contact_Assignments__r WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.Recordtype.DeveloperName != 'Testing_Projects' AND (Weekly_Getfeedback_sent__c <: wFSDate OR (Weekly_Getfeedback_sent__c = Null AND Project__r.Start_Date__c < :wFSDate.addDays(-14)))) FROM AcctSeed__Project__c WHERE Acctseed__Status__c = 'Active' AND End_Date__c > :nextMonthEnDate AND Start_Date__c <= :nextMonthEnDate]) {
                if( pro.Contact_Assignments__r != null && pro.Contact_Assignments__r.size() > 0 ) {
                    if(!proIdCAs.containskey(pro.Id)){
                        proIdCAs.put(pro.Id, new List<Contact_Assignments__c>{});
                    }
                    proIdCAs.get(pro.Id).addAll(pro.Contact_Assignments__r);
                }   
            }
            
            msg = 'How is your language training going? - 1 Month';
        } else if(sendNoti && opt == '2 Week') { //to get students list for receiving Weekly feedback form
            for(AcctSeed__Project__c pro :[SELECT Id,Name,Start_Date__c,End_Date__c, Project_Manager__c, (SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Candidate_Name__r.Email, Project__r.Project_Manager__c, Candidate_Name__r.IsEmailBounced,Email__c, Do_not_send_feedback_One_time__c, Project__c, Project__r.Name, Project__r.Start_Date__c, Project__r.End_Date__c,Opt_Out_for_Weekly_Survey__c,Opt_Out_From_All_Surveys_for_This_Projec__c,Opt_Out_Monthly_Survey_Date__c,Candidate_Name__r.Opt_Out_From_All_Surveys_Forever__c FROM Contact_Assignments__r WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.Recordtype.DeveloperName != 'Testing_Projects') FROM AcctSeed__Project__c WHERE Start_Date__c IN : weeklyDatSet AND Start_Date__c NOT IN :dateExpired]) {
                if( pro.Contact_Assignments__r != null && pro.Contact_Assignments__r.size() > 0 ) {
                    if(!proIdCAs.containskey(pro.Id)){ 
                        proIdCAs.put(pro.Id, new List<Contact_Assignments__c>{});
                    }
                    proIdCAs.get(pro.Id).addAll(pro.Contact_Assignments__r);
                }   
            }
            msg = 'Tell us how we are doing so far! - 2 Week';
        }
        System.debug('proIdCAs:::::'+proIdCAs);
        
        return proIdCAs; 
    }
    
    public class studentInfo{
        public List<String> expiryDates;    // to store dates on which we don't need to send feedback form because that dates are in past.
        public Date reviewdate;             // to store date on which Notification email will send to staff
        public Map<String,List<Contact_Assignments__c>> dateWithCAs; // to display students list based on the dates on which they will receive feedback form
        public String feedbacklink;         // to store feedback form link from "System Values" custom setting based on feedback type
        public System_Values__c feedbackNameWithLink;
        public Date nextMonthMailSendDate; // to store the next month first working day based on the selectd date
        public Map<String,String> userMap; // Store the User Id and Name
        public String sndReportLink; // to store the link of send report
    }
}