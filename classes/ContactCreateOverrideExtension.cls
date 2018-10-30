/**************************************************************
Company Name  :Jade Global Inc.
Created Date  :10th February 2018
*Purpose    :This is used as extension for visualforce page "ContactCreateOverride"
*            Used to autopopulate mailing address fields
**********************************************************/
public with sharing class ContactCreateOverrideExtension{
    private final Contact con;
    public ContactCreateOverrideExtension(ApexPages.StandardController controller) {
        this.con      = (Contact)controller.getRecord();
        con.AccountID = ApexPages.currentPage().getParameters().get('accid');       
        list<account> accountlist = [select id,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry from account where id =:con.AccountID];
       
        if(!accountlist.isEmpty()){                 
            con.MailingStreet       = (accountlist[0].BillingStreet !=null) ? accountlist[0].BillingStreet : con.MailingStreet;
            con.MailingCity         = (accountlist[0].BillingCity !=null) ? accountlist[0].BillingCity : con.MailingCity;
            con.MailingState        = (accountlist[0].BillingState !=null) ?accountlist[0].BillingState :  con.MailingState;
            con.MailingPostalCode   = (accountlist[0].BillingPostalCode !=null) ?accountlist[0].BillingPostalCode :  con.MailingPostalCode;
            con.MailingCountry      = (accountlist[0].BillingCountry !=null) ?accountlist[0].BillingCountry :  con.MailingCountry;
          }
      }
    public boolean getRedirect(){
        List<RecordType> rt = [select id,name from recordtype where id = : con.RecordTypeId];
        if(!rt.isEmpty() && rt[0].name=='PSA Resource')
        return true;
        return false;
    }
    public string getRecordTypeId(){
        return con.RecordTypeId;
    }

    
 }