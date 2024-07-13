// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InsuranceSystem {
    // Enums
    enum UserType {
        PATIENT,
        HOSPITAL,
        INSURER
    }

    // Structs
    struct User {
        uint256 id;
        UserType userType;
        bool verificationStatus;
        uint256 createdTime;
        uint256 updatedTime;
    }

    struct Patient {
        uint256 id;
        uint256 userId;
        string firstName;
        string lastName;
        string dob;
        string phoneNumber;
        string email;
        string patientAddress;
        string currentInsuranceNumber;
    }

    struct Hospital {
        uint256 id;
        uint256 userId;
        string hospitalName;
        string phoneNumber;
        string email;
        string hospitalAddress;
        bool endorsementStatus;
    }

    struct Insurer {
        uint256 id;
        uint256 userId;
        string insurerName;
        string phoneNumber;
        string email;
        string insurerAddress;
    }

    struct HospitalEndorsement {
        uint256 id;
        uint256 hospitalId;
        uint256 insurerId;
        bool status;
        uint256 createdAt;
    }

    struct InsurerHospitalPartnership {
        uint256 id;
        uint256 hospitalId;
        uint256 insurerId;
        bool partnershipStatus;
        uint256 createdAt;
    }

    struct TreatmentType {
        uint256 id;
        string name;
    }

    struct Policy {
        uint256 id;
        uint256 policyId;
        uint256 insurerId;
        bool policyStatus;
        uint256 monthlyCost;
        uint256 coverLimit;
        uint256 deductible;
        string details;
        string name;
        uint256 createdAt;
    }

    struct PolicyTreatmentCoverage {
        uint256 id;
        uint256 policyId;
        uint256 treatmentTypeId;
    }

    struct Appointment {
        uint256 id;
        uint256 patientId;
        uint256 hospitalId;
        string appointmentDate;
        uint256 treatmentId;
        uint256 verificationId;
        string doctorNote;
        uint256 createdAt;
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
        bool status;
        uint256 createdAt;
    }

    struct Claim {
        uint256 id;
        uint256 patientId;
        uint256 policyId;
        uint256 hospitalId;
        uint256 treatmentId;
        bool verificationStatus;
        uint256 verificationId;
        uint256 createdAt;
    }

    struct Disbursement {
        uint256 id;
        uint256 claimId;
        uint256 amount;
        uint256 createdAt;
        bool status;
    }

    struct Transaction {
        uint256 id;
        uint256 policyId;
        uint256 patientId;
        uint256 amount;
        bool status;
        uint256 createdAt;
    }

    struct InsuranceSubscription {
        uint256 id;
        string insuranceNumber;
        uint256 policyId;
        uint256 patientId;
        string startDate;
        string endDate;
        bool paymentStatus;
        bool requestStatus;
        uint256 createdAt;
    }

    // Mappings to store data
    mapping(uint256 => User) public users;
    mapping(uint256 => Patient) public patients;
    mapping(uint256 => Hospital) public hospitals;
    mapping(uint256 => Insurer) public insurers;
    mapping(uint256 => HospitalEndorsement) public hospitalEndorsements;
    mapping(uint256 => InsurerHospitalPartnership) public insurerHospitalPartnerships;
    mapping(uint256 => TreatmentType) public treatmentTypes;
    mapping(uint256 => Policy) public policies;
    mapping(uint256 => PolicyTreatmentCoverage) public policyTreatmentCoverages;
    mapping(uint256 => Appointment) public appointments;
    mapping(uint256 => Document) public documents;
    mapping(uint256 => Bill) public bills;
    mapping(uint256 => Claim) public claims;
    mapping(uint256 => Disbursement) public disbursements;
    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => InsuranceSubscription) public insuranceSubscriptions;

    // Additional mapping to track hospital endorsements by insurers
    mapping(uint256 => uint256[]) public hospitalEndorsementsList;

    // Counters for generating unique IDs
    uint256 public userIdCounter;
    uint256 public patientIdCounter;
    uint256 public hospitalIdCounter;
    uint256 public insurerIdCounter;
    uint256 public policyIdCounter;
    uint256 public treatmentTypeIdCounter;
    uint256 public appointmentIdCounter;
    uint256 public documentIdCounter;
    uint256 public billIdCounter;
    uint256 public claimIdCounter;
    uint256 public disbursementIdCounter;
    uint256 public transactionIdCounter;
    uint256 public insuranceSubscriptionIdCounter;
    uint256 public policyTreatmentCoverageIdCounter;
    uint256 public hospitalEndorsementIdCounter;

    // Events
    event UserCreated(uint256 id, UserType userType);
    event UserVerified(uint256 id);
    event PatientInsuranceUpdated(uint256 patientId, string insuranceNumber);
    event HospitalEndorsed(uint256 hospitalId, uint256 insurerId);
    event PolicyCreated(uint256 policyId);
    event ClaimCreated(uint256 claimId);
    event ClaimVerified(uint256 claimId, bool status);
    event DisbursementCreated(uint256 disbursementId);
    event AppointmentCreated(uint256 appointmentId);
    event DocumentCreated(uint256 documentId);
    event BillCreated(uint256 billId);
    event TransactionCreated(uint256 transactionId);

    /**
     * @dev Creates a new user
     * @param _userType Type of the user (PATIENT, HOSPITAL, INSURER)
     */
    function createUser(UserType _userType) public {
        userIdCounter++;
        users[userIdCounter] = User(userIdCounter, _userType, false, block.timestamp, block.timestamp);
        emit UserCreated(userIdCounter, _userType);
    }

    /**
     * @dev Verifies a user
     * @param _id ID of the user to verify
     */
    function verifyUser(uint256 _id) public {
        require(users[_id].id != 0, "User does not exist");
        users[_id].verificationStatus = true;
        users[_id].updatedTime = block.timestamp;
        emit UserVerified(_id);
    }

    /**
     * @dev Creates a new patient
     * @param _userId ID of the user associated with the patient
     * @param _firstName First name of the patient
     * @param _lastName Last name of the patient
     * @param _dob Date of birth of the patient
     * @param _phoneNumber Phone number of the patient
     * @param _email Email of the patient
     * @param _address Address of the patient
     */
    function createPatient(
        uint256 _userId,
        string memory _firstName,
        string memory _lastName,
        string memory _dob,
        string memory _phoneNumber,
        string memory _email,
        string memory _address
    )
        public
    {
        require(users[_userId].id != 0, "User does not exist");
        require(users[_userId].userType == UserType.PATIENT, "User is not a patient");
        patientIdCounter++;
        patients[patientIdCounter] =
            Patient(patientIdCounter, _userId, _firstName, _lastName, _dob, _phoneNumber, _email, _address, "");
    }

    /**
     * @dev Creates a new hospital
     * @param _userId ID of the user associated with the hospital
     * @param _hospitalName Name of the hospital
     * @param _phoneNumber Phone number of the hospital
     * @param _email Email of the hospital
     * @param _address Address of the hospital
     */
    function createHospital(
        uint256 _userId,
        string memory _hospitalName,
        string memory _phoneNumber,
        string memory _email,
        string memory _address
    )
        public
    {
        require(users[_userId].id != 0, "User does not exist");
        require(users[_userId].userType == UserType.HOSPITAL, "User is not a hospital");
        hospitalIdCounter++;
        hospitals[hospitalIdCounter] =
            Hospital(hospitalIdCounter, _userId, _hospitalName, _phoneNumber, _email, _address, false);
    }

    /**
     * @dev Creates a new insurer
     * @param _userId ID of the user associated with the insurer
     * @param _insurerName Name of the insurer
     * @param _phoneNumber Phone number of the insurer
     * @param _email Email of the insurer
     * @param _address Address of the insurer
     */
    function createInsurer(
        uint256 _userId,
        string memory _insurerName,
        string memory _phoneNumber,
        string memory _email,
        string memory _address
    )
        public
    {
        require(users[_userId].id != 0, "User does not exist");
        require(users[_userId].userType == UserType.INSURER, "User is not an insurer");
        insurerIdCounter++;
        insurers[insurerIdCounter] = Insurer(insurerIdCounter, _userId, _insurerName, _phoneNumber, _email, _address);
    }

    /**
     * @dev Endorses a hospital by an insurer
     * @param _hospitalId ID of the hospital to endorse
     * @param _insurerId ID of the insurer endorsing the hospital
     */
    function endorseHospital(uint256 _hospitalId, uint256 _insurerId) public {
        require(hospitals[_hospitalId].id != 0, "Hospital does not exist");
        require(insurers[_insurerId].id != 0, "Insurer does not exist");

        // Check if this insurer has already endorsed this hospital
        uint256[] storage endorsers = hospitalEndorsementsList[_hospitalId];
        for (uint256 i = 0; i < endorsers.length; i++) {
            require(endorsers[i] != _insurerId, "Hospital already endorsed by this insurer");
        }

        // Add the insurer to the list of endorsers for the hospital
        endorsers.push(_insurerId);

        // Create an endorsement record
        hospitalEndorsementIdCounter++;
        hospitalEndorsements[hospitalEndorsementIdCounter] =
            HospitalEndorsement(hospitalEndorsementIdCounter, _hospitalId, _insurerId, true, block.timestamp);

        emit HospitalEndorsed(_hospitalId, _insurerId);

        // Update hospital endorsement status if there are 3 or more endorsements
        if (endorsers.length >= 3) {
            hospitals[_hospitalId].endorsementStatus = true;
        }
    }
    /**
     * @dev Creates a new treatment type
     * @param _name Name of the treatment type
     */

    function createTreatmentType(string memory _name) public {
        treatmentTypeIdCounter++;
        treatmentTypes[treatmentTypeIdCounter] = TreatmentType(treatmentTypeIdCounter, _name);
    }

    /**
     * @dev Creates a new policy
     * @param _policyId ID of the policy
     * @param _insurerId ID of the insurer associated with the policy
     * @param _monthlyCost Monthly cost of the policy
     * @param _coverLimit Cover limit of the policy
     * @param _deductible Deductible of the policy
     * @param _details Details of the policy
     * @param _name Name of the policy
     */
    function createPolicy(
        uint256 _policyId,
        uint256 _insurerId,
        uint256 _monthlyCost,
        uint256 _coverLimit,
        uint256 _deductible,
        string memory _details,
        string memory _name
    )
        public
    {
        require(insurers[_insurerId].id != 0, "Insurer does not exist");
        policyIdCounter++;
        policies[policyIdCounter] = Policy(
            policyIdCounter,
            _policyId,
            _insurerId,
            true,
            _monthlyCost,
            _coverLimit,
            _deductible,
            _details,
            _name,
            block.timestamp
        );
        emit PolicyCreated(_policyId);
    }

    /**
     * @dev Creates a new policy treatment coverage
     * @param _policyId ID of the policy
     * @param _treatmentTypeId ID of the treatment type
     */
    function createPolicyTreatmentCoverage(uint256 _policyId, uint256 _treatmentTypeId) public {
        require(policies[_policyId].id != 0, "Policy does not exist");
        require(treatmentTypes[_treatmentTypeId].id != 0, "Treatment type does not exist");
        policyTreatmentCoverageIdCounter++;
        policyTreatmentCoverages[policyTreatmentCoverageIdCounter] =
            PolicyTreatmentCoverage(policyTreatmentCoverageIdCounter, _policyId, _treatmentTypeId);
    }

    /**
     * @dev Subscribes a patient to a policy
     * @param _insuranceNumber Insurance number of the subscription
     * @param _policyId ID of the policy
     * @param _patientId ID of the patient
     * @param _startDate Start date of the subscription
     * @param _endDate End date of the subscription
     */
    function subscribeToPolicy(
        string memory _insuranceNumber,
        uint256 _policyId,
        uint256 _patientId,
        string memory _startDate,
        string memory _endDate
    )
        public
    {
        require(policies[_policyId].id != 0, "Policy does not exist");
        require(patients[_patientId].id != 0, "Patient does not exist");

        insuranceSubscriptionIdCounter++;
        insuranceSubscriptions[insuranceSubscriptionIdCounter] = InsuranceSubscription(
            insuranceSubscriptionIdCounter,
            _insuranceNumber,
            _policyId,
            _patientId,
            _startDate,
            _endDate,
            true,
            true,
            block.timestamp
        );

        // Update patient's current insurance number
        patients[_patientId].currentInsuranceNumber = _insuranceNumber;

        emit PatientInsuranceUpdated(_patientId, _insuranceNumber);
    }

    /**
     * @dev Creates a new appointment
     * @param _patientId ID of the patient
     * @param _hospitalId ID of the hospital
     * @param _appointmentDate Date of the appointment
     * @param _treatmentId ID of the treatment type
     * @param _verificationId ID of the verification
     * @param _doctorNote Doctor's note for the appointment
     */
    function createAppointment(
        uint256 _patientId,
        uint256 _hospitalId,
        string memory _appointmentDate,
        uint256 _treatmentId,
        uint256 _verificationId,
        string memory _doctorNote
    )
        public
    {
        require(patients[_patientId].id != 0, "Patient does not exist");
        require(hospitals[_hospitalId].id != 0, "Hospital does not exist");
        require(treatmentTypes[_treatmentId].id != 0, "Treatment type does not exist");

        appointmentIdCounter++;
        appointments[appointmentIdCounter] = Appointment(
            appointmentIdCounter,
            _patientId,
            _hospitalId,
            _appointmentDate,
            _treatmentId,
            _verificationId,
            _doctorNote,
            block.timestamp
        );
        emit AppointmentCreated(appointmentIdCounter);
    }

    /**
     * @dev Creates a new document
     * @param _appointmentId ID of the appointment
     * @param _name Name of the document
     * @param _url URL of the document
     */
    function createDocument(uint256 _appointmentId, string memory _name, string memory _url) public {
        require(appointments[_appointmentId].id != 0, "Appointment does not exist");

        documentIdCounter++;
        documents[documentIdCounter] = Document(documentIdCounter, _appointmentId, _name, _url, block.timestamp);
        emit DocumentCreated(documentIdCounter);
    }

    /**
     * @dev Creates a new bill
     * @param _appointmentId ID of the appointment
     * @param _totalAmount Total amount of the bill
     * @param _status Status of the bill
     */
    function createBill(uint256 _appointmentId, uint256 _totalAmount, bool _status) public {
        require(appointments[_appointmentId].id != 0, "Appointment does not exist");

        billIdCounter++;
        bills[billIdCounter] = Bill(billIdCounter, _appointmentId, _totalAmount, _status, block.timestamp);
        emit BillCreated(billIdCounter);
    }

    /**
     * @dev Creates a new claim
     * @param _patientId ID of the patient
     * @param _policyId ID of the policy
     * @param _hospitalId ID of the hospital
     * @param _treatmentId ID of the treatment type
     * @param _verificationId ID of the verification
     */
    function createClaim(
        uint256 _patientId,
        uint256 _policyId,
        uint256 _hospitalId,
        uint256 _treatmentId,
        uint256 _verificationId
    )
        public
    {
        require(patients[_patientId].id != 0, "Patient does not exist");
        require(policies[_policyId].id != 0, "Policy does not exist");
        require(hospitals[_hospitalId].id != 0, "Hospital does not exist");
        require(treatmentTypes[_treatmentId].id != 0, "Treatment type does not exist");

        claimIdCounter++;
        claims[claimIdCounter] = Claim(
            claimIdCounter, _patientId, _policyId, _hospitalId, _treatmentId, false, _verificationId, block.timestamp
        );
        emit ClaimCreated(claimIdCounter);
    }

    /**
     * @dev Verifies a claim
     * @param _claimId ID of the claim to verify
     * @param _status Status of the verification (true or false)
     * @param _disbursementAmount Amount to disburse if the claim is verified
     */
    function verifyClaim(uint256 _claimId, bool _status, uint256 _disbursementAmount) public {
        require(claims[_claimId].id != 0, "Claim does not exist");
        claims[_claimId].verificationStatus = _status;
        emit ClaimVerified(_claimId, _status);

        if (_status) {
            // Create a disbursement
            disbursementIdCounter++;
            disbursements[disbursementIdCounter] =
                Disbursement(disbursementIdCounter, _claimId, _disbursementAmount, block.timestamp, true);
            emit DisbursementCreated(disbursementIdCounter);

            // Create a transaction
            Claim memory claim = claims[_claimId];
            transactionIdCounter++;
            transactions[transactionIdCounter] = Transaction(
                transactionIdCounter, claim.policyId, claim.patientId, _disbursementAmount, true, block.timestamp
            );
            emit TransactionCreated(transactionIdCounter);
        }
    }

    /**
     * @dev Creates a disbursement
     * @param _claimId ID of the claim associated with the disbursement
     * @param _amount Amount of the disbursement
     */
    function createDisbursement(uint256 _claimId, uint256 _amount) internal {
        require(claims[_claimId].id != 0, "Claim does not exist");
        require(claims[_claimId].verificationStatus == true, "Claim not verified");

        disbursementIdCounter++;
        disbursements[disbursementIdCounter] =
            Disbursement(disbursementIdCounter, _claimId, _amount, block.timestamp, true);
        emit DisbursementCreated(disbursementIdCounter);
    }

    /**
     * @dev Creates a transaction
     * @param _policyId ID of the policy associated with the transaction
     * @param _patientId ID of the patient associated with the transaction
     * @param _amount Amount of the transaction
     * @param _status Status of the transaction
     */
    function createTransaction(uint256 _policyId, uint256 _patientId, uint256 _amount, bool _status) internal {
        require(policies[_policyId].id != 0, "Policy does not exist");
        require(patients[_patientId].id != 0, "Patient does not exist");

        transactionIdCounter++;
        transactions[transactionIdCounter] =
            Transaction(transactionIdCounter, _policyId, _patientId, _amount, _status, block.timestamp);
        emit TransactionCreated(transactionIdCounter);
    }

    /**
     * @dev Gets all patients
     * @return An array of Patient structs
     */
    function getAllPatients() public view returns (Patient[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < patientIdCounter; i++) {
            if (patients[i].id != 0) {
                count++;
            }
        }

        Patient[] memory result = new Patient[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < patientIdCounter; i++) {
            if (patients[i].id != 0) {
                result[index] = patients[i];
                index++;
            }
        }
        return result;
    }

    /**
     * @dev Gets all insurers
     * @return An array of Insurer structs
     */
    function getAllInsurers() public view returns (Insurer[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < insurerIdCounter; i++) {
            if (insurers[i].id != 0) {
                count++;
            }
        }

        Insurer[] memory result = new Insurer[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < insurerIdCounter; i++) {
            if (insurers[i].id != 0) {
                result[index] = insurers[i];
                index++;
            }
        }
        return result;
    }

    /**
     * @dev Gets all policies
     * @return An array of Policy structs
     */
    function getAllPolicies() public view returns (Policy[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < policyIdCounter; i++) {
            if (policies[i].id != 0) {
                count++;
            }
        }

        Policy[] memory result = new Policy[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < policyIdCounter; i++) {
            if (policies[i].id != 0) {
                result[index] = policies[i];
                index++;
            }
        }
        return result;
    }

    /**
     * @dev Gets all hospitals
     * @return An array of Hospital structs
     */
    function getAllHospitals() public view returns (Hospital[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < hospitalIdCounter; i++) {
            if (hospitals[i].id != 0) {
                count++;
            }
        }

        Hospital[] memory result = new Hospital[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < hospitalIdCounter; i++) {
            if (hospitals[i].id != 0) {
                result[index] = hospitals[i];
                index++;
            }
        }
        return result;
    }

    /**
     * @dev Gets all appointments
     * @return An array of Appointment structs
     */
    function getAllAppointments() public view returns (Appointment[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < appointmentIdCounter; i++) {
            if (appointments[i].id != 0) {
                count++;
            }
        }

        Appointment[] memory result = new Appointment[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < appointmentIdCounter; i++) {
            if (appointments[i].id != 0) {
                result[index] = appointments[i];
                index++;
            }
        }
        return result;
    }

    /**
     * @dev Gets all bills
     * @return An array of Bill structs
     */
    function getAllBills() public view returns (Bill[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < billIdCounter; i++) {
            if (bills[i].id != 0) {
                count++;
            }
        }

        Bill[] memory result = new Bill[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < billIdCounter; i++) {
            if (bills[i].id != 0) {
                result[index] = bills[i];
                index++;
            }
        }
        return result;
    }

    /**
     * @dev Gets all transactions
     * @return An array of Transaction structs
     */
    function getAllTransactions() public view returns (Transaction[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < transactionIdCounter; i++) {
            if (transactions[i].id != 0) {
                count++;
            }
        }

        Transaction[] memory result = new Transaction[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < transactionIdCounter; i++) {
            if (transactions[i].id != 0) {
                result[index] = transactions[i];
                index++;
            }
        }
        return result;
    }

    /**
     * @dev Gets all disbursements
     * @return An array of Disbursement structs
     */
    function getAllDisbursements() public view returns (Disbursement[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < disbursementIdCounter; i++) {
            if (disbursements[i].id != 0) {
                count++;
            }
        }

        Disbursement[] memory result = new Disbursement[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < disbursementIdCounter; i++) {
            if (disbursements[i].id != 0) {
                result[index] = disbursements[i];
                index++;
            }
        }
        return result;
    }

    /**
     * @dev Gets all insurers that endorsed a hospital
     * @param _hospitalId ID of the hospital
     * @return An array of IDs of insurers that endorsed the hospital
     */
    function getHospitalEndorsers(uint256 _hospitalId) public view returns (uint256[] memory) {
        return hospitalEndorsementsList[_hospitalId];
    }
}
