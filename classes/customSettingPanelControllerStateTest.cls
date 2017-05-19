@isTest
private class customSettingPanelControllerStateTest {

	@isTest
  private static void test_method_one() {
    Integer numberOfContacts = 3;
    String sObjectType = 'Contact';
    String listFields = 'FirstName, LastName';

    List<Contact> contactList = generateContacts(numberOfContacts);
    database.insert(contactList);
		customSettingPanelController controller = new customSettingPanelController();

    system.assertEquals(null, controller.getSObjectType(), 'The sObjectType getter should always return null.');
    system.assertEquals(null, controller.getOmittedFieldList(), 'The omittedField getter should always return null.');
    system.assertEquals(null, controller.getListFieldList(), 'The ListFieldList getter should always return null.');
    system.assertEquals(null, controller.getDetailFieldList(), 'The DetailFieldList getter should always return null.');

    controller.setSObjectType(sObjectType);
    controller.setOmittedFieldList('');
    controller.setListFieldList(listFields);

    system.assertEquals(null, controller.getAllSettingsMap(), 'All variables should return null prior to completing initialization.');

    controller.setDetailFieldList(listFields);

    system.assert(!controller.getIsActivelyEditing(), 'A newly initialized controller should not be in the edit state.');
    system.assert(!controller.getIsActivelyViewing(), 'A newly initialized controller should not be actively viewing.');

    Map<Object, String> allSettingsIdMap = controller.getAllSettingsIdMap();
    for(Object item : allSettingsIdMap.keySet()) {
      system.assertEquals(String.valueOf(item), allSettingsIdMap.get(item), 'The allSettingsIdMap should consist of items mapped to their coerced string value.');
    }

    customSettingPanelController.settingFieldContainer[] settingFields = controller.getSettingFields();
    for (customSettingPanelController.settingFieldContainer settingField : settingFields) {
      system.assert(listFields.containsIgnoreCase(settingField.apiName) || settingField.apiName == 'id', 'The list field parameter should contain all of the setting fields except ID, but did not have ' + settingField.apiName);
    }

    customSettingPanelController.settingFieldContainer[] listFieldArray = controller.getListFields();
    for (customSettingPanelController.settingFieldContainer field : listFieldArray) {
      system.assert(listFields.containsIgnoreCase(field.apiName) || field.apiName == 'id', 'The list field parameter should contain all of the setting fields except ID, but did not contain ' + field.apiName);
    }

    
	}

	@isTest
  private static void test_method_two() {
		Integer numberOfContacts = 3;
    List<Contact> contactList = generateContacts(numberOfContacts);
    database.insert(contactList);
    customSettingPanelController controller = new customSettingPanelController();

    controller.setListFieldList('blank');
    controller.setDetailFieldList('blank');
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
