/* This trigger is created by Keerthika on Jan 18, 2018. To update the Equipment Assignment 
   Stage with Active to Ended when the Equipment Assignment with the Same Equipment is 
   inserted or Update with the Stage as Active */
   
trigger CheckEquiAssignStage on Equipment_Assignment__c (Before insert, Before update) {

    Set<Id> equId = new Set<Id>();
    List<Equipment_Assignment__c> equiAssignList = new List<Equipment_Assignment__c>();
    Map<Id, Integer> equipActiveCountMap = new Map<Id, Integer>();
    Integer Count = 1;
    
    if(trigger.isBefore) {    
        
        List<Equipment_Assignment__c> equipmentAssignments = new List<Equipment_Assignment__c>();
        Set<Id> roomIds = new Set<Id>();
        
       for(Equipment_Assignment__c equAss : trigger.new) {
           if((trigger.isInsert || (trigger.isUpdate && trigger.oldmap.get(equAss.Id).Stage__c != equAss.Stage__c)) && equAss.Stage__c == 'Active') {    
            
               if(!equipActiveCountMap.ContainsKey(equAss.Equipment__c)) {
                   // Map has the Equipment Id as key and the count of Equipment Assignment of the Same Equipment as the value
                   equipActiveCountMap.put(equAss.Equipment__c, Count);
               } else {
                   equipActiveCountMap.put(equAss.Equipment__c,equipActiveCountMap.get(equAss.Equipment__c)+1);
               }
           }   
           
           // Added by HL on June 15
           // W-002029 - Auto-update Location field on Equipment Assignment based on Room field
            if(Trigger.isInsert || (Trigger.isUpdate && (Trigger.oldmap.get(equAss.Id).Room__c != equAss.Room__c))){
            
                if(equAss.Room__c != NULL){
                
                    roomIds.add(equAss.Room__c);
                    equipmentAssignments.add(equAss);
                }
                
                if(Trigger.isUpdate && equAss.Room__c == NULL){
                    equipmentAssignments.add(equAss);
                }
            }
       }
       System.debug('roomIds===='+roomIds+'roomIds SIZE==='+roomIds.size());
       System.debug('equipmentAssignments===='+equipmentAssignments+'equipmentAssignments SIZE==='+equipmentAssignments.size());
       
       if(equipActiveCountMap != Null && equipActiveCountMap.size() > 0) {
           for(Id eqId : equipActiveCountMap.keySet()) {
               if(equipActiveCountMap.get(eqId) > 1) {
                   /* Equipment Id is added in set when more than one Equipment Assignment of the same Equipment is 
                   inserted or updated with the Stage as active */
                   equId.add(eqId);
               } 
           } 
           if(equId != Null && equId.size() > 0) {
               for(Equipment_Assignment__c equipAss : trigger.new) {
                   if((trigger.isInsert || (trigger.isUpdate && trigger.oldmap.get(equipAss.Id).Stage__c != equipAss.Stage__c)) && equipAss.Stage__c == 'Active') {
                       if(equId.contains(equipAss.Equipment__c)) {
                           // Error thrown when more than one Equipment Assignment of the same Equipment is inserted or updated with the Stage as active 
                           equipAss.addError('Only one Equipment Assignment of the same Equipment can be Inserted or Updated with the Stage as Active');
                       }
                   }
               }    
           } else {
               
               // Equipment Assignment with the stage as Active and equipment in the map keySet 
               equiAssignList = [SELECT Id, Name, Equipment__c, Stage__c FROM Equipment_Assignment__c 
                                 WHERE Stage__c = 'Active' AND Equipment__c IN :equipActiveCountMap.keySet()];
           
               if(equiAssignList != Null && equiAssignList.size() > 0) {                                                
                
                   for(Equipment_Assignment__c equAssign : equiAssignList) {                  
                       equAssign.Stage__c = 'Ended';
                       equAssign.Date_Returned__c = System.Today(); 
                   }
                   update equiAssignList;
               } 
           }        
       }       
       
       if(equipmentAssignments.size() > 0){
           
           Map<Id, Id> roomIdAndLocationId = new Map<Id, Id>();
           
           for(Room__c r : [SELECT Id, Location_n__c FROM Room__c WHERE Id IN :roomIds AND Location_n__c != NULL]){
               roomIdAndLocationId.put(r.Id, r.Location_n__c);    
           }
           System.debug('roomIdAndLocationId==='+roomIdAndLocationId+'roomIdAndLocationId SIZE==='+roomIdAndLocationId.size());
           
           for(Equipment_Assignment__c e : equipmentAssignments){
           
               if(roomIdAndLocationId.containsKey(e.Room__c)){
                   e.Location__c = roomIdAndLocationId.get(e.Room__c);
               }
               
               if(Trigger.isUpdate && e.Room__c == NULL){
                   e.Location__c = NULL;
               }
           }
       }
    }
}