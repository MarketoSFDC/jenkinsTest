@IsTest
public class LeadConvertTests {
	@IsTest
    public static void testLoadCoverage() {
        Lead l = new Lead();
        LeadConvert controller = new LeadConvert(new ApexPages.StandardController(l));
        controller.action();
    }
    @IsTest
    public static void testConvertRedirect() {
        PageReference pr = LeadConvert.sendToConvertPage(new Lead(Id='00Q000000000001'),true);
        System.assert(pr != null);
    }
    @IsTest
    public static void testBOFURedirect() {
        PageReference pr = LeadConvert.sendToBOFU(new Lead(Id='00Q000000000001'));
        System.assert(pr != null);
    }
}