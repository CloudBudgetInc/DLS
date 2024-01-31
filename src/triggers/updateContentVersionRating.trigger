trigger updateContentVersionRating on Material_Rating__c (After Insert, After Update) {

    Map<Id, Material_Rating__c> contentVersionIdAndMaterials = new Map<Id, Material_Rating__c>();
    Map<Id, Integer> contentVersionIdAndMaterialsIncOrDec = new Map<Id, Integer>();
    List<ContentVersion> contentVersions = new List<ContentVersion>();
    Material_Rating__c materialRatingOldMap = new Material_Rating__c();
    
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) {
        for(Material_Rating__c material : trigger.new) {
            Integer IncOrDec = 0;
            if(trigger.isUpdate) {
                materialRatingOldMap = Trigger.oldMap.get(material.Id);
            }
            if(trigger.isInsert || (material.Ratings__c != materialRatingOldMap.Ratings__c)) {
                if(material.ContentVersionId__c != Null && ((material.ContentVersionId__c).length() == 15 || (material.ContentVersionId__c).length() == 18)) {
                    contentVersionIdAndMaterials.put(material.ContentVersionId__c, material);
                    if(trigger.isUpdate) {
                        if(material.Ratings__c > materialRatingOldMap.Ratings__c) {
                            IncOrDec = Integer.valueOf(material.Ratings__c) - Integer.valueOf(materialRatingOldMap.Ratings__c);
                            contentVersionIdAndMaterialsIncOrDec.put(material.ContentVersionId__c, IncOrDec);
                        } else if (material.Ratings__c != Null && materialRatingOldMap.Ratings__c == Null) {
                            contentVersionIdAndMaterialsIncOrDec.put(material.ContentVersionId__c, Integer.valueOf(material.Ratings__c));
                        } else if(material.Ratings__c < materialRatingOldMap.Ratings__c) {
                            IncOrDec = Integer.valueOf(material.Ratings__c) - Integer.valueOf(materialRatingOldMap.Ratings__c);
                            contentVersionIdAndMaterialsIncOrDec.put(material.ContentVersionId__c, IncOrDec);
                        } else if (material.Ratings__c == Null && materialRatingOldMap.Ratings__c != Null){
                            IncOrDec = -Integer.valueOf(materialRatingOldMap.Ratings__c);
                            contentVersionIdAndMaterialsIncOrDec.put(material.ContentVersionId__c, IncOrDec);
                        }
                    }
                }
            }
        }
        
        if(contentVersionIdAndMaterials.size() > 0) {
            contentVersions = [SELECT Id, Rating__c, Sum_Of_Rating__c FROM ContentVersion WHERE Id IN :contentVersionIdAndMaterials.KeySet()];
            if(contentVersions.size() > 0) { 
                for(ContentVersion content : contentVersions) {
                    Material_Rating__c material = new Material_Rating__c();
                    material = contentVersionIdAndMaterials.get(content.Id);
                    content.Rating__c = material.Ratings__c;
                    if(trigger.isInsert) {
                        if(content.Sum_Of_Rating__c != Null && material.Ratings__c != Null) {
                            content.Sum_Of_Rating__c = content.Sum_Of_Rating__c + material.Ratings__c;
                        } else if(material.Ratings__c != Null) {
                            content.Sum_Of_Rating__c = material.Ratings__c;
                        }
                    }
                    if(trigger.isUpdate) {
                        if(contentVersionIdAndMaterialsIncOrDec.containsKey(content.Id)) {
                            if(content.Sum_Of_Rating__c != Null) {
                                content.Sum_Of_Rating__c = content.Sum_Of_Rating__c + contentVersionIdAndMaterialsIncOrDec.get(content.Id);
                            } else if(contentVersionIdAndMaterialsIncOrDec.get(content.Id) > 0) {
                                content.Sum_Of_Rating__c = contentVersionIdAndMaterialsIncOrDec.get(content.Id);
                            } else {
                                content.Sum_Of_Rating__c = 0;
                            }
                        } 
                    }
                }
            }
        }
    }
    System.debug(':::Trigger.new:::' + Trigger.new);
    System.debug(':::contentVersionIdAndMaterials:::' + contentVersionIdAndMaterials);
    System.debug(':::contentVersions:::' + contentVersions);
    if(contentVersions.size() > 0) {
        update contentVersions;
    }
}