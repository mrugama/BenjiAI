import Foundation
import Contacts

// MARK: - Contact Tool Implementation

final class ContactToolImpl: ContactTool, @unchecked Sendable {
    let id: String = "contact"
    let name: String = "Contact"
    let toolDescription: String = "Search, read, and create contacts"
    let category: ToolCategory = .contact
    
    private let contactStore = CNContactStore()
    
    var specification: ToolSpecification {
        ToolSpecification(
            name: "contact",
            description: "Manage contacts - search, read, and create contacts",
            parameters: ToolParameters(
                properties: [
                    "action": ToolParameterProperty(
                        type: "string",
                        description: "The action to perform",
                        enumValues: ["search", "read", "create"]
                    ),
                    "query": ToolParameterProperty(
                        type: "string",
                        description: "Search query for finding contacts"
                    ),
                    "contactId": ToolParameterProperty(
                        type: "string",
                        description: "Contact identifier for reading"
                    ),
                    "firstName": ToolParameterProperty(
                        type: "string",
                        description: "Contact's first name"
                    ),
                    "lastName": ToolParameterProperty(
                        type: "string",
                        description: "Contact's last name"
                    ),
                    "phoneNumber": ToolParameterProperty(
                        type: "string",
                        description: "Contact's phone number"
                    ),
                    "email": ToolParameterProperty(
                        type: "string",
                        description: "Contact's email address"
                    )
                ],
                required: ["action"]
            )
        )
    }
    
    func execute(parameters: [String: Any]) async throws -> ToolFunctionResult {
        guard let action = parameters["action"] as? String else {
            throw ToolError.missingParameter("action")
        }
        
        switch action {
        case "search":
            guard let query = parameters["query"] as? String else {
                throw ToolError.missingParameter("query")
            }
            return try await searchContacts(query: query)
            
        case "read":
            guard let contactId = parameters["contactId"] as? String else {
                throw ToolError.missingParameter("contactId")
            }
            return try await readContact(contactId: contactId)
            
        case "create":
            guard let firstName = parameters["firstName"] as? String else {
                throw ToolError.missingParameter("firstName")
            }
            let lastName = parameters["lastName"] as? String
            let phoneNumber = parameters["phoneNumber"] as? String
            let email = parameters["email"] as? String
            return try await createContact(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, email: email)
            
        default:
            throw ToolError.invalidParameter("action", reason: "Unknown action: \(action)")
        }
    }
    
    func searchContacts(query: String) async throws -> ToolFunctionResult {
        let authorized = try await requestContactAccess()
        guard authorized else {
            return .failure(error: "Contacts access denied")
        }
        
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactOrganizationNameKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor
        ]
        
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        request.predicate = CNContact.predicateForContacts(matchingName: query)
        
        var contacts: [CNContact] = []
        
        do {
            try contactStore.enumerateContacts(with: request) { contact, _ in
                contacts.append(contact)
            }
        } catch {
            return .failure(error: "Failed to search contacts: \(error.localizedDescription)")
        }
        
        let contactData: [[String: any Sendable]] = contacts.prefix(20).map { contact in
            [
                "contactId": contact.identifier,
                "firstName": contact.givenName,
                "lastName": contact.familyName,
                "fullName": "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces),
                "organization": contact.organizationName,
                "phoneNumbers": contact.phoneNumbers.map { $0.value.stringValue },
                "emails": contact.emailAddresses.map { $0.value as String }
            ]
        }
        
        let viewData = ToolViewData(
            type: "contacts_list",
            data: [
                "query": query,
                "contacts": contactData,
                "count": contacts.count
            ],
            template: "contacts_list_display"
        )
        
        return .success(viewData: viewData, metadata: ["contactCount": contacts.count])
    }
    
    func readContact(contactId: String) async throws -> ToolFunctionResult {
        let authorized = try await requestContactAccess()
        guard authorized else {
            return .failure(error: "Contacts access denied")
        }
        
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactMiddleNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactOrganizationNameKey as CNKeyDescriptor,
            CNContactJobTitleKey as CNKeyDescriptor,
            CNContactPostalAddressesKey as CNKeyDescriptor,
            CNContactBirthdayKey as CNKeyDescriptor,
            CNContactNoteKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor
        ]
        
        do {
            let contact = try contactStore.unifiedContact(withIdentifier: contactId, keysToFetch: keysToFetch)
            
            var birthdayString: String? = nil
            if let birthday = contact.birthday, let date = Calendar.current.date(from: birthday) {
                let formatter = DateFormatter()
                formatter.dateStyle = .long
                birthdayString = formatter.string(from: date)
            }
            
            let viewData = ToolViewData(
                type: "contact_detail",
                data: [
                    "contactId": contact.identifier,
                    "firstName": contact.givenName,
                    "lastName": contact.familyName,
                    "middleName": contact.middleName,
                    "fullName": "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces),
                    "organization": contact.organizationName,
                    "jobTitle": contact.jobTitle,
                    "phoneNumbers": contact.phoneNumbers.map { ["label": $0.label ?? "phone", "number": $0.value.stringValue] },
                    "emails": contact.emailAddresses.map { ["label": $0.label ?? "email", "address": $0.value as String] },
                    "birthday": birthdayString ?? "",
                    "note": contact.note
                ],
                template: "contact_detail_display"
            )
            
            return .success(viewData: viewData)
        } catch {
            return .failure(error: "Contact not found: \(error.localizedDescription)")
        }
    }
    
    func createContact(firstName: String, lastName: String?, phoneNumber: String?, email: String?) async throws -> ToolFunctionResult {
        let authorized = try await requestContactAccess()
        guard authorized else {
            return .failure(error: "Contacts access denied")
        }
        
        let contact = CNMutableContact()
        contact.givenName = firstName
        if let lastName = lastName {
            contact.familyName = lastName
        }
        
        if let phoneNumber = phoneNumber {
            let phone = CNPhoneNumber(stringValue: phoneNumber)
            contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMobile, value: phone)]
        }
        
        if let email = email {
            contact.emailAddresses = [CNLabeledValue(label: CNLabelHome, value: email as NSString)]
        }
        
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)
        
        do {
            try contactStore.execute(saveRequest)
            
            let viewData = ToolViewData(
                type: "contact_created",
                data: [
                    "contactId": contact.identifier,
                    "firstName": firstName,
                    "lastName": lastName ?? "",
                    "fullName": "\(firstName) \(lastName ?? "")".trimmingCharacters(in: .whitespaces),
                    "phoneNumber": phoneNumber ?? "",
                    "email": email ?? "",
                    "action": "created"
                ],
                template: "contact_created_display"
            )
            
            return .success(viewData: viewData, metadata: ["contactId": contact.identifier])
        } catch {
            return .failure(error: "Failed to create contact: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Helpers
    
    private func requestContactAccess() async throws -> Bool {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return try await contactStore.requestAccess(for: .contacts)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
}

