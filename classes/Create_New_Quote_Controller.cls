/*********************************************
 * Class Name : Create_New_Quote_Controller
 * Description : Controller for Create_New_Quote_VF
 * *****************************************/

public class Create_New_Quote_Controller {
    
    public Flow.Interview.CreateNewQuoteFlow quoteFlow { get; set; }
    public string quotoRecordid{get;set;}

    public Create_New_Quote_Controller(ApexPages.StandardController stdController)
    {
        
    }
    
    public String getQuoteID() {
        
        
     if (quoteFlow == null)
        return '';
     else 
        return quoteFlow.QuoteRecordID;
      
    }
    
    public PageReference getQID(){
        
        PageReference pageRef = new PageReference('/apex/SBQQ__sb?scontrolCaching=1&id=' +getQuoteID() + '#quote/le?qId=' + getQuoteID());
        pageRef.setRedirect(true);
        return pageRef;
       
    
    }

}