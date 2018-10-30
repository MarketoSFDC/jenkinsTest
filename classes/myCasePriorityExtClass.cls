public class myCasePriorityExtClass{
    Public Case CasePrio{get;set;}
    public myCasePriorityExtClass(ApexPages.StandardController controller) {
        CasePrio=(Case)controller.getRecord();
    }
    Public PageReference Save() {         
        try {
            update CasePrio;
            PageReference returnURL = new PageReference('/apex/ChangePriority');
            returnURL.getParameters().put('id', CasePrio.Id);
            returnURL.getParameters().put('selfClose', 'true');
            returnURL.setRedirect(true);
            return returnURL;                        
        } catch (Exception ex) {
            ApexPages.addMessages(ex);            
        }
        return null;
    }
    
    @isTest public static void MyTestMethod()
    {
        Case myCase = new Case(Status = 'New', Priority = 'P3', Subject = 'Test', Description = 'Test Description');
        insert myCase;
        myCase.Priority = 'P4';
        ApexPages.StandardController ctrl = new ApexPages.StandardController(myCase);         
        myCasePriorityExtClass myCaseP = new myCasePriorityExtClass(ctrl);
        myCaseP.Save();            
    }
     
     
}