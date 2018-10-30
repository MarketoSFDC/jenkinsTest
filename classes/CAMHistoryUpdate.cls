public class CAMHistoryUpdate{

    public static boolean isAccountupdateExecuted = false;

    public static void AccountUpdate(List<Customer_Account_Management_History__c> triggerNew){
        
        List<Account> acc2update = new List<Account>();       
        //Setting map for CAM History records
        Map<Id,Customer_Account_Management_History__c> CAMHistory = new Map<Id,Customer_Account_Management_History__c>();        
        Set<Id> accIds = new Set<Id>();  
        MAP<ID, Customer_Account_Management_History__c>  NewestCAMRecord = New MAP<ID, Customer_Account_Management_History__c> ();
        //Setting the markoRecordId to the RecordId value for the Marketo record type
        Id marketoRecordId  = Schema.SObjectType.Customer_Account_Management_History__c.getRecordTypeInfosByName().get('Marketo').getRecordTypeId();
        
        
        for(Customer_Account_Management_History__c camHistry : triggerNew)       
        {
            //Checking if CAM record has account information
            if(camHistry.Account__c != null){
                //Adding the account Id from to the accIds list and putting the camHistry record to the CAMHistory map
                accIds.add(camHistry.Account__c);
                CAMHistory.put(camHistry.Account__c,camHistry);
            }
        }
		
        //Mapping the newest CAM record per account to the map NewestCAMRecord
        NewestCAMRecord = getNewestCAMRecord(accIds);
        
        {
        if(!accIds.isEmpty()){
            for(Id accId : accIds){
                Account acc = new Account(Id = accId);
                //Rolling up CAM History data to account level if the record type is Marketo and is newest CAMRecord on account   
                if(!CAMHistory.isEmpty() && CAMHistory.containsKey(acc.id) && CAMHistory.get(acc.id).RecordTypeId == marketoRecordId && NewestCAMRecord.get(acc.id).CreatedDate == CAMHistory.get(acc.id).CreatedDate){
                    acc.Temperature_Contact__c    	  = CAMHistory.get(acc.id).Contact__c;
                    acc.Temperature_Next_Step__c  	  = CAMHistory.get(acc.id).Notes_Next_Steps__c;
                    acc.Temperature_Reason__c     	  = CAMHistory.get(acc.id).Summary__c;
                    acc.Temperature__c            	  = CAMHistory.get(acc.id).Temperature__c;
                    acc.Temp_Reason__c            	  = CAMHistory.get(acc.id).Temperature_Reason__c;
                    acc.Temperature_Sub_Reason__c 	  = CAMHistory.get(acc.id).Temperature_Sub_Reason__c;
                    acc.First_Business_Priority__c    = CAMHistory.get(acc.id).First_Business_Priority__c;
                    acc.Second_Business_Priority__c   = CAMHistory.get(acc.id).Second_Business_Priority__c;
                    acc.Tertiary_Business_Priority__c = CAMHistory.get(acc.id).Tertiary_Business_Priority__c;
                    //Setting the last Quarterly Business Review date on an account if the Purpose for the Customer Success Management Record was QBR
                        if(CAMHistory.get(acc.id).Purpose__c.contains(System.Label.CAM_Purpose)){
                        acc.Last_QBR_Date__c = Date.Today();
                    }
                    acc2update.add(acc);
                }
             }
        	}
        }
        
        if(!acc2update.isEmpty()){
           try{
               update acc2update;
           }catch(exception ex){
               system.debug('GOT AN EXCEPTION_____'+ex);
           }
        }
    }
    
      Static MAP<ID, Customer_Account_Management_History__c> getNewestCAMRecord(SET<ID> accIDS)
      {
        //Declaring Map of CAMRecords and List of CAMRecords
       MAP <ID, Customer_Account_Management_History__c> CamCreatedRecords = new Map <ID, Customer_Account_Management_History__c> ();
       List<Customer_Account_Management_History__c> CAMCreatedDates = New List<Customer_Account_Management_History__c> ();
        
          //Getting List of the newest CAMrecord per account
       CAMCreatedDates = [Select Id, CreatedDate, Account__c From Customer_Account_Management_History__c Where Account__c in :accIDS Order By CreatedDate Desc LIMIT 1];
			
          //Putting CAM records on CamHistoryCreated Map by AccountId
          for (Customer_Account_Management_History__c CAMCreatedDate : CAMCreatedDates )
          {
              CamCreatedRecords.put(CAMCreatedDate.Account__c, CAMCreatedDate);
          }
          
          return CamCreatedRecords;
    }
}