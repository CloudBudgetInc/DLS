/************
    - Created By HL on May 21 2019
    - Work Item : W-001591
    - To update content version total favorite count(Total_Favourite_Count__c) field
*****************/

trigger favouriteMaterialTrigger on Favourite_Material__c (after insert, after delete) {

    if(Trigger.isAfter){
    
        if(Trigger.isInsert || Trigger.isDelete){
            
            List<Favourite_Material__c> favouriteMaterials = new List<Favourite_Material__c>();
            
            if(Trigger.isInsert){
                favouriteMaterials = Trigger.new;
            }else if(Trigger.isDelete){
                favouriteMaterials = Trigger.old;
            }
            System.debug('favouriteMaterials ================'+favouriteMaterials+'favouriteMaterials  SIZE======'+favouriteMaterials.size());
            
            Map<Id, Integer> contentVersionIdAndNoOfFavMat = new Map<Id, Integer>();
            List<ContentVersion> toUpdateContentVersions = new List<ContentVersion>();
            
            for(Favourite_Material__c fm : favouriteMaterials){
            
                if(String.isNotBlank(fm.ContentVersion_Id__c) && ((fm.ContentVersion_Id__c).length() == 15 || (fm.ContentVersion_Id__c).length() == 18)){
                
                    if(!contentVersionIdAndNoOfFavMat.containsKey(fm.ContentVersion_Id__c)){
                    
                        contentVersionIdAndNoOfFavMat.put(fm.ContentVersion_Id__c, 1);
                    }else{
                        contentVersionIdAndNoOfFavMat.put(fm.ContentVersion_Id__c, contentVersionIdAndNoOfFavMat.get(fm.ContentVersion_Id__c)+1);
                    }
                }
            }
            System.debug('contentVersionIdAndNoOfFavMat==============='+contentVersionIdAndNoOfFavMat+'contentVersionIdAndNoOfFavMat SIZE======='+contentVersionIdAndNoOfFavMat.size());
            
            if(contentVersionIdAndNoOfFavMat.size() > 0){
                                            
                for(ContentVersion c : [SELECT Id, Total_Favourite_Count__c FROM ContentVersion WHERE Id IN : contentVersionIdAndNoOfFavMat.keySet()]){
                
                    if(contentVersionIdAndNoOfFavMat.containsKey(c.Id)){
                    
                        if(Trigger.isInsert){
                        
                            if(c.Total_Favourite_Count__c != NULL){
                            
                                c.Total_Favourite_Count__c = c.Total_Favourite_Count__c + contentVersionIdAndNoOfFavMat.get(c.Id);
                            }else{
                                c.Total_Favourite_Count__c = contentVersionIdAndNoOfFavMat.get(c.Id);
                            }
                            toUpdateContentVersions.add(c);
                        }
                        
                        if(Trigger.isDelete){
                        
                            if(c.Total_Favourite_Count__c != NULL && c.Total_Favourite_Count__c > 0){
                                c.Total_Favourite_Count__c = c.Total_Favourite_Count__c - contentVersionIdAndNoOfFavMat.get(c.Id);
                                toUpdateContentVersions.add(c);
                            }
                        }
                    }
                }
                System.debug('toUpdateContentVersions==============='+toUpdateContentVersions+'toUpdateContentVersions SIZE======='+toUpdateContentVersions.size());
                
                if(toUpdateContentVersions.size() > 0){
                    update toUpdateContentVersions;
                }
            }
        }
    }
}