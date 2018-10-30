@isTest
public class OPTIMIZED_Utility_Test{

  
    static testmethod void UtilityMethod(){
    
       User newUser =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser', 'Mkto', 'cfsId');
       insert newUSer;
       
       Account aa = Utility.insertAccountInTestClasses();
       insert aa;
       
       Contact cc = Utility.insertContactInTestClasses(aa.Id);
       insert cc;
       
       Date dd = date.today();
       
       Opportunity oo = Utility.insertOpportunityInTestClasses(aa.id, cc.id, 'Closed Won', 'New Business',dd ,dd ,dd.addDays(3) ,dd.addDays(3) );
       insert oo;
       
       Date dd2 = Date.Today().addDays(2);
                    
       RecordType rr = [Select Id from Recordtype where id ='01250000000UTA6'];          
       Entitlement ee =Utility.insertEntitlementInTestClasses(rr.id, 'Elite',aa.Id, dd, dd2);
       insert ee;
       
       /*---------------------------Datanyze----------------*/
       String currEspSoln = 'a,b,c';
       string oldEspSoln = 'd,e,f';
       
       String NcurrEspSoln = '';
       string NoldEspSoln = '';
       
       String currEspSolnA = 'a';
       String currEspSolnB = 'b';
       String currEspSolnC = 'c';
       String oldEspSolnA = 'd';
       String oldEspSolnB = 'e';
       String oldEspSolnC = 'f';
       List<String> Current_Solution = new List<String>();
       List<String> Current_ExpSolution = new List <String>();
       Current_Solution.add(currEspSolnA);
       Current_Solution.add(currEspSolnB);
       Current_Solution.add(currEspSolnC);
       
       Current_ExpSolution.add(oldEspSolnA);
       Current_ExpSolution.add(oldEspSolnB);
       Current_ExpSolution.add(oldEspSolnC);
       
       Utility.checkForDatanyzeChange(currEspSoln,oldEspSoln,Current_Solution,Current_ExpSolution );
       Utility.checkForDatanyzeChange(NcurrEspSoln,NoldEspSoln,Current_Solution,Current_ExpSolution );
       Utility.checkForDatanyzeChange(currEspSoln,NoldEspSoln,Current_Solution,Current_ExpSolution );
       Utility.checkForDatanyzeChange(NcurrEspSoln,oldEspSoln,Current_Solution,Current_ExpSolution );
       
       /*---------------------------Datanyze----------------*/
       
       //User uu = Utility.insertCustomerPortalUser(con.id);
       //insert uu;
       
       //Utility.sendEcxeptionMailToDeveloper(,'a@a.com','aaaaaa');
       try{
       
           Account aa1 = Utility.insertAccountInTestClasses();
           insert aa1;
           
           Contact cc1 = Utility.insertContactInTestClasses(aa1.Id);
           insert cc1;
           
           User uu1 = Utility.insertCustomerPortalUser(cc1.id);
           insert uu1;
           
       }catch(Exception ex){
           Utility.sendEcxeptionMailToDeveloper(ex,'a@a.com','aaaaaa');
       }
         
       
    }
     static testmethod void UtilityMethod2(){
         
         
       Account aa = Utility.insertAccountInTestClasses();
       insert aa;
       
       Contact cc = Utility.insertContactInTestClasses(aa.Id);
       insert cc;
       
       User uu = Utility.insertCustomerPortalUser(cc.id);
       insert uu;
         
     }
}