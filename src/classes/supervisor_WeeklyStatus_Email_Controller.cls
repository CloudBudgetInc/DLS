/************************************************************************
    - Class used in Supervisor_Weekly_Status_Email_Component 
    - Used for Weekly Timesheet Status E-mail to Supervisor (Monday @ 2:00 pm ET) email sending purpose
    - WeeklyStatusEmail_schedule ---> supervisor_WeeklyStatus_Email_Batch ---> Supervisor_Weekly_Status_Summary_Mail(template) ---> Supervisor_Weekly_Status_Email_Component
*************************************************************************/

public class supervisor_WeeklyStatus_Email_Controller {
    
     public class InnerClass {
        public String  ContactName {get; set;}
        public String periodWeekRange {get; set;}
        public Decimal totalHrs {get; set;}
        public String submittedDate {get; set;}
    }
  
    public Id supervisorId;
    public Id contactId;
    public String Name {get; set;}
    public Id userIdKey {get; set;}
    public Map<String,List<InnerClass>> statusInnerRecMap {get; set;}
    public Boolean displayDAMsg {get; set;}
    public String ActualSupervisorName {get; set;}
    
    // Actual Approver details on DA approval process
    public Id actualContactId;
    
    public String getcontactId() {
        return contactId;        
    }
    
    public void setcontactId(String t) {
        contactId = t;
        populateData();      
    }
    
    public String getactualContactId(){
        return actualContactId;
    }
    
    public void setactualContactId(String td){
        actualContactId = td;
        if(td != null) {
            populateData();
        }
    }
    
     public void populateData() {
     
        statusInnerRecMap = new Map<String,List<InnerClass>>();
        
        system.debug(':::::::contactId::::::'+contactId);
        
        Id supervisorId;
        
        Date myDate = date.today();
        Date weekstdate = myDate.toStartofWeek()+1;
        Date weekenddate = myDate.toStartofWeek()+7;
        
        Date Laststdate = weekstdate.addDays(-7);
        Date Lastenddate = weekenddate.addDays(-7);
        
        system.debug(':::::myDate:::::'+myDate);
        system.debug(':::::weekstdate:::::'+weekstdate);
        system.debug(':::::weekenddate:::::'+weekenddate);
        
        system.debug(':::::Laststdate:::::'+Laststdate);
        system.debug(':::::Lastenddate:::::'+Lastenddate);
        
        statusInnerRecMap.put('Submitted',new List<InnerClass>{});
        statusInnerRecMap.put('Approved',new List<InnerClass>{});
        statusInnerRecMap.put('Rejected',new List<InnerClass>{});
        statusInnerRecMap.put('Pending Submission',new List<InnerClass>{});
        
        Id supervisorConId;
        
        if(actualContactId != null) {
            supervisorConId = actualContactId;
            displayDAMsg = true;
        } else {
            supervisorConId = contactId;
            displayDAMsg = false;
        }
        
        //Qry contact related user
        
        List<Contact> contactList = [SELECT Id,Name,FirstName,MiddleName,LastName FROM  Contact WHERE Id = :supervisorConId];
        List<Contact> DAContact = new List<Contact>();
        if(actualContactId != null) {
            DAContact = [SELECT Id,Name FROM Contact WHERE Id = :contactId];
        }
        
        system.debug(':::::::contactList::::'+contactList);
        system.debug(':::::::DAContact::::'+DAContact);
        if(actualContactId != null &&  DAContact.size() > 0) {
            Name =  DAContact[0].Name; 
        }
        
        if(contactList.size() > 0) {
            if(actualContactId == null){
                Name = contactList[0].Name;
            }else {
                ActualSupervisorName = contactList[0].Name;
            }
               
           List<User> usrList = [SELECT Id,Name FROM User WHERE FirstName = :contactList[0].FirstName AND MiddleName = :contactList[0].MiddleName AND LastName = : contactList[0].LastName]; 
           
           if(usrList.size() > 0)
               supervisorId = usrList[0].Id;
            
            for(AcctSeed__Time_Card__c cardRec : [SELECT Id,Name,Intructor__c,Intructor__r.Name,
                                                        Intructor__r.Supervisor_Name__c,AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c,AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c,
                                                        of_Approved_Hours__c,of_Rejected_Hours__c,of_Submitted_Hours__c,Submitted_Date__c,of_Pending_Time_Logs__c
                                                    FROM AcctSeed__Time_Card__c  
                                                    WHERE Intructor__r.Supervisor_Name__c = :supervisorId AND Intructor__r.RecordType.DeveloperName = 'DLS_Employee' 
                                                            AND AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c = :Laststdate 
                                                            AND AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c = :Lastenddate
                                                    ]) {
                                                    
                system.debug(':cardRec::cardRec:::cardRec'+cardRec);
                Date stDate = cardRec.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c;
                Date endDate = cardRec.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c;
                
                DateTime st = datetime.newInstance(stDate.year(), stDate.month(),stDate.day());
                DateTime ed = datetime.newInstance(endDate.year(), endDate.month(),endDate.day());
                
                DateTime subDate;
                
                if(cardRec.Submitted_Date__c != null){
                    Date submittedDt = cardRec.Submitted_Date__c;
                    
                    subDate = datetime.newInstance(submittedDt.year(),submittedDt.month(),submittedDt.day());
                }
                
                String weekrange = st.format('MM/dd/yy')+' - '+ed.format('MM/dd/yy');
                
                // Submitted records details
                if(statusInnerRecMap.containsKey('Submitted')) {
                
                    InnerClass inr = new InnerClass();
                    
                    if(cardRec.of_Submitted_Hours__c > 0) {
                        inr.ContactName = cardRec.Intructor__r.Name;
                        inr.periodWeekRange = weekrange;
                        inr.totalHrs = cardRec.of_Submitted_Hours__c;
                        if(subDate != null)
                            inr.submittedDate = subDate.format('MM/dd/yy');
                        
                        statusInnerRecMap.get('Submitted').add(inr);
                    }
                    
                }
                
                //Approved records details
                if(statusInnerRecMap.containsKey('Approved')) {
                    InnerClass inr = new InnerClass();
                    
                    if(cardRec.of_Approved_Hours__c > 0) {
                        inr.ContactName = cardRec.Intructor__r.Name;
                        inr.periodWeekRange = weekrange;
                        inr.totalHrs = cardRec.of_Approved_Hours__c;
                        if(subDate != null)
                            inr.submittedDate = subDate.format('MM/dd/yy');
                        
                        statusInnerRecMap.get('Approved').add(inr);
                    }
                    
                }
                
                //Rejected records details
                if(statusInnerRecMap.containsKey('Rejected')) {
                    InnerClass inr = new InnerClass();
                    
                    if(cardRec.of_Rejected_Hours__c > 0) {
                        inr.ContactName = cardRec.Intructor__r.Name;
                        inr.periodWeekRange = weekrange;
                        inr.totalHrs = cardRec.of_Rejected_Hours__c;
                        if(subDate != null)
                            inr.submittedDate = subDate.format('MM/dd/yy');
                        
                        statusInnerRecMap.get('Rejected').add(inr);
                    }
                    
                }
                
                // Added By HL on Sep 30 2020
                // Work Item : W-005866 - "Supervisor Weekly Status Summary Mail" email not sending
                // Pending Submission records details
                if(statusInnerRecMap.containsKey('Pending Submission')) {
                    InnerClass inr = new InnerClass();
                    
                    if(cardRec.of_Pending_Time_Logs__c > 0) {
                        inr.ContactName = cardRec.Intructor__r.Name;
                        inr.periodWeekRange = weekrange;
                        inr.totalHrs = cardRec.of_Pending_Time_Logs__c;
                        if(subDate != null)
                            inr.submittedDate = subDate.format('MM/dd/yy');
                        
                        statusInnerRecMap.get('Pending Submission').add(inr);
                    }
                }
            }
            
            system.debug('::::::statusInnerRecMap:::::'+statusInnerRecMap);            
            system.debug(':::::::Name::::'+Name);
        }
       
     }
     
     public supervisor_WeeklyStatus_Email_Controller() {
     
     }
}