({
    afterRender: function (cmp,helper) {
        this.superAfterRender();
        
        
        helper.windowClick = $A.getCallback(function(event){
            if(cmp.isValid()){
                helper.helperMethod(cmp, event);
            }
        });
        
        document.addEventListener('click',helper.windowClick);
    }
})