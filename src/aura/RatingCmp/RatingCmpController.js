({
    afterScriptsLoaded : function(cmp, event, helper) {
        cmp.set("v.ready", true);
        helper.createRating(cmp);
    }
})