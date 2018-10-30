@isTest
public class AccountUpdate_Test{  
 
    public static TestMethod void Method1(){
        Account acc = new Account();
       acc.name = 'testAccount';
       insert acc;
       
       Contact con=new contact();
       con.accountid=acc.id;
       con.lastname='tester';
       insert con;
       
       Case cs=new Case();
       cs.accountid = acc.id;
       cs.contactid=con.id;
       cs.origin = 'Voicemail';
       insert cs;
       cs.origin ='Phone';
       update cs;
    }
    
    }