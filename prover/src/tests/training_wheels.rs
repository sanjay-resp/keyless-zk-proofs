use std::time::{SystemTime, UNIX_EPOCH};

use crate::config::CONFIG;
use crate::tests::common::types::{ProofTestCase, TestJWTPayload};
use crate::tests::common::{gen_test_jwk_keypair, get_test_circuit_config, types::TestJWKKeyPair};
use crate::training_wheels::validate_jwt_sig_and_dates;

#[test]
fn test_validate_jwt_sig_and_dates() {
    let jwt_payload = TestJWTPayload {
        ..TestJWTPayload::default()
    };

    let testcase =
        ProofTestCase::default_with_payload(jwt_payload).compute_nonce(&get_test_circuit_config());

    let jwk_keypair = gen_test_jwk_keypair();
    let prover_request_input = testcase.convert_to_prover_request(&jwk_keypair);

    assert!(validate_jwt_sig_and_dates(
        &prover_request_input,
        Some(&jwk_keypair.into_rsa_jwk()),
        &CONFIG,
    )
    .is_ok());
}

#[test]
#[should_panic]
fn test_validate_jwt_sig_and_dates_expired() {
    let start = SystemTime::now();
    let since_the_epoch = start
        .duration_since(UNIX_EPOCH)
        .expect("Time went backwards");

    let jwt_payload = TestJWTPayload {
        exp: since_the_epoch.as_secs() - 100,
        ..TestJWTPayload::default()
    };

    let testcase =
        ProofTestCase::default_with_payload(jwt_payload).compute_nonce(&get_test_circuit_config());

    let jwk_keypair = gen_test_jwk_keypair();
    let prover_request_input = testcase.convert_to_prover_request(&jwk_keypair);

    assert!(validate_jwt_sig_and_dates(
        &prover_request_input,
        Some(&jwk_keypair.into_rsa_jwk()),
        &CONFIG,
    )
    .is_ok());
}

#[test]
fn test_validate_jwt_sig_and_dates_expired_can_be_disabled() {
    let start = SystemTime::now();
    let since_the_epoch = start
        .duration_since(UNIX_EPOCH)
        .expect("Time went backwards");

    let jwt_payload = TestJWTPayload {
        exp: since_the_epoch.as_secs() - 100,
        ..TestJWTPayload::default()
    };

    let testcase =
        ProofTestCase::default_with_payload(jwt_payload).compute_nonce(&get_test_circuit_config());

    let jwk_keypair = gen_test_jwk_keypair();
    let prover_request_input = testcase.convert_to_prover_request(&jwk_keypair);

    let mut config = CONFIG.clone();
    config.disable_exp_claim_in_future_check = true;

    assert!(validate_jwt_sig_and_dates(
        &prover_request_input,
        Some(&jwk_keypair.into_rsa_jwk()),
        &config,
    )
    .is_ok());
}

#[test]
#[should_panic]
fn test_validate_jwt_sig_and_dates_future_iat() {
    let start = SystemTime::now();
    let since_the_epoch = start
        .duration_since(UNIX_EPOCH)
        .expect("Time went backwards");

    let jwt_payload = TestJWTPayload {
        exp: since_the_epoch.as_secs() + 100,
        iat: since_the_epoch.as_secs() + 100,
        ..TestJWTPayload::default()
    };

    let testcase =
        ProofTestCase::default_with_payload(jwt_payload).compute_nonce(&get_test_circuit_config());

    let jwk_keypair = gen_test_jwk_keypair();
    let prover_request_input = testcase.convert_to_prover_request(&jwk_keypair);

    assert!(validate_jwt_sig_and_dates(
        &prover_request_input,
        Some(&jwk_keypair.into_rsa_jwk()),
        &CONFIG,
    )
    .is_ok());
}

#[test]
fn test_validate_jwt_sig_and_dates_future_iat_can_be_disabled() {
    let start = SystemTime::now();
    let since_the_epoch = start
        .duration_since(UNIX_EPOCH)
        .expect("Time went backwards");

    let jwt_payload = TestJWTPayload {
        exp: since_the_epoch.as_secs() + 100,
        iat: since_the_epoch.as_secs() + 100,
        ..TestJWTPayload::default()
    };

    let testcase =
        ProofTestCase::default_with_payload(jwt_payload).compute_nonce(&get_test_circuit_config());

    let jwk_keypair = gen_test_jwk_keypair();
    let prover_request_input = testcase.convert_to_prover_request(&jwk_keypair);

    let mut config = CONFIG.clone();
    config.disable_iat_in_past_check = true;
    // Disable the future iat check.
    assert!(validate_jwt_sig_and_dates(
        &prover_request_input,
        Some(&jwk_keypair.into_rsa_jwk()),
        &config
    )
    .is_ok());
}
