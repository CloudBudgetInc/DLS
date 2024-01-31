({
    doInit : function(component, event, helper) {
        var record = component.get("v.record");
        var field = component.get("v.field");
        var apiName = field.Name;
        var cellData = record[apiName];
        if(cellData){
            if(field.type == 'reference'){
                $A.createComponent(
                    "lightning:formattedUrl",
                    {
                        "label": cellData,
                        "value" : '/'+record[field.value],
                        "target": '_blank'
                    },
                    function(newComponent){
                        var container = component.find('textView');
                        container.set("v.body",newComponent);
                    }
                );
            }else if(field.type == 'checkbox'){
                $A.createComponent(
                    "ui:outputCheckbox",
                    {
                        "value" : cellData
                    },
                    function(newComponent){
                        var container = component.find('textView');
                        container.set("v.body",newComponent);
                    }
                );
            }else if(field.type == 'currency'){
                $A.createComponent(
                    "ui:outputCurrency",
                    {
                        "value" : cellData
                    },
                    function(newComponent){
                        var container = component.find('textView');
                        container.set("v.body",newComponent);
                    }
                );
            }else if(field.type == 'date'){
                $A.createComponent(
                    "ui:outputDate",
                    {
                        "value" : cellData,
                        "format": "MM/DD/YYYY"
                    },
                    function(newComponent){
                        var container = component.find('textView');
                        container.set("v.body",newComponent);
                    }
                );
            }else{
                $A.createComponent(
                    "ui:outputText",
                    {
                        "value" : cellData
                    },
                    function(newComponent){
                        var container = component.find('textView');
                        container.set("v.body",newComponent);
                    }
                );
            }
        }
    }
})