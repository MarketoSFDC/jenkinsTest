/*********************************************
 * Class Name : Create_New_Quote_Controller_Test
 * Description :  
 * *****************************************/
@IsTest
public class Create_New_Quote_Controller_Test {

  @IsTest
    public static void testMethod1() {
    
        
        ApexPages.StandardController stdController = new ApexPages.StandardController((new Account(name ='Test Account')));
        Create_New_Quote_Controller cnqcObj = new Create_New_Quote_Controller(stdController);
        cnqcObj.getQuoteID();
        PageReference pageRef = cnqcObj.getQID();
        String quotoRecordid = cnqcObj.quotoRecordid;
    
    }

}