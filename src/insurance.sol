// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract HealthInsuranceSystem {
    // Enum to define user types
    enum UserType {
        PATIENT,
        HOSPITAL,
        INSURER
    }

    // Structs for each entity and process
    struct Stakeholder {
        uint256 stakeholderId;
        UserType userType;
        bool verificationStatus;
        uint256 createdTime;
        uint256 updatedTime;
    }

    struct Patient {
        uint256 id;
        uint256 stakeholderId;
        string firstName;
        string lastName;
        string dateOfBirth;
        string contactNumber;
        string email;
        address userAddress;
        uint256 insurancePolicyNumber;
    }

    struct Hospital {
        uint256 id;
        uint256 stakeholderId;
        string hospitalName;
        string contactNumber;
        string email;
        string location;
        address hospitalAddress;
        uint256[] insurancePartners;
    }

    struct Insurer {
        uint256 id;
        uint256 stakeholderId;
        string insurerName;
        string contactNumber;
        string email;
        address insurerAddress;
    }

    struct Policy {
        uint256 id;
        uint256 policyId;
        uint256 insurerId;
        string coverageDetails;
        uint256 cost;
        uint256 term;
        bool policyStatus;
    }

    struct Appointment {
        uint256 id;
        uint256 patientId;
        uint256 hospitalId;
        uint256 appointmentDate;
        string reasonForVisit;
        bool status;
        uint256 verificationId;
        uint256 treatmentID;
    }

    struct Document {
        uint256 id;
        uint256 appointmentId;
        string name;
        string url;
        uint256 createdAt;
    }

    struct Bill {
        uint256 id;
        uint256 appointmentId;
        uint256 totalAmount;
        bool paymentStatus;
    }

    struct Claim {
        uint256 id;
        uint256 policyId;
        uint256 claimAmount;
        bool status;
        uint256 patientId;
        uint256 hospitalId;
        uint256 verificationId;
    }

    struct Disbursement {
        uint256 id;
        uint256 claimId;
        uint256 amountPaid;
        uint256 dateOfPayment;
    }

    struct Subscription {
        uint256 id;
        uint256 policyId;
        uint256 patientId;
        uint256 startDate;
        uint256 endDate;
        bool active;
    }

    struct Treatment {
        uint256 id;
        uint256 appointmentId;
        string treatmentDetails;
        string name;
    }

    // Mappings to store data
    mapping(uint256 => Stakeholder) public stakeholders;
    mapping(uint256 => Patient) public patients;
    mapping(uint256 => Hospital) public hospitals;
    mapping(uint256 => Insurer) public insurers;
    mapping(uint256 => Policy) public policies;
    mapping(uint256 => Appointment) public appointments;
    mapping(uint256 => Document) public documents;
    mapping(uint256 => Bill) public bills;
    mapping(uint256 => Claim) public claims;
    mapping(uint256 => Disbursement) public disbursements;
    mapping(uint256 => Subscription) public subscriptions;
    mapping(uint256 => Treatment) public treatments;

    // Counters for IDs
    uint256 public stakeholderCounter;
    uint256 public patientCounter;
    uint256 public hospitalCounter;
    uint256 public insurerCounter;
    uint256 public policyCounter;
    uint256 public appointmentCounter;
    uint256 public documentCounter;
    uint256 public billCounter;
    uint256 public claimCounter;
    uint256 public disbursementCounter;
    uint256 public subscriptionCounter;
    uint256 public treatmentCounter;

    // Custom Errors
    error StakeholderNotVerified();
    error StakeholderAlreadyExists();
    error InvalidUserType();
    error PatientAlreadyExists();
    error HospitalAlreadyExists();
    error InsurerAlreadyExists();
    error InsurerDoesNotExist();
    error InvalidCoverageDetails();
    error InvalidCost();
    error InvalidTerm();
    error PatientDoesNotExist();
    error HospitalDoesNotExist();
    error InvalidAppointmentDate();
    error InvalidReasonForVisit();
    error PolicyNotValid();
    error ClaimAlreadyApproved();
    error PolicyPatientMismatch();
    error InvalidHospital();
    error AppointmentNotExist();
    error TreatmentNotExist();
    error InsufficientFunds();
    error PolicyNotActive();

    // Modifier to check if the caller is a verified stakeholder
    modifier onlyVerifiedStakeholder(uint256 _stakeholderId) {
        if (!stakeholders[_stakeholderId].verificationStatus) revert StakeholderNotVerified();
        _;
    }

    // Events for logging actions
    event StakeholderRegistered(uint256 stakeholderId, UserType userType);
    event PatientRegistered(uint256 patientId, uint256 stakeholderId);
    event HospitalRegistered(uint256 hospitalId, uint256 stakeholderId);
    event InsurerRegistered(uint256 insurerId, uint256 stakeholderId);
    event PolicyCreated(uint256 policyId, uint256 insurerId);
    event AppointmentCreated(uint256 appointmentId, uint256 patientId, uint256 hospitalId);
    event BillGenerated(uint256 billId, uint256 appointmentId);
    event ClaimSubmitted(uint256 claimId, uint256 policyId, uint256 patientId, uint256 hospitalId);
    event ClaimApproved(uint256 claimId);
    event DisbursementMade(uint256 disbursementId, uint256 claimId);
    event SubscriptionDeactivated(uint256 subscriptionId);

    /// @notice Registers a stakeholder
    /// @param _userType The type of the user being registered (PATIENT, HOSPITAL, INSURER)
    /// @return The ID of the newly registered stakeholder
    function registerStakeholder(UserType _userType) public returns (uint256) {
        stakeholderCounter++;
        stakeholders[stakeholderCounter] =
            Stakeholder(stakeholderCounter, _userType, false, block.timestamp, block.timestamp);
        emit StakeholderRegistered(stakeholderCounter, _userType);
        return stakeholderCounter;
    }

    /// @notice Verifies a stakeholder
    /// @param _stakeholderId The ID of the stakeholder to be verified
    function verifyStakeholder(uint256 _stakeholderId) public {
        stakeholders[_stakeholderId].verificationStatus = true;
        stakeholders[_stakeholderId].updatedTime = block.timestamp;
    }

    /// @notice Checks if a patient already exists
    /// @param _userAddress The address of the patient to check
    /// @return True if the patient exists, false otherwise
    function patientExists(address _userAddress) internal view returns (bool) {
        for (uint256 i = 1; i <= patientCounter; i++) {
            if (patients[i].userAddress == _userAddress) {
                return true;
            }
        }
        return false;
    }

    /// @notice Checks if a hospital already exists
    /// @param _hospitalAddress The address of the hospital to check
    /// @return True if the hospital exists, false otherwise
    function hospitalExists(address _hospitalAddress) internal view returns (bool) {
        for (uint256 i = 1; i <= hospitalCounter; i++) {
            if (hospitals[i].hospitalAddress == _hospitalAddress) {
                return true;
            }
        }
        return false;
    }

    /// @notice Checks if an insurer already exists
    /// @param _insurerAddress The address of the insurer to check
    /// @return True if the insurer exists, false otherwise
    function insurerExists(address _insurerAddress) internal view returns (bool) {
        for (uint256 i = 1; i <= insurerCounter; i++) {
            if (insurers[i].insurerAddress == _insurerAddress) {
                return true;
            }
        }
        return false;
    }

    /// @notice Registers a patient
    /// @param _userType The type of the user being registered (must be PATIENT)
    /// @param _firstName The first name of the patient
    /// @param _lastName The last name of the patient
    /// @param _dateOfBirth The date of birth of the patient
    /// @param _contactNumber The contact number of the patient
    /// @param _email The email address of the patient
    /// @param _address The address of the patient
    /// @param _insurancePolicyNumber The insurance policy number of the patient
    /// @return The ID of the newly registered patient
    function registerPatient(
        UserType _userType,
        string memory _firstName,
        string memory _lastName,
        string memory _dateOfBirth,
        string memory _contactNumber,
        string memory _email,
        address _address,
        uint256 _insurancePolicyNumber
    )
        public
        returns (uint256)
    {
        if (_userType != UserType.PATIENT) revert InvalidUserType();
        if (patientExists(_address)) revert PatientAlreadyExists();

        uint256 _stakeholderId = registerStakeholder(_userType);
        patientCounter++;
        patients[patientCounter] = Patient(
            patientCounter,
            _stakeholderId,
            _firstName,
            _lastName,
            _dateOfBirth,
            _contactNumber,
            _email,
            _address,
            _insurancePolicyNumber
        );
        emit PatientRegistered(patientCounter, _stakeholderId);
        return patientCounter;
    }

    /// @notice Registers a hospital
    /// @param _userType The type of the user being registered (must be HOSPITAL)
    /// @param _hospitalName The name of the hospital
    /// @param _contactNumber The contact number of the hospital
    /// @param _email The email address of the hospital
    /// @param _location The location of the hospital
    /// @param _hospitalAddress The address of the hospital
    /// @param _insurancePartners The list of insurance partners' IDs
    /// @return The ID of the newly registered hospital
    function registerHospital(
        UserType _userType,
        string memory _hospitalName,
        string memory _contactNumber,
        string memory _email,
        string memory _location,
        address _hospitalAddress,
        uint256[] memory _insurancePartners
    )
        public
        returns (uint256)
    {
        if (_userType != UserType.HOSPITAL) revert InvalidUserType();
        if (hospitalExists(_hospitalAddress)) revert HospitalAlreadyExists();

        uint256 _stakeholderId = registerStakeholder(_userType);
        hospitalCounter++;
        hospitals[hospitalCounter] = Hospital(
            hospitalCounter,
            _stakeholderId,
            _hospitalName,
            _contactNumber,
            _email,
            _location,
            _hospitalAddress,
            _insurancePartners
        );
        emit HospitalRegistered(hospitalCounter, _stakeholderId);
        return hospitalCounter;
    }

    /// @notice Registers an insurer
    /// @param _userType The type of the user being registered (must be INSURER)
    /// @param _insurerName The name of the insurer
    /// @param _contactNumber The contact number of the insurer
    /// @param _email The email address of the insurer
    /// @param _insurerAddress The address of the insurer
    /// @return The ID of the newly registered insurer
    function registerInsurer(
        UserType _userType,
        string memory _insurerName,
        string memory _contactNumber,
        string memory _email,
        address _insurerAddress
    )
        public
        returns (uint256)
    {
        if (_userType != UserType.INSURER) revert InvalidUserType();
        if (insurerExists(_insurerAddress)) revert InsurerAlreadyExists();

        uint256 _stakeholderId = registerStakeholder(_userType);
        insurerCounter++;
        insurers[insurerCounter] =
            Insurer(insurerCounter, _stakeholderId, _insurerName, _contactNumber, _email, _insurerAddress);
        emit InsurerRegistered(insurerCounter, _stakeholderId);
        return insurerCounter;
    }

    /// @notice Creates a policy
    /// @param _insurerId The ID of the insurer creating the policy
    /// @param _coverageDetails The details of the coverage
    /// @param _cost The cost of the policy
    /// @param _term The term of the policy
    /// @return The ID of the newly created policy
    function createPolicy(
        uint256 _insurerId,
        string memory _coverageDetails,
        uint256 _cost,
        uint256 _term
    )
        public
        onlyVerifiedStakeholder(insurers[_insurerId].stakeholderId)
        returns (uint256)
    {
        if (!insurerExists(insurers[_insurerId].insurerAddress)) revert InsurerDoesNotExist();
        if (bytes(_coverageDetails).length == 0) revert InvalidCoverageDetails();
        if (_cost <= 0) revert InvalidCost();
        if (_term <= 0) revert InvalidTerm();

        policyCounter++;
        policies[policyCounter] = Policy(policyCounter, policyCounter, _insurerId, _coverageDetails, _cost, _term, true);
        emit PolicyCreated(policyCounter, _insurerId);
        return policyCounter;
    }

    /// @notice Creates an appointment
    /// @param _patientId The ID of the patient
    /// @param _hospitalId The ID of the hospital
    /// @param _appointmentDate The date of the appointment
    /// @param _reasonForVisit The reason for the visit
    /// @return The ID of the newly created appointment
    function createAppointment(
        uint256 _patientId,
        uint256 _hospitalId,
        uint256 _appointmentDate,
        string memory _reasonForVisit
    )
        public
        onlyVerifiedStakeholder(patients[_patientId].stakeholderId)
        returns (uint256)
    {
        if (!patientExists(patients[_patientId].userAddress)) revert PatientDoesNotExist();
        if (!hospitalExists(hospitals[_hospitalId].hospitalAddress)) revert HospitalDoesNotExist();
        if (_appointmentDate <= block.timestamp) revert InvalidAppointmentDate();
        if (bytes(_reasonForVisit).length == 0) revert InvalidReasonForVisit();

        appointmentCounter++;
        appointments[appointmentCounter] =
            Appointment(appointmentCounter, _patientId, _hospitalId, _appointmentDate, _reasonForVisit, false, 0, 0);
        emit AppointmentCreated(appointmentCounter, _patientId, _hospitalId);
        return appointmentCounter;
    }

    /// @notice Generates a bill
    /// @param _patientId The ID of the patient
    /// @param _appointmentId The ID of the appointment
    /// @param _totalAmount The total amount for the bill
    /// @return The ID of the newly generated bill
    function generateBill(
        uint256 _patientId,
        uint256 _appointmentId,
        uint256 _totalAmount
    )
        public
        onlyVerifiedStakeholder(patients[_patientId].stakeholderId)
        returns (uint256)
    {
        if (!appointments[_appointmentId].status) revert AppointmentNotExist();
        if (appointments[_appointmentId].patientId != _patientId) revert PatientDoesNotExist();
        if (appointments[_appointmentId].hospitalId != appointments[_appointmentId].hospitalId) {
            revert HospitalDoesNotExist();
        }

        billCounter++;
        bills[billCounter] = Bill(billCounter, _appointmentId, _totalAmount, false);
        emit BillGenerated(billCounter, _appointmentId);
        return billCounter;
    }

    /// @notice Submits a claim
    /// @param _policyId The ID of the policy
    /// @param _claimAmount The amount of the claim
    /// @param _patientId The ID of the patient
    /// @param _hospitalId The ID of the hospital
    /// @return The ID of the newly submitted claim
    function submitClaim(
        uint256 _policyId,
        uint256 _claimAmount,
        uint256 _patientId,
        uint256 _hospitalId
    )
        public
        onlyVerifiedStakeholder(patients[_patientId].stakeholderId)
        returns (uint256)
    {
        if (!appointments[claims[_policyId].verificationId].status) revert AppointmentNotExist();
        if (!hospitalExists(hospitals[_hospitalId].hospitalAddress)) revert HospitalDoesNotExist();
        if (!policies[_policyId].policyStatus) revert PolicyNotValid();
        if (patients[_patientId].insurancePolicyNumber != policies[_policyId].id) revert PolicyPatientMismatch();

        claimCounter++;
        claims[claimCounter] = Claim(claimCounter, _policyId, _claimAmount, false, _patientId, _hospitalId, 0);
        emit ClaimSubmitted(claimCounter, _policyId, _patientId, _hospitalId);
        return claimCounter;
    }

    /// @notice Approves a claim
    /// @param _claimId The ID of the claim to approve
    function approveClaim(uint256 _claimId) public onlyVerifiedStakeholder(claims[_claimId].hospitalId) {
        Claim storage claim = claims[_claimId];
        if (claim.status) revert ClaimAlreadyApproved();
        if (!policies[claim.policyId].policyStatus) revert PolicyNotValid();
        if (patients[claim.patientId].insurancePolicyNumber != policies[claim.policyId].id) {
            revert PolicyPatientMismatch();
        }
        if (hospitals[claim.hospitalId].stakeholderId == 0) revert InvalidHospital();

        claim.status = true;
        emit ClaimApproved(_claimId);
    }

    /// @notice Disburses payment for a claim
    /// @param _claimId The ID of the claim
    /// @param _amountPaid The amount to be paid
    function disbursePayment(
        uint256 _claimId,
        uint256 _amountPaid
    )
        public
        payable
        onlyVerifiedStakeholder(claims[_claimId].hospitalId)
    {
        if (msg.value < _amountPaid) revert InsufficientFunds();

        address payable patientAddress = payable(patients[claims[_claimId].patientId].userAddress);
        patientAddress.transfer(_amountPaid);

        Disbursement memory disbursement = Disbursement({
            id: disbursementCounter++,
            claimId: _claimId,
            amountPaid: _amountPaid,
            dateOfPayment: block.timestamp
        });

        disbursements[disbursement.id] = disbursement;
        emit DisbursementMade(disbursement.id, _claimId);
    }

    /// @notice Subscribes a patient to a policy
    /// @param _policyId The ID of the policy
    /// @param _patientId The ID of the patient
    /// @return The ID of the newly created subscription
    function subscribePolicy(
        uint256 _policyId,
        uint256 _patientId
    )
        public
        onlyVerifiedStakeholder(patients[_patientId].stakeholderId)
        returns (uint256)
    {
        if (!policies[_policyId].policyStatus) revert PolicyNotValid();

        subscriptionCounter++;
        subscriptions[subscriptionCounter] = Subscription({
            id: subscriptionCounter,
            policyId: _policyId,
            patientId: _patientId,
            startDate: block.timestamp,
            endDate: block.timestamp + policies[_policyId].term,
            active: true
        });

        patients[_patientId].insurancePolicyNumber = _policyId;
        return subscriptionCounter;
    }

    /// @notice Deactivates a subscription
    /// @param _subscriptionId The ID of the subscription to deactivate
    function deactivateSubscription(uint256 _subscriptionId) public {
        Subscription storage subscription = subscriptions[_subscriptionId];
        subscription.active = false;
        patients[subscription.patientId].insurancePolicyNumber = 0;
        emit SubscriptionDeactivated(_subscriptionId);
    }

    /// @notice Records a treatment
    /// @param _appointmentId The ID of the appointment
    /// @param _treatmentDetails The details of the treatment
    /// @param _name The name of the treatment
    /// @return The ID of the newly created treatment
    function recordTreatment(
        uint256 _appointmentId,
        string memory _treatmentDetails,
        string memory _name
    )
        public
        returns (uint256)
    {
        if (!appointments[_appointmentId].status) revert AppointmentNotExist();

        treatmentCounter++;
        treatments[treatmentCounter] = Treatment({
            id: treatmentCounter,
            appointmentId: _appointmentId,
            treatmentDetails: _treatmentDetails,
            name: _name
        });

        return treatmentCounter;
    }
}
