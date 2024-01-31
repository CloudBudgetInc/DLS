Public Class New_Class_Announcement_Project_Comp_Ctrl{

    Public String proId { get; set; }
    
    Public New_Class_Announcement_Project_Comp_Ctrl() {
    System.debug('proId::::'+proId);
        
    }
    public class project_New_Class_Announce{
        public String studName {get; set;}
        public String insName {get; set;}
        public String acctName {get; set;}
        public String langName {get; set;}
        public String locName {get; set;}
        public Date sDate {get; set;}
        public Date eDate {get; set;}
        public String days1 {get; set;}
        public String sTime1 {get; set;}
        public String etime1 {get; set;}
        public String days2 {get; set;}
        public String sTime2 {get; set;}
        public String etime2 {get; set;}
        public String hrsPerWeek {get; set;}
        public String ctryMap {get; set;}
        public String notes {get; set;}
        public Decimal matBudget {get; set;}
        public String recURL {get; set;}
        public List<Schedule__c> schs{get; set;}
        
    }   
    public project_New_Class_Announce getProj() {
        System.debug('proId::::'+proId);  
        List<AcctSeed__Project__c> projs = new List<AcctSeed__Project__c>();
        project_New_Class_Announce pro = new project_New_Class_Announce();
        if(proId != null) {
            pro.recURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + proId ;
            List<Contact_Assignments__c> caList = [
                                                    SELECT Id, Name, Project__c, RecordTypeId, RecordType.DeveloperName, Candidate_Name__c, Candidate_Name__r.Name 
                                                    FROM Contact_Assignments__c 
                                                    WHERE Project__c =:proId AND (Status__c = 'Active' OR Status__c = 'Planned') AND (RecordType.Developername = 'Instructor' OR RecordType.Developername = 'Student')
                                                  ];
            String InstructorName = '',StudentName = '';
            for(Contact_Assignments__c ca : calist){
                if(ca.RecordType.Developername == 'Instructor'){
                    if(InstructorName != ''){
                        InstructorName +=','+ca.Candidate_Name__r.Name;
                    }else{
                        InstructorName = ca.Candidate_Name__r.Name;
                    }
                }
                if(ca.RecordType.Developername == 'Student'){
                    if(StudentName != ''){
                        StudentName +=','+ca.Candidate_Name__r.Name;
                    }else{
                        StudentName = ca.Candidate_Name__r.Name;
                    }
                }
            }
            
            for(AcctSeed__Project__c pr : [SELECT AcctSeed__Account__c, AcctSeed__Account__r.Name, Id, Name, Start_Date__c, End_Date__c, DLS_Class__c, Language__c, Language__r.Name, Students__c, Instructors__c 
                        ,Training_Location__c, Training_Location__r.Name, Notes__c, Hours_Week__c,Country_Map__c,Material_budget_Budgeted__c, (SELECT Id, Name, Start_Time__c, End_Time__c, Days__c FROM Schedules__r WHERE Project_Task__r.Name != 'Language Training- Preparation')
                        FROM AcctSeed__Project__c 
                            WHERE Id =: proId
                   ]) {
                   pro.studName = StudentName;
                   pro.insName = InstructorName;
                   pro.acctName = pr.AcctSeed__Account__c != null ? pr.AcctSeed__Account__r.Name : '';
                   pro.langName = pr.Language__c != null ? pr.Language__r.Name : '';
                   pro.locName = pr.Training_Location__c != null ? pr.Training_Location__r.Name : '';
                   pro.sDate = pr.Start_Date__c;
                   pro.eDate = pr.End_Date__c;
                   pro.hrsPerWeek = String.ValueOF(pr.Hours_Week__c);
                   pro.notes = pr.Notes__c;
                   pro.ctryMap = pr.Country_Map__c;
                   pro.matBudget = pr.Material_budget_Budgeted__c;
                   if(pr.Schedules__r != null) {
                       pro.schs = pr.Schedules__r;
                       if(pr.Schedules__r.Size() > 1) {
                           pro.sTime2 = pr.Schedules__r[1].Start_Time__c;
                           pro.eTime2 = pr.Schedules__r[1].End_Time__c;
                           pro.days2 = pr.Schedules__r[1].Days__c;
                       } 
                       if(pr.Schedules__r.Size() > 0) {
                           pro.sTime1 = pr.Schedules__r[0].Start_Time__c;
                           pro.eTime1 = pr.Schedules__r[0].End_Time__c;
                           pro.days1 = pr.Schedules__r[0].Days__c;
                       }
                   }
             }
           
            System.debug('proj::::'+pro);
        }   
        return pro;  
    }
}