public class OooList {
    public Out_Of_Office__c temp   {get;set;}
    public List<Out_Of_Office__c> Ooo{get;set;}
    public id OooId{get;set;}
    public OooList(ApexPages.StandardController controller) { 
        temp = (Out_Of_Office__c) controller.getrecord();
    }    
     public List<Out_Of_Office__c> GetsaveList(){         
         List <Out_Of_Office__c> OoOLsit = new List <Out_Of_Office__c>([select id,Start_Date__c,Time_Zone__c,LastModifiedDate,EndDAteString__c,CreatedDate,StartDateString__c,End_Date__c,Timezone__c,Frequency__c,Tse_name__c from Out_Of_Office__c where Tse_name__c =: temp.Tse_name__c  ]);   
         if(OoOLsit.isempty()){             
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Record Found'));          
        } 
         return OoOLsit;   
     }
     
   public pageReference search() {
      GetsaveList();     
      return null;     
    } 
     
    public PageReference Newpage(){           
        PageReference reRend = new PageReference('/apex/OutOfOffice?MyVariable');
        reRend.getParameters().put('MyVariable', temp.Tse_name__c);
        reRend.setRedirect(false);
        return reRend;
    }
    
    public PageReference OnDemandPage(){           
        PageReference reRend = new PageReference('/apex/OnDemandPage?MyVariable');
        reRend.getParameters().put('MyVariable', temp.Tse_name__c);
        reRend.setRedirect(false);
        return reRend;
    }
    
    public void deleteOoo(){
      Ooo = [select id from Out_Of_Office__c where id = :OooId];
      if(Ooo.size() > 0 ){
      delete Ooo;
      }
      GetsaveList();  
   }    
}