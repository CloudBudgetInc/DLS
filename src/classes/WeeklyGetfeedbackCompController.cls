public class WeeklyGetfeedbackCompController {
    
    public String proId;
    public String conId;
    public AcctSeed__Project__c pro { get; set; }
    public Contact con { get; set; }
    public Contact_Assignments__c conAssign { get; set; }
    
    public String getproId() { return proId; }
    
    public void setproId(String pro) {
        proId = pro;
        populateData();
    }
    public String getconId() { return conId; }
    public void setconId(String con) {
        conId = con;
        populateData();
    }
    
    public void populateData() {
        //oppId = '006P0000005yDVe';
        //conId = '003P000000nI3qH';
        pro = new AcctSeed__Project__c();
        con = new Contact();
        conAssign = new Contact_Assignments__c();
        if((proId <> null && (proId.length() == 15 || proId.length() == 18)) && (conId <> null && (conId.length() == 15 || conId.length() == 18))) {
            //List<Opportunity> oppList = [SELECT Id,Student_Name_ID__c,Student_Name__c,Student_Name__r.Name,Supervisor__c,Name,InstructorName__c FROM Opportunity WHERE Id =:oppId];
            List<AcctSeed__Project__c> proList = [SELECT Id,Name,Project_Manager__c,AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE Id = :proId]; // Added to use Project instead of Opportunity
            if(proList.size() > 0){
                pro = proList[0];
            }
            List<Contact_Assignments__c> conAss = [SELECT Id,Name,Candidate_Name__c,Candidate_Name__r.Name,Email__c,Opportunity_Name__c,Project__c, RecordType.DeveloperName, Project__r.DLS_Class__c, Project__r.Students__c FROM Contact_Assignments__c WHERE Project__c =:proId AND Candidate_Name__c =:conId];
            if(conAss.size() > 0) {
                conAssign = conAss[0];
            }
        }
    }
}