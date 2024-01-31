public class DLI_Attendance_Ctrl{
    
    //public Account acc;
    public Id acctId {get; set;}
    public DLI_Attendance_Ctrl(ApexPages.StandardController controller) {
        //acc = new Account();
        Account acc = (Account)controller.getRecord();
        
        acctId = acc.Id;
        system.debug('::acctId::'+acctId);
    }
    
    @RemoteAction
    public static List<String> picklistvalues(String ObjectName, String PickListName){
        List<String> pickListvalues = StudentTestResult_ReportPage_Controller.PicklistValues(ObjectName, PickListName);
        return pickListvalues;  
    }
    
    @RemoteAction
    public static List<AttendanceWrapper> getStudentsBasedonFloors(String accId,String floor,String selDate){
        Map<String,Set<Id>> roomProIdMap = new Map<String,Set<Id>>();
        Map<Id,List<Contact_Assignments__c>> proConAssMap = new Map<Id,List<Contact_Assignments__c>>();
        Set<Id> proIds = new Set<Id>();
        Date currentdate = system.Today();
        Date seDate = Date.ValueOf(selDate);
        List<Schedule__c> schList = [SELECT Id,Name,Room__c,Room__r.Name,Room__r.Floor_Suite__c,Room__r.Floor_Suite__r.Floor__c,Project__c FROM Schedule__c WHERE Status__c = 'Active' AND Project__r.AcctSeed__Account__c = :accId AND Start_Date__c <= :seDate AND End_Date__c >= :seDate AND Room__r.Floor_Suite__r.Floor__c = :floor];
        System.debug('::schList:::'+schList);
        for(Schedule__c s : schList){
            proIds.add(s.Project__c);
            if(!roomProIdMap.containskey(s.Room__r.Name)){
                roomProIdMap.put(s.Room__r.Name,new Set<Id>()); 
            } 
            roomProIdMap.get(s.Room__r.Name).add(s.Project__c);
        }
        List<Contact_Assignments__c> conAssigns = [SELECT Id,Name,Candidate_Name__c,Candidate_Name__r.Name,Project__c,Project__r.Language__c,Project__r.Language__r.Name,Project__r.Name FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Project__c IN :proIds];
        for(Contact_Assignments__c c : conAssigns){
            if(!proConAssMap.containskey(c.Project__c)){
                proConAssMap.put(c.Project__c,new List<Contact_Assignments__c>()); 
            } 
            proConAssMap.get(c.Project__c).add(c);
        }
        system.debug(':::ca::'+conAssigns.size());
        List<AttendanceWrapper> attenWrap = new List<AttendanceWrapper>();
        for(String roomName : roomProIdMap.keySet()){
            Integer i=0;
            for(Id proId : roomProIdMap.get(roomName)){
                if(proConAssMap.containskey(proId)){
                    for(Contact_Assignments__c con : proConAssMap.get(proId)){ 
                        AttendanceWrapper att = new AttendanceWrapper();

                        i++;
                        att.roomName = roomName;
                        att.contactName = con.Candidate_Name__r.Name;
                        att.language = con.Project__r.Language__r.Name;
                        if(i == 1){
                            att.groupStart = true;
                        } else {
                            att.groupStart = false;
                        }
                        attenWrap.add(att);
                    }
                }    
            }
            
        }
        return attenWrap;
    }
    
    public class AttendanceWrapper{
        public String roomName;
        public String contactName;
        public String language;
        public String timeIn;
        public String timeOut;
        public String initials;
        public String notes;
        public Boolean groupStart;
        public Boolean groupEnd;
    }
}