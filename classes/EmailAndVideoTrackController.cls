global class EmailAndVideoTrackController{
    global Id parId;
    global EmailAndVideoTrackController(){
        parId = ApexPages.currentPage().getParameters().get('id') != NULL?ApexPages.currentPage().getParameters().get('id'):'';     
        system.debug('controller called =====>>>' + parId);           
    }   
    global void UpdateAuth(){
        system.debug('parId called =====>>>'+parId);
        list<Authorized_Contact_Onboarding__c> authOnbList = new list<Authorized_Contact_Onboarding__c>([select id,Video_last_open__c ,Video_Seen__c,Video_Seen_Time__c,No_of_times_Video_open__c ,Email_Read__c,Email_Date_Opened__c,No_of_times_email_open__c,Email_Last_Opened__c  from Authorized_Contact_Onboarding__c where Authorized_Contact_Id__c=:parId] );
        if(!authOnbList.IsEmpty()){            
            authOnbList[0].Email_Read__c =true;
            if(authOnbList[0].Email_Date_Opened__c ==null) authOnbList[0].Email_Date_Opened__c = system.now();
            if(authOnbList[0].No_of_times_email_open__c ==null){
                authOnbList[0].No_of_times_email_open__c = 1;
            }else{
                authOnbList[0].No_of_times_email_open__c += 1;
            }
            authOnbList[0].Email_Last_Opened__c = system.now();
            system.debug('parId called =====>>>'+parId);
            update authOnbList[0];   
        }else{
            Authorized_Contact_Onboarding__c authOnb = new Authorized_Contact_Onboarding__c();
            authOnb.Authorized_Contact_Id__c = parId;
            authOnb.Email_Read__c =true;
            if(authOnb.Email_Date_Opened__c ==null) authOnb.Email_Date_Opened__c = system.now();
            if(authOnb.No_of_times_email_open__c ==null){
                authOnb.No_of_times_email_open__c = 1;
            }else{
                authOnb.No_of_times_email_open__c += 1;
            }
            authOnb.Email_Last_Opened__c = system.now();
            system.debug('parId called =====>>>'+parId);
            insert authOnb;
        }
    }
    
     global void CustomerCommunicationTrack(){
        system.debug('parId called =====>>>'+parId);
        list<Customer_Communication_Action__c> OutreachList = new list<Customer_Communication_Action__c>([select id, Email_Read__c, Email_Date_Opened__c, Number_of_Times_Email_Opened__c, Email_Last_Opened__c from Customer_Communication_Action__c where id=:parId] );
        if(!OutreachList.IsEmpty()){
            OutreachList[0].Email_Read__c = true;
            if(OutreachList[0].Email_Date_Opened__c == null) OutreachList[0].Email_Date_Opened__c = system.now();
            if(OutreachList[0].Number_of_Times_Email_Opened__c == null){
                OutreachList[0].Number_of_Times_Email_Opened__c = 1;
            }else{
                OutreachList[0].Number_of_Times_Email_Opened__c += 1;
            }
            OutreachList[0].Email_Last_Opened__c = system.now();
            system.debug('parId called =====>>>'+parId);          
            update OutreachList[0];
        }                     
    }
    
    
    global PageReference VideoTrack(){
        //id parId = ApexPages.currentPage().getParameters().get('id');
        
        system.debug('parId called =====>>>'+parId);
        list<Authorized_Contact_Onboarding__c> authOnbList = new list<Authorized_Contact_Onboarding__c>([select id,Video_last_open__c ,Video_Seen__c,Video_Seen_Time__c,No_of_times_Video_open__c ,Email_Read__c,Email_Date_Opened__c,No_of_times_email_open__c,Email_Last_Opened__c  from Authorized_Contact_Onboarding__c where Authorized_Contact_Id__c=:parId] );
        if(!authOnbList.IsEmpty()){
            authOnbList[0].Video_Seen__c = true;
            if(authOnbList[0].Video_Seen_Time__c == null) authOnbList[0].Video_Seen_Time__c = system.now();
            if(authOnbList[0].No_of_times_Video_open__c == null){
                authOnbList[0].No_of_times_Video_open__c = 1;
            }else{
                authOnbList[0].No_of_times_Video_open__c+= 1;
            }
            authOnbList[0].Video_last_open__c = system.now();
            authOnbList[0].Onboarding_Complete__c=true;
            system.debug('parId called =====>>>'+parId);          
            authOnbList[0].Authorized_Contact_Id__c = parId;
            update authOnbList[0];
        }else{
            Authorized_Contact_Onboarding__c authOnb = new Authorized_Contact_Onboarding__c();
            authOnb.Authorized_Contact_Id__c = parId;
            authOnb.Video_Seen__c = true;
            if(authOnb.Video_Seen_Time__c == null) authOnb.Video_Seen_Time__c = system.now();
            if(authOnb.No_of_times_Video_open__c == null){
                authOnb.No_of_times_Video_open__c = 1;
            }else{
                authOnb.No_of_times_Video_open__c+= 1;
            }
            authOnb.Video_last_open__c = system.now();
            authOnb.Onboarding_Complete__c=true;
            system.debug('parId called =====>>>'+parId);          
            insert authOnb;
        }           
        PageReference pageRef = new PageReference('http://ec2-52-4-11-66.compute-1.amazonaws.com:3000/videos/OnboardingVideo_v2.mp4');
        return pageRef.setRedirect(true);             
        return null;
    }
}