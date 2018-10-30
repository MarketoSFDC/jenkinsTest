@isTest
private class GlobalFunctions_Test {
    
    static testMethod void getShortBodyTest() {
        System.assertEquals(null, GlobalFunctions.getShortBody(null));
        System.assertEquals('test bold, italic, and underline.', GlobalFunctions.getShortBody('test <b>bold</b>, <i>italic</i>, and <u>underline</u>.'));

        GlobalFunctions.MAX_SHORT_BODY_LENGTH = 10;
        System.assertEquals('test long  ...', GlobalFunctions.getShortBody('test long body'));
       
    }
    
}