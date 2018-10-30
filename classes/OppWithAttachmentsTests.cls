@IsTest
class OppWithAttachmentsTests {
    @IsTest
    static void integrationTest() {
        // test init
        OppWithAttachments_Con con = new OppWithAttachments_Con();
        // test getters for coverage
        con.agreementMap.size();
        con.opportunities.size();
    }
}