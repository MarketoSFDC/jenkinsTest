/*************************************************************
* Last modified By : Tushar Misri, Grazitti Interactive, 10th  Aug  2018
* Purpose          : APPS-20840, Field Cleanup Project - Phase One
                     Fields which are being commented out:
                     primary_marketo_user_phone__c

**************************************************************/
public with sharing class MKT_ShoppingCart {
  public Map<Id, PricebookEntry> ProductIdPricebookEntry;
  //private Map<Id, kumocomm__ShoppingCartItem__c> ShoppingCartItemIdMap;
  public List<CartItemWrapper> CartItems { get; set; }
  public String idObjectToDelete { get; set; }
  public Boolean ValidExpError { get; set; }
  public Boolean ValidCodeError { get; set; }
  public Boolean ValidCardNumError { get; set; }
  public String ValidErrorText { get; set; }
  public String ValidCodeErrorText { get; set; }
  public String idObjectForUpdate { get; set; }
  public Integer CartCount { get; set; }
  public PricebookEntry TotalAmount { get; set; }
  public String Step { get; set; }
  public String GatewayTransactionId { get; set; }
  public String ResultCode { get; set; }
  public String NewQuantity { get; set; }
  public String OrderId { get; set; }
  public String respString { get; set; }
  public String ResponseMessage { get; set; }
  public Boolean IsChangePaymentVar;
  public Boolean IsOrderError{ get; set; }
  public Map<Id, List<lmsilt__Class__c>> CLSMap ;
  public PaymentInfo paymentObj { get; set; }
  public String HTMLBody{ get; set; }
  public Boolean SuccessPayment { get; set; }
  //private kumocomm__Payment_Source__c PaymentSourceItem;
  //List<kumocomm__OrderItem__c> NewOrderItems { get; set; }
  public MKT_ShoppingCart () {
    CartItems = new List<CartItemWrapper>();
    CartCount = 0;
    IsChangePaymentVar = false;
    TotalAmount = new PricebookEntry();
    //ShoppingCartItemIdMap = new Map<Id, kumocomm__ShoppingCartItem__c>();
    CLSMap = new Map<Id, List<lmsilt__Class__c>>();
    OrderId = ApexPages.currentPage().getParameters().get('OrderId');
    //Step = ApexPages.currentPage().getParameters().get('Step');
    Step = (OrderId == NULL || OrderId == '') ? 'cart' : '2';
    //NewOrderItems = new List<kumocomm__OrderItem__c>();
  }

  public List<CartItemWrapper> GetCartItems () {
    InitShoppingCart();
    return CartItems;
  }
  public PageReference InitShoppingCart() {
    //Map<Id, kumocomm__ShoppingCartItem__c> CartItemsProductsMap = (OrderId != NULL && OrderId != '') ? HelperWithoutSharing.getOrderItemsProductsMap() : HelperWithoutSharing.getCurrentCartItemsProductsMap();
    if (OrderId != NULL && OrderId != '') {
      //List<kumocomm__Order__c> OldOrder = [SELECT ID, /*kumocomm__Contact__c, kumocomm__Amount__c,*/ kumocomm__PaymentSource__c,kumocomm__BillingAddress__c,kumocomm__ShippingAddress__c, /*kumocomm__Status__c,*/CurrencyIsoCode FROM kumocomm__Order__c WHERE Id = :OrderId LIMIT 1];
     // if (OldOrder.size() == 0) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.MKT_OrderID_Record_Not_Found)); IsOrderError = true; return NULL;}
      //else if (OldOrder[0].kumocomm__Status__c == 'Completed') {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This order has been already paid')); IsOrderError = true; return NULL;}
    }
    //Map<Id, kumocomm__ShoppingCartItem__c> CartItemsProductsMap = HelperWithoutSharing.getCurrentCartItemsProductsMap();

    TotalAmount.UnitPrice = 0;
    /*if (CartItemsProductsMap.Size() > 0){}// FillShoppingCart(CartItemsProductsMap);
    else {
      CartItems = new List<CartItemWrapper>();
      CartCount = 0;
    }*/
    paymentObj = (OrderId != NULL && OrderId != '') ? (new PaymentInfo(OrderId)) : (new PaymentInfo());
    return NULL;
  }
  public void CheckoutNow () {
    if (CartCount > 0) Step = '1';
    paymentObj = (OrderId != NULL && OrderId != '') ? (new PaymentInfo(OrderId)) : (new PaymentInfo());
  }

  /*public void FillShoppingCart (Map<Id, kumocomm__ShoppingCartItem__c> CartItemsProductsMap) {
    CartCount = 0;
    CartItems = new List<CartItemWrapper>();
    Set<Id> CartItemsProductsSet = CartItemsProductsMap.keySet();
    String Name_Event = lmsilt__Event__c.sObjectType.getDescribe().getLabel();
    String Name_Module = 'On-Demand';
    String Name_Course = lmscons__Training_Path__c.sObjectType.getDescribe().getLabel();
    String Name_LP = lmscons__Learning_Path__c.sObjectType.getDescribe().getLabel();
    String Name_Curriculum = lmscons__Curriculum__c.sObjectType.getDescribe().getLabel();
    List<lmscons__Training_Content__c> ListModules = [SELECT Id, lmscons__Title__c, Product__c, lmscons__Description__c,Product__r.isActive FROM lmscons__Training_Content__c WHERE Product__c IN :CartItemsProductsSet];
    List<lmscons__Quiz__c> ListQuizes = [SELECT Id, Name, Product__c, lmscons__Description__c,Product__r.isActive FROM lmscons__Quiz__c WHERE Product__c IN :CartItemsProductsSet];
    List<lmsilt__Event__c> ListEvents = [SELECT lmsilt__Description__c, Name, Id, Product__c,Product__r.isActive FROM lmsilt__Event__c WHERE Product__c IN :CartItemsProductsSet];
    List<lmscons__Training_Path__c> ListCourses = [SELECT id, Name, lmscons__Description__c, lmscons__Total_Items__c, Product__c,Product__r.isActive FROM lmscons__Training_Path__c WHERE  Product__c IN :CartItemsProductsSet];
    List<lmscons__Learning_Path__c> ListLP = [SELECT id, Name, lmscons__Description__c, lmscons__Total_Items__c, Product__c,Product__r.isActive FROM lmscons__Learning_Path__c WHERE  Product__c IN :CartItemsProductsSet];
    List<lmscons__Curriculum__c> ListCurr = [SELECT id, Name, lmscons__Description__c, lmscons__Total_Items__c, Product__c, Product__r.isActive FROM lmscons__Curriculum__c WHERE  Product__c IN :CartItemsProductsSet];
    ProductIdPricebookEntry = HelperWithoutSharing.getProductsPrice(ListCourses, ListLP, ListCurr, ListEvents, ListQuizes, ListModules);

    if (ListEvents.size() > 0) {
      Set<Id> EventIds = new Set<Id>();
      for (lmsilt__Event__c e : ListEvents) {
        EventIds.add(e.Id);
      }
      for (lmsilt__Class__c cl : [SELECT Id, Name, lmsilt__Event__c, lmsilt__Start_Date__c, lmsilt__End_Date__c, lmsilt__Maximum_Capacity__c, lmsilt__Waitlist_Enabled__c, lmsilt__Cancellation_Policy_lookup__c, (SELECT Id, Name, lmsilt__ILT_vILT__c, lmsilt__Session_Location__c, lmsilt__Session_Location__r.Name, lmsilt__Start_Date_Time__c, lmsilt__End_Date_Time__c FROM lmsilt__Sessions__r) FROM lmsilt__Class__c WHERE lmsilt__Event__c IN : EventIds]) {

        List<lmsilt__Class__c> classes_list = new List<lmsilt__Class__c>();
        if (CLSMap.containskey(cl.lmsilt__Event__c)) {
          classes_list = CLSMap.get(cl.lmsilt__Event__c);
        }
        classes_list.add(cl);
        CLSMap.put(cl.lmsilt__Event__c, classes_list);
      }
    }
    for (lmscons__Training_Content__c moduleItem : ListModules) {
      CartItemWrapper CartItemObj = new CartItemWrapper();
      CartItemObj.CourseName = moduleItem.lmscons__Title__c;
      CartItemObj.Type = Name_Module;
      CartItemObj.Description = moduleItem.lmscons__Description__c;
      CartItemObj.Price = (moduleItem.Product__c != NULL ) ? getProductPricebook(moduleItem.Product__c) : NULL;
      if (CartItemsProductsMap.containsKey(moduleItem.Product__c)) {
        kumocomm__ShoppingCartItem__c cartItem = (kumocomm__ShoppingCartItem__c)CartItemsProductsMap.get(moduleItem.Product__c);
        CartItemObj.CartItemId = cartItem.Id;
        CartItemObj.ShoppingCartItem = cartItem;
        CartItemObj.ProductId = moduleItem.Product__c;
        CartItemObj.Quantity = (Integer)cartItem.kumocomm__Quantity__c;
        CartItemObj.IsPaid = (CartItemObj.Price.UnitPrice > 0) ? true : false;
        ShoppingCartItemIdMap.put(CartItemObj.CartItemId, cartItem);
      }
      CartItems.Add(CartItemObj);
      CartCount += CartItemObj.Quantity;
      TotalAmount.UnitPrice += (CartItemObj.Price != NULL) ? CartItemObj.Quantity*CartItemObj.Price.UnitPrice : 0;
      TotalAmount.CurrencyIsoCode = (TotalAmount.CurrencyIsoCode == NULL) ? CartItemObj.Price.CurrencyIsoCode : TotalAmount.CurrencyIsoCode;

    }
    for (lmscons__Quiz__c quizItem : ListQuizes) {
      CartItemWrapper CartItemObj = new CartItemWrapper();
      CartItemObj.CourseName = quizItem.Name;
      CartItemObj.Type = Name_Module;
      CartItemObj.Description = quizItem.lmscons__Description__c;
      CartItemObj.Price = (quizItem.Product__c != NULL ) ? getProductPricebook(quizItem.Product__c) : NULL;
      if (CartItemsProductsMap.containsKey(quizItem.Product__c)) {
        kumocomm__ShoppingCartItem__c cartItem = (kumocomm__ShoppingCartItem__c)CartItemsProductsMap.get(quizItem.Product__c);
        CartItemObj.CartItemId = cartItem.Id;
        CartItemObj.ShoppingCartItem = cartItem;
        CartItemObj.ProductId = quizItem.Product__c;
        CartItemObj.Quantity = (Integer)cartItem.kumocomm__Quantity__c;
        CartItemObj.IsPaid = (CartItemObj.Price.UnitPrice > 0) ? true : false;
        ShoppingCartItemIdMap.put(CartItemObj.CartItemId, cartItem);
      }
      CartItems.Add(CartItemObj);
      CartCount += CartItemObj.Quantity;
      TotalAmount.UnitPrice += (CartItemObj.Price != NULL) ? CartItemObj.Quantity*CartItemObj.Price.UnitPrice : 0;
      TotalAmount.CurrencyIsoCode = (TotalAmount.CurrencyIsoCode == NULL) ? CartItemObj.Price.CurrencyIsoCode : TotalAmount.CurrencyIsoCode;
    }
    for (lmsilt__Event__c eventItem : ListEvents) {
      CartItemWrapper CartItemObj = new CartItemWrapper();
      CartItemObj.CourseName = eventItem.Name;
      CartItemObj.Description = eventItem.lmsilt__Description__c;
      if (CartItemsProductsMap.containsKey(eventItem.Product__c)) {
        kumocomm__ShoppingCartItem__c cartItem = (kumocomm__ShoppingCartItem__c)CartItemsProductsMap.get(eventItem.Product__c);
        CartItemObj.CartItemId = cartItem.Id;
        CartItemObj.ShoppingCartItem = cartItem;
        CartItemObj.ProductId = eventItem.Product__c;
        CartItemObj.Quantity = (Integer)cartItem.kumocomm__Quantity__c;
        CartItemObj.EventId = eventItem.Id;
        //CartItemObj.ClassId = cartItem.MKT_Class__c;
        ShoppingCartItemIdMap.put(CartItemObj.CartItemId, cartItem);
        Map<String,String> infoEvent = getEventInfo(eventItem.Id, ''/*cartItem.MKT_Class__c*//*);
        CartItemObj.Price = (eventItem.Product__c != NULL ) ? getProductPricebook(eventItem.Product__c) : NULL;
        CartItemObj.IsPaid = (CartItemObj.Price.UnitPrice > 0) ? true : false;
        CartItemObj.Location = (infoEvent.containsKey('location')) ? infoEvent.Get('location') : '';
        CartItemObj.StartSess = (infoEvent.containsKey('start')) ? infoEvent.Get('start') : '';
        CartItemObj.EndSess = (infoEvent.containsKey('end')) ? infoEvent.Get('end') : '';
        CartItemObj.Type = (infoEvent.containsKey('type')) ? infoEvent.Get('type') : '';
        CartItemObj.IsExpired = (infoEvent.containsKey('isExpired')) ? (infoEvent.Get('isExpired') != 'false') : false;
      }
      CartItems.Add(CartItemObj);
      CartCount += CartItemObj.Quantity;
      TotalAmount.UnitPrice += (CartItemObj.Price != NULL) ? CartItemObj.Quantity*CartItemObj.Price.UnitPrice : 0;
      TotalAmount.CurrencyIsoCode = (TotalAmount.CurrencyIsoCode == NULL) ? CartItemObj.Price.CurrencyIsoCode : TotalAmount.CurrencyIsoCode;
    }
    for (lmscons__Training_Path__c courseItem : ListCourses) {
      CartItemWrapper CartItemObj = new CartItemWrapper();
      CartItemObj.CourseName = courseItem.Name;
      CartItemObj.Type = Name_Course;
      CartItemObj.Description = courseItem.lmscons__Description__c;
      CartItemObj.Price = (courseItem.Product__c != NULL ) ? getProductPricebook(courseItem.Product__c) : NULL;
      if (CartItemsProductsMap.containsKey(courseItem.Product__c)) {
        kumocomm__ShoppingCartItem__c cartItem = (kumocomm__ShoppingCartItem__c)CartItemsProductsMap.get(courseItem.Product__c);
        CartItemObj.CartItemId = cartItem.Id;
        CartItemObj.ShoppingCartItem = cartItem;
        CartItemObj.ProductId = courseItem.Product__c;
        CartItemObj.Quantity = (Integer)cartItem.kumocomm__Quantity__c;
        CartItemObj.IsPaid = (CartItemObj.Price.UnitPrice > 0) ? true : false;
        ShoppingCartItemIdMap.put(CartItemObj.CartItemId, cartItem);
      }
      CartItems.Add(CartItemObj);
      CartCount += CartItemObj.Quantity;
      TotalAmount.UnitPrice += (CartItemObj.Price != NULL) ? CartItemObj.Quantity*CartItemObj.Price.UnitPrice : 0;
      TotalAmount.CurrencyIsoCode = (TotalAmount.CurrencyIsoCode == NULL) ? CartItemObj.Price.CurrencyIsoCode : TotalAmount.CurrencyIsoCode;
    }
    for (lmscons__Learning_Path__c lpItem : ListLP) {
      CartItemWrapper CartItemObj = new CartItemWrapper();
      CartItemObj.CourseName = lpItem.Name;
      CartItemObj.Type = Name_LP;
      CartItemObj.Description = lpItem.lmscons__Description__c;
      CartItemObj.Price = (lpItem.Product__c != NULL ) ? getProductPricebook(lpItem.Product__c) : NULL;
      if (CartItemsProductsMap.containsKey(lpItem.Product__c)) {
        kumocomm__ShoppingCartItem__c cartItem = (kumocomm__ShoppingCartItem__c)CartItemsProductsMap.get(lpItem.Product__c);
        CartItemObj.CartItemId = cartItem.Id;
        CartItemObj.ShoppingCartItem = cartItem;
        CartItemObj.ProductId = lpItem.Product__c;
        CartItemObj.Quantity = (Integer)cartItem.kumocomm__Quantity__c;
        CartItemObj.IsPaid = (CartItemObj.Price.UnitPrice > 0) ? true : false;
        ShoppingCartItemIdMap.put(CartItemObj.CartItemId, cartItem);
      }
      CartItems.Add(CartItemObj);
      CartCount += CartItemObj.Quantity;
      TotalAmount.UnitPrice += (CartItemObj.Price != NULL) ? CartItemObj.Quantity*CartItemObj.Price.UnitPrice : 0;
      TotalAmount.CurrencyIsoCode = (TotalAmount.CurrencyIsoCode == NULL) ? CartItemObj.Price.CurrencyIsoCode : TotalAmount.CurrencyIsoCode;
    }
    for (lmscons__Curriculum__c currItem : ListCurr) {
      CartItemWrapper CartItemObj = new CartItemWrapper();
      CartItemObj.CourseName = currItem.Name;
      CartItemObj.Type = Name_Curriculum;
      CartItemObj.Description = currItem.lmscons__Description__c;
      CartItemObj.Price = (currItem.Product__c != NULL) ? getProductPricebook(currItem.Product__c) : NULL;
      if (CartItemsProductsMap.containsKey(currItem.Product__c)) {
        kumocomm__ShoppingCartItem__c cartItem = (kumocomm__ShoppingCartItem__c)CartItemsProductsMap.get(currItem.Product__c);
        CartItemObj.CartItemId = cartItem.Id;
        CartItemObj.ShoppingCartItem = cartItem;
        CartItemObj.ProductId = currItem.Product__c;
        CartItemObj.Quantity = (Integer)cartItem.kumocomm__Quantity__c;
        CartItemObj.IsPaid = (CartItemObj.Price.UnitPrice > 0) ? true : false;
        ShoppingCartItemIdMap.put(CartItemObj.CartItemId, cartItem);
      }
      CartItems.Add(CartItemObj);
      CartCount += CartItemObj.Quantity;
      TotalAmount.UnitPrice += (CartItemObj.Price != NULL) ? CartItemObj.Quantity*CartItemObj.Price.UnitPrice : 0;
      TotalAmount.CurrencyIsoCode = (TotalAmount.CurrencyIsoCode == NULL) ? CartItemObj.Price.CurrencyIsoCode : TotalAmount.CurrencyIsoCode;
    }


  }*/
  public PricebookEntry getProductPricebook(Id prId) {
    if (prId != NULL && ProductIdPricebookEntry.containsKey(prId)) {
      PricebookEntry PricebookEntryItem = ProductIdPricebookEntry.get(prId);
      if (PricebookEntryItem.UnitPrice != 0) {
        return PricebookEntryItem;
      }
      else {
        return NULL;
      }
    }
    else {
      return NULL;
    }
  }
  /*public Map<String,String> getEventInfo(Id EvtId, Id ClassID) {
    Map<String,String> EvtInfo = new Map<String,String>();
    String expired = 'true';
    if (CLSMap.containskey(EvtId)) {
      Set<String> location = new Set<String>();
      Set<String> typeEvnt = new Set<String>();
      for (lmsilt__Class__c cl : CLSMap.get(EvtId)) {
        if (cl.lmsilt__Sessions__r != NULL && cl.ID == ClassID) {
          for (lmsilt__Session__c sess : cl.lmsilt__Sessions__r) {
            String SessType = (sess.lmsilt__ILT_vILT__c == 'ILT') ? Label.MKT_Classroom : Label.MKT_Virtual;
            if (SessType == 'Virtual') {
              if (!location.contains(SessType) ) {
                location.Add(SessType);
              }
            }
            if (!typeEvnt.contains(SessType) ) {
              typeEvnt.Add(SessType);
            }
            if (sess.lmsilt__Session_Location__r != NULL) {
              if (!location.contains(sess.lmsilt__Session_Location__r.Name) ) {
                location.Add(sess.lmsilt__Session_Location__r.Name);
              }
            }
            EvtInfo.put('start', sess.lmsilt__Start_Date_Time__c.format('MM/dd/yyyy h:mm a'));
            EvtInfo.put('end', sess.lmsilt__End_Date_Time__c.format('MM/dd/yyyy h:mm a'));
          }
        }
        if (cl.lmsilt__Start_Date__c > datetime.now()) expired = 'false';
      }
      if (location.size() > 1) {
        EvtInfo.put('location', 'choose');
      }
      else if (location.size() == 1) {
        List<String> resultList = new List<String>();
        resultList.addAll(location);
        EvtInfo.put('location', resultList[0]);
      }
      else {
        EvtInfo.put('location', '');
      }

      String typeEvntTmp = '';
      for (String tmp : typeEvnt) {
        typeEvntTmp += tmp + '/';
      }
      EvtInfo.put('type',typeEvntTmp.substring(0,typeEvntTmp.length()-1));
      EvtInfo.put('isExpired', expired);
    }
    return EvtInfo;
  }*/
  public void DeleteFromCart() {
   // if (idObjectToDelete != NULL && idObjectToDelete != ''/* && ShoppingCartItemIdMap.containsKey(idObjectToDelete)*/) {
      //kumocomm__ShoppingCartItem__c ItemForDel = new kumocomm__ShoppingCartItem__c();/*ShoppingCartItemIdMap.get(idObjectToDelete);*/
      //ItemForDel.kumocomm__Status__c = 'Removed';
      //update ItemForDel;
    /*  InitShoppingCart();
    }*/
  }
  public PageReference BackStep() {
    ValidExpError = false;
    ValidCodeError = false;
    ValidCardNumError  = false;
    ValidCodeErrorText = '';
    ValidErrorText = '';
    if (Step == '1') {
      Step = 'cart';

    }
    else if (Step == '2') {
      Step = '1';
    }
    else if (Step == '3') {
      Step = '1';
    }
    else {
      Step = 'cart';
    }
    IsChangePaymentVar = false;
    return NULL;
  }
  public PageReference PreviewOrder() {
    //pageref.getParameters().put('Step',Step);
    String NewOrderID = SaveOrder();
    if (NewOrderID != NULL) {
      if (Step == '1') {
        Step = '2';
      }
      else {
        Step = 'cart';
      }

      PageReference pageref = Page.MKT_ShoppingCart;
      pageref.getParameters().put('OrderId',NewOrderID);
      pageref.setRedirect(true);
      return pageref;
    }
    else return NULL;
  }
  public void ChangePayment() {
    if (IsChangePaymentVar) {}//paymentObj.PaymentSourceItem = paymentObj.getOldPayment(paymentObj.PaymentSourceItem);
    IsChangePaymentVar = (IsChangePaymentVar == true) ? false : true;
  }
  public Boolean getIsShowChange() {
    if (IsChangePaymentVar || !paymentObj.ExCard) return true;
    else return false;
  }
  public Boolean ValidatePaymentData () {
    /*ValidExpError = false;
    ValidCodeError = false;
    ValidCardNumError  = false;
    ValidCodeErrorText = '';
    ValidErrorText = '';
    //if ((Integer.valueOf(paymentObj.PaymentSourceItem.kumocomm__CreditCardExpirationMonth__c) <= datetime.now().month() && Integer.valueOf(paymentObj.PaymentSourceItem.kumocomm__CreditCardExpirationYear__c) <= datetime.now().year()) || Integer.valueOf(paymentObj.PaymentSourceItem.kumocomm__CreditCardExpirationYear__c) < datetime.now().year()) {
     // ValidExpError = true;
    //}
    //if (paymentObj.PaymentSourceItem.kumocomm__CreditCardSecurityCode__c != NULL && paymentObj.PaymentSourceItem.kumocomm__CreditCardSecurityCode__c != '') {
     // String cardTypeInput = paymentObj.PaymentSourceItem.kumocomm__CreditCardType__c;
      //String cardExpInput = paymentObj.PaymentSourceItem.kumocomm__CreditCardSecurityCode__c;
      /*if ((cardTypeInput == 'Mastercard' || cardTypeInput == 'Visa' || cardTypeInput == 'Discover' || cardTypeInput == 'JCB') && cardExpInput.length() != 3){
        ValidCodeError = true;
        ValidCodeErrorText = cardTypeInput + ' card security code should have 3 digits length';
        //return NULL;
      }
      if (cardTypeInput == 'American Express' && cardExpInput.length() != 4) {
        ValidCodeError = true;
        ValidCodeErrorText = cardTypeInput + ' card security code should have 3 digits length';
        //return NULL;
      }

    }
    if (paymentObj.CardNumber != NULL && paymentObj.CardNumber != '') {
      String cardNumInput = paymentObj.CardNumber;
      /*String cardTypeInput = paymentObj.PaymentSourceItem.kumocomm__CreditCardType__c;
      if (cardTypeInput == 'Visa' && !cardNumInput.startsWith('4')){
        ValidCardNumError = true;
        ValidErrorText = 'Your ' + cardTypeInput + ' card number should begin with 4 ';
      }
      if (cardTypeInput == 'Visa' && cardNumInput.length() != 16 && cardNumInput.length() != 13){
        ValidCardNumError = true;
        ValidErrorText = 'Your ' + cardTypeInput + ' card number should be 16 or 13 digits length';
      }

      if (cardTypeInput == 'Mastercard' && !cardNumInput.startsWith('51') && !cardNumInput.startsWith('55')) {
        ValidCardNumError = true;
        ValidErrorText = 'Your ' + cardTypeInput + ' card number should begin with 51 or 55 ';
      }
      if (cardTypeInput == 'Mastercard' && cardNumInput.length() != 16) {
        ValidCardNumError = true;
        ValidErrorText = 'Your ' + cardTypeInput + ' card number should be 16 digits length';
      }
      if (cardTypeInput == 'American Express' && !cardNumInput.startsWith('34') && !cardNumInput.startsWith('37')) {
        ValidCardNumError = true;
        ValidErrorText = 'Your ' + cardTypeInput + ' card number should begin with 34 or 37 ';
      }
      if (cardTypeInput == 'American Express' && cardNumInput.length() != 15) {
        ValidCardNumError = true;
        ValidErrorText = 'Your ' + cardTypeInput + ' card number should be 15 digits length';
      }
      if (cardTypeInput == 'Discover' && cardNumInput.length() == 15 && !cardNumInput.startsWith('5')) {
        ValidCardNumError = true;
        ValidErrorText = 'Your ' + cardTypeInput + ' card number should begin with 5';
      }
      if (cardTypeInput == 'Discover' && cardNumInput.length() == 16 && !cardNumInput.startsWith('6011') && !cardNumInput.startsWith('65')) {
        ValidCardNumError = true;
        ValidErrorText = 'Your ' + cardTypeInput + ' card number should begin with 6011 or 65';
      }
      if (cardTypeInput == 'Discover' && cardNumInput.length() != 15  && cardNumInput.length() != 16) {
        ValidCardNumError = true;
        ValidErrorText = 'Your ' + cardTypeInput + ' card number should be 15 or 16 digits length';
      }

      if (cardTypeInput == 'JCB' && cardNumInput.length() == 15 && !cardNumInput.startsWith('2131') && !cardNumInput.startsWith('1800')) {
        ValidCardNumError = true;
        ValidErrorText = 'Your ' + cardTypeInput + ' card number should begin with 2131 or 1800';
      }
      if (cardTypeInput == 'JCB' && cardNumInput.length() == 16 && !cardNumInput.startsWith('35')) {
        ValidCardNumError = true;
        ValidErrorText = 'Your ' + cardTypeInput + ' card number should begin with 35';
      }
      if (cardTypeInput == 'JCB' && cardNumInput.length() != 15  && cardNumInput.length() != 16) {
        ValidCardNumError = true;
        ValidErrorText = 'Your ' + cardTypeInput + ' card number should be 15 or 16 digits length';
      }*/

    //}
    return false;
  }
  public String SaveOrder() {
    //Savepoint sp = Database.setSavepoint();
    /*try {
      if (paymentObj.curUserContact != NULL) {
        if (!ValidatePaymentData()) return NULL;

        //kumocomm__Order__c NewOrder = new kumocomm__Order__c();
        //List<kumocomm__OrderItem__c> OldOrderItems = new List<kumocomm__OrderItem__c>();
        if (OrderId != NULL && OrderId != '') {
          //List<kumocomm__Order__c> OldOrder = [SELECT ID, /*kumocomm__Contact__c, kumocomm__Amount__c,*/ //kumocomm__PaymentSource__c,kumocomm__BillingAddress__c,kumocomm__ShippingAddress__c, /*kumocomm__Status__c,*/CurrencyIsoCode FROM kumocomm__Order__c WHERE Id = :OrderId LIMIT 1];
          //if (OldOrder.size() == 0) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.MKT_OrderID_Record_Not_Found)); return NULL;}
          //else if (OldOrder[0].kumocomm__Status__c == 'Completed') {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This order has been already paid'));return NULL;}

          //NewOrder = OldOrder[0];
          //OldOrderItems = [SELECT ID FROM kumocomm__OrderItem__c WHERE kumocomm__Order__c = :OrderId];

        //}
        //NewOrder.kumocomm__Contact__c = paymentObj.curUserContact.Id;
        //NewOrder.kumocomm__Amount__c = TotalAmount.UnitPrice;
        //NewOrder.kumocomm__Status__c = 'Pending';
        //NewOrder.CurrencyIsoCode = TotalAmount.CurrencyIsoCode;

        //kumocomm__Payment_Source__c PaymentSource = FillPaymentSource();
        //if (getIsShowChange()/*  ||  PaymentSource.kumocomm__Token__c == NULL*/) {
         /* Map<String,Object> RespMap = HelperWithoutSharing.RegisterToken(paymentObj);
          String TransactionId = (String)(RespMap.containskey('TransactionId') ? RespMap.get('TransactionId') : '');
          GatewayTransactionId = (String)((RespMap.containskey('GatewayTransactionId')) ? RespMap.get('GatewayTransactionId') : '');
          String ResponseStatus = (String)((RespMap.containskey('ResponseStatus')) ? RespMap.get('ResponseStatus') : '');
          String ResponseMessage = (String)((RespMap.containskey('ResponseMessage')) ? RespMap.get('ResponseMessage') : '');
          String ResultCode = (String)((RespMap.containskey('ResultCode')) ? RespMap.get('ResultCode') : '');
          String OrderResponseMessage = (String)((RespMap.containskey('OrderResponseMessage')) ? RespMap.get('OrderResponseMessage') : '');
          String GatewayToken = (String)((RespMap.containskey('GatewayToken')) ? RespMap.get('GatewayToken') : '');*/
         /* if (ResponseStatus != 'APPROVED') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ResponseStatus:' + ResponseStatus));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ResponseMessage:' + ResponseMessage));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ResultCode:' + ResultCode));
            return NULL;
          }
          if (GatewayToken == '') ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Token is empty'));
*/
         // PaymentSource.kumocomm__Token__c = GatewayToken;
          //PaymentSource.kumocomm__Gateway_Config__c =
          //upsert PaymentSource;
       // }

        //NewOrder.kumocomm__BillingAddress__c = FillBillingAddress();
        //NewOrder.kumocomm__ShippingAddress__c = NewOrder.kumocomm__BillingAddress__c;
        //NewOrder.kumocomm__PaymentSource__c = PaymentSource.Id;
       // upsert NewOrder;

        //if (OldOrderItems.Size() > 0) {
         // delete OldOrderItems;
        //}
       // OrderId = NewOrder.Id;
        //List<kumocomm__OrderItem__c> NewOrderItems = new List<kumocomm__OrderItem__c>();

       // for (CartItemWrapper CartItem :CartItems) {
          //kumocomm__OrderItem__c NewOrderItem = new kumocomm__OrderItem__c();
          //NewOrderItem.kumocomm__Amount__c = CartItem.Price.UnitPrice;
          //NewOrderItem.kumocomm__Order__c = NewOrder.Id;
          //NewOrderItem.kumocomm__Product__c = CartItem.ProductId;
          //NewOrderItem.kumocomm__Quantity__c = CartItem.Quantity;
          //NewOrderItem.MKT_Class__c = CartItem.ClassId;
          //NewOrderItems.Add(NewOrderItem);
        //}
        //insert NewOrderItems;
      //}
	  return null;
    //}
    /*catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.GetMessage()));
      //Database.rollback(sp);
      return NULL;
    }
    return OrderId;*/
  }

  public PageReference SubmitOrder() {
   /* try {
      System.Debug('=========SubmitOrder start==========' + system.now());
      if (!paymentObj.isAccept) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Confirm the Legal Lightbox'));
        return NULL;
      }
      //List<kumocomm__Order__c> NewOrder = [SELECT ID FROM kumocomm__Order__c WHERE Id = :OrderId LIMIT 1 /*MKT_ConfirmLegalBox__c, kumocomm__Status__c *///];
      //if (NewOrder.size() == 0) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.MKT_OrderID_Record_Not_Found)); return NULL;}
     // else if (NewOrder[0].kumocomm__Status__c == 'Completed') {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This order has been already paid'));return NULL;}
      //List<kumocomm__ShoppingCartItem__c> CartItemsForDel = new List<kumocomm__ShoppingCartItem__c>();
      //for (CartItemWrapper CartItem :CartItems){
        //CartItem.ShoppingCartItem.kumocomm__Status__c = 'Paid';
        //CartItemsForDel.Add(CartItem.ShoppingCartItem);
      //}
      /*if (paymentObj.curUserContact != NULL) {
        Map<String, String> properties = new Map<String, String>();
        properties.put('OrderId', OrderId);
        properties.put('TransactionType', 'AuthorizeAndCharge');
        String RequestString = JSON.serialize(properties);
        System.Debug('=========PaymentWebService Request Start==========' + system.now());
        respString = HelperWithoutSharing.processPaymentWebService(RequestString);
        System.Debug('=========PaymentWebService Request End==========' + system.now());
        System.Debug('=========Parsing PaymentWebService Response Start==========' + system.now());
        Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(respString);

        String TransactionId = (String)(Test.IsRunningTest() ? paymentObj.TestTransactionID : ((responseMap.containskey('TransactionId')) ? responseMap.get('TransactionId') : ''));
        GatewayTransactionId = (String)((responseMap.containskey('GatewayTransactionId')) ? responseMap.get('GatewayTransactionId') : '');
        String ResponseStatus = (String)((responseMap.containskey('ResponseStatus')) ? responseMap.get('ResponseStatus') : '');
        ResponseMessage = (String)((responseMap.containskey('ResponseMessage')) ? responseMap.get('ResponseMessage') : '');
        ResultCode = (String)((responseMap.containskey('ResultCode')) ? responseMap.get('ResultCode') : '');
        String OrderResponseMessage = (String)((responseMap.containskey('OrderResponseMessage')) ? responseMap.get('OrderResponseMessage') : '');
        System.Debug('=========Parsing PaymentWebService Response End==========' + system.now());
        if (ResponseStatus == 'APPROVED' || Test.IsRunningTest()) {
          SuccessPayment = true;
          //List<kumocomm__Order__c> NewOrder2 = [SELECT ID FROM kumocomm__Order__c WHERE Id = :OrderId LIMIT 1/* MKT_ConfirmLegalBox__c, kumocomm__Status__c *///];
          //if (NewOrder2.size() > 0) {
            //NewOrder2[0].MKT_ConfirmLegalBox__c = true;
            //update NewOrder2[0];
            //update NewOrder2[0];
         // }
         // if (paymentObj.curUserContact != NULL) {
            //List<kumocomm__OrderItem__c> NewOrderItems = [SELECT Id, /*MKT_Class__c, kumocomm__Amount__c,*/ kumocomm__Order__c, kumocomm__Product__c, kumocomm__Quantity__c/*, kumocomm__Order__r.kumocomm__Contact__c*/ FROM kumocomm__OrderItem__c WHERE kumocomm__Order__c = :OrderID];
          //  Set <String> NewOrderItemsSet = new Set<String>();
            //for (kumocomm__OrderItem__c NewOrderI :NewOrderItems) {
             // NewOrderItemsSet.Add(NewOrderI.Id);
           // }
          //  CreateOpportunity(TransactionId, NewOrderItems);

            //String SerializeString = JSON.serialize(NewOrderItemsSet);
            /*MKT_AssignQueue__c AssignQueue = new MKT_AssignQueue__c();
            AssignQueue.MKT_ApexClassName__c = 'MKT_BatchAssign';
            AssignQueue.MKT_Status__c = 'Pending';
            //AssignQueue.MKT_SerializedData__c = SerializeString;
            HelperWithoutSharing.InsertAssignQueue(new List<MKT_AssignQueue__c>{AssignQueue});

            //update CartItemsForDel;
            System.Debug('=========Send Email Start==========' + system.now());
            HTMLBody = FillHTMLBody ();
            List<Messaging.SendEmailResult> results = HelperWithoutSharing.sendEmail(paymentObj.Email, HTMLBody);
            System.Debug('=========Send Email End==========' + system.now());
            System.Debug('###SendEmail results: == ' + results);

          }
        }
      }
      step = '3';
    }
    catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.GetMessage()));
    }*/
    return NULL;
  }
  public String FillHTMLBody () {
    String HTMLBody = '';
    HTMLBody += '<table style="width: 100%; font-family: Arial, Helvetica, sans-serif;">';
    HTMLBody += '<tbody>';
    HTMLBody += '<tr><td><div class="mkt-mail-heder" style="padding: 10px 0; border-bottom: 3px solid #726fbc; font-size: 16px; font-weight: bold;  text-transform: uppercase; color: #333; "><img src="' +  Label.MKT_MarketoLogoFile + '" alt="marketo logo" /></div></td></tr>';
    HTMLBody += '<tr><td height="30" valign="middle"><strong style="font-size: 14px; color: #726fbc;">' + Label.MKT_Order_Confirmation + '</strong></td></tr>';
    HTMLBody += '<tr><td><table cellspacing="0" cellpadding="0" width="703"><tbody>';
    HTMLBody += '<tr><td><table cellspacing="0" width="100%" cellpadding="8" style="border-collapse: collapse; font-size: 12px; "><thead>';
    HTMLBody += '<tr><th bgcolor="#1C91D5" align="left" align="left" style="width: 200px; color: #dddddd; border-width: 1px 1px 1px 1px; border-color: #1C91D5 #dddddd #dddddd #1C91D5; border-style: solid;">'+Label.MKT_CourseHead+'</th>';
    HTMLBody += '<th bgcolor="#1C91D5" style="width: 90px; color: #dddddd; border-width: 1px 1px 1px 0; border-color:#1C91D5 #dddddd #dddddd; border-style: solid;">'+Label.MKT_TypeHead+'</th>';
    HTMLBody += '<th bgcolor="#1C91D5" style="width: 119px; color: #dddddd;border-width: 1px 1px 1px 0; border-color: #1C91D5 #dddddd #dddddd; border-style: solid;">SESSION</th>';
    HTMLBody += '<th bgcolor="#1C91D5" style="width: 60px; color: #dddddd; border-width: 1px 1px 1px 0; border-color: #1C91D5 #dddddd #dddddd; border-style: solid;">'+Label.MKT_CostHead+'</th>';
    HTMLBody += '<th bgcolor="#1C91D5" style="width: 61px; color: #dddddd; border-width: 1px 1px 1px 0; border-color: #1C91D5 #dddddd #dddddd #dddddd; border-style: solid;">'+Label.MKT_QTYHead+'</th>';
    HTMLBody += '<th bgcolor="#1C91D5" style="width: 70px; color: #dddddd; border-width: 1px 1px 1px 0; border-color: #1C91D5 #1C91D5 #dddddd #dddddd; border-style: solid;">'+Label.MKT_SUBTOTALHead+'</th>';
    HTMLBody += '</tr></thead></table></td></tr>';
    for (CartItemWrapper CartItem :CartItems) {
      String Location = (cartItem.Location != NULL) ? (cartItem.Location + '<br/>' + cartItem.StartSess + '<br/>' + cartItem.EndSess) : '';
      HTMLBody += '<tr><td><table cellspacing="0" width="100%" cellpadding="8" style="border-collapse: collapse; font-size: 12px;"><tbody><tr>';
      HTMLBody += '<td style="width: 200px; border-width: 0 1px 1px 1px; border-color: #dddddd; border-style: solid;">'+cartItem.CourseName+'</td>';
      HTMLBody += '<td align="center" style="width: 90px; border-width: 0 1px 1px 0; border-color: #dddddd; border-style: solid;">' + cartItem.Type + '</td>';
      HTMLBody += '<td align="center" style="width: 119px; border-width: 0 1px 1px 0; border-color: #dddddd; border-style: solid;">' + Location + '</td>';
      HTMLBody += '<td align="center" style="width: 60px; border-width: 0 1px 1px 0; border-color: #dddddd; border-style: solid;">' + cartItem.getCost() + '</td>';
      HTMLBody += '<td align="center" style="width: 61px; border-width: 0 1px 1px 0; border-color: #dddddd; border-style: solid;">' + cartItem.Quantity + '</td>';
      HTMLBody += '<td align="center" style="width: 70px; border-width: 0 1px 1px 0; border-color: #dddddd; border-style: solid;">' + cartItem.getSubtotal() + '</td>';
      HTMLBody += '</tr></tbody></table></td></tr>';
      //Description
      String Descr = (cartItem.Description != NULL && cartItem.Description != '') ? String.escapeSingleQuotes(cartItem.Description.trim()) : '';
      if (Descr != '') {
        HTMLBody += '<tr><td><table cellspacing="0" width="100%" cellpadding="8" style="border-collapse: collapse; font-size: 12px;"><tbody><tr>';
        HTMLBody += '<td style="font-size: 12px; font-family: Arial; border-width: 0 1px 1px 1px; border-color: #dddddd; border-style: solid;"><pre style="font-family: Arial, helvetica, sans-serif; font-size: 12px; white-space: pre-wrap;">'+ Descr +'</pre></td>';
        HTMLBody += '</tr></tbody></table></td></tr>';
      }
    }
    HTMLBody += '<tr><td><table width="100%" cellpadding="8" style="border-collapse: collapse; font-size: 12px; "><tbody><tr>';
    HTMLBody += '<td bgcolor="#1C91D5" style="width: 200px; border-width: 0 1px 1px 1px; border-color: #dddddd #dddddd #dddddd #8D8CCE; border-style: solid; font-weight: bold; color: #dddddd;">'+Label.MKT_Total+'</td>';
    HTMLBody += '<td style="border-width: 0 0 1px 0; border-color: #dddddd; border-style: solid;"></td>';
    HTMLBody += '<td width="90" align="center" style="border-width: 0 1px 1px 0; border-color: #dddddd; border-style: solid; ">'+ getTotalPrice() + '</td>';
    HTMLBody += '</tr></tbody></table></td></tr>';


    HTMLBody += '<tr><td height="10"></td></tr>';
    HTMLBody += '<tr><td bgcolor="#F2F2F2" style="padding: 8px 7px; border: 1px solid #dddddd">';
    HTMLBody += '<table cellspacing="0" cellpadding="1" width="100%" style="border-collapse: collapse; font-size: 12px;">';
    HTMLBody += '<tr><td valign="middle" height="30" style = "font-size: 12px; font-family: Arial;"><strong>'+Label.MKT_Payment_Date+':</strong> <strong>' + system.now().format('MM/dd/yyyy')+ '</strong></td>';
    HTMLBody += '<td></td><td></td></tr>';
    HTMLBody += '<tr><td style = "font-size: 12px; font-family: Arial;"><strong>'+Label.MKT_Billing_Address+'</strong></td><td style = "font-size: 12px; font-family: Arial;"><strong>'+Label.MKT_Payment_Information+'</strong></td><td style = "font-size: 12px; font-family: Arial;">  </td></tr>';
    HTMLBody += '<tr><td style = "font-size: 12px; font-family: Arial;">' + paymentObj.FirstName + ' ' + paymentObj.LastName + '</td>';
    HTMLBody += '<td style = "font-size: 12px; font-family: Arial;"><span>'+Label.MKT_Type+':</span> <span>'+ /*paymentObj.PaymentSourceItem.kumocomm__CreditCardType__c*/ +'</span></td>';
    HTMLBody += '<td></td></tr>';
    HTMLBody += ' <tr><td style = "font-size: 12px; font-family: Arial;">'+paymentObj.Address1+'</td>';
    HTMLBody += '<td style="font-size: 12px; font-family: Arial;"><span>Number:</span> <span>............</span> <span>'+ /*paymentObj.PaymentSourceItem.kumocomm__Last4CreditCardNumber__c*/ +'</span></td>';
    HTMLBody += '<td></td></tr>';
    HTMLBody += '<tr><td style="font-size: 12px; font-family: Arial;">' + paymentObj.City + ','+ paymentObj.State + ' ' + paymentObj.Zip + '</td>';
    HTMLBody += '<td style="font-size: 12px; font-family: Arial;"><span>'+Label.MKT_Exp_Date+':</span> <span>'+/* paymentObj.PaymentSourceItem.kumocomm__CreditCardExpirationMonth__c*/ + '/' + /*paymentObj.PaymentSourceItem.kumocomm__CreditCardExpirationYear__c */+'</span></td>';
    HTMLBody += '<td></td></tr>';
    HTMLBody += '<tr><td style="font-size: 12px; font-family: Arial;"><a href="mailto: '+ paymentObj.Email +'">'+ paymentObj.Email +'</a></td>';
    HTMLBody += '<td style="font-size: 12px; font-family: Arial;"><strong style="color: #6A67B9">'+Label.MKT_Confirmation+':</strong> <strong style="color: #6A67B9;">' + GatewayTransactionId + '</strong></td>';
    HTMLBody += '<td></td></tr>';
    HTMLBody += '<tr><td></td><td style="font-size: 12px; font-family: Arial;"> </td>';
    HTMLBody += '<td></td></tr>';
    HTMLBody += '</table></td></tr>';
    HTMLBody += '<tr><td height="10"></td></tr><tr><td bgcolor="#F2F2F2" style="padding: 8px 7px; line-height: 1.4; border: 1px solid #dddddd"><p style="font-size: 11px; text-transform: uppercase; ">Customer cancellations for in-classroom training events must be received via email within three (72 hours) or more business days prior to the start of the training event. Cancellations are not accepted if less than 72 hours before the start of an in-class training event, nor for absences that occur the day of the course. No shows are billed 100%.<br/>Customer cancellations for Live-Virtual training events are: NOT permitted if less than 72 hours before the live presentation. NOT permitted after event is in-session or past the event date and time. NO refund is given if the unregistration takes place within 72 hours of the event. If you are unable to attend a Live Virtual course for any reason, please note that many of these Virtual Instructor-led Training events are recorded and accessible in Marketo university.<br/>Marketo does not guarantee your satisfaction with the training programs, including without limitation the courses for which you register, or your results. The training programs are provided as-is, where-is. Marketo and its affiliates make and you receive no warranties or conditions of any kind, express, implied or statutory, arising from or related to the training programs. Marketo hereby disclaims all warranties that might otherwise be implied by law, including merchantibility, fitness for a particular purpose and non-infringement of third party.</p></td></tr>';
    HTMLBody += '</tbody></table></td></tr></tbody></table>';
    return HTMLBody;
  }
  /*public kumocomm__Payment_Source__c FillPaymentSource() {
    kumocomm__GatewayConfig__c DefaultGateway = HelperWithoutSharing.getDefaultGateway(); // костыль, после обновления kumo необходимо переписать
    List<RecordType> RCPaymentSourceList = [SELECT Id FROM RecordType WHERE SobjectType='kumocomm__Payment_Source__c' AND DeveloperName='CreditCard' limit 1];
    List<kumocomm__Payment_Source__c> PaymentSourceList = [SELECT Id/*, kumocomm__Contact__c*//*,kumocomm__Gateway_Config__c, kumocomm__CreditCardExpirationMonth__c, kumocomm__Token__c, /*kumocomm__Last4CreditCardNumber__c, kumocomm__CreditCardExpirationYear__c, kumocomm__CreditCardSecurityCode__c, kumocomm__CreditCardType__c FROM kumocomm__Payment_Source__c WHERE /*kumocomm__Contact__c = :paymentObj.curUserContact.Id AND kumocomm__Gateway_Config__c = :DefaultGateway.ID LIMIT 1];
    kumocomm__Payment_Source__c PaymentSourceItem;
    if (PaymentSourceList.Size() > 0 /*&& getIsShowChange()) {
      PaymentSourceItem = PaymentSourceList[0];
    }
    else {
      PaymentSourceItem = new kumocomm__Payment_Source__c ();
      //PaymentSourceItem.kumocomm__Contact__c = paymentObj.curUserContact.Id;
    }
    PaymentSourceItem.kumocomm__CreditCardExpirationMonth__c = paymentObj.PaymentSourceItem.kumocomm__CreditCardExpirationMonth__c;
    PaymentSourceItem.kumocomm__CreditCardExpirationYear__c = paymentObj.PaymentSourceItem.kumocomm__CreditCardExpirationYear__c;
    PaymentSourceItem.kumocomm__CreditCardSecurityCode__c = paymentObj.PaymentSourceItem.kumocomm__CreditCardSecurityCode__c;
    PaymentSourceItem.kumocomm__CreditCardType__c = paymentObj.PaymentSourceItem.kumocomm__CreditCardType__c;
    PaymentSourceItem.kumocomm__Gateway_Config__c = DefaultGateway.Id;
    if (paymentObj.CardNumber != '') /*PaymentSourceItem.kumocomm__Last4CreditCardNumber__c =  paymentObj.getCardEnding();
    PaymentSourceItem.kumocomm__Token__c =  paymentObj.PaymentSourceItem.kumocomm__Token__c;
    if (RCPaymentSourceList.Size() > 0) PaymentSourceItem.RecordTypeId = RCPaymentSourceList[0].Id;
    //upsert PaymentSourceItem;
    return PaymentSourceItem;
  }*/
  public String FillBillingAddress() {
   // List<kumocomm__Address__c> BillingAddressList = [SELECT Id, MKT_Address2__c, MKT_FirstName__c, MKT_LastName__c, MKT_Phone__c, /*kumocomm__Contact__c, */kumocomm__City__c, kumocomm__Country__c, kumocomm__PostalCode__c, kumocomm__State__c, kumocomm__Street__c, kumocomm__Type__c FROM kumocomm__Address__c WHERE /*kumocomm__Contact__c = :paymentObj.curUserContact.Id AND */kumocomm__Type__c = 'Billing Address' LIMIT 1];
    //kumocomm__Address__c BillingAddressItem;
    //if (BillingAddressList.Size() > 0) {
     // BillingAddressItem = BillingAddressList[0];
    //}
    //else {
    //  BillingAddressItem = new kumocomm__Address__c();
   // }
    //BillingAddressItem.kumocomm__Contact__c = paymentObj.curUserContact.Id;
    /*BillingAddressItem.kumocomm__Type__c = 'Billing Address';
    BillingAddressItem.kumocomm__City__c = paymentObj.City;
    BillingAddressItem.kumocomm__Country__c = paymentObj.Country;
    BillingAddressItem.kumocomm__PostalCode__c = paymentObj.Zip;
    BillingAddressItem.kumocomm__State__c = paymentObj.State;
    BillingAddressItem.kumocomm__Street__c = paymentObj.Address1;
    BillingAddressItem.kumocomm__PostalCode__c = paymentObj.Zip;
    BillingAddressItem.MKT_FirstName__c = paymentObj.FirstName;
    BillingAddressItem.MKT_LastName__c = paymentObj.LastName;
    BillingAddressItem.MKT_Phone__c = paymentObj.Phone;
    BillingAddressItem.MKT_Address2__c = paymentObj.Address2;
    upsert BillingAddressItem;
    return BillingAddressItem.Id;*/
    return '';
  }
  public void EditOrder() {
    Step = 'cart';
  }
  public void UpdateQuantity() {
    /*if (idObjectForUpdate != NULL && idObjectForUpdate != '' /*&& ShoppingCartItemIdMap.containsKey(idObjectForUpdate)*/ /*&& NewQuantity != NULL && NewQuantity != '') {
      try {
        //kumocomm__ShoppingCartItem__c ItemForUpdate = new kumocomm__ShoppingCartItem__c (); /*ShoppingCartItemIdMap.get(idObjectForUpdate);*/
        //if (ItemForUpdate.kumocomm__Quantity__c != Integer.valueOf(NewQuantity)) {
//ItemForUpdate.kumocomm__Quantity__c = Integer.valueOf(NewQuantity);
         // update ItemForUpdate;
          //InitShoppingCart();
        //}
    /*  }
      catch(Exception e) {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Wrong Quantity'));
      }
    }*/
  }
  public List<SelectOption> getStates() {
    return HelperWithoutSharing.getStates();
  }

  public List<SelectOption> getCardTypes() {
    return HelperWithoutSharing.getCardTypes();
  }
  public List<SelectOption> getYears() {
    return HelperWithoutSharing.getYears();
  }

  /*public void CreateOpportunity(String TransactionId, List<kumocomm__OrderItem__c> NewOrderItems) {
    Savepoint sp = Database.setSavepoint();
    try {
      //System.Debug('=========CreateOpportunity Start==========' + system.now());
      kumocomm__Transaction__c transactionObj = [SELECT Id FROM kumocomm__Transaction__c WHERE Id =: TransactionId/* ,kumocomm__Amount__c,kumocomm__Last4CreditCardNumber__c *//*];
      RecordType recT = [SELECT Id FROM RecordType WHERE SobjectType =: Opportunity.sObjectType.getDescribe().getName() AND DeveloperName = 'Closed_Won' LIMIT 1];
      String oppName = !Test.isRunningTest() ? ((paymentObj.curUserContact.AccountId != NULL) ? (paymentObj.curUserContact.Account.Name + '-') : '') : 'Test';
      oppName += 'University-' + datetime.now() + ' ' +datetime.now().millisecond();
      String IntacctEntity;
      List<Intacct_Entity__c> IntacctEntityList = [SELECT ID FROM Intacct_Entity__c WHERE Name = 'Marketo-us' LIMIT 1];
      if (IntacctEntityList.size() > 0) {
        IntacctEntity = IntacctEntityList[0].Id;
      }
      Opportunity newOpp = new Opportunity(
                          AccountId = paymentObj.curUserContact.AccountId,
                          MKT_User__c = paymentObj.curUser.Id,
                          Name = oppName, RecordTypeId = recT.Id,
                          Type = 'Upsell/Crossell',
                          StageName = 'Discovery',
                          CloseDate = date.today(),
                          MKT_Transaction__c = transactionObj.Id,
                          MKT_Order__c = OrderId,
                          Payment_Frequency__c = 'One-time',
                          Contract_Sign_Date__c = date.today(),
                          Intacct_Entity__c = IntacctEntity,
                          Deal_Type__c = 'University',
                          Sub_Start_Date__c = date.today(),
                          Sub_End_Date__c = date.today(),
                          Primary_Marketo_User_Lookup__c = paymentObj.curUserContact.Id,
                          Primary_Marketo_User_Email__c = paymentObj.curUser.Email,
                          //Primary_Marketo_User_Phone__c = paymentObj.curUser.Phone,
                          Subscription_Time_Zone__c = 'Pacific Time (America/Los_Angeles)',
                          Subscription_Language__c = 'English',
                          Subscription_Locale__c = 'English-United States'
                        );
      String OwnerId = HelperWithoutSharing.getOpportunityOwnerId();
      if (OwnerId != NULL) {
        newOpp.OwnerId = OwnerId;
      }
      HelperWithoutSharing.insertOpportunities(new List<Opportunity> {newOpp});
      System.Debug('=========CreateOpportunity End==========' + system.now());
      List<OpportunityLineItem> OpportunityLItems = new List<OpportunityLineItem>();
      System.Debug('=========CreateOpportunity Products Start==========' + system.now());
      //for (kumocomm__OrderItem__c NewOrderItem : NewOrderItems) {
        OpportunityLineItem opportunityLItem = new OpportunityLineItem(
                                        OpportunityId = newOpp.Id,
                                        //Quantity = NewOrderItem.kumocomm__Quantity__c,
                                        //PricebookEntryId = getProductPricebook(NewOrderItem.kumocomm__Product__c).Id,
                                        //UnitPrice = NewOrderItem.kumocomm__Amount__c,
                                        ServiceEndDate__c = date.today(),
                                        ServiceDate = date.today(),
                                        Geography__c = 'US', Location__c = 'Marketo-us',
                                        Rev_Rec_Template__c = '',
                                        Subscription_Time_Zone__c = 'Pacific Time (America/Los_Angeles)',
                                        Subscription_Language__c = 'English',
                                        Subscription_Locale__c = 'English-United States'
                                        );
      OpportunityLItems.Add(opportunityLItem);
      //}
      HelperWithoutSharing.insertOpportunityLineItems(OpportunityLItems);
      System.Debug('=========CreateOpportunity Products End==========' + system.now());
      newOpp.StageName = 'Closed Won';
      System.Debug('=========UpdateOpportunity Start==========' + system.now());
      HelperWithoutSharing.updateOpportunities(new List<Opportunity> {newOpp});
      System.Debug('=========UpdateOpportunity End==========' + system.now());
      List<MKT_PaymentLicense__c> pl = new List<MKT_PaymentLicense__c>();
      Set<Id> PrIDss = new Set<Id>();
      //for (kumocomm__OrderItem__c NewO : NewOrderItems){
        //PrIDss.Add(NewO.kumocomm__Product__c);
      //}

      List<MKT_Payment__c> paymentList = [SELECT Id, Remaining_Seats__c FROM MKT_Payment__c WHERE  Account__c =: paymentObj.curUserContact.AccountId AND MKT_Opportunity__c = :newOpp.ID /*Product__c IN: PrIDss AND*//*];
      if (paymentList.Size() > 0) {
        for (MKT_Payment__c pItem : paymentList) {
          MKT_PaymentLicense__c paymentLicense = new MKT_PaymentLicense__c(User__c = paymentObj.curUser.Id, MKT_Payment__c = pItem.Id);
          pl.Add(paymentLicense);
        }
        System.Debug('=========Insert Payment Rec Start==========' + system.now());
        if (pl.Size() > 0) insert pl;
        System.Debug('=========Insert Payment Rec End==========' + system.now());
        System.Debug('=========createSOTransaction Start==========' + system.now());
        HelperWithoutSharing.processIntacctTransaction(String.ValueOf(newOpp.ID), String.ValueOf(paymentObj.curUserContact.Account.IntacctID__c));
        System.Debug('=========createSOTransaction End==========' + system.now());
      }
    }
    catch (Exception e) {
      Database.rollback(sp);
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.GetMessage()));
    }
  }*/
  public String getTotalPrice() {
    Decimal TotalDec = 0;
    String TotalString = '0';
    if (TotalAmount != NULL && TotalAmount.UnitPrice != NULL) {
      TotalDec = TotalAmount.UnitPrice;
      TotalString = HelperWithoutSharing.currencySymbol(TotalAmount.CurrencyIsoCode) + String.ValueOf(TotalDec.setScale(0).format());
    }
    return TotalString;
  }


    // Inner Classes//
  public class CartItemWrapper {
    public String CourseName { get; set; }
    public String Type { get; set; }
    public String Location { get; set; }
    public String StartSess { get; set; }
    public String EndSess { get; set; }
    public String EventId { get; set; }
    public String ClassId { get; set; }
    public Integer Quantity { get; set; }
    public String ProductId { get; set; }
    public String Description { get; set; }
    public PricebookEntry Price { get; set; }
    public String CartItemId { get; set; }
    public Boolean IsPaid { get; set; }
    public Boolean IsExpired { get; set; }
    //public kumocomm__ShoppingCartItem__c ShoppingCartItem{ get; set; }
    public String getCost() {
      String CostString = '0';
      if (Price != NULL && Price.UnitPrice != NULL) {
        CostString = HelperWithoutSharing.currencySymbol(Price.CurrencyIsoCode) + String.ValueOf(Price.UnitPrice.setScale(0).format());
      }
      return CostString;
    }
    public String getSubtotal() {
      Decimal SubtotalDec = 0;
      String SubtotalString = '0';
      if (Price != NULL && Price.UnitPrice != NULL && Quantity != NULL && Quantity >= 0) {
        SubtotalDec = Price.UnitPrice * Quantity;
        SubtotalString = HelperWithoutSharing.currencySymbol(Price.CurrencyIsoCode) + String.ValueOf(SubtotalDec.setScale(0).format());
      }
      return SubtotalString;
    }
  }

  public class PaymentInfo {
    public String paymentStatus { get; set; }
    public String Title { get; set; }
    public Boolean isAccept { get; set; }
    public PricebookEntry PricebookEntryItem { get; set; }
    //public kumocomm.KumoCollectionClasses.AddressInfo customerAddress{ get; set; }
    public lmsilt__Class__c ClassesObj { get; set; }
    public User curUser { get; set; }
    public Contact curUserContact { get; set; }
    public String TestTransactionId { get; set; } // Only for Test.IsRunningTest()
    public Decimal Cost { get; set; }
    public String ProductId { get; set; }
    public String Description { get; set; }
    public Boolean ExCard { get; set; }
    public String FirstName { get; set; }
    public String LastName { get; set; }
    public String Quantity { get; set; }
    public String CardType { get; set; }
    public String CardNumber { get; set; }
    public String ExpirationMonth { get; set; }
    public String ExpirationYear { get; set; }
    public String Code { get; set; }
    public String Phone { get; set; }
    public String CardNumberCoded;
    public String CardEnding;

    public String Email { get; set; }
    public String Address1 { get; set; }
    public String Address2 { get; set; }
    public String Country { get; set; }
    public String State { get; set; }
    public String Zip { get; set; }
    public String City { get; set; }
  //  public kumocomm__Payment_Source__c PaymentSourceItem { get; set; }
   // public kumocomm__Payment_Source__c PaymentSourceItemOld { get; set; }

    public String getCardEnding () {
      String CardEndingS = '';
      if (CardNumber != '' && CardNumber != NULL) {
        CardEndingS = CardNumber.substring(CardNumber.length() - 4);
      }
      return CardEndingS;
    }
    /*public void saveOldPayment(kumocomm__Payment_Source__c PaymentSourceItemNew) {
      PaymentSourceItemOld.kumocomm__CreditCardExpirationMonth__c = PaymentSourceItemNew.kumocomm__CreditCardExpirationMonth__c;
      PaymentSourceItemOld.kumocomm__CreditCardExpirationYear__c = PaymentSourceItemNew.kumocomm__CreditCardExpirationYear__c;
      PaymentSourceItemOld.kumocomm__CreditCardType__c = PaymentSourceItemNew.kumocomm__CreditCardType__c;
      PaymentSourceItemOld.kumocomm__CreditCardSecurityCode__c = PaymentSourceItemNew.kumocomm__CreditCardSecurityCode__c;
      //PaymentSourceItemOld.kumocomm__Last4CreditCardNumber__c =  PaymentSourceItemNew.kumocomm__Last4CreditCardNumber__c;
      PaymentSourceItemOld.kumocomm__Token__c =  PaymentSourceItemNew.kumocomm__Token__c;
      PaymentSourceItemOld.kumocomm__Gateway_Config__c = PaymentSourceItemNew.kumocomm__Gateway_Config__c;
    }*/
    /*public kumocomm__Payment_Source__c getOldPayment(kumocomm__Payment_Source__c PaymentSourceItemNew) {
      PaymentSourceItemNew.kumocomm__CreditCardExpirationMonth__c = PaymentSourceItemOld.kumocomm__CreditCardExpirationMonth__c;
      PaymentSourceItemNew.kumocomm__CreditCardExpirationYear__c = PaymentSourceItemOld.kumocomm__CreditCardExpirationYear__c;
      PaymentSourceItemNew.kumocomm__CreditCardType__c = PaymentSourceItemOld.kumocomm__CreditCardType__c;
      PaymentSourceItemNew.kumocomm__CreditCardSecurit
      
      
      yCode__c = PaymentSourceItemOld.kumocomm__CreditCardSecurityCode__c;
      //PaymentSourceItemNew.kumocomm__Last4CreditCardNumber__c =  PaymentSourceItemOld.kumocomm__Last4CreditCardNumber__c;
      PaymentSourceItemNew.kumocomm__Token__c = PaymentSourceItemOld.kumocomm__Token__c;
      PaymentSourceItemNew.kumocomm__Gateway_Config__c = PaymentSourceItemOld.kumocomm__Gateway_Config__c;
      return PaymentSourceItemNew;
    }*/
    public String getCardNumberCoded () {
      String CardNumberCodedS = '';
      if (CardNumber != '' && CardNumber != NULL) {
        String[] CardNumberArray = CardNumber.Split('');
        if (CardNumberArray.size() > 0) {
          Integer j = 1;
          for (Integer i = 1; i < CardNumberArray.size() - 4; i++) {
            CardNumberCodedS += '.';
            if (j == 4) {
              CardNumberCodedS += ' ';
              j = 0;
            }
            j++;
          }
        }
      }
      return CardNumberCodedS;
    }
    public PaymentInfo() {
      CardNumber= '';
      String curHost = ApexPages.currentPage().getHeaders().get('Host');
      String ContactIdForTest = ApexPages.currentPage().getParameters().get('ContactIdForTest');
      //customerAddress = new kumocomm.KumoCollectionClasses.AddressInfo();
      paymentStatus = NULL;
      isAccept = false;
      curUser = [SELECT Id, ContactID, AccountId, Email, Phone, Contact.Phone, Contact.OtherStreet, Contact.Email, Contact.MailingCountry, Contact.MailingPostalCode, Contact.MailingState, Contact.MailingCity, Contact.MailingStreet, Contact.FirstName, Contact.LastName, Contact.AccountId, Contact.Account.Name, Contact.Account.IntacctID__c FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];
      String ContactID = curUser.ContactID;
      /*PaymentSourceItem = new kumocomm__Payment_Source__c();*/
      /*PaymentSourceItemOld = new kumocomm__Payment_Source__c();*/
      ExCard = false;
      if (Test.IsRunningTest() && ContactIdForTest != NULL && ContactIdForTest != '') ContactID = ContactIdForTest;
      if (ContactID != NULL) {
        curUserContact = [SELECT Id, AccountId, Phone, OtherStreet, Email, MailingCountry, MailingPostalCode, MailingState, MailingCity, MailingStreet, FirstName, LastName, Account.Name, Account.IntacctID__c FROM Contact WHERE ID = :ContactID LIMIT 1];
        //List<kumocomm__Address__c> BillingAddressList = [SELECT Id, MKT_Address2__c, MKT_FirstName__c, MKT_LastName__c, MKT_Phone__c, /*kumocomm__Contact__c,*/ kumocomm__City__c, kumocomm__Country__c, kumocomm__PostalCode__c, kumocomm__State__c, kumocomm__Street__c, kumocomm__Type__c FROM kumocomm__Address__c WHERE /*kumocomm__Contact__c = :ContactID AND */kumocomm__Type__c = 'Billing Address' LIMIT 1];
        /*List<kumocomm__Payment_Source__c> PaymentSourceList = new List<kumocomm__Payment_Source__c>();*/
        //List<kumocomm__GatewayConfig__c> ActiveGatewayList = HelperWithoutSharing.getActiveGatewayList();
        //if (ActiveGatewayList.Size() == 1 || (Test.IsRunningTest() && ActiveGatewayList.Size() > 0)) {
          //PaymentSourceList = [SELECT Id, kumocomm__Gateway_Config__c, kumocomm__Contact__c, kumocomm__CreditCardExpirationMonth__c, kumocomm__Token__c, /*kumocomm__Last4CreditCardNumber__c, */kumocomm__CreditCardExpirationYear__c, kumocomm__CreditCardSecurityCode__c, kumocomm__CreditCardType__c FROM kumocomm__Payment_Source__c WHERE /*kumocomm__Contact__c = :ContactID AND */kumocomm__Gateway_Config__c = :ActiveGatewayList[0].ID LIMIT 1];
        //}
        /*if (BillingAddressList.Size() > 0) {
          City = BillingAddressList[0].kumocomm__City__c;
          Country = BillingAddressList[0].kumocomm__Country__c;
          State = BillingAddressList[0].kumocomm__State__c;
          Address1 = BillingAddressList[0].kumocomm__Street__c;
          Zip = BillingAddressList[0].kumocomm__PostalCode__c;
          Phone = BillingAddressList[0].MKT_Phone__c;
          Address2 = BillingAddressList[0].MKT_Address2__c;
        }
        else {
          Address1 = curUser.Contact.MailingStreet;
          Address2 = curUser.Contact.OtherStreet;
          State = curUser.Contact.MailingState;
          Zip = curUser.Contact.MailingPostalCode;
          City = curUser.Contact.MailingCity;
        }*/
        //if (PaymentSourceList.Size() > 0) {
         // ExCard = true;
          /*PaymentSourceItem.kumocomm__CreditCardExpirationMonth__c = PaymentSourceList[0].kumocomm__CreditCardExpirationMonth__c;
          PaymentSourceItem.kumocomm__CreditCardExpirationYear__c = PaymentSourceList[0].kumocomm__CreditCardExpirationYear__c;
          PaymentSourceItem.kumocomm__CreditCardType__c = PaymentSourceList[0].kumocomm__CreditCardType__c;
          PaymentSourceItem.kumocomm__CreditCardSecurityCode__c = PaymentSourceList[0].kumocomm__CreditCardSecurityCode__c;
          //PaymentSourceItem.kumocomm__Last4CreditCardNumber__c = PaymentSourceList[0].kumocomm__Last4CreditCardNumber__c;
          PaymentSourceItem.kumocomm__Token__c = PaymentSourceList[0].kumocomm__Token__c;
          PaymentSourceItem.kumocomm__Gateway_Config__c = PaymentSourceList[0].kumocomm__Gateway_Config__c;*/
       // }
        FirstName = curUser.Contact.FirstName;
        LastName = curUser.Contact.LastName;
        Email = curUser.Contact.Email;
        Country = 'US'/*curUser.Contact.MailingCountry*/;

      }
   // saveOldPayment(PaymentSourceItem);
    }
    public PaymentInfo(String OrderId) {
      paymentStatus = NULL;
      ExCard = false;
      isAccept = false;
      CardNumber= '';
      String ContactIdForTest = ApexPages.currentPage().getParameters().get('ContactIdForTest');

      //PaymentSourceItem = new kumocomm__Payment_Source__c();
     // PaymentSourceItemOld = new kumocomm__Payment_Source__c();
      curUser = [SELECT Id, ContactID, AccountId, Email, Phone, Contact.Phone, Contact.OtherStreet, Contact.Email, Contact.MailingCountry, Contact.MailingPostalCode, Contact.MailingState, Contact.MailingCity, Contact.MailingStreet, Contact.FirstName, Contact.LastName, Contact.AccountId, Contact.Account.Name, Contact.Account.IntacctID__c FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];
      String ContactID = curUser.ContactID;
     // List<kumocomm__Address__c> BillingAddressList = new List<kumocomm__Address__c>();
     // List<kumocomm__Payment_Source__c> PaymentSourceList = new List<kumocomm__Payment_Source__c>();
      //List<kumocomm__Order__c> OrderObj = [SELECT ID, kumocomm__BillingAddress__c, kumocomm__PaymentSource__c FROM kumocomm__Order__c WHERE Id = :OrderId]/*kumocomm__Contact__c*/ ;
      //if (OrderObj.Size() > 0) {
        //BillingAddressList = [SELECT Id, MKT_Address2__c, MKT_FirstName__c, MKT_LastName__c, MKT_Phone__c, /*kumocomm__Contact__c,*/ kumocomm__City__c, kumocomm__Country__c, kumocomm__PostalCode__c, kumocomm__State__c, kumocomm__Street__c, kumocomm__Type__c FROM kumocomm__Address__c WHERE ID = :OrderObj[0].kumocomm__BillingAddress__c AND kumocomm__Type__c = 'Billing Address' LIMIT 1];
       // List<kumocomm__GatewayConfig__c> ActiveGatewayList = HelperWithoutSharing.getActiveGatewayList();
        //if (ActiveGatewayList.Size() == 1) {
         // PaymentSourceList = [SELECT Id, kumocomm__Gateway_Config__c, kumocomm__Contact__c, kumocomm__CreditCardExpirationMonth__c,kumocomm__Last4CreditCardNumber__c, kumocomm__Token__c, kumocomm__CreditCardExpirationYear__c, kumocomm__CreditCardSecurityCode__c, kumocomm__CreditCardType__c FROM kumocomm__Payment_Source__c WHERE ID = :OrderObj[0].kumocomm__PaymentSource__c AND kumocomm__Gateway_Config__c = :ActiveGatewayList[0].ID LIMIT 1];
       // }
      //}
      if (Test.IsRunningTest() && ContactIdForTest != NULL && ContactIdForTest != '') ContactID = ContactIdForTest;
      if (ContactID != NULL) {
        curUserContact = [SELECT Id, AccountId, Phone, OtherStreet, Email, MailingCountry, MailingPostalCode, MailingState, MailingCity, MailingStreet, FirstName, LastName, Account.Name, Account.IntacctID__c FROM Contact WHERE ID = :ContactID LIMIT 1];
       /*if (BillingAddressList.Size() > 0) {
          City = BillingAddressList[0].kumocomm__City__c;
          Country = BillingAddressList[0].kumocomm__Country__c;
          State = BillingAddressList[0].kumocomm__State__c;
          Address1 = BillingAddressList[0].kumocomm__Street__c;
          Zip = BillingAddressList[0].kumocomm__PostalCode__c;
          Phone = BillingAddressList[0].MKT_Phone__c;
          Address2 = BillingAddressList[0].MKT_Address2__c;
        }
        else {*/
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Billing Address is not defined'));
          return;
        //}
        //if (PaymentSourceList.Size() > 0) {
          //ExCard = true;
          //PaymentSourceItem.kumocomm__CreditCardExpirationMonth__c = PaymentSourceList[0].kumocomm__CreditCardExpirationMonth__c;
         // PaymentSourceItem.kumocomm__CreditCardExpirationYear__c = PaymentSourceList[0].kumocomm__CreditCardExpirationYear__c;
          //PaymentSourceItem.kumocomm__CreditCardType__c = PaymentSourceList[0].kumocomm__CreditCardType__c;
         // PaymentSourceItem.kumocomm__CreditCardSecurityCode__c = PaymentSourceList[0].kumocomm__CreditCardSecurityCode__c;
          //PaymentSourceItem.kumocomm__Last4CreditCardNumber__c = PaymentSourceList[0].kumocomm__Last4CreditCardNumber__c;
          //PaymentSourceItem.kumocomm__Token__c = PaymentSourceList[0].kumocomm__Token__c;
          //PaymentSourceItem.kumocomm__Gateway_Config__c = PaymentSourceList[0].kumocomm__Gateway_Config__c;
        //}
        
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Payment Source is not defined'));
          return;
        
        FirstName = curUser.Contact.FirstName;
        LastName = curUser.Contact.LastName;
        Email = curUser.Contact.Email;
      }
   // saveOldPayment(PaymentSourceItem);
    }
  }
}