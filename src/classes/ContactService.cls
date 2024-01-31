/**********************************************************************
    Created by Vinitha on Jan 31, 2017: Service class used for Contact object     
***********************************************************************/
public class ContactService {
    
     /**********************************************************************
        Created by Vinitha on Jan 31 2017: This method return list of Contact 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        @parentIdset - pass set of parent ids
        return - list of ContactAssignment records
    ***********************************************************************/ 
    
    public static list<Contact> getContactByparentId(String filterQry, String parentFields,Set<Id> parentId) {
    
        list<Contact> conList =  new list<Contact>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Contact');
        String defalutQry = 'SELECT '+ fieldName +' FROM Contact';
        
        if(parentFields != null && parentFields != ''){
            defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM Contact';
        }
        
        if(filterQry != null && filterQry != '' && parentId != null && parentId.size() > 0){            
            defalutQry = defalutQry + filterQry + 'IN :parentId';          
        }else if(filterQry != null && filterQry != '') {
            defalutQry = defalutQry + filterQry;
        } 
        
        System.debug('::defalutQry:::'+defalutQry);
        conList =  Database.query(defalutQry);   
        return conList;
    }
    /**********************************************************************
        Created by Shalini on Feb 13 2017:
        @filterQry - pass where Conditions
        @parentFields - Pass parent field names 
        @names - Set of Contact names
        @name - Contact name
        return - List of Contacts.
    ***********************************************************************/  
    
    public static List<Contact> getContactByName(String filterQry, String parentFields,Set<String> names,String name) {
    
        List<Contact> conList =  new List<Contact>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Contact');
        String defalutQry = 'SELECT '+ fieldName +' FROM Contact';
        
        if(parentFields != null && parentFields != ''){
            defalutQry = 'SELECT '+ fieldName + parentFields + ' FROM Contact';
        }
        
        if(filterQry != Null && filterQry != ''){            
            defalutQry += filterQry;          
        } 
        
        if(filterQry == '' && names != Null && names.size() > 0){
            defalutQry += ' WHERE Name IN :names';
        } else if(filterQry != '' && names != Null && names.size() > 0){
            defalutQry += ' AND Name IN :names';
        }
        
        if(filterQry == '' &&  name != Null && name != ''){
            defalutQry += ' WHERE Name LIKE :name LIMIT 1';
        }
        
        System.debug('::defalutQry::ContactService::::ByName:'+defalutQry);
        conList =  Database.query(defalutQry);   
        return conList;
    }
    
    /**********************************************************************
        Created by Karthiga on Feb 27, 2017:
        @conId - Contact Id
        return - List of Contacts.
    ***********************************************************************/ 
    
    public Static List<Contact> getInstructorChildRec(Set<Id> ConId) {
        String conQuery = 'SELECT '+SObjectQueryService.getSObjectFieldsBySObjectName('Contact') +
                            ',(SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Experience__c') + ',RecordType.DeveloperName FROM Experiences__r)'+
                            ',(SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Known_Language__c') + ',Language__r.Name FROM Known_Languages__r)'+
                            ' FROM Contact WHERE Id IN:ConId';
        List<Contact> conList = database.query(conQuery);
        return conList;
    }
    /**********************************************************************
        Created by Vinitha on Mar 7 2017: This method return list of Contact 
        @firstname - set of firstname string
        @lastname - set of Lastname        
        return - list of ContactAssignment records
    ***********************************************************************/ 
    
    public static list<Contact> getContactRecDetails(Set<String> firstname,Set<String> lastname,Set<String> middlename){
       
        String conQuery = 'SELECT '+SObjectQueryService.getSObjectFieldsBySObjectName('Contact') +
                               ' From Contact where FirstName like :firstname AND LastName like :lastname AND MiddleName like :middlename AND RecordType.developerName = \'DLS_Employee\'';
        system.debug(':contactService:conQuery::'+conQuery);
        list<Contact> conList = database.query(conQuery);
        system.debug('ContactService:conList::'+conList);
        return conList;
    }
    /**********************************************************************
        Created by Shalini on Feb 13 2017: 
        @contactList - List of Contacts to update.
        return - List of Contacts.
    ***********************************************************************/  
    public static List<Contact> updateContact(List<Contact> contactList){
        if( contactList != null && contactList.size() > 0 ) {
            update contactList;
            
            return contactList;
        }
        return null;
    }
    
    /**********************************************************************
        Created by Shalini on Feb 13 2017: 
        @contactList - List of Contacts to upsert.
        return - List of Contacts.
    ***********************************************************************/  
    public static List<Contact> upsertContact(List<Contact> contactList){
        if( contactList != null && contactList.size() > 0 ) {
            upsert contactList;
            
            return contactList;
        }
        return null;
    }
}