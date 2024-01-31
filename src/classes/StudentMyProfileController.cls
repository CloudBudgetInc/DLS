public class StudentMyProfileController{
    @AuraEnabled
    public static String getProfileInformation() {
        
        try{
            String contactId = getLoggedUserContactId();
            if(contactId != null && contactId != '') {
                List<Contact> contactRecord = [SELECT Id,Name, Salutation, FirstName, LastName, MiddleName, /*Suffix,*/ Email, Preferred_Phone__c, Phone,Timezone__c,
                                               MobilePhone, HomePhone, MailingStreet, MailingCity, MailingState, MailingPostalCode, Teaching_in_DLS_since__c,
                                               Active_Count_as_Instructor__c, Sum_Instructor_Hours_Week__c, Count_Projects_by_Instructor_Name__c,of_Hours_Taught_at_Vendor__c,
                                               of_Class_Projects_Taught__c,Time_Approval_Preference__c,number_of_workshops_attended__c, of_Tests_Perfomed__c, of_Students_Taught__c,
                                               of_Class_Hours__c,Virtual_Conference_License__c 
                                               FROM Contact WHERE Id = :contactId];
                if(contactRecord.size() > 0) {
                    /* Querying Contact, Experience, Skill and known language objects */
                    List<Contact> contactList = new List<Contact>();
                    List<String> options = new List<String>();
                    contactList.add(contactRecord[0]);
                    
                    ContactDomain.ContactInfo conInfo = (ContactTranslator.contactRecordsFormation(contactList)[0]);
                    
                    conInfo.timeZonePicklist = contactPickListFormation('Timezone__c');
                    conInfo.salutationPickList = contactPickListFormation('Salutation');
                    conInfo.preferredPhonePickList = contactPickListFormation('Preferred_Phone__c');
                    conInfo.timeApprovalPreferencePickList = contactPickListFormation('Time_Approval_Preference__c');
                    
                    return json.serialize(conInfo);
                }
                return null;
            }else{
                return 'No Contact Found';
            }
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
        
    }
    /* Contact field Picklist formation*/
    @AuraEnabled
    public static List<String> contactPickListFormation(String fieldName){
        List<String> options = new List<String>();
        sObject sObj = Schema.getGlobalDescribe().get('Contact').newSObject();
        Schema.sObjectType sObjType = sObj.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sObjType.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues(); 
        
        for( Schema.PicklistEntry f : pick_list_values)
        {
            options.add(f.getValue());
        }      
        return options;
    }
    @AuraEnabled
    public static String updateContactRecord(String contactRecord){
        
        Boolean currentUsrIsValid = checkCurrentUsrIsValid();
        if(!currentUsrIsValid){
            throw new AuraHandledException('Your session is expried and the changes will not be saved. Please login to contact information.');
        }
        
        /* For Updating Contact Record */
        ContactDomain.ContactInfo conRecord = (ContactDomain.ContactInfo)JSON.deserialize(contactRecord, ContactDomain.ContactInfo.class);
        List<Contact> contactList = ContactTranslator.wrapperToContactsFormation(new List<ContactDomain.ContactInfo>{conRecord});
        if(contactList != null && contactList.size() > 0) {
            update contactList;
        }
        System.debug('Contact list:::'+contactList);
        return '';
    }
    
    public static String getLoggedUserContactId() {
        return [Select Id,ContactId FROM User where Id =: userInfo.getUserId()].ContactId; //For getting Logged in User contact Id
    }
    
    @AuraEnabled
    //Method to check current user is session is expired or not
    public static Boolean checkCurrentUsrIsValid(){
        
        List<User> currentUsr = [SELECT Id,Name,Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        
        if(currentUsr.size() > 0 && currentUsr[0].Profile.Name == 'Student Profile'){
            
            return false;
        }
        return true;
    }
}