({
    doinit : function(component, event, helper) {
        var fieldAPINameToShowBadge = component.get('v.fieldAPINameToShowBadge'),
            conAssign = component.get('v.conAssign');
        
        if(component.get('v.showSentBadge') && conAssign[fieldAPINameToShowBadge] != null){
            component.set('v.showBadge', true);
        }
    },
    toggleSelection: function(component, event, helper){
        var params = event.getParam('arguments'),
            isSelect = params.isSelect ? params.isSelect : false;
        
        component.find("selectRow").set("v.checked", isSelect);
    },
    getSelectedRowInfo: function(component, event, helper){
        return {isSelected: component.find("selectRow").get("v.checked"), ca:component.get("v.conAssign")};
    }
})