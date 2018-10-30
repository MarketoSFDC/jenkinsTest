trigger AppviewObjTrigger on Appview_Data__c (before update) {
    Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Appview_Data__c').getDescribe().fields.getMap();
    List<String> strList = new List<String>(objectFields.keySet());

    for(Appview_Data__c obj : trigger.new){
        for(string str : strList){
            if(label.OrionSubscriptionFields.containsIgnoreCase(str)){                
                string str1 = string.ValueOf(obj.get(str));
                if(str1!= null && str1 != '' && str1.contains('<br>')){
                    obj.put(str,str1.split('<br>')[0]);
                }
            }
            else if(label.AppviewMunchkin.containsIgnoreCase(str)){                
                string str1 = string.ValueOf(obj.get(str));
                if(str1!= null && str1 != '' && str1.contains('<br>')){
                    obj.put(str,str1.replaceAll('<br>','/'));
                }
            }
        }
    }
}