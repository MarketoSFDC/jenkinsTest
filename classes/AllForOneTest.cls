@isTest
public class AllForOneTest{

    static testMethod void TestPrintOrder(){
       
        
        MKT_PrintOrder mkt = new MKT_PrintOrder();
        MKT_ShoppingCart mktshop = new MKT_ShoppingCart();
        MKT_BatchAssign batch = new MKT_BatchAssign ();
        MKT_PaymentController pay = new MKT_PaymentController();
        MKT_ShoppingCart.CartItemWrapper cert = new MKT_ShoppingCart.CartItemWrapper();
        MKT_ShoppingCart.PaymentInfo infos = new MKT_ShoppingCart.PaymentInfo();
        MKT_ShoppingCart.PaymentInfo infoss = new MKT_ShoppingCart.PaymentInfo('Test123');
        
        mktshop.GetCartItems();
        mktshop.CheckoutNow();
        //mktshop.getProductPricebook('Testings');
        mktshop.DeleteFromCart();
        mktshop.ChangePayment();
        mktshop.getIsShowChange();
        mktshop.ValidatePaymentData();
        mktshop.SaveOrder();
        mktshop.FillHTMLBody();
        mktshop.FillBillingAddress();
        mktshop.EditOrder();
        mktshop.UpdateQuantity();
        mktshop.getStates();
        mktshop.getCardTypes();
        mktshop.getYears();
        mktshop.getTotalPrice();
        mktshop.SubmitOrder();
        mktshop.InitShoppingCart();
        mktshop.BackStep();
        mktshop.PreviewOrder();
        
        cert.getCost();
        cert.getSubtotal();
        cert.CourseName = 'String';
        cert.Type = 'Test';
        cert.Location = 'Test';
        cert.StartSess = 'Test';
        cert.EndSess = 'Test';
        cert.EventId = 'Test';
        cert.ClassId = 'Test';
        cert.Quantity = 1;
        cert.ProductId = 'Test';
        cert.Description = 'Test';
        cert.CartItemId = 'Test';
        cert.IsPaid = true;
        cert.IsExpired = true;
        
        infos.getCardEnding();
        infos.getCardNumberCoded();
        infos.Title = 'Test';
        infos.TestTransactionId = 'Test';
        infos.ProductId= 'Test';
        infos.Description = 'Test';
        infos.Quantity = 'Test';
        infos.CardType = 'Test';
        infos.ExpirationMonth = 'Test';
        infos.ExpirationYear = 'Test';
        infos.Code = 'Test';
        infos.Phone = 'Test';
        infos.Address2 = 'Test';
        infos.Address2 = 'Test';
        
        mktshop.ResultCode= 'Test';
        mktshop.NewQuantity= 'Test';
        mktshop.respString= 'Test';
        mktshop.ResponseMessage= 'Test';
        mktshop.IsOrderError = true;
        mktshop.HTMLBody= 'Test';
        mktshop.SuccessPayment =true;
        
        //infos.PaymentInfo();
        //infos.PaymentInfo();
        
        
        
        batch.start(null);
        batch.execute(null,null);
        batch.finish(null);
        pay.AddToCart();
        pay.setCookie();
        //pay.CheckAssignEvent();
        
        List<Account> accList = new List<Account>();
Account acc = new Account();
                        acc.Name                 = 'GRAZITTI TEST ACCOUNT 1';
                        acc.Sales_Region__c      = 'North America';
                        acc.Business_Unit__c     = 'AMER-SB';
                        acc.BillingCity          = 'NewYork';
                        acc.BillingCountry       = 'United States';
                        acc.BillingStreet        = 'Test Street';
                        acc.BillingState         = 'Test Billing State';
                        acc.BillingPostalCode    = '12345';
                        acc.ShippingCity         = 'Chandigarh';
                        acc.ShippingCountry      = 'India';
                        acc.ShippingPostalCode   = '12345';
                        acc.ShippingState        = '';
                        acc.ShippingStreet       = 'Test Shipping Street';
                        acc.IntacctID__c         = 'TestID123';

accList.add(acc);

HelperWithoutSharing.InsertSObjects(accList);
HelperWithoutSharing.DeleteSObjects(accList);
HelperWithoutSharing.StartAssignJob();
HelperWithoutSharing.getDevPlanAssignmentList();
HelperWithoutSharing.getIsUserUS();
HelperWithoutSharing.getOpportunityOwnerId();

//HelperWithoutSharing.insertOpportunities();
//HelperWithoutSharing.updateOpportunities();

        
    }
}