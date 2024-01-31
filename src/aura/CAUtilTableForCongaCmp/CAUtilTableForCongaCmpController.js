({
    toggleSelectAllRows: function(component, event, helper){        
        let tableRows = component.find('tableRow');
        if(!Array.isArray(tableRows)) tableRows = [tableRows];
        for(let i = 0; i < tableRows.length; i++){
            tableRows[i].toggleRow(event.getSource().get('v.checked'));
        }
    },
    getSelectedRows: function(component, event, helper){
        let selectedRows = [];
        
        let tableRows = component.find('tableRow');
        if(!Array.isArray(tableRows)) tableRows = [tableRows];
        for(const row of tableRows){
            var result = row.selectedRow();
            if(result.isSelected){                
                selectedRows.push(result.ca);
            }
        }                    

        return selectedRows;
    },
    actionHandler: function(component, event, helper){
        
    }
})