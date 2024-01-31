({
    cATabRecords : function(cmp) {
        var caRecords =  cmp.get("v.CAListItems");
        var cATabName = cmp.get("v.cATabName");
        var caTabArray = [];
        
        for(var i = 0;i < caRecords.length;i++){
            if(caRecords[i].recordTypeName == cATabName) {
                caTabArray.push(caRecords[i]); 
            }
        }
        cmp.set("v.CATabList",caTabArray);
    }
})