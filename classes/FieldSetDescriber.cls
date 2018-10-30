public class FieldSetDescriber{
    static Map<String, Schema.SObjectType> globalDescribe;
    
     /*
    *This method generates query according to passed in object and fieldset name
    **/
    public static String generateQueryFromFieldSets(String sObjectName,Set<String> fieldSets,Set<String> additionalFields,String whereClause){
        Set<String> fields = new Set<String>{'Id'};
        
        if(additionalFields!=null)
        for(String fs : additionalFields) {
           fields.add(fs);
        }

        //describe the provided sObject to get the fields set map
        Schema.DescribeSObjectResult res = getGlobalDescribe().get(sObjectName).getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = res.fieldSets.getMap();
        
        for(String fieldSetName : fieldSets){
            Schema.FieldSet fs = fieldSetMap.get(fieldSetName);
            if(fs != null) {
                for(Schema.FieldSetMember fsm : fs.getFields()) {
                   fields.add(fsm.getFieldPath());
                }
            }
        }
        String[] fieldsIterable = new String[]{};
        fieldsIterable.addAll(fields);
        String query = 'select '+String.join(fieldsIterable, ',') + ' from ' + sObjectName;
        query += (whereClause == '' || whereClause ==null) 
                        ? ''
                        : ' where ' + whereClause;
        
        return query;
    }
    
    private static Map<String, Schema.SObjectType> getGlobalDescribe(){
        if(globalDescribe == NULL){
            globalDescribe =Schema.getGlobalDescribe();
        }
        
        return globalDescribe;
    }

}