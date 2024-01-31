({
	// Your renderer method overrides go here
	rerender : function(cmp, helper){
        this.superRerender();
		// do custom rerendering here
		console.log('called::::::');
	}
})