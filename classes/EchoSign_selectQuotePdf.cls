/*******************************************************************
*Modified By: Sumit Bhatt, Grazitti Interactive
*Purpose: REF: #APPS-18580# Update Test Classes :: Moved the testmethods to class EchoSign_Quote_Test
*Tracking: One cn track the changes by searching ticket number in code
*******************************************************************/

public with sharing class EchoSign_selectQuotePdf 
{
     
    public EchoSign_selectQuotePdf()
    {
        quote = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('Quoteid'));
        strErrorMessage = '';
        isError = false;
        isInserted = false;
        checkDocuments();
    }
    
    List<Quote> lstQuoteContact = new List<Quote>();
    
    public PageReference checkDocuments()
    {
        lstQuoteContact = new List<Quote>();
        lstQuoteDoc = [select Id, Name, Quote.Name from QuoteDocument where QuoteId =: quote order by CreatedDate desc limit 1000];
        lstQuoteContact = [select Id, Contact.Name, Name, Opportunity.Id, Email from Quote where Id =:quote limit 1];
        if(lstQuoteContact != null && lstQuoteContact.size() > 0)
        {
            strQuoteName = lstQuoteContact[0].Name;
            ContactName = lstQuoteContact[0].Contact.Name;
            ContactId = lstQuoteContact[0].ContactId;
            OpportunityId = lstQuoteContact[0].Opportunity.Id;
        }
        
        if(lstQuoteDoc.size() > 0)
        {
            strSelectedQuote = lstQuoteDoc[0].Id;
            isDocumentExists = true;
        }
        else
        {
            isDocumentExists = false;
        }
        return null;
    }
    public String strQuoteName
    {   get; set;   }

    public String ContactName
    {    get; set;    }
    public String ContactId
    {    get; set;    }
    public Boolean isDocumentExists
    {    get; set;    }
    public String OpportunityId
    {    get; set;    }
    
    List<QuoteDocument> lstQuoteDoc = new List<QuoteDocument>();
    
    
    public String quote 
    {    get; set;    }
    
    public Boolean isInserted
    {    get; set;    }
    
    public String strSelectedQuote
    {    get; set;    }
    
    public Boolean isError
    {    get; set;    }

    public String strErrorMessage
    {   get; set;   }
    
    public String agreementId
    {    get; set;    }
    
    List<SelectOption> optionsQuotePdf = new List<SelectOption>();
    Map<String, QuoteDocument> mapQuoteDoc = new Map<String, QuoteDocument>();
    
    public List<SelectOption> getQuotePdf()
    {
        optionsQuotePdf = new List<SelectOption>();
        if(lstQuoteDoc.size() > 0)
        {
            optionsQuotePdf.add(new SelectOption('', '--None--'));
            for(Integer i = 0; i < lstQuoteDoc.size(); i++)
            {
                optionsQuotePdf.add(new SelectOption(lstQuoteDoc[i].Id,lstQuoteDoc[i].Name));
                //mapQuoteDoc.put(lstQuoteDoc[i].Id, lstQuoteDoc[i]);
            }
        }
        return optionsQuotePdf;
    }
    
    public PageReference next()
    {
        isError = false;
            echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c();
            try
            {
                
                agreement.Name = strQuoteName;
                if(ContactId  != null && ContactId != '')
                {
                    agreement.echosign_dev1__Recipient__c = ContactId ;
                } else if(lstQuoteContact[0].Email != null && lstQuoteContact[0].Email != '')
                {
                     agreement.echosign_dev1__More_Recipients__c = lstQuoteContact[0].Email;
                }
                agreement.Quote__c = quote;
                agreement.echosign_dev1__Opportunity__c = OpportunityId ;
                agreement.echosign_dev1__SignatureOrder__c = '';
                
                insert agreement;
            }
            catch(DmlException e) 
            {
                isError = true;
                strErrorMessage = e.getMessage();
                ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.ERROR, strErrorMessage ));  
            }
            
            isInserted = true;
            agreementId = agreement.id;
            if(!isError)
            {
                if(strSelectedQuote != null && strSelectedQuote != '')
                 {
                    
                    try
                    {
                        Attachment attachment = new Attachment();
                        
                        transient Blob docBlob = [select Document from QuoteDocument where Id =: strSelectedQuote].Document;
                        
                        attachment.Body = docBlob ;
                        attachment.Name = [select Name from QuoteDocument where Id =: strSelectedQuote].Name;
                        attachment.ParentId = agreementId ;
                        insert attachment;
                    }
                    catch(DmlException e) 
                    {
                        isError = true;
                        strErrorMessage = e.getMessage();
                        ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.ERROR, strErrorMessage ));  
                    }
                }
               else
               {
               }
            }
       
        return null;
    }
}