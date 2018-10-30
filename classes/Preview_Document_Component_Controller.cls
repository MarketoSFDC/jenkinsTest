/* Name: Preview_Document_Component_Controller
     Description : Controller for Preview_Document_Component component
     Author : LK
     History:
     VERSION     AUTHOR               DATE                            DETAIL                                    UserStory/Req#
     1.0 -             
       */
public class Preview_Document_Component_Controller {
    
    @AuraEnabled
    public static String validateGenerateDocument(Id quoteId)
    {
        return PreviewGenerateDocumentValidate.validateGenerateDocument(quoteId);
    }

}