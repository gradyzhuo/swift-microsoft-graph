// beta user response model
public struct GraphBetaUser: Sendable, Decodable {

    // MARK: - Core identity
    public let id: String
    public let userPrincipalName: String
    public let userType: String?
    public let securityIdentifier: String?

    // MARK: - Name
    public let displayName: String?
    public let givenName: String?
    public let surname: String?

    // MARK: - Contact
    public let mail: String?
    public let mailNickname: String?
    public let otherMails: [String]
    public let imAddresses: [String]
    public let businessPhones: [String]
    public let mobilePhone: String?
    public let faxNumber: String?

    // MARK: - Job / Organization
    public let jobTitle: String?
    public let department: String?
    public let companyName: String?
    public let employeeId: String?
    public let employeeType: String?
    public let officeLocation: String?
    public let usageLocation: String?
    public let employeeOrgData: EmployeeOrgData?

    // MARK: - Address
    public let city: String?
    public let state: String?
    public let country: String?
    public let postalCode: String?
    public let streetAddress: String?

    // MARK: - Account status
    public let accountEnabled: Bool?
    public let isResourceAccount: Bool?
    public let isManagementRestricted: Bool?
    public let isLicenseReconciliationNeeded: Bool?
    public let showInAddressList: Bool?

    // MARK: - Dates
    public let createdDateTime: String?
    public let deletedDateTime: String?
    public let employeeHireDate: String?
    public let employeeLeaveDateTime: String?
    public let refreshTokensValidFromDateTime: String?
    public let signInSessionsValidFromDateTime: String?
    public let externalUserConvertedOn: String?
    public let externalUserState: String?
    public let externalUserStateChangeDateTime: String?

    // MARK: - On-premises sync
    public let onPremisesSyncEnabled: Bool?
    public let onPremisesDomainName: String?
    public let onPremisesDistinguishedName: String?
    public let onPremisesImmutableId: String?
    public let onPremisesLastSyncDateTime: String?
    public let onPremisesObjectIdentifier: String?
    public let onPremisesSecurityIdentifier: String?
    public let onPremisesSamAccountName: String?
    public let onPremisesUserPrincipalName: String?
    public let onPremisesExtensionAttributes: OnPremisesExtensionAttributes?
    public let onPremisesProvisioningErrors: [OnPremisesProvisioningError]
    public let onPremisesSipInfo: OnPremisesSipInfo?

    // MARK: - Misc
    public let preferredLanguage: String?
    public let preferredDataLocation: String?
    public let passwordPolicies: String?
    public let creationType: String?
    public let ageGroup: String?
    public let consentProvidedForMinor: String?
    public let legalAgeGroupClassification: String?
    public let identityParentId: String?
    public let agentIdentityBlueprintId: String?
    public let proxyAddresses: [String]
    public let infoCatalogs: [String]

    // MARK: - License & Plans
    public let assignedLicenses: [AssignedLicense]
    public let assignedPlans: [AssignedPlan]
    public let provisionedPlans: [ProvisionedPlan]
    public let serviceProvisioningErrors: [ServiceProvisioningError]

    // MARK: - Auth & Security
    public let identities: [UserIdentity]
    public let deviceKeys: [DeviceKey]
    public let authorizationInfo: AuthorizationInfo?
    public let cloudRealtimeCommunicationInfo: CloudRealtimeCommunicationInfo?
    public let passwordProfile: PasswordProfile?
}

// MARK: - Nested types

public struct AssignedLicense: Sendable, Decodable {
    public let disabledPlans: [String]
    public let skuId: String
}

public struct AssignedPlan: Sendable, Decodable {
    public let assignedDateTime: String?
    public let capabilityStatus: String?
    public let service: String?
    public let servicePlanId: String?
}

public struct ProvisionedPlan: Sendable, Decodable {
    public let capabilityStatus: String?
    public let provisioningStatus: String?
    public let service: String?
}

public struct ServiceProvisioningError: Sendable, Decodable {
    public let createdDateTime: String?
    public let isResolved: Bool?
    public let serviceInstance: String?
}

public struct UserIdentity: Sendable, Decodable {
    public let signInType: String?
    public let issuer: String?
    public let issuerAssignedId: String?
}

public struct DeviceKey: Sendable, Decodable {
    public let deviceId: String?
    public let keyMaterial: String?
    public let keyType: String?
}

public struct AuthorizationInfo: Sendable, Decodable {
    public let certificateUserIds: [String]
}

public struct CloudRealtimeCommunicationInfo: Sendable, Decodable {
    public let isSipEnabled: Bool?
}

public struct OnPremisesExtensionAttributes: Sendable, Decodable {
    public let extensionAttribute1: String?
    public let extensionAttribute2: String?
    public let extensionAttribute3: String?
    public let extensionAttribute4: String?
    public let extensionAttribute5: String?
    public let extensionAttribute6: String?
    public let extensionAttribute7: String?
    public let extensionAttribute8: String?
    public let extensionAttribute9: String?
    public let extensionAttribute10: String?
    public let extensionAttribute11: String?
    public let extensionAttribute12: String?
    public let extensionAttribute13: String?
    public let extensionAttribute14: String?
    public let extensionAttribute15: String?
}

public struct OnPremisesProvisioningError: Sendable, Decodable {
    public let category: String?
    public let occurredDateTime: String?
    public let propertyCausingError: String?
    public let value: String?
}

public struct OnPremisesSipInfo: Sendable, Decodable {
    public let isSipEnabled: Bool?
    public let sipDeploymentLocation: String?
    public let sipPrimaryAddress: String?
}

public struct EmployeeOrgData: Sendable, Decodable {
    public let costCenter: String?
    public let division: String?
}

public struct PasswordProfile: Sendable, Decodable {
    public let password: String?
    public let forceChangePasswordNextSignIn: Bool?
    public let forceChangePasswordNextSignInWithMfa: Bool?
}
