/* Name: Create_New_Agreement_Controller
     Description : Controller for Create_New_Agreement_Page
     Author : LK
     History:
     VERSION     AUTHOR               DATE                            DETAIL                                    UserStory/Req#
     1.0 -             
       */
public class Create_New_Agreement_Controller{
    
    String quoteId;
    Boolean isQuoteDocExist;
    
    public Create_New_Agreement_Controller()
    {
         
    }
    
     public PageReference doRedirect()
     {
         isQuoteDocExist = false;
         quoteId =System.currentPageReference().getParameters().get('quoteId');
         system.debug('==quoteId='+quoteId);
         if(quoteId != null)
         {
             isQuoteDocExist = EchoSign_QuoteGlobal.GetQuotes(quoteId);
             if(isQuoteDocExist)
             {
                  return redirectToSelectQuotePdf();
             }
             else
             {
                 return redirectToSignAgreement();
             }
         }
         return null;
     }
     public PageReference redirectToSelectQuotePdf()
     {
          system.debug('==here=11');
          return new PageReference('/apex/EchoSign_selectQuotePdf?Quoteid='+quoteId);
         // pgref.setRedirect(true);
          
     }
     
     public  PageReference redirectToSignAgreement()
     {
          system.debug('==here=');
          return new PageReference('/a05/e?save_new=1&sfdc.override=1&&retURL='+quoteId);
          //pgref.setRedirect(true);
          
     }
}