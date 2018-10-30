public with sharing class cont_ext_opportunity_override {

    public Opportunity myOpp{get;set;}
    
    public static String errormsg1= 'This Opportunity is a Renewal Opportunity.  You may not Override';
    //public static String errormsg2='This Opportunity already has been updated with an Amended Contract.  You may not currently use this Opportunity to Override the Amended Opportunity';
    public static String errormsg2='Amend functionality is only utilized with Solution Customers.  Please use Feature or Legacy tools to upgrade this Customer.  If you need assistance, submit a Sales Ops Case.';
   // public static String errormsg3= 'There are Multiple Active Contracts under this Account.  You may not currently use this Opportunity to Override the Amended Opportunity';
    public static String successmsg1='Active Contract(s) were Found.  Please Select the Contract you Wish to Amend and Press the Amend Button Below to Continue';
    public Boolean isAmendValid{get;set;}
    public List<SelectOption> availablecontracts{get;set;}
    public String selectedContract{get;set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public cont_ext_opportunity_override(ApexPages.StandardController stdController) {
        this.myOpp = (Opportunity)stdController.getRecord();
        myOpp=[Select id, Accountid, SBQQ__AmendedContract__c,SBQQ__RenewedContract__c from Opportunity where id=:myOpp.id];
        isAmendValid=false;

        //Pull Account and Find Active Contract Under that Account
        //If More than One, Alert User there is More than One Active Contract and they need to evaluate
        //If None, Alert user there are no active contracts so no action was taking
        //If 1, Pull that Contract ID and assign to the Amended Contract Field on the Opportunity and Alert User of Success

        //Opportunity oppDetails=[Select Accountid from Opportunity where id=: myOpp.id];
        

    }

    public PageReference amendQuote(){
        //'https://marketo--rubiks--sbqq.cs51.visual.force.com';
        //'https://marketo--rubiks.cs51.my.salesforce.com'
        //
        availablecontracts=new List<SelectOption>();
        List<Contract> contractList=new List<Contract>([Select id, contractNumber  from Contract where Accountid=:myOpp.Accountid and SBQQ__ActiveContract__c=1 and SBQQ__Quote__r.Rubiks_Quote__c=true Order by contractNumber ]);
        if(myOpp.SBQQ__RenewedContract__c!=NULL){
            //Renewal Opportunity
            isAmendValid=false;
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,errormsg1));
             return null;
        }else if(contractList.isEmpty()){
            //No Active Contracts
            isAmendValid=false;
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,errormsg2));
            return null;
        }else if(!contractList.isEmpty()){
            //Correct, Update Opportunity
            //Populate List of Contracts
            isAmendValid=true;
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,successmsg1));
            
            /*for(Contract cont:contractList){
                availablecontracts.add(new SelectOption(cont.id,cont.contractNumber));
            }  */
        }
        try{
            Pricebook2 pb=[Select id from Pricebook2 where Name='MKTO Standard Price Book'];
            myOpp.SBQQ__QuotePricebookId__c=pb.id;
            myOpp.Pricebook2Id=pb.id;
        }catch(queryException q){
            system.debug('Exception in pricebook catch'+ q.getmessage());
        }
            
            myOpp.SBQQ__AmendedContract__c=selectedContract;
            

            try{
                update myOpp;
                
            }catch(DmlException d){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,d.getMessage()));
                system.debug('Exception in update'+d.getMessage());
                 return null;
            }
           

        String instance=[SELECT InstanceName from Organization].InstanceName;
        String myURL=ApexPages.currentPage().getHeaders().get('Host');
        if(test.isRunningTest()){
                myURL='salesforce.com';
            }else{
                myURL=myURL.substring(0,myURL.IndexOf('.') -3) +'--sbqq.' +  instance.toLowerCase() + '.visual.force.com';
            }
        

		system.debug('my opp Id ###########'+myOpp.id);
        String amendUrl='https://' + myURL + '/apex/SelectContractOpp?scontrolCaching=1&id='+ myOpp.id ;
        system.debug('############# amendUrl'+amendUrl);
        PageReference p=new PageReference(amendUrl);
        system.debug('p ###########'+p);
        //p.getParameters().put('id',selectedContract);
        p.setRedirect(true);
        return p;
    }

    public PageReference returnToOpp(){
        PageReference p=new PageReference('/' + myOpp.id);
        p.setRedirect(true);
        return p;
    }
    
}