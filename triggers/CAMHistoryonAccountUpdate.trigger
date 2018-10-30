trigger CAMHistoryonAccountUpdate on Customer_Account_Management_History__c (after insert,after update) {

    if(!CAMHistoryUpdate.isAccountupdateExecuted){
    
        CAMHistoryUpdate.isAccountupdateExecuted = true;
        CAMHistoryUpdate.AccountUpdate(Trigger.new);
        
    }

}