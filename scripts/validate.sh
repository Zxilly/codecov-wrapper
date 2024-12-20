#!/usr/bin/env bash

if [ "$CODECOV_SKIP_VALIDATION" = "true" ] || [ -n "$CODECOV_BINARY" ];
then
  say "$r==>$x Bypassing validation as requested by user"
else
  . ./set_validation_key.sh
  echo "${CODECOV_PUBLIC_PGP_KEY}"  | \
    gpg --no-default-keyring --import
  # One-time step
  say "$g==>$x Verifying GPG signature integrity"
  sha_url="https://cli.codecov.io"
  sha_url="${sha_url}/${codecov_version}/${codecov_os}"
  sha_url="${sha_url}/${codecov_filename}.SHA256SUM"
  say "$g ->$x Downloading $b${sha_url}$x"
  say "$g ->$x Downloading $b${sha_url}.sig$x"
  say " "

  curl -Os --retry 5 --retry-delay 2 --connect-timeout 2 "$sha_url"
  curl -Os --retry 5 --retry-delay 2 --connect-timeout 2 "${sha_url}.sig"

  if ! gpg --verify "${codecov_filename}.SHA256SUM.sig" "${codecov_filename}.SHA256SUM";
  then
    exit_if_error "Could not verify signature. Please contact Codecov if problem continues"
  fi

  if ! (shasum -a 256 -c "${codecov_filename}.SHA256SUM" || \
    sha256sum -c "${codecov_filename}.SHA256SUM");
  then
    exit_if_error "Could not verify SHASUM. Please contact Codecov if problem continues"
  fi
  say "$g==>$x CLI integrity verified"
  say
fi
