public class CSUtils {

	private static Map<String, Schema.SObjectType> sObjectTypeMap = Schema.getGlobalDescribe();
	private static Map<String, Map<String, Schema.RecordTypeInfo>> sObjectTypeToRecordTypesMap = new Map<String,  Map<String, Schema.RecordTypeInfo>>();

	// Mapping of standard object prefixes to their names.
	private static Map<String, String> OBJECT_NAMES =
		new Map<String, String>{'001' => 'Account',
		                        '002' => 'Note',
		                        '003' => 'Contact',
		                        '005' => 'User',
		                        '006' => 'Opportunity',
		                        '00Q' => 'Lead',
		                        '00G' => 'Group',
		                        '500' => 'Case',
		                        '00T' => 'Task',
		                        '00U' => 'Event'};


	/**
	 * Determine if a String object is empty.
	 */
	public static Boolean isEmpty(String str) {
		return (str == null || str.trim().length() < 1);
	}

	/**
	 * Determine if a String object has a numeric value.
	 */
	public static Boolean isNumeric(String str) {
		try {
			Double.valueOf(str);
			return true;
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * Determine if a String is a valid Id.
	 */
	public static Boolean isValidId(String idValue) {
		try {
			Id id = idValue;
			return true;
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * Parse a string representation of a Boolean into a Boolean object.
	 */
	public static Boolean parseBoolean(String str) {
		if (str == null) return null;
		if ('true'.equalsIgnoreCase(str)) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Left pad a String to the given length with the given pad character.
	 */
	public static String leftPad(String str, String pad, Integer length) {
		if (str != null) {
			while ((length - str.length()) > 0) {
				str = pad + str;
			}
		}

		return str;
	}

	/**
	 * Right pad a String to the given length with the given pad character.
	 */
	public static String rightPad(String str, String pad, Integer length) {
		if (str != null) {
			while ((length - str.length()) > 0) {
				str += pad;
			}
		}

		return str;
	}

	/*
	 * Convert a Decimal to an Integer by removing everything after the decimal.
	 */
	public static Integer convertDecimalToInteger(Decimal dec) {
		String decimalString = dec + '';

		Integer decimalPlace = decimalString.indexOf('.');
		if (decimalPlace != -1) {
			decimalString = decimalString.substring(0, decimalPlace);
		}

		return Integer.valueOf(decimalString);
	}

	/**
	 * Perform a null-safe equals comparison on two strings.
	 */
	public static Boolean nullSafeEquals(String a, String b) {
		return a == null ? (b == null ? true : false) : (b == null ? false : a.equals(b));
	}

	/**
	 * Join a list of String values into one string separated by the specified separator.
	 */
	public static String join(List<String> values, String separator) {
		if (values == null || values.size() < 1) return null;
		
		String joined = '';

		Iterator<String> iterator = values.iterator();
		if (iterator.hasNext()) {
			joined += iterator.next();
			while (iterator.hasNext()) {
				joined += separator + iterator.next();
			}
		}

		return joined;
	}
	
	/**
	 * Join a set of String values into one string separated by the specified separator.
	 */
	public static String join(Set<String> values, String separator) {
		List<String> valuesList;

		if (values != null) {
			valuesList = new List<String>();
			valuesList.addAll(values);
		}

		return join(valuesList, separator);
	}

	/**
	 * Join a list of field values from a list of SObjects into one string separated by the specified separator.
	 */
	public static String join(List<sObject> objects, String fieldName, String separator) {
		List<String> valuesList;

		if (objects != null) {
			valuesList = new List<String>();

			for (sObject obj : objects) {
				valuesList.add(String.valueOf(obj.get(fieldName)));
			}
		}

		return join(valuesList, separator);
	}

	/**
	 * Wraps a string in quote (") characters and escapes any existing quotes in the string.
	 * This method is useful when generating CSV files.
	 */
	public static String quote(String value) {
		if (isEmpty(value)) return '""';

		String escaped = value.replace('"', '""');

		return '"' + escaped + '"';
	}
	
	/**
	 * Quotes a list of values.
	 */
	public static List<String> quote(List<String> values) {
		if (values == null) return null;

		List<String> quotedValues = new List<String>();
		for (String value : values) {
			String quotedValue = quote(value);
			quotedvalues.add(quotedValue);
		}

		return quotedValues;
	}

	/**
	 * Format a Date with the given format.
	 */
	public static String formatDate(Date d, String format) {
		if (d == null) return null;

		DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
		return dt.format(format);
	}

	/**
	 * Convert a DateTime object to a Date object.
	 */
	public static Date convertDateTimeToDate(DateTime dt) {
		if (dt == null) return null;
		
		return Date.newInstance(dt.year(), dt.month(), dt.day());
	}

	/**
	 * Given an SObject name and Record Type name, return the Record Type's Id.
	 */
	public static Id getRecordTypeId(String sObjectType, String recordType) {
		if (sObjectTypeToRecordTypesMap.containsKey(sObjectType) == false) {
			Schema.SObjectType sotype = sObjectTypeMap.get(sObjectType);
			Map<String, Schema.RecordTypeInfo> recordTypesMap = sotype.getDescribe().getRecordTypeInfosByName();
			sObjectTypeToRecordTypesMap.put(sObjectType, recordTypesMap);
		}

		Map<String, Schema.RecordTypeInfo> recordTypesMap = sObjectTypeToRecordTypesMap.get(sObjectType);
		if (recordTypesMap != null) {
			Schema.RecordTypeInfo recordTypeInfo = recordTypesMap.get(recordType);
			if (recordTypeInfo != null) {
				return recordTypeInfo.getRecordTypeId();
			}
		}

		return null;
	}

	public static Schema.DescribeSObjectResult getObjectDescription(String objectName) {
		Schema.sObjectType objectType = sObjectTypeMap.get(objectName);
		if (objectType == null) {
			return null;
		}
		
		return objectType.getDescribe();
	}

	/**
	 * Get a list of a field's picklist values.
	 */
	public static List<String> getPicklistValues(String objectName, String fieldName, Boolean sortValues) {
		Schema.sObjectType objectType = sObjectTypeMap.get(objectName);
		Schema.DescribeSObjectResult objectDescription = objectType.getDescribe();
		Map<String, Schema.SObjectField> fieldsMap = objectDescription.fields.getMap();
		List<Schema.PicklistEntry> pickListValues = fieldsMap.get(fieldName).getDescribe().getPickListValues();

		List<String> values = new List<String>();

		for (Schema.PickListEntry entry : pickListValues){
			values.add(entry.getValue());
		}

		if (sortValues) values.sort();

		return values;
	}

	/**
	 * Get a field's picklist values as list of SelectOptions that can be used with a VF page.
	 */
	public static List<SelectOption> getPicklistAsSelectOptions(String objectName, String fieldName, Boolean sortValues) {
		List<SelectOption> selectOptions = new List<SelectOption>();
		for (String value : getPicklistValues(objectName, fieldName, sortValues)) {
			selectOptions.add(new SelectOption(value, value));
		}

		return selectOptions;
    }

	/* Get the field length for a text field. */
	public static Integer getTextFieldLength(String objectName, String fieldName) {
		Schema.sObjectType objectType = sObjectTypeMap.get(objectName);
		Schema.DescribeSObjectResult objectDescription = objectType.getDescribe();
		Map<String, Schema.SObjectField> fieldsMap = objectDescription.fields.getMap();
		Schema.DescribeFieldResult fieldResult = fieldsMap.get(fieldName).getDescribe();
		return fieldResult.getLength();
	}

	/**
	 * Given a Salesforce object id, return the name of the object that the id is for.
	 */
	public static String getObjectNameFromId(String id) {
		if (id == null) return null;
		
		String prefix = id.substring(0, 3);
		return OBJECT_NAMES.get(prefix);
	}

	/**
	 * Converts a Salesforce id to fifteen character variant.
	 */
	public static String fifteenCharacterId(String originalId) {
		if (CSUtils.isEmpty(originalId) || originalId.length() <= 15) {
			return originalId;
		}

		return originalId.substring(0, 15);
	}

	/**
	 * Given two objects and a set of field names, determine if any of the fields' values are different.
	 */
	public static Boolean fieldValuesDifferent(SOBject objectA, SObject objectB, Set<String> fieldNames) {
		for (String fieldName : fieldNames) {
			if (objectA.get(fieldName) != objectB.get(fieldName)) {
				return true;
			}
		}

		return false;
	}


	// --------------------------------------------------------------------------------------------
	// UNIT TESTS
	// --------------------------------------------------------------------------------------------

	static testMethod void testIsEmpty() {
		System.assertEquals(true, CSUtils.isEmpty(null));
		System.assertEquals(true, CSUtils.isEmpty(''));
		System.assertEquals(true, CSUtils.isEmpty('  '));
		System.assertEquals(false, CSUtils.isEmpty('not empty'));
	}

	static testMethod void testIsNumeric() {
		System.assertEquals(false, CSUtils.isNumeric(null));
		System.assertEquals(false, CSUtils.isNumeric(''));
		System.assertEquals(true, CSUtils.isNumeric('1'));
		System.assertEquals(true, CSUtils.isNumeric('1.0'));
		System.assertEquals(true, CSUtils.isNumeric('01'));
		System.assertEquals(true, CSUtils.isNumeric('.01'));
		System.assertEquals(false, CSUtils.isNumeric('text'));
	}

	static testMethod void testIsValidId() {
		System.assertEquals(true, CSUtils.isValidId(null));
		System.assertEquals(false, CSUtils.isValidId('1234'));
		System.assertEquals(false, CSUtils.isValidId('1234567890123456'));

		Contact contact = new Contact();
		contact.LastName = 'Test';
		insert contact;

		System.assertEquals(true, CSUtils.isValidId('' + contact.Id));
	}

	static testMethod void testParseBoolean() {
		System.assertEquals(null, CSUtils.parseBoolean(null));
		System.assertEquals(true, CSUtils.parseBoolean('true'));
		System.assertEquals(false, CSUtils.parseBoolean('false'));
		System.assertEquals(false, CSUtils.parseBoolean('neither'));
	}

	static testMethod void testLeftPad() {
		System.assertEquals(null, CSUtils.leftPad(null, null, null));
		System.assertEquals('1234', CSUtils.leftPad('1234', '0', 4));
		System.assertEquals('0555', CSUtils.leftPad('555', '0', 4));
		System.assertEquals('12345', CSUtils.leftPad('12345', '0', 4));
	}

	static testMethod void testRightPad() {
		System.assertEquals(null, CSUtils.rightPad(null, null, null));
		System.assertEquals('1234', CSUtils.rightPad('1234', '0', 4));
		System.assertEquals('5550', CSUtils.rightPad('555', '0', 4));
		System.assertEquals('12345', CSUtils.rightPad('12345', '0', 4));
	}

	static testMethod void testConvertDecimalToInteger() {
		System.assertEquals(1, convertDecimalToInteger(Decimal.valueOf(1)));
		System.assertEquals(1, convertDecimalToInteger(Decimal.valueOf('1.1')));
	}

	static testMethod void testNullSafeEquals() {
		System.assertEquals(true, CSUtils.nullSafeEquals(null, null));
		System.assertEquals(false, CSUtils.nullSafeEquals(null, 'val'));
		System.assertEquals(false, CSUtils.nullSafeEquals('val', null));
		System.assertEquals(true, CSUtils.nullSafeEquals('val', 'val'));
		System.assertEquals(false, CSUtils.nullSafeEquals('vala', 'valb'));
	}

	static testMethod void testJoin() {
		// List version.
		System.assertEquals(null, CSUtils.join((List<String>) null, ','));
		System.assertEquals('one', CSUtils.join(new List<String>{'one'}, '|'));
		System.assertEquals('one,two', CSUtils.join(new List<String>{'one', 'two'}, ','));
		System.assertEquals('one;two;three', CSUtils.join(new List<String>{'one', 'two', 'three'}, ';'));

		// Set version.
		System.assertEquals(null, CSUtils.join((Set<String>) null, ','));
		System.assertEquals('one', CSUtils.join(new Set<String>{'one'}, '|'));

		String joined = CSUtils.join(new Set<String>{'one', 'two'}, ',');
		System.assert(joined.contains('one'));
		System.assert(joined.contains('two'));
		System.assert(joined.contains(','));

		// SObject version.
		System.assertEquals(null, CSUtils.join((List<sObject>) null, 'Name', ','));
		System.assertEquals('Account1', CSUtils.join(new List<sObject>{new Account(Name='Account1')}, 'Name', '|'));
		System.assertEquals('Account1|Account2', CSUtils.join(new List<sObject>{new Account(Name='Account1'), new Account(Name='Account2')}, 'Name', '|'));
	}

	static testMethod void testQuote() {
		System.assertEquals('""', CSUtils.quote((String) null));
		System.assertEquals('""', CSUtils.quote(''));
		System.assertEquals('"John Doe"', CSUtils.quote('John Doe'));
		System.assertEquals('"This has ""quotes"" embedded."', CSUtils.quote('This has "quotes" embedded.'));

		List<String> quotedValues = CSUtils.quote(new List<String>{'John Doe', 'Jane Doe'});
		System.assertNotEquals(null, quotedValues);
		System.assertEquals('"John Doe"', quotedValues.get(0));
		System.assertEquals('"Jane Doe"', quotedValues.get(1));
		System.assertEquals(null, CSUtils.quote((List<String>) null));
	}

	static testMethod void testFormatDate() {
		System.assertEquals(null, CSUtils.formatDate(null, null));
		
		Date d1 = Date.newInstance(2009, 4, 6);
		System.assertEquals('2009-04-06', CSUtils.formatDate(d1, 'yyyy-MM-dd'));

		Date d2 = Date.newInstance(2009, 10, 22);
		System.assertEquals('2009/10/22', CSUtils.formatDate(d2, 'yyyy/MM/dd'));
	}

	static testMethod void testConvertDateTimeToDate() {
		// Test positive scenario.
		DateTime dt = DateTime.newInstance(2009, 4, 6);
		Date d = CSUtils.convertDateTimeToDate(dt);
		
		System.assertEquals(2009, d.year());
		System.assertEquals(4, d.month());
		System.assertEquals(6, d.day());
		
		// Test negative scenario.
		dt = null;
		d = CSUtils.convertDateTimeToDate(dt);
		
		System.assertEquals(null, d);
	}

	static testMethod void testGetRecordTypeId() {
		System.assertEquals(null, CSUtils.getRecordTypeId('Account', 'Test'));
	}

	static testMethod void testGetObjectDescription() {
		System.assertEquals(null, CSUtils.getObjectDescription(null));
		System.assert(CSUtils.getObjectDescription('Account') != null);
	}

	static testMethod void testGetPicklistValues() {
		System.assertNotEquals(null, CSUtils.getPicklistValues('Account', 'Industry', true));
	}

	static testMethod void testGetPicklistAsSelectOptions() {
		System.assertNotEquals(null, CSUtils.getPicklistAsSelectOptions('Account', 'Industry', true));
	}

	static testMethod void testGetTextFieldLength() {
		System.assert(CSUtils.getTextFieldLength('Account', 'Name') != 0);
	}
	
	static testMethod void testGetObjectNameFromId() {
		System.assertEquals(null, CSUtils.getObjectNameFromId(null));

		try {
			Account account = new Account();
			account.Name = 'Test';
            account.BillingCity = 'Ichalkaranji';
            account.BillingCountry = 'India';
            account.BillingStreet = 'Test Street';
            account.BillingState ='Test Billing State';
            account.BillingPostalCode ='12345';
            account.ShippingCity ='Pune';
            account.ShippingCountry ='India';
            account.ShippingPostalCode = '12345';
            account.ShippingState = 'Maharashtra';
            account.ShippingStreet = 'Test Shipping Street';
			insert account;
			System.assertEquals('Account', CSUtils.getObjectNameFromId(account.Id));
		} catch (Exception e) {
			// Org has custom validation(s) preventing the record from
			// inserting and thus this test from running. Ignore exception.
		}

		try {
			Contact contact = new Contact();
			contact.FirstName = 'Test';
			contact.LastName = 'Test';
			insert contact;
			System.assertEquals('Contact', CSUtils.getObjectNameFromId(contact.Id));
		} catch (Exception e) {
			// Org has custom validation(s) preventing the record from
			// inserting and thus this test from running. Ignore exception.
		}

		try {
			Opportunity opportunity = new Opportunity();
			opportunity.Name = 'Test';
			opportunity.StageName = 'Prospecting';
			opportunity.CloseDate = Date.today();
			insert opportunity;
			System.assertEquals('Opportunity', CSUtils.getObjectNameFromId(opportunity.Id));
		} catch (Exception e) {
			// Org has custom validation(s) preventing the record from
			// inserting and thus this test from running. Ignore exception.
		}

		try {
			Lead lead = new Lead();
			lead.LastName = 'Test';
			lead.Company = 'Test';
			insert lead;
			System.assertEquals('Lead', CSUtils.getObjectNameFromId(lead.Id));
		} catch (Exception e) {
			// Org has custom validation(s) preventing the record from
			// inserting and thus this test from running. Ignore exception.
		}
	}

	static testMethod void testFifteenCharacterId() {
		System.assertEquals(null, CSUtils.fifteenCharacterId(null));
		System.assertEquals('01234', CSUtils.fifteenCharacterId('01234')); // 5 characters
		System.assertEquals('012345678901234', CSUtils.fifteenCharacterId('012345678901234')); // 15 characters
		System.assertEquals('012345678901234', CSUtils.fifteenCharacterId('012345678901234567')); // 18 characters
	}

	static testMethod void testFieldValuesDifferent() {
		// Test String field.
		Contact contactA = new Contact();
		contactA.FirstName = 'Test';

		Contact contactB = new Contact();
		contactB.FirstName = 'Test';

		System.assertEquals(false, CSUtils.fieldValuesDifferent(contactA, contactB, new Set<String>{'FirstName'}));

		contactB.FirstName = 'Test 2';

		System.assertEquals(true, CSUtils.fieldValuesDifferent(contactA, contactB, new Set<String>{'FirstName'}));

		// Test Boolean field.
		contactA = new Contact();
		contactA.DoNotCall = false;

		contactB = new Contact();
		contactB.DoNotCall = false;

		System.assertEquals(false, CSUtils.fieldValuesDifferent(contactA, contactB, new Set<String>{'DoNotCall'}));

		contactB.DoNotCall = true;

		System.assertEquals(true, CSUtils.fieldValuesDifferent(contactA, contactB, new Set<String>{'DoNotCall'}));
    }

}