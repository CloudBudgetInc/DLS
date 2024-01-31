public class MaterialsMergeValidation {

    public Boolean showMsg {get; set;}
    public String idsJson {get; set;}
    
    public MaterialsMergeValidation(ApexPages.StandardSetController standardSetController){
        List<Materials__c> seletedMaterials = (List<Materials__c>) standardSetController.getSelected();
        system.debug('::::::seletedMaterials:::'+seletedMaterials);
        
        if(seletedMaterials.size() > 0){
            if(seletedMaterials.size() == 1){
                showMsg = true;
            }else {
                showMsg = false;
                
                List<Id> materialIds = new List<Id>();
                
                if(seletedMaterials.size() == 2){
                    materialIds.add(seletedMaterials[0].Id);
                    materialIds.add(seletedMaterials[1].Id);
                }else if(seletedMaterials.size() == 3){
                    materialIds.add(seletedMaterials[0].Id);
                    materialIds.add(seletedMaterials[1].Id);
                    materialIds.add(seletedMaterials[2].Id);
                }
                idsJson = JSON.serialize(seletedMaterials);
            }
            
        }else {
            showMsg = true;
        }
    }
    

}