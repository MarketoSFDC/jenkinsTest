//This class handles all operation of Trigger 'accountTrigger'
public class AccountTriggerHandler{

    //This method called from class methods,  beforeInsertSDP and beforeUpdateSDP
    public static void updateSDPFields(List<Account> triggerNew){
        Map<String, List<Account>> mapNameAccount = new Map<String, List<Account>>();

        for(Account objAcc : triggerNew){
            if(String.isNotBlank(objAcc.SDR_Owner_Picklist__c)){
                if(!mapNameAccount.containsKey(objAcc.SDR_Owner_Picklist__c)){
                    mapNameAccount.put(objAcc.SDR_Owner_Picklist__c, new List<Account>());
                }
                mapNameAccount.get(objAcc.SDR_Owner_Picklist__c).add(objAcc);   
            }
            else{
                //Assign fields null value
                objAcc = copyUserValues(new User(),objAcc);
            }
        }

        //Query User Object
        if(!mapNameAccount.isEmpty()){
            Set<String> setSDPNames = mapNameAccount.keySet();
            //Update fields for Account
            for(User objUser : [SELECT Id, Email, Name, FirstName, LastName, Phone, Title FROM User WHERE Name IN : setSDPNames AND IsActive = true AND IsPortalEnabled = false]){
                //Get List of Accounts based on Name
                List<Account> tempAccount = mapNameAccount.get(objUser.Name);
                for(Account objTempAcc : tempAccount){
                    objTempAcc = copyUserValues(objUser,objTempAcc);
                }
            }
        }  
            
    }

    public static Account copyUserValues(User srcUser,Account desAcc){
        desAcc.SDR_Owner_Email_Address__c = truncateField(Account.SDR_Owner_Email_Address__c ,srcUser.Email);
        desAcc.SDR_Owner_First_Name__c = truncateField(Account.SDR_Owner_First_Name__c ,srcUser.FirstName);
        desAcc.SDR_Owner_Last_Name__c = truncateField(Account.SDR_Owner_Last_Name__c ,srcUser.LastName);
        desAcc.SDR_Owner_Phone_Number__c = truncateField(Account.SDR_Owner_Phone_Number__c ,srcUser.Phone);
        desAcc.SDR_Owner_Title__c = truncateField(Account.SDR_Owner_Title__c ,srcUser.Title);
        return desAcc;
    }

    private static String truncateField(Schema.SObjectField sobjField,String value){
        Integer fieldLength = sobjField.getDescribe().getLength();
        return String.isBlank(value) || value.length() <= fieldLength ? value : value.substring(0,fieldLength - 1);
    }    
   
}