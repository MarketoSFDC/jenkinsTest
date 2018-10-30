@isTest(SeeAllData=true)

private class testApplyForCreditService {
    
   @istest  static void testWsApplyforCredit() {              
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl ());
        string aid='0015000000Fduuv';
        string oppid='0065000000KIQnL';
        // Call the method that invokes a callout
               User u = [select Name,ID from user where id = :Userinfo.getUserId()];
    
         System.runAs(u){
            
         ApplyForCreditService.ApplyForCredit(aid,oppid);
         creditappMessageEaiDnbiCom.UpdateCreditApplicationResult ucar= new creditappMessageEaiDnbiCom.UpdateCreditApplicationResult();
         creditappMessageEaiDnbiCom.ApplyForCreditResult afcr =new creditappMessageEaiDnbiCom.ApplyForCreditResult();
         businessbureauDtoEaiDnbiCom bt=new businessbureauDtoEaiDnbiCom();
         businessbureauDtoEaiDnbiCom.BureauCompanyDTO btw=new businessbureauDtoEaiDnbiCom.BureauCompanyDTO();
         businessbureauDtoEaiDnbiCom.ArrayOfBureauCompanyDTO aobc=new businessbureauDtoEaiDnbiCom.ArrayOfBureauCompanyDTO ();
         creditappDtoEaiDnbiCom.CompanyInfoDTO cidto = new creditappDtoEaiDnbiCom.CompanyInfoDTO();
         creditappDtoEaiDnbiCom.GetListOfApplicationsRequestDTO  gloardto =new creditappDtoEaiDnbiCom.GetListOfApplicationsRequestDTO();
         creditappDtoEaiDnbiCom.GetCreditApplicationsResultDTO cgardto = new creditappDtoEaiDnbiCom.GetCreditApplicationsResultDTO();
         creditappDtoEaiDnbiCom.ArrayOfCreditApplicationDTO  aocadto = new  creditappDtoEaiDnbiCom.ArrayOfCreditApplicationDTO(); 
         creditappDtoEaiDnbiCom.CreditApplicationDTO cappdto = new creditappDtoEaiDnbiCom.CreditApplicationDTO();
         creditappDtoEaiDnbiCom.CreditApplicationECFDTO caecfdto =new creditappDtoEaiDnbiCom.CreditApplicationECFDTO();
         creditappDtoEaiDnbiCom.UpdateCreditApplicationRequestDTO ucardewto = new creditappDtoEaiDnbiCom.UpdateCreditApplicationRequestDTO();
         creditappDtoEaiDnbiCom.BureauErrorDTO bedto = new creditappDtoEaiDnbiCom.BureauErrorDTO(); 
         creditappDtoEaiDnbiCom.CorporateLinkageDTO cldto = new creditappDtoEaiDnbiCom.CorporateLinkageDTO();
         creditappDtoEaiDnbiCom.PerformECFActionRequestDTO pecfardto =new creditappDtoEaiDnbiCom.PerformECFActionRequestDTO();
         creditappMessageEaiDnbiCom.ApplyForCreditEnhancedResult response = new creditappMessageEaiDnbiCom.ApplyForCreditEnhancedResult();
         
         }
    
  
        
        // Verify that a fake result is returned
        //System.assertEquals('Mock response', output); 
    }
}