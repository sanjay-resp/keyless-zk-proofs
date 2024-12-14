import os
import utils


res_root = os.environ['RESOURCES_DIR']

utils.prepare_single_setup(
    setup_root=f'{res_root}/setup_2024_05',
    url_prover_key='https://github.com/aptos-labs/aptos-keyless-trusted-setup-contributions-may-2024/raw/main/contributions/main_39f9c44b4342ed5e6941fae36cf6c87c52b1e17f_final.zkey',
    url_main_c='https://github.com/aptos-labs/devnet-groth16-keys/raw/master/main_c_cpp/main_c',
    url_main_c_dat='https://github.com/aptos-labs/devnet-groth16-keys/raw/master/main_c_cpp/main_c.dat',
    url_vk='https://github.com/aptos-labs/aptos-keyless-trusted-setup-contributions-may-2024/raw/main/verification_key_39f9c44b4342ed5e6941fae36cf6c87c52b1e17f.json',
    url_circuit_config='https://raw.githubusercontent.com/aptos-labs/aptos-keyless-trusted-setup-contributions-may-2024/0f2ca4730147c5d4123b9c32a0cf0bd800f36b38/circuit_config.yml',
    url_generate_witness_js='https://github.com/aptos-labs/devnet-groth16-keys/raw/master/main_js/generate_witness.js',
    url_main_wasm='https://github.com/aptos-labs/devnet-groth16-keys/raw/master/main_js/main.wasm',
    url_witness_calculator_js='https://github.com/aptos-labs/devnet-groth16-keys/raw/master/main_js/witness_calculator.js'
)

# utils.prepare_single_setup(
#     setup_root=f'{res_root}/setup_2025_01',
#     url_prover_key='https://github.com/aptos-labs/aptos-keyless-trusted-setup-contributions-may-2024/raw/main/contributions/main_39f9c44b4342ed5e6941fae36cf6c87c52b1e17f_final.zkey',
#     url_main_c='https://github.com/aptos-labs/devnet-groth16-keys/raw/master/main_c_cpp/main_c',
#     url_main_c_dat='https://github.com/aptos-labs/devnet-groth16-keys/raw/master/main_c_cpp/main_c.dat',
#     url_vk='https://github.com/aptos-labs/aptos-keyless-trusted-setup-contributions-may-2024/raw/main/verification_key_39f9c44b4342ed5e6941fae36cf6c87c52b1e17f.json',
#     url_circuit_config='https://raw.githubusercontent.com/aptos-labs/aptos-keyless-trusted-setup-contributions-may-2024/0f2ca4730147c5d4123b9c32a0cf0bd800f36b38/circuit_config.yml'
#     url_generate_witness_js='https://github.com/aptos-labs/devnet-groth16-keys/raw/master/main_js/generate_witness.js',
#     url_main_wasm='https://github.com/aptos-labs/devnet-groth16-keys/raw/master/main_js/main.wasm',
#     url_witness_calculator_js='https://github.com/aptos-labs/devnet-groth16-keys/raw/master/main_js/witness_calculator.js'
# )

utils.force_symlink_dir(f'{res_root}/setup_2024_05', f'{res_root}/default')
utils.force_symlink_dir(f'{res_root}/setup_2024_05', f'{res_root}/new')
