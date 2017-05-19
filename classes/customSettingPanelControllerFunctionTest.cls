@isTest
private class customSettingPanelControllerFunctionTest {

  @isTest
  private static void convertMapToSObject1() {
    try {
      sObject convertedItem = customSettingPanelController.convertMapToSObject(null, new Map<String, Object>(), new List<customSettingPanelController.settingFieldContainer>());
      system.assert(false, 'An exception should be thrown when converting a map to a null or invalid sObject type.');
    }
    catch (Exception e) {
      system.assert(true, 'An exception should be thrown when converting a map to a null or invalid sObject type.');
    }
  }

  @isTest
  private static void convertMapToSObject2() {
    try {
      sObject convertedItem = customSettingPanelController.convertMapToSObject('Contact', new Map<String, Object>(), null);
      system.assert(false, 'An exception should be thrown when converting a map using a null field list.');
    }
    catch (Exception e) {
      system.assert(true, 'An exception should be thrown when converting a map using a null field list.');
    }
  }

  @isTest
  private static void convertMapToSObject3() {
    List<customSettingPanelController.settingFieldContainer> settingFields = new List<customSettingPanelController.settingFieldContainer>();
    customSettingPanelController.settingFieldContainer field1 = new customSettingPanelController.settingFieldContainer();
    field1.apiName = 'name';
    settingFields.add(field1);

    try {
      sObject convertedItem = customSettingPanelController.convertMapToSObject('Contact', null, settingFields);
      system.assert(false, 'An exception should be thrown when converting a map using a null source map.');
    }
    catch (Exception e) {
      system.assert(true, 'An exception should be thrown when converting a map using a null source map.');
    }
  }

  @isTest
  private static void convertMapToSObject4() {
    Integer numberOfContacts = 1;
    List<Contact> contactList = generateContacts(numberOfContacts);
    database.insert(contactList);

    Map<String, object> itemMap = new Map<String, Object>();
    itemMap.put('id', contactList.get(0).get('id'));
    itemMap.put('lastname', 'thisisourname');

    List<customSettingPanelController.settingFieldContainer> settingFields = new List<customSettingPanelController.settingFieldContainer>();
    customSettingPanelController.settingFieldContainer field1 = new customSettingPanelController.settingFieldContainer();
    field1.apiName = 'id';
    field1.type = 'id';
    field1.isReadOnly = false;
    settingFields.add(field1);
    customSettingPanelController.settingFieldContainer field2 = new customSettingPanelController.settingFieldContainer();
    field2.apiName = 'lastname';
    field2.type = 'string';
    field2.isReadOnly = false;
    settingFields.add(field2);

    sObject convertedItem = customSettingPanelController.convertMapToSObject('Contact', itemMap, settingFields);

    for (customSettingPanelController.settingFieldContainer settingField : settingFields) {
      system.assertEquals(itemMap.get(settingField.apiName), convertedItem.get(settingField.apiName), 'The converted value should match the original value.');
    }
  }

  @isTest
  private static void removeSetting1() {
    List<sObject> results = customSettingPanelController.removeSetting(null, 1);
    system.assertEquals(0, results.size(), 'Removing a setting from a null list should result in an empty list result.');
  }

  @isTest
  private static void removeSetting2() {
    Integer numberOfContacts = 3;
    List<sObject> items = generateContacts(numberOfContacts);
    List<sObject> results = customSettingPanelController.removeSetting(items, null);
    system.assertEquals(numberOfContacts, results.size(), 'Removing a setting using a null index should result in a list of the same size.');
  }

  @isTest
  private static void removeSetting3() {
    Integer numberOfContacts = 3;
    Integer position = 1;

    List<sObject> items = generateContacts(numberOfContacts);
    String email = (String) items.get(position).get('email');

    List<sObject> results = customSettingPanelController.removeSetting(items, position);
    system.assertEquals(numberOfContacts - 1, results.size(), 'An item should have been removed.');
    system.assertNotEquals(email, results.get(position).get('email'), 'The email addresses should not match for a removed item.');
  }

  @isTest
  private static void conformToOrder1() {
    try {
      customSettingPanelController.settingFieldContainer[] sorted = customSettingPanelController.conformToOrder(new List<customSettingPanelController.settingFieldContainer>(), null);
      system.assert(false, 'An exception should be thrown when attempting to sort on a list with a null order.');
    }
    catch (Exception e) {
      system.assert(true, 'An exception should be thrown when attempting to sort on a list with a null order.');
    }
  }

  @isTest
  private static void conformToOrder2() {
    customSettingPanelController.settingFieldContainer[] sorted = customSettingPanelController.conformToOrder(null, new List<String>());
    system.assertEquals(0, sorted.size(), 'Attempting to sort on a null sort order should result in an empty list.');
  }

  @isTest
  private static void conformToOrder3() {
    customSettingPanelController.settingFieldContainer[] original = new List<customSettingPanelController.settingFieldContainer>();

    customSettingPanelController.settingFieldContainer field1 = new customSettingPanelController.settingFieldContainer();
    field1.apiName = 'cccc';
    original.add(field1);
    customSettingPanelController.settingFieldContainer field2 = new customSettingPanelController.settingFieldContainer();
    field2.apiName = 'aaaa';
    original.add(field2);
    customSettingPanelController.settingFieldContainer field3 = new customSettingPanelController.settingFieldContainer();
    field3.apiName = 'bbbb';
    original.add(field3);

    List<String> order = new List<String>{'aaaa', 'bbbb', 'cccc'};

    customSettingPanelController.settingFieldContainer[] sorted = customSettingPanelController.conformToOrder(original, order);

    for (Integer i = 0; i < order.size(); i++) {
      system.assertEquals(order.get(i), sorted.get(i).apiName, 'The sorted list is not in the correct order.');
    }
  }

  @isTest
  private static void hasValidId1() {
    Boolean hasValidId = customSettingPanelController.hasValidId(null);

    system.assert(!hasValidId, 'A null sObject should not be recognized as having a valid id.');
  }

  @isTest
  private static void hasValidId2() {
    Boolean hasValidId = customSettingPanelController.hasValidId(new Map<String, Object>());

    system.assert(!hasValidId, 'A new sObject should nto be recognized as having a valid id.');
  }

  @isTest
  private static void hasValidId3() {
    Map<String, Object> objectMap = new Map<String, Object>();
    objectMap.put('id', 'notnull');

    Boolean hasValidId = customSettingPanelController.hasValidId(objectMap);
    system.assert(hasValidId, 'An inserted sObject should be recognized as having a valid id.');
  }

  @isTest
  private static void createReverseIdLookup1() {
    Map<Object, String> idLookup = customSettingPanelController.createReverseIdLookup(null);
    system.assertEquals(0, idLookup.keySet().size(), 'An null sObject list should result in a map with no keys.');
  }

  @isTest
  private static void createReverseIdLookup2() {
    Integer numberOfContacts = 3;
    List<Contact> contactList = generateContacts(numberOfContacts);
    database.insert(contactList);

    Map<Object, String> idLookup = customSettingPanelController.createReverseIdLookup(contactList);

    system.assertEquals(idLookup.keySet().size(), contactList.size(), 'And sObject list and a reverse ID lookup should have the same number of entries.');
    for (Object item : idLookup.keySet()) {
      system.assertEquals(idLookup.get(item), (String) item, 'A reverse ID lookup should have the same value as its key.');
    }
  }

  @isTest
  private static void convertSettingsToMap1() {
    List<Map<String, Object>> results = customSettingPanelController.convertSettingsToMap(null, null);
    system.assertEquals(0, results.size(), 'Converting a null list of sObjects to Maps should result in an empty list.');
  }

  @isTest
  private static void convertSettingsToMap2() {
    Integer numberOfContacts = 3;
    List<Contact> contactList = generateContacts(numberOfContacts);
    List<Map<String, Object>> results = customSettingPanelController.convertSettingsToMap(contactList, null);

    system.assertEquals(numberOfContacts, results.size(), 'Converting a list of ' + numberOfContacts + ' contacts to Maps should result in a list of ' + numberOfContacts + ' maps.');
    for (Integer i = 0; i < results.size(); i++) {
      system.assertEquals(0, results[i].keySet().size(), 'Converting a list of contacts to Maps with a null field list should return empty maps.');
    }
  }

  @isTest
  private static void convertSettingsToMap3() {
    Integer numberOfContacts = 3;
    List<Contact> contactList = generateContacts(numberOfContacts);

    List<customSettingPanelController.settingFieldContainer> fields = new List<customSettingPanelController.settingFieldContainer>();

    customSettingPanelController.settingFieldContainer field1 = new customSettingPanelController.settingFieldContainer();
    field1.apiName = 'firstname';
    fields.add(field1);
    customSettingPanelController.settingFieldContainer field2 = new customSettingPanelController.settingFieldContainer();
    field2.apiName = 'lastname';
    fields.add(field2);
    customSettingPanelController.settingFieldContainer field3 = new customSettingPanelController.settingFieldContainer();
    field3.apiName = 'email';
    fields.add(field3);

    List<Map<String, Object>> results = customSettingPanelController.convertSettingsToMap(contactList, fields);
    system.assertEquals(numberOfContacts, results.size(), 'Converting a list of ' + numberOfContacts + ' contacts to Maps should result in a list of ' + numberOfContacts + ' maps.');

    for (Integer i = 0; i < results.size(); i++) {
      system.assertEquals(fields.size(), results[i].keySet().size(), 'Converting a list of contacts to maps with ' + fields.size() + ' valid fields should result in maps with ' + fields.size() + ' keys.');

      for (Integer j = 0; j < fields.size(); j++) {
        system.assertEquals(contactList.get(i).get(fields.get(j).apiName), results.get(i).get(fields.get(j).apiName), 'Field values should match between an sObject and its converted map.');
      }
    }
  }

  @isTest
  private static void convertSettingToMap1() {
    Map<String, Object> result = customSettingPanelController.convertSettingToMap(null, new List<customSettingPanelController.settingFieldContainer>());
    system.assertEquals(0, result.keySet().size(), 'A null object should return an empty map.');
  }

  @isTest
  private static void convertSettingToMap2() {
    Map<String, Object> result = customSettingPanelController.convertSettingToMap(new Contact(), null);
    system.assertEquals(0, result.keySet().size(), 'A null list of fields should return an empty map.');
  }

  @isTest
  private static void convertSettingToMap3() {
    Contact item = new Contact();
    item.firstname = 'Test sObject';

    List<customSettingPanelController.settingFieldContainer> fields = new List<customSettingPanelController.settingFieldContainer>();

    customSettingPanelController.settingFieldContainer nameField = new customSettingPanelController.settingFieldContainer();
    nameField.apiName = 'firstname';
    fields.add(nameField);

    Map<String, Object> result = customSettingPanelController.convertSettingToMap(item, fields);

    system.assertEquals((String) result.get('firstname'), item.firstname, 'The name field on a contact converted to a map should match.');
    system.assertEquals(fields.size(), result.keySet().size(), 'There should not be more fields on a converted map than there are fields in the list of settingFields.');
  }

  @isTest
  private static void getAllSettings1() {
    try {
      List<SObject> results = customSettingPanelController.getAllSettings(null, new List<customSettingPanelController.settingFieldContainer>());
      system.assert(false, 'Passing a null sObject type should throw an exception.');
    } catch (Exception e) {
      system.assert(true, 'Passing a null sObject type should throw an exception.');
    }
  }

  @isTest
  private static void getAllSettings2() {
    try {
      List<SObject> results = customSettingPanelController.getAllSettings('Contact', null);
      system.assert(false, 'Passing a null list of setting fields should throw an exception.');
    } catch (Exception e) {
      system.assert(true, 'Passing a null list of setting fields should throw an exception.');
    }
  }

  @isTest
  private static void getAllSettings3() {
    Integer numberOfContacts = 3;

    Database.insert(generateContacts(numberOfContacts));
    customSettingPanelController.settingFieldContainer[] fields = new List<customSettingPanelController.settingFieldContainer>();

    customSettingPanelController.settingFieldContainer field1 = new customSettingPanelController.settingFieldContainer();
    field1.apiName = 'Name';
    fields.add(field1);
    customSettingPanelController.settingFieldContainer field2 = new customSettingPanelController.settingFieldContainer();
    field2.apiName = 'Id';
    fields.add(field2);

    List<SObject> results = customSettingPanelController.getAllSettings('Contact', fields);

    system.assertEquals(numberOfContacts, results.size(), 'After inserting 2 contacts, getting all settings should provide 2 contacts.');
    system.assertNotEquals(null, results.get(0).Id, 'The Id of a queried contact should not be null.');
    system.assertNotEquals(null, results.get(0).get('Name'), 'The name of a queried contact should not be null.');
  }

  @isTest
  private static void filterSettingFields1() {
    customSettingPanelController.settingFieldContainer[] results = customSettingPanelController.filterSettingFields(null, new List<String>());
    system.assertEquals(0, results.size(), 'Passing a null list of settingFieldContainer should result in an empty list.');
  }

  @isTest
  private static void filterSettingFields2() {
    customSettingPanelController.settingFieldContainer[] results = customSettingPanelController.filterSettingFields(new List<customSettingPanelController.settingFieldContainer>(), null);
    system.assertEquals(0, results.size(), 'Passing a null list of field API names should result in an empty list.');
  }

  @isTest
  private static void filterSettingFields3() {
    customSettingPanelController.settingFieldContainer[] results = customSettingPanelController.filterSettingFields(new List<customSettingPanelController.settingFieldContainer>(), new List<String>());
    system.assertEquals(0, results.size(), 'Passing a blank list of field API names should result in an empty list.');
  }

  @isTest
  private static void filterSettingFields4() {
    customSettingPanelController.settingFieldContainer[] items = new List<customSettingPanelController.settingFieldContainer>();

    customSettingPanelController.settingFieldContainer item1 = new customSettingPanelController.settingFieldContainer();
    item1.apiName = 'field_1__c';
    items.add(item1);
    customSettingPanelController.settingFieldContainer item2 = new customSettingPanelController.settingFieldContainer();
    item2.apiName = 'field_2__c';
    items.add(item2);
    customSettingPanelController.settingFieldContainer item3 = new customSettingPanelController.settingFieldContainer();
    item3.apiName = 'field_3__c';
    items.add(item3);

    String[] filters = new List<String>();
    filters.add('field_1__c');

    items = customSettingPanelController.filterSettingFields(items, filters);
    system.assertEquals(2, items.size(), 'Filtering setting fields with a list where there is 1 match should result in a list of 1.');
  }

  @isTest
  private static void filterSettingFields5() {
    customSettingPanelController.settingFieldContainer[] items = new List<customSettingPanelController.settingFieldContainer>();

    customSettingPanelController.settingFieldContainer item1 = new customSettingPanelController.settingFieldContainer();
    item1.apiName = 'field_1__c';
    items.add(item1);
    customSettingPanelController.settingFieldContainer item2 = new customSettingPanelController.settingFieldContainer();
    item2.apiName = 'field_2__c';
    items.add(item2);
    customSettingPanelController.settingFieldContainer item3 = new customSettingPanelController.settingFieldContainer();
    item3.apiName = 'field_3__c';
    items.add(item3);

    String[] filters = new List<String>();
    filters.add('field_4__c');

    items = customSettingPanelController.filterSettingFields(items, filters);
    system.assertEquals(3, items.size(), 'Filtering setting fields where no filters match any fields should result in a new list the same size as the original.');
  }

  @isTest
  private static void antiFilterSettingFields1() {
    customSettingPanelController.settingFieldContainer[] results = customSettingPanelController.antiFilterSettingFields(null, new List<String>());
    system.assertEquals(0, results.size(), 'Passing a null list of settingFieldContainer should result in an empty list.');
  }

  @isTest
  private static void antiFilterSettingFields2() {
    customSettingPanelController.settingFieldContainer[] results = customSettingPanelController.antiFilterSettingFields(new List<customSettingPanelController.settingFieldContainer>(), null);
    system.assertEquals(0, results.size(), 'Passing a null list of field API names should result in an empty list.');
  }

  @isTest
  private static void antiFilterSettingFields3() {
    customSettingPanelController.settingFieldContainer[] results = customSettingPanelController.antiFilterSettingFields(new List<customSettingPanelController.settingFieldContainer>(), new List<String>());
    system.assertEquals(0, results.size(), 'Passing a blank list of field API names should result in an empty list.');
  }

  @isTest
  private static void antiFilterSettingFields4() {
    customSettingPanelController.settingFieldContainer[] items = new List<customSettingPanelController.settingFieldContainer>();

    customSettingPanelController.settingFieldContainer item1 = new customSettingPanelController.settingFieldContainer();
    item1.apiName = 'field_1__c';
    items.add(item1);
    customSettingPanelController.settingFieldContainer item2 = new customSettingPanelController.settingFieldContainer();
    item2.apiName = 'field_2__c';
    items.add(item2);
    customSettingPanelController.settingFieldContainer item3 = new customSettingPanelController.settingFieldContainer();
    item3.apiName = 'field_3__c';
    items.add(item3);

    String[] filters = new List<String>();
    filters.add('field_1__c');

    items = customSettingPanelController.antiFilterSettingFields(items, filters);
    system.assertEquals(1, items.size(), 'Anti filtering setting fields with a list where there is 1 match should result in a list of 1.');
  }

  @isTest
  private static void antiFilterSettingFields5() {
    customSettingPanelController.settingFieldContainer[] items = new List<customSettingPanelController.settingFieldContainer>();

    customSettingPanelController.settingFieldContainer item1 = new customSettingPanelController.settingFieldContainer();
    item1.apiName = 'field_1__c';
    items.add(item1);
    customSettingPanelController.settingFieldContainer item2 = new customSettingPanelController.settingFieldContainer();
    item2.apiName = 'field_2__c';
    items.add(item2);
    customSettingPanelController.settingFieldContainer item3 = new customSettingPanelController.settingFieldContainer();
    item3.apiName = 'field_3__c';
    items.add(item3);

    String[] filters = new List<String>();
    filters.add('field_4__c');

    items = customSettingPanelController.antiFilterSettingFields(items, filters);
    system.assertEquals(3, items.size(), 'Anti filtering setting fields where no filters match any fields should result in a new list the same size as the original.');
  }

  @isTest
  private static void cloneSettingFields1() {
    customSettingPanelController.settingFieldContainer[] results = customSettingPanelController.cloneSettingFields(null);
    system.assertEquals(0, results.size(), 'Cloning a null list of setting fields should result in an empty list.');
  }

  @isTest
  private static void cloneSettingFields2() {
    customSettingPanelController.settingFieldContainer[] fieldList = new List<customSettingPanelController.settingFieldContainer>();
    fieldList.add(null);
    customSettingPanelController.settingFieldContainer[] results = customSettingPanelController.cloneSettingFields(fieldList);
    system.assertEquals(0, results.size(), 'Any null setting field containers should be excluded from a cloned list.');
  }

  @isTest
  private static void cloneSettingFields3() {
    customSettingPanelController.settingFieldContainer[] fieldList = new List<customSettingPanelController.settingFieldContainer>();

    customSettingPanelController.settingFieldContainer field1 = new customSettingPanelController.settingFieldContainer();
    field1.apiName = 'Field_1__c';
    field1.displayName = 'Field 1';
    field1.type = 'type1';
    field1.isReadOnly = true;
    customSettingPanelController.settingFieldContainer field2 = new customSettingPanelController.settingFieldContainer();
    field2.apiName = 'Field_2__c';
    field2.displayName = 'Field 2';
    field2.type = 'type2';
    field2.isReadOnly = false;
    customSettingPanelController.settingFieldContainer field3 = new customSettingPanelController.settingFieldContainer();
    field3.apiName = 'Field_3__c';
    field3.displayName = 'Field 3';
    field3.type = 'type3';
    field3.isReadOnly = true;

    fieldList.add(field1);
    fieldList.add(field2);
    fieldList.add(field3);

    customSettingPanelController.settingFieldContainer[] results = customSettingPanelController.cloneSettingFields(fieldList);
    system.assertEquals(fieldList.size(), results.size(), 'A cloned list should have the same number of items as the original, besides null values.');

    for (Integer i = 0; i < fieldList.size(); i++) {
      system.assertEquals(fieldList[i].apiName, results[i].apiName, 'The API names of a field container and its clone should match.');
      system.assertEquals(fieldList[i].displayName, results[i].displayName, 'The display names of a field container and its clone should match.');
      system.assertEquals(fieldList[i].type, results[i].type, 'The types of a field container and its clone should match.');
      system.assertEquals(fieldList[i].isReadOnly, results[i].isReadOnly, 'The isReadOnly flag of a field container and its clone should match.');
    }
  }

  @isTest
  private static void isMemberOf1() {
    Boolean isMember = customSettingPanelController.isMemberOf(null, new List<String>());
    system.assert(!isMember, 'A null string should not be a member of any list.');
  }

  @isTest
  private static void isMemberOf2() {
    Boolean isMember = customSettingPanelController.isMemberOf('asdf', null);
    system.assert(!isMember, 'A string should never be a member of a null list.');
  }

  @isTest
  private static void isMemberOf3() {
    Boolean isMember = customSettingPanelController.isMemberOf('asdf', new List<String>{'ffff', 'ssss', 'dddd', 'aaaa'});
    system.assert(!isMember, 'The string \'asdf\' is not a member of the list.');
  }

  @isTest
  private static void isMemberOf4() {
    Boolean isMember = customSettingPanelController.isMemberOf('asdf', new List<String>{'ffff', 'ssss', 'dddd', 'asdf'});
    system.assert(isMember, 'The string \'asdf\' should be a member of the list.');
  }

  @isTest
  private static void getSettingFields1() {
    try {
      customSettingPanelController.settingFieldContainer[] results = customSettingPanelController.getSettingFields(null);
      system.assert(false, 'An exception should be thrown when a null value is passed as an sObject name.');
    } catch (Exception e) {
      system.assert(true, 'An exception should be thrown when a null value is passed as an sObject name.');
    }
  }

  @isTest
  private static void getSettingFields2() {
    try {
      customSettingPanelController.settingFieldContainer[] results = customSettingPanelController.getSettingFields('asdfasdf');
      system.assert(false, 'An exception should be thrown when a bad value is passed as an sObject name.');
    } catch (Exception e) {
      system.assert(true, 'An exception should be thrown when a bad value is passed as an sObject name.');
    }
  }

  @isTest
  private static void getSettingFields3() {
    customSettingPanelController.settingFieldContainer[] results = customSettingPanelController.getSettingFields('Contact');
    system.assert(results.size() > 0, 'There should be at least 1 field listed in contacts.');
  }

  @isTest
  private static void convertDescribeFieldsToSettingFields1() {
    customSettingPanelController.settingFieldContainer[] results = customSettingPanelController.convertDescribeFieldsToSettingFields(null);

    system.assertEquals(results.size(), 0, 'Converting a null Map to an array of setting field containers should result in an empty array.');
  }

  @isTest
  private static void convertDescribeFieldsToSettingFields2() {
    Map<String, sObjectField> fields = new Map<String, sObjectField>();
    customSettingPanelController.settingFieldContainer[] results = customSettingPanelController.convertDescribeFieldsToSettingFields(fields);

    system.assertEquals(results.size(), 0, 'Converting an empty Map to an array of setting field containers should result in an empty array.');
  }

  @isTest
  private static void convertDescribeFieldsToSettingFields3() {
    Map<String, sObjectField> fields = new Map<String, sObjectField>();
    fields.put('field1', null);
    customSettingPanelController.settingFieldContainer[] results = customSettingPanelController.convertDescribeFieldsToSettingFields(fields);

    system.assertEquals(results.size(), 0, 'An array of settingFieldContainers converted from a map with a key that resolves to a null sObjectfield should exclude that key.');
  }

  @isTest
  private static void convertDescribeFieldsToSettingFields4() {
    Map<String, sObjectField> fields = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
    customSettingPanelController.settingFieldContainer[] results = customSettingPanelController.convertDescribeFieldsToSettingFields(fields);

    system.assertEquals(results.size(), fields.size(), 'The array of settingFieldContainers should have the same number of items as the described fields map.');

    String apiName = results[0].apiName;
    DescribeFieldResult describedField = fields.get(apiName).getDescribe();
    system.assertEquals(apiName, describedField.getName().toLowerCase(), 'The API Name should match the name of the describeFieldResult in lower case.');
    system.assertEquals(results[0].displayName, describedField.getLabel(), 'The Display Name should match the label of the describeFieldResult.');
    system.assertEquals(results[0].type, String.valueOf(describedField.getType()).toLowerCase(), 'The type should match the type of the describeFieldResult in lower case.');
  }

  @isTest
  private static void convertDescribeFieldToSettingField1() {
    DescribeFieldResult contactNameDescription = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get('Id').getDescribe();

    customSettingPanelController.settingFieldContainer result = customSettingPanelController.convertDescribeFieldToSettingField(contactNameDescription);

    system.assertEquals(result.apiName, result.apiName.toLowerCase(), 'The API name should be all lower case.');
    system.assertEquals(result.type, result.type.toLowerCase(), 'The type should be all lower case.');
    system.assertEquals(result.apiName, 'id', 'The API name of the Id field should be id.');
    system.assertEquals(result.displayName, 'Contact ID', 'The display name of the Contact Id field should be Contact ID.');
    system.assertEquals(result.type, 'id', 'The type of the Id field should be id.');
  }

  @isTest
  private static void convertDescribeFieldToSettingField2() {

    customSettingPanelController.settingFieldContainer result = customSettingPanelController.convertDescribeFieldToSettingField(null);

    system.assertEquals(result.apiName, null, 'The API name of a null field should be null.');
    system.assertEquals(result.displayName, null, 'The Display name of a null field should be null.');
    system.assertEquals(result.type, null, 'The type of a null field should be null.');
  }

	@isTest
  private static void testAreNotNull1() {
		List<Object> objectList = new List<Object>();
    system.assertEquals(customSettingPanelController.areNotNull(objectList), true, 'An empty list of objects should still be recognized as having no null values.');
	}

	@isTest
  private static void testAreNotNull2() {
		system.assertEquals(customSettingPanelController.areNotNull(null), false, 'A null value for a list of objects should be recognized as having null values.');
	}

  @isTest
  private static void testAreNotNull3() {
    List<Object> objectList = new List<Object>();
    objectList.add(null);
    objectList.add(1);
    objectList.add(2);
    objectList.add(3);
    system.assertEquals(customSettingPanelController.areNotNull(objectList), false, 'One null value should be enough for the list to be recognized as having a null value.');
  }

  @isTest
  private static void testAreNotNull4() {
    List<Object> objectList = new List<Object>();
    objectList.add(1);
    objectList.add(2);
    objectList.add(3);
    system.assertEquals(customSettingPanelController.areNotNull(objectList), true, 'The list should be recognized as having no null values if it does not.');
  }

  private static List<Contact> generateContacts (Integer amount) {
    List<Contact> contactList = new List<Contact>();

    for (Integer i = 0; i < amount; i++) {
      Contact generatedContacts = new Contact(
        firstName = 'Name ' + i,
        lastName = 'Last ' + i,
        email = 'TestContact' + String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') + '@test.' + String.valueOf(Math.rint(Math.random() * 10000)) + 'com'
      );

      contactlist.add(generatedContacts);
    }

    return contactList;
  }
}
