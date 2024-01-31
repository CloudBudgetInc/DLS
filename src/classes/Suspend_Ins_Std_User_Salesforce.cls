/********
    - W-007696: System is unchecking the Active DLS Online Checkbox on Active Instructor & Student Contact Pages
    - To InActivating the user if they have not logged in since last 2 years
    **********/
global class Suspend_Ins_Std_User_Salesforce implements Schedulable {

    global void execute(SchedulableContext sc) {
    
        Date todayDate = Date.Today();
        Date lastLoginDate_val = Date.newInstance(todayDate.Year()-2, todayDate.month(), todayDate.day());
        
        List<User> users = [SELECT Id, Name, ContactId, IsActive
                            FROM User 
                            WHERE IsActive = True AND IsPortalEnabled = True AND Is_Instructor_Student_User__c = True AND 
                            (LastLoginDate = null OR LastLoginDate <= : lastLoginDate_val)];
        
        if(users.size() > 0){
        
            Set<Id> conIds = new Set<Id>();
            List<User> updateUser = new List<User>();
            Map<Id, List<Contact_Assignments__c>> conIdAndConAssigns = new Map<Id, List<Contact_Assignments__c>>();
            
            for(User u : users){
            
                conIds.add(u.ContactId);
            }
            
            for(Contact c : [SELECT Id, 
                                (SELECT Id FROM Candidate_Assignments__r WHERE Candidate_Name__c IN : conIds AND RecordType.DeveloperName IN ('Instructor', 'Student', 'Client_Partner') AND Status__c IN ('Planned','Active') AND End_Date__c > TODAY)
                                FROM Contact WHERE Id IN : conIds]){
                
                if(c.Candidate_Assignments__r.size() > 0){   
                
                    conIdAndConAssigns.put(c.Id, c.Candidate_Assignments__r);
                }
            }
            
            for(User u : users){
                
                if(!conIdAndConAssigns.containsKey(u.ContactId)){
                    
                    u.IsActive = False;
                    updateUser.add(u);
                }
            }            
            if(updateUser.size() > 0){
                update updateUser;
            }
        }
    }
}