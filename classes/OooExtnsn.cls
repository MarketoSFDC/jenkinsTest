public with sharing class OooExtnsn{
    public Out_Of_Office__c temp   {get;set;}
    public id OooId;
    public OooExtnsn(ApexPages.StandardController controller) {   
        temp = (Out_Of_Office__c) controller.getrecord();
        OooId = controller.getid();    
    }    
    
     public PageReference BacktoOoo(){           
        PageReference reRend = new PageReference('/apex/OutOfOfficeEdit');
        return reRend;
    }
    
    public PageReference UpdateOoo(){
    
        String StartDate         =     String.valueOf(temp.StartDate__c);
        String EndDate           =     String.valueOf(temp.EndDate__c);           
        Out_Of_Office__c Ooo = [select id,Start_Date__c,Time_Zone__c,LastModifiedDate,EndDAteString__c,CreatedDate,StartDateString__c,End_Date__c,Timezone__c,Frequency__c,Tse_name__c from Out_Of_Office__c where id =:OooId ];
        //Ooo.id                   =     ApexPages.currentPage().getParameters().get('id');              
        Ooo.Tse_name__c          =     temp.Tse_name__c;  
        Ooo.StartDate__c         =     temp.StartDate__c;
        Ooo.Time__c              =     temp.Time__c;
        Ooo.EndDate__c           =     temp.EndDate__c;
        Ooo.EndTime__c           =     temp.EndTime__c;
        Ooo.Frequency__c         =     temp.Frequency__c;
        Ooo.TimeZone__c          =     temp.Time_Zone__c;
        Ooo.Time_Zone__c         =     temp.Time_Zone__c;
        Ooo.StartDateString__c   =     (temp.Time__c == Null || temp.Time__c == '' ?  StartDate + ' 00:00:00' : StartDate + ' ' +temp.Time__c+ ':00');
        Ooo.EndDAteString__c     =     (temp.EndTime__c == Null || temp.EndTime__c == '' ?  EndDate   + ' 00:00:00' : EndDate   + ' ' +temp.EndTime__c+ ':00');   
  
        Update Ooo; 
        PageReference reRend = new PageReference('/apex/OutOfOfficeEdit?id='+Ooo.id);
        Return reRend;       
    }         
}