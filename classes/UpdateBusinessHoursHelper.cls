public with sharing class UpdateBusinessHoursHelper {
    public static boolean b=false;
    //A boolean that is set and then checked at the beginning of update triggers to be sure they only execute once
    public static  void  recursiveUpdater(Boolean tempBool,List<Case> myCaseList){
        b=tempBool;
        update myCaseList;        
    }
    
    @isTest
    public static void runTest()
    {
        //Test.startTest();
        List<Case> myTestCases  = new List<Case>(); 
        Case caseObj1 = new Case(Status = 'New', Priority = 'P3', Subject = 'Test1', Description = 'Test Description2');
        insert caseObj1;  
        Case caseObj2 = new Case(Status = 'New', Priority = 'P2', Subject = 'Test2', Description = 'Test Description1');
        insert caseObj2;  
        myTestCases.Add(caseObj1);
        myTestCases.Add(caseObj2);
        
        if(myTestCases.size() > 0)         
        {
            UpdateBusinessHoursHelper.recursiveUpdater(true,myTestCases);                   
        }
        //Test.stopTest();    
    }
}