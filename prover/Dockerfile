# syntax=docker/dockerfile:1.7

FROM rust:1-bookworm as build_prover_service
ARG TARGETARCH


RUN apt-get update \
    && apt-get install -y gcc clang cmake make libyaml-dev nasm libgmp-dev libomp-dev

COPY --link . .

# Build gmp separately so that docker will cache this step
RUN cargo build --release -p prover-service && \
    cp target/release/prover-service /prover-service-bin

FROM debian:12.4

RUN apt-get update \
    && apt-get install -y libgmp-dev libsodium-dev libomp-dev curl 

# copy prover server
COPY --link --from=build_prover_service ./prover-service-bin ./prover-service-bin
COPY --link --from=build_prover_service ./prover/rust-rapidsnark/rapidsnark/package ./rapidsnark-package


ARG TRUSTLESS_REPO_GIT_SHA=ae684b376059c791ded97d89c3ca114edc1cb44c
ARG GROTH16_KEYS_REPO_GIT_SHA=6625c811aed782067875cf7998c143f8db17324e

RUN mkdir -p /resources/setup_2024_05 \
    && curl --location -o /resources/setup_2024_05/prover_key.zkey https://github.com/aptos-labs/aptos-keyless-trusted-setup-contributions-may-2024/raw/main/contributions/main_39f9c44b4342ed5e6941fae36cf6c87c52b1e17f_final.zkey \
    && curl --location -o /resources/setup_2024_05/main_c https://github.com/aptos-labs/devnet-groth16-keys/raw/master/main_c_cpp/main_c \
    && curl --location -o /resources/setup_2024_05/main_c.dat https://github.com/aptos-labs/devnet-groth16-keys/raw/master/main_c_cpp/main_c.dat \
    && curl --location -o /resources/setup_2024_05/verification_key.json https://github.com/aptos-labs/aptos-keyless-trusted-setup-contributions-may-2024/raw/main/verification_key_39f9c44b4342ed5e6941fae36cf6c87c52b1e17f.vkey \
    && curl --location -o /resources/setup_2024_05/circuit_config.yml https://github.com/aptos-labs/devnet-groth16-keys/raw/master/circuit_config.yml \
    #    && mkdir -p /resources/setup_2024_02 \
#    && curl --location -o /resources/setup_2024_02/prover_key.zkey https://github.com/aptos-labs/aptos-keyless-trusted-setup-contributions-may-2024/raw/main/contributions/main_39f9c44b4342ed5e6941fae36cf6c87c52b1e17f_final.zkey \
#    && curl --location -o /resources/setup_2024_02/main_c https://github.com/aptos-labs/devnet-groth16-keys/raw/master/main_c_cpp/main_c \
#    && curl --location -o /resources/setup_2024_02/main_c.dat https://github.com/aptos-labs/devnet-groth16-keys/raw/master/main_c_cpp/main_c.dat \
#    && curl --location -o /resources/setup_2024_02/verification_key.json https://github.com/aptos-labs/aptos-keyless-trusted-setup-contributions-may-2024/raw/main/verification_key_39f9c44b4342ed5e6941fae36cf6c87c52b1e17f.vkey \
#    && curl --location -o /resources/setup_2024_02/circuit_config.yml https://github.com/aptos-labs/devnet-groth16-keys/raw/master/circuit_config.yml \
    && echo "Resources ready."

RUN chmod u+x /resources/setup_2024_05/main_c
#RUN chmod u+x /resources/setup_2024_02/main_c


COPY --link ./prover/config.yml ./config.yml

EXPOSE 8080

# Add Tini to make sure the binaries receive proper SIGTERM signals when Docker is shut down
ADD --chmod=755 https://github.com/krallin/tini/releases/download/v0.19.0/tini-amd64 /tini
ENTRYPOINT ["/tini", "--"]

ENV LD_LIBRARY_PATH="./rapidsnark-package/lib"
CMD ["./prover-service-bin"]
