({
    updateSearchTerm : function(component, searchTerm) {
        // Cleanup new search term
        const updatedSearchTerm = searchTerm.trim().replace(/\*/g).toLowerCase();
        
        // Compare clean new search term with current one and abort if identical
        const curSearchTerm = component.get('v.searchTerm');
        if (curSearchTerm === updatedSearchTerm) {
            return;
        }

        // Update search term
        component.set('v.searchTerm', updatedSearchTerm);
        
        // Ignore search terms that are too small
        if (updatedSearchTerm.length < 2) {
            component.set('v.searchResults', []);
            return;
        }
        
        // Apply search throttling (prevents search if user is still typing)
        let searchTimeout = component.get('v.searchThrottlingTimeout');
        if (searchTimeout) {
            clearTimeout(searchTimeout);
        }
        searchTimeout = window.setTimeout(
            $A.getCallback(() => {
                // Send search event if it long enougth
                const searchTerm = component.get('v.searchTerm');
                if (searchTerm.length >= 2) {
                    const searchEvent = component.getEvent('onSearch');
                    searchEvent.fire();
                }
                component.set('v.searchThrottlingTimeout', null);
            }),
            300
        );
        component.set('v.searchThrottlingTimeout', searchTimeout);
    },

    selectResult : function(component, recordId,isSelected) {
        // Save selection
        const searchResults = component.get('v.searchResults');
        const selectedResult = searchResults.filter(result => result.Id === recordId);
        if (selectedResult.length > 0) {
            if(component.get('v.isRequired'))
            	component.set('v.hasError', false);
            const selection = component.get('v.selection');
            if(component.get("v.allowMultiSelect")){
                if(isSelected){
                    selection.push(selectedResult[0]);
                }else {
                    var existingIndex;
                    for(var i = 0;i < selection.length;i++){
                        if(selection[i].Id == recordId){
                            existingIndex = i;
                            break;
                        }
                    }
                    selection.splice(existingIndex,1);
                }
            }else {
                selection.push(selectedResult[0]);
            }
            component.set('v.selection', selection);
            
        }else{
            if(component.get('v.isRequired'))
            	component.set('v.hasError', true);
        }
        // Reset search
        if(!component.get("v.allowMultiSelect")){
            const searchInput = component.find('searchInput');
            searchInput.getElement().value = '';
            component.set('v.searchTerm', '');
            component.set('v.searchResults', []);
        }
    },

    getSelectedIds : function(component) {
        const selection = component.get('v.selection');
        return selection.map(element => element.Id);
    },

    removeSelectedItem : function(component, removedItemId) {
        const selection = component.get('v.selection');
        const updatedSelection = selection.filter(item => item.Id !== removedItemId);
        component.set('v.selection', updatedSelection);
    },

    clearSelection : function(component, itemId) {
        component.set('v.selection', []);
    },

    isSelectionAllowed : function(component) {
        return component.get('v.isMultiEntry') || component.get('v.selection').length === 0;
    }
})