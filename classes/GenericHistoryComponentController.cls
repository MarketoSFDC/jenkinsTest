public class GenericHistoryComponentController {
    
    // External variables
    public SObject myObject {get; set;}
    public Integer recordLimit {get; set;}
    public static String objectLabel {get;}
    
    // Internal Variables
    public objectHistoryLine[] objectHistory; 

    public static final Map<String, Schema.SObjectType> mySObjectTypeMap = Schema.getGlobalDescribe();
    public static Map<String, Schema.SObjectField> myObjectFieldMap;
    public static List<Schema.PicklistEntry> historyFieldPicklistValues;
    
    public List<objectHistoryLine> getObjectHistory(){

        Id myObjectId = String.valueOf(myObject.get('Id'));
        Schema.DescribeSObjectResult objectDescription = myObject.getSObjectType().getDescribe();

        myObjectFieldMap = objectDescription.fields.getMap();
        objectLabel = String.valueOf(objectDescription.getLabel());
        
        //Get the name of thew history table
        String objectHistoryTableName = objectDescription.getName();
        //if we have a custom object we need to drop the 'c' off the end before adding 'History' to get the history tables name
        if (objectDescription.isCustom()){
            objectHistoryTableName = objectHistoryTableName.substring(0, objectHistoryTableName.length()-1);
        }
        objectHistoryTableName = objectHistoryTableName + 'History';
        
        Schema.DescribeFieldResult objectHistoryFieldField = mySObjectTypeMap.get(objectHistoryTableName).getDescribe().fields.getMap().get('Field').getDescribe();
        historyFieldPicklistValues = objectHistoryFieldField.getPickListValues();
                    
        list<objectHistoryLine> objectHistory = new list<objectHistoryLine>();
        
        String prevDate = '';
        
        if (recordLimit== null){
            recordLimit = 100;
        }
        
        list<sObject> historyList = Database.query( 'SELECT CreatedDate,'+
                                                    'CreatedById,'+
                                                    'Field,'+
                                                    'NewValue,'+
                                                    'OldValue ' +
                                                    'FROM ' + objectHistoryTableName + ' ' +
                                                    'WHERE CaseId =\'' + myObjectId + '\' ' +
                                                    'ORDER BY CreatedDate DESC '+
                                                    'LIMIT ' + String.valueOf(recordLimit));
        
        for(Integer i = 0; i < historyList.size(); i++){
            sObject historyLine = historyList.get(i);
            if ((historyLine.get('newValue') == null && historyLine.get('oldValue') == null) 
                    || (historyLine.get('newValue') != null && !(string.valueOf(historyLine.get('newValue')).startsWith('005') || string.valueOf(historyLine.get('newValue')).startsWith('00G')))
                    || (historyLine.get('oldValue') != null && !(string.valueOf(historyLine.get('oldValue')).startsWith('005') || string.valueOf(historyLine.get('oldValue')).startsWith('00G')))){
                objectHistoryLine tempHistory = new objectHistoryLine();
                // Set the Date and who performed the action
                if (String.valueOf(historyLine.get('CreatedDate')) != prevDate){
                    //tempHistory.theDate = String.valueOf(historyLine.get('CreatedDate'));
                    tempHistory.userId = String.valueOf(historyLine.get('CreatedById'));
                    tempHistory.who = String.valueOf(historyLine.get('CreatedById'));
                    string tempCreatedDate = String.valueOf(historyLine.get('CreatedDate'));

                    List<String> newStrArr = tempCreatedDate.split(' ');
                    List<String> myDate = newStrArr[0].split('-');
                    List<String> myTime = newStrArr[1].split(':');                    
                    datetime objdt = Datetime.newInstanceGmt(
                        integer.valueof(myDate[0]),
                        integer.valueof(myDate[1]),
                        integer.valueof(myDate[2]),
                        integer.valueof(myTime[0]),
                        integer.valueof(myTime[1]),
                        integer.valueof(myTime[2])                        
                    );
                    //tempHistory.timePST = objdt.format('EEE MMM d kk:mm:ss z yyyy','PST'); //Specify Time zone like IST,CST                                
                    //tempHistory.timePST = objdt.format('yyyy-MM-dd kk:mm:ss z ','PST'); //Specify Time zone like IST,CST                                
                    User timeZone= [Select TimeZoneSidKey from User where Id =: UserInfo.getUserId() Limit 1];
                    tempHistory.tempCreatedDate = objdt.format();
                    }
                else{
                    tempHistory.theDate = '';
                    tempHistory.who = '';
                    tempHistory.userId = String.valueOf(historyLine.get('CreatedById'));
                }
                prevDate = String.valueOf(historyLine.get('CreatedDate'));
                
                // Get the field label
                String fieldLabel = GenericHistoryComponentController.returnFieldLabel(String.valueOf(historyLine.get('Field')));
                
                // Set the Action value
                   if (String.valueOf(historyLine.get('Field')) == 'created') {    // on Creation
                       tempHistory.action = 'Created.';
                  }
                  else if (historyLine.get('oldValue') != null && historyLine.get('newValue') == null){ // when deleting a value from a field
                      // Format the Date and if there's an error, catch it and re
                      try {
                         tempHistory.action = 'Deleted ' + Date.valueOf(historyLine.get('oldValue')).format() + ' in <b>' + fieldLabel + '</b>.';
                    } catch (Exception e){
                         tempHistory.action = 'Deleted ' + String.valueOf(historyLine.get('oldValue')) + ' in <b>' + fieldLabel + '</b>.';
                    }
                  }
                  else{  // all other scenarios
                      String fromText = '';
                    if (historyLine.get('oldValue') != null) {
                         try {
                              fromText = ' from ' + Date.valueOf(historyLine.get('oldValue')).format();
                         } catch (Exception e) {
                              fromText = ' from ' + String.valueOf(historyLine.get('oldValue'));
                         }
                    }
                    
                    String toText = '';
                    if (historyLine.get('oldValue') != null) {
                        try {
                             toText = Date.valueOf(historyLine.get('newValue')).format();
                        } catch (Exception e) {
                             toText = String.valueOf(historyLine.get('newValue'));
                        }
                    }
                    if (toText != ''){
                        tempHistory.action = 'Changed <b>' + fieldLabel + '</b>' + fromText + ' to <b>' + toText + '</b>.';
                    }
                    else {
                        tempHistory.action = 'Changed <b>' + fieldLabel;
                    }
                   }
                   
                   // Add to the list
                   objectHistory.add(tempHistory);
            }
         }
         
         List<Id> userIdList = new List<Id>();
         for (objectHistoryLine myHistory : objectHistory){
             userIdList.add(myHistory.userId);
         }
         Map<Id, User> userIdMap = new Map<ID, User>([SELECT Name FROM User WHERE Id IN : userIdList]);
         
         for (objectHistoryLine myHistory : objectHistory){
             if (userIdMap.containsKey(myHistory.userId) & (myHistory.who != '') ){
                 myHistory.who = userIdMap.get(myHistory.who).Name;
             }
         }
         
         return objectHistory;
    }    
    
    // Function to return Field Label of a object field given a Field API name
    public Static String returnFieldLabel(String fieldName){

        if (GenericHistoryComponentController.myObjectFieldMap.containsKey(fieldName)){
            return GenericHistoryComponentController.myObjectFieldMap.get(fieldName).getDescribe().getLabel();
        }
        else {
            for(Schema.PicklistEntry pickList : historyFieldPicklistValues){
                if (pickList.getValue() == fieldName){
                    if (pickList.getLabel() != null){
                        return pickList.getLabel();
                    }
                    else {
                        return pickList.getValue();
                    }
                }
            }
        }
        return '';
    }
    
    // Inner Class to store the detail of the object history lines    
    public class objectHistoryLine {
        public String  tempCreatedDate {get; set;}
        public String theDate {get; set;}
        public String who {get; set;}
        public Id userId {get; set;} 
        public String action {get; set;}
    }
}