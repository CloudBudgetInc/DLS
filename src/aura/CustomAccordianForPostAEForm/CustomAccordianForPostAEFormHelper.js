({
	tableSortHelper : function(cmp ,name) {
        var filterObj =  cmp.get("v.faSort");
        var aeWrapList = cmp.get("v.aeWrap.aeList");
        var ascendingRecs = false;
       
        if(filterObj.fieldToSort != name){
            filterObj.arrowDirection = 'arrowdown';
        }
        filterObj.fieldToSort = name;  
        
        var currentDir = filterObj.arrowDirection; 
        
        if (currentDir == 'arrowdown') {
            filterObj.arrowDirection = 'arrowup';
            filterObj.sortingOrder = 'Asc';
            ascendingRecs = true;
        } else {
            filterObj.arrowDirection = 'arrowdown';
            filterObj.sortingOrder = 'Desc';
        }
        
        aeWrapList.sort((a, b) => {
            let fa = a[name],
            fb = b[name];
            
            if (fa === fb) {// equal items sort equally
            return 0;
        }else if (!fa) {// nulls sort after anything else
            return 1;
        }else if (!fb) {
            return -1;
        }else if (ascendingRecs) {// otherwise, if we're ascending, lowest sorts first
            return fa < fb ? -1 : 1;
        }else {// if descending, highest sorts first
            return fa < fb ? 1 : -1;
        }
    });
    cmp.set("v.faSort",filterObj);
    cmp.set("v.aeWrap.aeList",aeWrapList);
 },
})