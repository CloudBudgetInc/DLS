/**
*    Developed by softSquare to update the Contact's Highest Degree field
*    (Which will be populated in DLI TOEP FORM)
*/
trigger updateContactHighestDegree on Experience__c (after insert, after update) {
    Set<Id> ConIds = new Set<Id>();
    //Modified By Dhinesh - 24/09/2021 - W-007010 - Added New Picklist Values and reordered.
    Map<String,Integer> DegAndLevelMap = new Map<String,Integer>{'H.S.' => 1, 'Courses' => 2, 'Cert' => 3, 'A.A.' => 4, 'B.A.' => 5, 'B.S.' => 6, 'M.A.' => 7, 'M.S.' => 8,'Ph.D.' => 9}; // Degree and its Level Map to Obtain the Highest degree
    Map<Integer,String> LevelAndDegMap = new Map<Integer,String>{1 => 'H.S.', 2 => 'Courses', 3 => 'Cert', 4 => 'A.A.', 5 => 'B.A.', 6 => 'B.S.',7 => 'M.A.', 8 => 'M.S.',9 => 'Ph.D.'}; // Level and its Degree Map to Obtain the Highest degree
    Id eduRTId;
    Map<Id,Integer> contsHighstDegMap = new Map<Id,Integer>();
    List<Contact> ConUpdList = new List<Contact>();
    
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) {
        
        for(RecordType rt : [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType = 'Experience__c']) {
            if(rt.DeveloperName == 'Education_Experience') {
                eduRTId = rt.Id;
            }
        }        
        
        for(Experience__c exp : trigger.New) {
            if(exp.RecordTypeId == eduRTId && ((trigger.isInsert && exp.Degree_Level__c != null) || (trigger.isUpdate && exp.Degree_Level__c != trigger.oldMap.get(exp.Id).Degree_Level__c) )) {
                ConIds.add(exp.Contact__c);
            }
        }
        
        for(Experience__c ex : [SELECT Id,Name,Degree__c,Degree_Level__c,Contact__c FROM Experience__c WHERE Contact__c IN: ConIds AND RecordTypeId =: eduRTId]) {
            if(DegAndLevelMap != null && DegAndLevelMap.containskey(ex.Degree_Level__c)) {
                if(!contsHighstDegMap.containskey(ex.Contact__c) ) {
                    contsHighstDegMap.put(ex.Contact__c,DegAndLevelMap.get(ex.Degree_Level__c));
                } else if(contsHighstDegMap.get(ex.Contact__c) < DegAndLevelMap.get(ex.Degree_Level__c)) {
                    contsHighstDegMap.put(ex.Contact__c,DegAndLevelMap.get(ex.Degree_Level__c));
                }
            }    
        }
        
        if( contsHighstDegMap != null && contsHighstDegMap.size() > 0 ) {
            for(Id cId : contsHighstDegMap.keyset()) {
                if(LevelAndDegMap.Containskey(contsHighstDegMap.get(cId))) {
                    ConUpdList.add(new Contact(Id = cId,Highest_Degree__c = LevelAndDegMap.get(contsHighstDegMap.get(cId))));
                }
            }
        }
        
        if(ConUpdList != null && ConUpdList.size() > 0) {
            update ConUpdList;
        }
    }
}