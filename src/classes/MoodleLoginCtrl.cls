public class MoodleLoginCtrl {
    
    @AuraEnabled
    public static String getLoginDetialsForD2L(){
        
        String returnUrl = 'Redirect to Moodle';
        
        List<User> usrRecords = [SELECT Id,Name,ContactId,Profile.Name,Contact.Moodle_User_Id__c FROM User WHERE Id = :userInfo.getUserId()];
        
        if(usrRecords.size() > 0) {
            
            if(usrRecords[0].ContactId == null || usrRecords[0].Contact.Moodle_User_Id__c == null){
                
                returnUrl = usrRecords[0].Profile.Name == 'Client Community' ? 'Coming soon!!' : 'There is no LMS account for you. Please contact your LTS.';
                
            }
        } 
        
        return returnUrl;
    }
    
    //For SSO community defaultly loading instructor / student community
    @AuraEnabled
    public static string getCommunityUrl(){
    
        String returnUrl = '';
        
        List<User> usrRecords = [SELECT Id,Name,Profile.Name FROM User WHERE Id = :userInfo.getUserId()];
        
        if(usrRecords.size() > 0 && usrRecords[0].Profile.Name == 'Instructor Community'){
            returnUrl = System.Label.Instructor_Community_Site_Prefix;
        }else if(usrRecords.size() > 0 && usrRecords[0].Profile.Name == 'Student Community'){
            returnUrl = System.Label.Student_Community_Site_Prefix;
        }
        
        return returnUrl;
    }
}