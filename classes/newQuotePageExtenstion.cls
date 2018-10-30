/***************************************************************
* Created by         : Rajesh Wani
* Created Date       : 11th FEB 2015
* Last Modified By   : Rajesh Wani11th FEB 2015
* Purpose            : This is Extension class for  visualforce page "newQuotePage"
                      This is used for,
                     1. To create the SteelBrick Quote record.
                     2. After creating  SteelBrick Quote record redirecting user to SteelBrick VF page
                   
******************************************************/
public class newQuotePageExtenstion {
    public  SBQQ__Quote__c quote{get;set;}
    public string oppType{get;set;} 
   
     public boolean showerr{get;set;}
     public boolean err{get;set;}
     public boolean noextCont{get;set;}
     public boolean rubikscheck{get;set;}
     public boolean onerubikscontract{get;set;}

     list<Opportunity> opplist  = new list<Opportunity>();
     list<contract> contractlist  = new list<contract>();
      id accid ;
    id oppid ;
    public String quoteType{get;set;}

   
    public newQuotePageExtenstion(ApexPages.StandardController controller) {
      
       oppid = ApexPages.currentPage().getParameters().get('oppid');
       accid = ApexPages.currentPage().getParameters().get('accid');
       quoteType = ApexPages.currentPage().getParameters().get('quotetype');

       quote = (SBQQ__Quote__c)controller.getRecord();
       quote.SBQQ__Account__c     = accid;
       //quote.SBQQ__Opportunity__c = oppid;
       quote.SBQQ__Opportunity2__c = oppid; 
       noextCont                  = false;
       opplist  = [select id,CurrencyIsoCode,name,type,ORC_Segment__c,Account.PO_Required__c  FROM Opportunity WHERE id=: oppid];
          showerr=true;
       quote.Quote_Name__c        = opplist[0].name;
       quote.Opportunity_Type__c  = opplist[0].type;
       quote.CurrencyIsoCode  = opplist[0].CurrencyIsoCode;
       oppType                    = opplist[0].type;
       
       if((oppType =='Upsell/Crossell'|| oppType=='Renewal') && quote.New_Instance_or_Change_to_Existing__c!='New Instance'){
            
            contractList = [SELECT id ,name,accountid,SBQQ__Quote__r.Payment_Frequency__c FROM Contract WHERE accountid=:accid And status='Activated' ORDER BY Createddate DESC LIMIT 1];
       }
       if(!contractList.isEmpty() && oppType=='Renewal'){
           
             showerr=true;
       }
       if(opplist[0].ORC_Segment__c=='CH'){
          quote.Order_Type__c = 'Agency Standard';
       
       }

       if(quotetype=='Solution'){
            quote.Rubiks_Quote__c=true;
          }
      
    }//End of Constructor
    
    //Method to check whether any contracted rubiks quotes exist on this account

    public void checkForContractedRubiks(){

      Integer i=0;
      onerubikscontract=true;
      String oppId=ApexPages.currentPage().getParameters().get('oppid');
      if(oppId!=null && oppId!=''){
          Opportunity MyOpp=[Select id, Accountid,Type,RecordType.Name from Opportunity where id=:oppId];

          if(myOpp.Type=='Upsell/Crossell' && myOpp.RecordType.Name=='Upsell/Crossell'){
            //List<Contract> con=new List<Contract>([Select id, contractNumber,SBQQ__Quote__r.Rubiks_Quote__c  from Contract where Accountid=:myOpp.Accountid and SBQQ__ActiveContract__c=1 Order by contractNumber ]);
            //system.debug(con);
              for(Contract contract:[Select id, contractNumber,SBQQ__Quote__r.Rubiks_Quote__c  from Contract where Accountid=:myOpp.Accountid and SBQQ__ActiveContract__c=1 Order by contractNumber ]){
                if(contract.SBQQ__Quote__r.Rubiks_Quote__c==true){
                  rubikscheck=true;
                }else{
                  onerubikscontract=false;
                }
                i++;
              }

          }  
      }
      
      

    }

    //Method to skip the rubiks check
    public PageReference proceed(){
      rubikscheck=false;
      onerubikscontract=false;
      return null;
    }


    // This method is used to save the Quote record 
    
    public pagereference saveQuote(){
      try{

          if(oppType!=quote.Opportunity_Type__c ){
              
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.warning, '<b>'+system.label.QuoteOpportunityTypeErrMsg+'</b> '));
             return null;
          }
          if((oppType=='New Business' || (quote.New_Instance_or_Change_to_Existing__c=='New Instance' && oppType=='Upsell/Crossell')) && quote.Target_Number_of_Contact_Records__c==null && quote.Target_Number_of_Unique_Visitors__c==null ){
              if(quotetype=='Feature'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.warning, '<b>'+system.label.NewQuoteValidationMsg+'</b> '));
                return null;   
              }
          }
           
         if(quote.New_Instance_or_Change_to_Existing__c =='Change to Existing Instance' && oppType =='Upsell/Crossell' && contractList.isEmpty()){
         
            noextCont = true;
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.warning, '<b>'+system.label.QuoteNoExtContractMsg+'</b> '));
            return null;
         }
          
          quote.Opportunity_Type__c  = opplist[0].type;
          quote.PO_Required__c = opplist[0].Account.PO_Required__c;    
           
          system.debug('quote=============================='+quote);
          insert quote; 
         
          pagereference  pegeEditQuote ; 
          
          if(!contractList.isEmpty() && oppType =='Upsell/Crossell' && quote.New_Instance_or_Change_to_Existing__c =='Change to Existing Instance'){
              pegeEditQuote = new pagereference ('/apex/SBQQ__selectcontract?newid='+quote.id);
          }
          else{
              pegeEditQuote = new pagereference ('/apex/SBQQ__EditQuoteLines?newid='+quote.id);
          }
         
          pegeEditQuote .setRedirect(true);
          return pegeEditQuote; 
      }//End of TRY block
      catch(Exception ex ){
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
          string message=string.valueof(msg);
          String[] errMsg = message.split('EXCEPTION,',2);
          ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,errMsg[1]);
          ApexPages.addMessage(errorMessage);
          return null;
      }//End of Catch block   
    }//End of saveQuote
}