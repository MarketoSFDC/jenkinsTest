/*******************************************************************
*Modified By: Sumit Bhatt, Grazitti Interactive
*Purpose: REF: #APPS-18580# Update Test Classes :: Moved the testmethods to class EchoSign_Quote_Test
*Tracking: One cn track the changes by searching ticket number in code
*******************************************************************/

global with sharing class EchoSign_QuoteGlobal
{
    
    public Webservice static boolean GetQuotes(String ActionID)
    {
    
        List<QuoteDocument> obj = [select Id from QuoteDocument where QuoteId =: ActionID limit 1];
        
        if(obj != null && obj.size() > 0)
            return true;
        return false;
    }
    
    public Webservice static String GetContactName(String ActionID)
    {
    
        List<Quote> objQuote = [select Id, Contact.Name from Quote where Id =: ActionID limit 1];
        
        if(objQuote != null && objQuote.size() > 0)
            return objQuote[0].Contact.Name;
        return null;
    }
}