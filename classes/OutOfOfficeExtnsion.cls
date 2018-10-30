public with sharing class OutOfOfficeExtnsion {
    public Out_Of_Office__c temp   {get;set;}
    public String Var01 { get; set; }
    public String TseName{ get; set; }
    public Boolean Bool{ get; set; }
    public Id TseId{ get; set; }
    
    public OutOfOfficeExtnsion(ApexPages.StandardController controller) {
        Bool = false;
        Map<string, string> timezoneMap = new Map<string, string>();
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Schema.sObjectType.User.fields.TimeZoneSidkey;
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            timezoneMap.put(f.getValue(),f.getLabel());
        }   
    
        temp = (Out_Of_Office__c) controller.getrecord();
        Var01 = Apexpages.currentPage().getParameters().get('MyVariable');
        user Usr = [select id,name,timezonesidkey from user where id =: Var01];
        TseName = Usr.name;
        TseId = Usr.Id;
        temp.Time_Zone__c = timezoneMap.get(Usr.timezonesidkey);        
    }    
    
     public PageReference BacktoOoo(){           
        PageReference reRend = new PageReference('/apex/OutOfOfficeEdit?User='+TseName);        
        return reRend;
    }
    

        public PageReference save(){
            String StartDate         =     String.valueOf(temp.StartDate__c);
            String EndDate           =     String.valueOf(temp.EndDate__c);           
            Out_Of_Office__c Ooo     =     new Out_Of_Office__c();      
            Ooo.Tse_name__c          =     Var01;  
            Ooo.StartDate__c         =     temp.StartDate__c;
            Ooo.Time__c              =     temp.Time__c;
            Ooo.EndDate__c           =     temp.EndDate__c;
            Ooo.EndTime__c           =     temp.EndTime__c;
            Ooo.Frequency__c         =     temp.Frequency__c;
            Ooo.TimeZone__c          =     temp.Time_Zone__c;
            Ooo.Time_Zone__c         =     temp.Time_Zone__c;
            Ooo.StartDateString__c   =     (temp.Time__c == Null || temp.Time__c == '' ?  StartDate + ' 00:00:00' : StartDate + ' ' +temp.Time__c+ ':00');
            Ooo.EndDAteString__c     =     (temp.EndTime__c == Null || temp.EndTime__c == '' ?  EndDate   + ' 00:00:00' : EndDate   + ' ' +temp.EndTime__c+ ':00');   
            try{
                insert Ooo;  
                if(Ooo.Id != null) SupportUtil.sendEmailNotificatioToManager(TseId,Ooo.Id);
                PageReference reRend = new PageReference('/apex/OutOfOfficeEdit?id='+Ooo.id);
                Return reRend;
            }
            catch(Exception ex){
                Bool = True;
                ApexPages.addMessages(ex);
            }
            return null;      
        }   
     
}