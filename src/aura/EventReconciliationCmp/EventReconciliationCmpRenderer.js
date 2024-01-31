({
	rerender : function (component, helper) {
        this.superRerender();
        
        window.setTimeout($A.getCallback(function(){
            console.log('Adjusting header');
            //helper.setFixedHeader(component);
        }),500);
  
    },
})