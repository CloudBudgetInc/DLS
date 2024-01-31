public class partial_Approve_RejectEmail_Ctrl {
    
    public class InnerClass {
        
        public String DateValue {get; set;}
        public Decimal Hours {get; set;}
        public String Comments {get; set;}
    }
    
    public Id contactId;
    public Id timecardId;
    public String Name {get; set;}
    public String periodName {get;set;}
    public Map<String,List<InnerClass>> approvedTimeEntryDetailsMap {get; set;}
    public Map<String,List<InnerClass>> rejectedTimeEntryDetailsMap {get; set;}
    public Boolean showApproveTable {get; set;}
    public Boolean showRejectTable {get; set;}
    
     public String getcontactId() {
        return contactId;        
    }
    
    public void setcontactId(String t) {
        contactId = t;
        parameterCheck();      
    }
    
    public String gettimecardId() {
        return timecardId;
    }
    
    public void settimecardId(String t) {
        timecardId = t;
        parameterCheck();      
    }
    
    public void parameterCheck() {
        if(contactId != null && timecardId != null)
            populateData();
    }
    
     public void populateData() {
        approvedTimeEntryDetailsMap = new Map<String,List<InnerClass>>();
        rejectedTimeEntryDetailsMap = new Map<String,List<InnerClass>>();
        showApproveTable = false;
        showRejectTable = false;
        approvedTimeEntryDetailsMap.put('Approved',new List<InnerClass>{});
        rejectedTimeEntryDetailsMap.put('Rejected',new List<InnerClass>{});
        
        for(AcctSeed__Time_Card_Day__c dayRec : [SELECT Id,Name,Status__c,Total_Hours_Before_Approved__c,AcctSeed__Internal_Comment__c,AcctSeed__Date__c,AcctSeed__Invoice_Comment__c 
                                                    FROM AcctSeed__Time_Card_Day__c
                                                    WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = :contactId 
                                                            AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c = :timecardId 
                                                            AND  AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = 'DLS_Employee' 
                                                ]) {
                                                
            InnerClass inr = new InnerClass();
            inr.DateValue = String.valueOf(dayRec.AcctSeed__Date__c).split(' ')[0];
            inr.Hours = dayRec.Total_Hours_Before_Approved__c;
            inr.Comments = dayRec.AcctSeed__Invoice_Comment__c; //Changed AcctSeed__Internal_Comment__c to AcctSeed__Invoice_Comment__c By Dhinesh 19-10-2020
            
            if(dayRec.Status__c == 'Approved') {
                showApproveTable = true;
                if(!approvedTimeEntryDetailsMap.containsKey(dayRec.Status__c))
                    approvedTimeEntryDetailsMap.put(dayRec.Status__c,new List<InnerClass>{inr});
                else
                    approvedTimeEntryDetailsMap.get(dayRec.Status__c).add(inr);
            }else if(dayRec.Status__c == 'Rejected') {
                showRejectTable = true;
                if(!rejectedTimeEntryDetailsMap.containsKey(dayRec.Status__c))
                    rejectedTimeEntryDetailsMap.put(dayRec.Status__c,new List<InnerClass>{inr});
                else
                    rejectedTimeEntryDetailsMap.get(dayRec.Status__c).add(inr);
            }
        }
        
        system.debug(':::approvedTimeEntryDetailsMap::::::'+approvedTimeEntryDetailsMap);
        system.debug(':::rejectedTimeEntryDetailsMap::::::'+rejectedTimeEntryDetailsMap);
        
        List<Contact> conList = [SELECT Id,Name FROM Contact WHERE Id = :contactId];
        
        if(conList.size() > 0)
            Name = conList[0].Name;
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id,Name,Time_Card_Period_Week_Range__c FROM AcctSeed__Time_Card__c WHERE Id = :timecardId];
        
        if(timeCard.size() > 0)
            periodName = timeCard[0].Time_Card_Period_Week_Range__c;
        
     }
     
     public partial_Approve_RejectEmail_Ctrl() {
         
     }
}