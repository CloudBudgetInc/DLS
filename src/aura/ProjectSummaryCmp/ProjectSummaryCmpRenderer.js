({
    // Your renderer method overrides go here
    rerender : function(component, helper){
        if(component.get("v.isLoaded")){
            component.set("v.initialLoad",true);
        }
        this.superRerender();
        
    }
})