trigger UpdateAuthContactOnboardingInfo on Authorized_Contact_Onboarding__c (after insert, after update) {

    list<Authorized_Contact__c> authList =new list<Authorized_Contact__c>( [select id,Video_last_open__c ,Video_Seen__c,Video_Seen_Time__c,No_of_times_Video_open__c ,Email_Read__c,Date_Opened__c,No_of_times_email_open__c,Last_Opened__c  from Authorized_Contact__c where id=:trigger.new[0].Authorized_Contact_Id__c] );
    system.debug('authList===>'+authList);
    if(!authList.IsEmpty()) {
        authList[0].Email_Read__c                           =    trigger.new[0].Email_Read__c;
        authList[0].Date_Opened__c                          =    trigger.new[0].Email_Date_Opened__c; 
        authList[0].No_of_times_email_open__c               =    trigger.new[0].No_of_times_email_open__c;
        authList[0].Last_Opened__c                          =    trigger.new[0].Email_Last_Opened__c;             
        authList[0].Video_Seen__c                           =    trigger.new[0].Video_Seen__c;
        authList[0].Video_Seen_Time__c                      =    trigger.new[0].Video_Seen_Time__c; 
        authList[0].No_of_times_Video_open__c               =    trigger.new[0].No_of_times_Video_open__c;
        authList[0].Video_last_open__c                      =    trigger.new[0].Video_last_open__c;        
        authList[0].Onboarding_Complete__c                  =    trigger.new[0].Onboarding_Complete__c;
        update authList[0];   
    }
             
}