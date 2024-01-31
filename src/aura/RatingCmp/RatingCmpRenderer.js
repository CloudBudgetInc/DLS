({
    // Your renderer method overrides go here
    afterRender: function(cmp, helper) {
        this.superAfterRender(cmp, helper);
        helper.createRating(cmp);
    }
})