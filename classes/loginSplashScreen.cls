public class loginSplashScreen {

    public PageReference FinishLoginFlowHome() 
    {
        return Auth.SessionManagement.finishLoginFlow();
    }
}