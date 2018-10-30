@istest
public class loginSplashScreentest {

     static testMethod void test_login(){
        loginSplashScreen controller = new LoginSplashScreen();       
        PageReference pageRef = Page.LoginSplashScreen; // Adding VF page Name here
        Test.setCurrentPage(pageRef);
        controller.FinishLoginFlowHome();
         
       }
}