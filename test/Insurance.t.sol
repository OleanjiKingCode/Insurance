// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "remix_tests.sol";
import "./HealthInsuranceSystem.sol";

contract HealthInsuranceSystemTest {
    HealthInsuranceSystem healthInsuranceSystem;
    
    enum UserType { PATIENT, HOSPITAL, INSURER }
    
    function beforeAll() public {
        healthInsuranceSystem = new HealthInsuranceSystem();
    }

    function testRegisterStakeholder() public {
        uint256 stakeholderId = healthInsuranceSystem.registerStakeholder(UserType.PATIENT);
        Assert.equal(stakeholderId, 1, "First stakeholder ID should be 1");
    }
    
    function testVerifyStakeholder() public {
        uint256 stakeholderId = healthInsuranceSystem.registerStakeholder(UserType.PATIENT);
        healthInsuranceSystem.verifyStakeholder(stakeholderId);
        Assert.isTrue(healthInsuranceSystem.stakeholders(stakeholderId).verificationStatus, "Stakeholder should be verified");
    }
    
    function testRegisterPatient() public {
        uint256 stakeholderId = healthInsuranceSystem.registerStakeholder(UserType.PATIENT);
        uint256 patientId = healthInsuranceSystem.registerPatient(
            UserType.PATIENT,
            "John",
            "Doe",
            "1990-01-01",
            "+123456789",
            "john.doe@example.com",
            address(this),
            123456789
        );
        Assert.equal(patientId, 1, "First patient ID should be 1");
    }
    
    function testRegisterPatientFailsIfAlreadyExists() public {
        healthInsuranceSystem.registerStakeholder(UserType.PATIENT);
        healthInsuranceSystem.registerPatient(
            UserType.PATIENT,
            "John",
            "Doe",
            "1990-01-01",
            "+123456789",
            "john.doe@example.com",
            address(this),
            123456789
        );
        Assert.reverts(
            function() { healthInsuranceSystem.registerPatient(
                UserType.PATIENT,
                "Jane",
                "Smith",
                "1992-03-04",
                "+987654321",
                "jane.smith@example.com",
                address(this),
                987654321
            ); },
            "Should revert on registering patient with existing address"
        );
    }
    
    function testRegisterHospital() public {
        uint256 stakeholderId = healthInsuranceSystem.registerStakeholder(UserType.HOSPITAL);
        uint256 hospitalId = healthInsuranceSystem.registerHospital(
            UserType.HOSPITAL,
            "Test Hospital",
            "+987654321",
            "hospital@example.com",
            "Test Location",
            address(this),
            new uint256 
        );
        Assert.equal(hospitalId, 1, "First hospital ID should be 1");
    }
    
    function testRegisterHospitalFailsIfAlreadyExists() public {
        healthInsuranceSystem.registerStakeholder(UserType.HOSPITAL);
        healthInsuranceSystem.registerHospital(
            UserType.HOSPITAL,
            "Test Hospital",
            "+987654321",
            "hospital@example.com",
            "Test Location",
            address(this),
            new uint256 
        );
        Assert.reverts(
            function() { healthInsuranceSystem.registerHospital(
                UserType.HOSPITAL,
                "Another Hospital",
                "+123456789",
                "another.hospital@example.com",
                "Another Location",
                address(this),
                new uint256 
            ); },
            "Should revert on registering hospital with existing address"
        );
    }
    
    function testRegisterInsurer() public {
        uint256 stakeholderId = healthInsuranceSystem.registerStakeholder(UserType.INSURER);
        uint256 insurerId = healthInsuranceSystem.registerInsurer(
            UserType.INSURER,
            "Test Insurer",
            "+1122334455",
            "insurer@example.com",
            address(this)
        );
        Assert.equal(insurerId, 1, "First insurer ID should be 1");
    }
    
    function testRegisterInsurerFailsIfAlreadyExists() public {
        healthInsuranceSystem.registerStakeholder(UserType.INSURER);
        healthInsuranceSystem.registerInsurer(
            UserType.INSURER,
            "Test Insurer",
            "+1122334455",
            "insurer@example.com",
            address(this)
        );
        Assert.reverts(
            function() { healthInsuranceSystem.registerInsurer(
                UserType.INSURER,
                "Another Insurer",
                "+9988776655",
                "another.insurer@example.com",
                address(this)
            ); },
            "Should revert on registering insurer with existing address"
        );
    }
    
    function testCreatePolicy() public {
        uint256 insurerId = healthInsuranceSystem.registerInsurer(
            UserType.INSURER,
            "Test Insurer",
            "+1122334455",
            "insurer@example.com",
            address(this)
        );
        uint256 policyId = healthInsuranceSystem.createPolicy(insurerId, "Coverage details", 100, 365);
        Assert.equal(policyId, 1, "First policy ID should be 1");
    }
    
    function testCreatePolicyFailsIfInvalidCoverageDetails() public {
        uint256 insurerId = healthInsuranceSystem.registerInsurer(
            UserType.INSURER,
            "Test Insurer",
            "+1122334455",
            "insurer@example.com",
            address(this)
        );
        Assert.reverts(
            function() { healthInsuranceSystem.createPolicy(insurerId, "", 100, 365); },
            "Should revert on creating policy with empty coverage details"
        );
    }
    
    function testCreatePolicyFailsIfInvalidCost() public {
        uint256 insurerId = healthInsuranceSystem.registerInsurer(
            UserType.INSURER,
            "Test Insurer",
            "+1122334455",
            "insurer@example.com",
            address(this)
        );
        Assert.reverts(
            function() { healthInsuranceSystem.createPolicy(insurerId, "Coverage details", 0, 365); },
            "Should revert on creating policy with zero cost"
        );
    }
    
    function testCreatePolicyFailsIfInvalidTerm() public {
        uint256 insurerId = healthInsuranceSystem.registerInsurer(
            UserType.INSURER,
            "Test Insurer",
            "+1122334455",
            "insurer@example.com",
            address(this)
        );
        Assert.reverts(
            function() { healthInsuranceSystem.createPolicy(insurerId, "Coverage details", 100, 0); },
            "Should revert on creating policy with zero term"
        );
    }
    
    function testCreateAppointment() public {
        uint256 patientId = healthInsuranceSystem.registerPatient(
            UserType.PATIENT,
            "John",
            "Doe",
            "1990-01-01",
            "+123456789",
            "john.doe@example.com",
            address(this),
            123456789
        );
        uint256 hospitalId = healthInsuranceSystem.registerHospital(
            UserType.HOSPITAL,
            "Test Hospital",
            "+987654321",
            "hospital@example.com",
            "Test Location",
            address(this),
            new uint256 
        );
        uint256 appointmentId = healthInsuranceSystem.createAppointment(
            patientId,
            hospitalId,
            block.timestamp + 3600,
            "Regular Checkup"
        );
        Assert.equal(appointmentId, 1, "First appointment ID should be 1");
    }
    
    function testCreateAppointmentFailsIfInvalidAppointmentDate() public {
        uint256 patientId = healthInsuranceSystem.registerPatient(
            UserType.PATIENT,
            "John",
            "Doe",
            "1990-01-01",
            "+123456789",
            "john.doe@example.com",
            address(this),
            123456789
        );
        uint256 hospitalId = healthInsuranceSystem.registerHospital(
            UserType.HOSPITAL,
            "Test Hospital",
            "+987654321",
            "hospital@example.com",
            "Test Location",
            address(this),
            new uint256 
        );
        Assert.reverts(
            function() { healthInsuranceSystem.createAppointment(
                patientId,
                hospitalId,
                block.timestamp - 3600,
                "Regular Checkup"
            ); },
            "Should revert on creating appointment with past appointment date"
        );
    }
    
    function testGenerateBill() public {
        uint256 patientId = healthInsuranceSystem.registerPatient(
            UserType.PATIENT,
            "John",
            "Doe",
            "1990-01-01",
            "+123456789",
            "john.doe@example.com",
            address(this),
            123456789
        );
        uint256 hospitalId = healthInsuranceSystem.registerHospital(
            UserType.HOSPITAL,
            "Test Hospital",
            "+987654321",
            "hospital@example.com",
            "Test Location",
            address(this),
            new uint256 
        );
        uint256 appointmentId = healthInsuranceSystem.createAppointment(
            patientId,
            hospitalId,
            block.timestamp + 3600,
            "Regular Checkup"
        );
        uint256 billId = healthInsuranceSystem.generateBill(patientId, appointmentId, 500);
        Assert.equal(billId, 1, "First bill ID should be 1");
    }
    
    function testGenerateBillFailsIfAppointmentNotExists() public {
        uint256 patientId = healthInsuranceSystem.registerPatient(
            UserType.PATIENT,
            "John",
            "Doe",
            "1990-01-01",
            "+123456789",
            "john.doe@example.com",
            address(this),
            123456789
        );
        Assert.reverts(
            function() { healthInsuranceSystem.generateBill(patientId, 1, 500); },
            "Should revert on generating bill for non-existent appointment"
        );
    }
    
    function testSubmitClaim() public {
        uint256 insurerId = healthInsuranceSystem.registerInsurer(
            UserType.INSURER,
            "Test Insurer",
            "+1122334455",
            "insurer@example.com",
            address(this)
        );
        uint256 policyId = healthInsuranceSystem.createPolicy(insurerId, "Coverage details", 100, 365);
        uint256 patientId = healthInsuranceSystem.registerPatient(
            UserType.PATIENT,
            "John",
            "Doe",
            "1990-01-01",
            "+123456789",
            "john.doe@example.com",
            address(this),
            policyId
        );
        uint256 hospitalId = healthInsuranceSystem.registerHospital(
            UserType.HOSPITAL,
            "Test Hospital",
            "+987654321",
            "hospital@example.com",
            "Test Location",
            address(this),
            new uint256 
        );
        uint256 appointmentId = healthInsuranceSystem.createAppointment(
            patientId,
            hospitalId,
            block.timestamp + 3600,
            "Regular Checkup"
        );
        uint256 claimId = healthInsuranceSystem.submitClaim(policyId, 500, patientId, hospitalId);
        Assert.equal(claimId, 1, "First claim ID should be 1");
    }
    
    function testSubmitClaimFailsIfInvalidAmount() public {
        uint256 insurerId = healthInsuranceSystem.registerInsurer(
            UserType.INSURER,
            "Test Insurer",
            "+1122334455",
            "insurer@example.com",
            address(this)
        );
        uint256 policyId = healthInsuranceSystem.createPolicy(insurerId, "Coverage details", 100, 365);
        uint256 patientId = healthInsuranceSystem.registerPatient(
            UserType.PATIENT,
            "John",
            "Doe",
            "1990-01-01",
            "+123456789",
            "john.doe@example.com",
            address(this),
            policyId
        );
        uint256 hospitalId = healthInsuranceSystem.registerHospital(
            UserType.HOSPITAL,
            "Test Hospital",
            "+987654321",
            "hospital@example.com",
            "Test Location",
            address(this),
            new uint256 
        );
        Assert.reverts(
            function() { healthInsuranceSystem.submitClaim(policyId, 0, patientId, hospitalId); },
            "Should revert on submitting claim with zero amount"
        );
    }
    
    function testApproveClaim() public {
        uint256 insurerId = healthInsuranceSystem.registerInsurer(
            UserType.INSURER,
            "Test Insurer",
            "+1122334455",
            "insurer@example.com",
            address(this)
        );
        uint256 policyId = healthInsuranceSystem.createPolicy(insurerId, "Coverage details", 100, 365);
        uint256 patientId = healthInsuranceSystem.registerPatient(
            UserType.PATIENT,
            "John",
            "Doe",
            "1990-01-01",
            "+123456789",
            "john.doe@example.com",
            address(this),
            policyId
        );
        uint256 hospitalId = healthInsuranceSystem.registerHospital(
            UserType.HOSPITAL,
            "Test Hospital",
            "+987654321",
            "hospital@example.com",
            "Test Location",
            address(this),
            new uint256 
        );
        uint256 appointmentId = healthInsuranceSystem.createAppointment(
            patientId,
            hospitalId,
            block.timestamp + 3600,
            "Regular Checkup"
        );
        uint256 claimId = healthInsuranceSystem.submitClaim(policyId, 500, patientId, hospitalId);
        healthInsuranceSystem.approveClaim(claimId);
        Assert.isTrue(healthInsuranceSystem.claims(claimId).status, "Claim should be approved");
    }
    
    function testSubscribePolicy() public {
        uint256 insurerId = healthInsuranceSystem.registerInsurer(
            UserType.INSURER,
            "Test Insurer",
            "+1122334455",
            "insurer@example.com",
            address(this)
        );
        uint256 policyId = healthInsuranceSystem.createPolicy(insurerId, "Coverage details", 100, 365);
        uint256 patientId = healthInsuranceSystem.registerPatient(
            UserType.PATIENT,
            "John",
            "Doe",
            "1990-01-01",
            "+123456789",
            "john.doe@example.com",
            address(this),
            policyId
        );
        uint256 subscriptionId = healthInsuranceSystem.subscribePolicy(policyId, patientId);
        Assert.equal(subscriptionId, 1, "First subscription ID should be 1");
    }
    
    function testDeactivateSubscription() public {
        uint256 insurerId = healthInsuranceSystem.registerInsurer(
            UserType.INSURER,
            "Test Insurer",
            "+1122334455",
            "insurer@example.com",
            address(this)
        );
        uint256 policyId = healthInsuranceSystem.createPolicy(insurerId, "Coverage details", 100, 365);
        uint256 patientId = healthInsuranceSystem.registerPatient(
            UserType.PATIENT,
            "John",
            "Doe",
            "1990-01-01",
            "+123456789",
            "john.doe@example.com",
            address(this),
            policyId
        );
        uint256 subscriptionId = healthInsuranceSystem.subscribePolicy(policyId, patientId);
        healthInsuranceSystem.deactivateSubscription(subscriptionId);
        Assert.equal(healthInsuranceSystem.patients(patientId).insurancePolicyNumber, 0, "Subscription should be deactivated");
    }
    
    function testRecordTreatment() public {
        uint256 patientId = healthInsuranceSystem.registerPatient(
            UserType.PATIENT,
            "John",
            "Doe",
            "1990-01-01",
            "+123456789",
            "john.doe@example.com",
            address(this),
            123456789
        );
        uint256 hospitalId = healthInsuranceSystem.registerHospital(
            UserType.HOSPITAL,
            "Test Hospital",
            "+987654321",
            "hospital@example.com",
            "Test Location",
            address(this),
            new uint256 
        );
        uint256 appointmentId = healthInsuranceSystem.createAppointment(
            patientId,
            hospitalId,
            block.timestamp + 3600,
            "Regular Checkup"
        );
        uint256 treatmentId = healthInsuranceSystem.recordTreatment(appointmentId, "Treatment details", "Treatment1");
        Assert.equal(treatmentId, 1, "First treatment ID should be 1");
    }
    
    function testRecordTreatmentFailsIfInvalidAppointmentId() public {
        Assert.reverts(
            function() { healthInsuranceSystem.recordTreatment(1, "Treatment details", "Treatment1"); },
            "Should revert on recording treatment with invalid appointment ID"
        );
    }
}
