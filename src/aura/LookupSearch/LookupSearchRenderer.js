({
	// Your renderer method overrides go here
	afterRender: function (cmp,helper) {
        this.superAfterRender();
        
        
        helper.windowClick = $A.getCallback(function(event){
            if(cmp.isValid()){
                if(cmp.get("v.allowMultiSelect")){
                    const searchInput = cmp.find('searchInput');
                    searchInput.getElement().value = '';
                    cmp.set('v.searchTerm', '');
                    cmp.set('v.searchResults', []);
                }
            }
        });
        
        document.addEventListener('click',helper.windowClick);
    }
})