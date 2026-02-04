#!/usr/bin/env bash
nixos-install \
  --option extra-substituters "https://iglu.holypenguin.net/default https://nix-community.cachix.org" \
  --option extra-trusted-public-keys "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= default:xZJwKM6k5SCrviOA50/5RKldgPHRPkOrv/uziJVAm2U=" "$@"
