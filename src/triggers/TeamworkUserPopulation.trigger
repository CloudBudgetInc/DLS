trigger TeamworkUserPopulation on TeamforcePro__People__c (before insert, before update) {
   
   // Populate the User value in teamwork people based on the existing org user values
   // Find the First Name, Last name & email match for usr population
    
    Set<String> firstNameSet = new Set<String>();
    Set<String> lastNameSet = new Set<String>();
    Set<String> emailSet = new Set<String>();
    Map<String, Integer> usrCountMap = new Map<String, Integer>();
    Map<String, Id> usrMap = new Map<String, Id>();
    List<User> userList = new List<User>();
    Set<String> profileIdSet = new Set<String>();
    List<TeamforcePro__People__c> teampeopleList = new List<TeamforcePro__People__c>();
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        for (TeamforcePro__People__c tp : Trigger.new) {
            
            if(trigger.oldmap == NULL || (trigger.oldmap != NULL && (trigger.oldmap.get(tp.Id).TeamforcePro__First_Name__c != tp.TeamforcePro__First_Name__c ||
                trigger.oldmap.get(tp.Id).TeamforcePro__Last_Name__c != tp.TeamforcePro__Last_Name__c || trigger.oldmap.get(tp.Id).TeamforcePro__Email__c != tp.TeamforcePro__Email__c))) { 
                if(!String.isBlank(tp.TeamforcePro__First_Name__c) || !String.isBlank(tp.TeamforcePro__Last_Name__c) || !String.isBlank(tp.TeamforcePro__Email__c)) {
                    firstNameSet.add(tp.TeamforcePro__First_Name__c);
                    lastNameSet.add(tp.TeamforcePro__Last_Name__c);
                    emailSet.add(tp.TeamforcePro__Email__c);
                    teampeopleList.add(tp);
                    system.debug(':::teampeopleList'+teampeopleList);
                } 
            }           
        } 
        
        // Get the Custom Setting teamwork user profile ids
        // Qry the existing users based on the custom setting
        if(!firstNameSet.isEmpty() || !lastNameSet.isEmpty() || !emailSet.isEmpty()){  
            
            String usrProfileId;
            System_Values__c sysVal = System_Values__c.getValues('Teamwork_People User Profile');
     
            if(sysVal != null && sysVal.Value__c != null) {
                usrProfileId = sysVal.Value__c;
            }
            // Form profile id set from custom setting by excluding space
            if (String.isNotEmpty(usrProfileId)) {
                if (usrProfileId.contains(',')) {
                    for(String str : usrProfileId.split(',')) {
                        if (!profileIdSet.contains(Id.valueOf(str.trim()))){
                            profileIdSet.add(Id.valueOf(str.trim()));
                        }
                    }
                } else {
                    profileIdSet.add(Id.valueOf(usrProfileId));
                }
            }
                         
            userList = [SELECT ID,FirstName,LastName,Email,ProfileId FROM User 
                        WHERE (FirstName IN :firstNameSet OR LastName IN :lastNameSet OR Email IN :emailSet)
                        AND ProfileId IN :profileIdSet];          
            system.debug(':::userList'+userList);
        }
        
        // For the usr FN,LN & email & usr id map, usr id, count map
        if(!userList.isEmpty()) {
        
            for(User us : userList){  
                
                String usrinfo = us.FirstName+'--'+us.LastName+'--'+us.Email;              
                
                if(!usrMap.containsKey(usrinfo)){
                    usrMap.put(usrinfo,us.Id);
                }
                
                if(!usrCountMap.containsKey(usrinfo)) {
                    usrCountMap.put(usrinfo,1);
                } else {
                    usrCountMap.put(usrinfo,usrCountMap.get(usrinfo)+1);
                }                    
            }            
        }
        
        // Check the existing users & populate the values in teamwork people
        if(!teampeopleList.isEmpty()) {        
            for (TeamforcePro__People__c tp : teampeopleList) {             
                String peopleInfo = tp.TeamforcePro__First_Name__c+'--'+tp.TeamforcePro__Last_Name__c+'--'+tp.TeamforcePro__Email__c;
                system.debug(':::peopleInfo'+peopleInfo);
                if(usrMap.containsKey(peopleInfo)){                
                    if(usrMap.get(peopleInfo) != null && usrCountMap.get(peopleInfo) == 1) {                
                        tp.User__c = usrMap.get(peopleInfo);
                        system.debug('::::tp.User__c'+tp.User__c);
                    } 
                }
            }
        }
    }
}