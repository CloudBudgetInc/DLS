({
    createRating : function(cmp) {
        // check in case coming from afterRender,
        // before scripts are loaded
        var ready = cmp.get("v.ready");
        if (ready === false) {
            return;   
        }
        
        var ratingElem = cmp.find("rating").getElement();
        $(ratingElem).raty({
            starType: "i",            
            score: cmp.get("v.value"),
            readOnly : cmp.get("v.readOnly"),
            click: function(score, evt) {
                cmp.set("v.value", score);
            }
        });
    }
})