# YubiKey onboarding

Each YubiKey carries two things this repo relies on:

- A resident FIDO2 SSH credential, recorded in `home/ssh.nix` as `dotfiles.yubikey.keys.<name>.sshKey`.
- An age identity in PIV slot 1, listed in `.sops.yaml` as a backup recipient for every secret.

The OpenPGP applet stays empty.
Commits are signed with each machine's `id_ed25519`, not a YubiKey (see `modules/git/signing.nix`).

## Prerequisites

- `pcscd` and the YubiKey udev rules, from the system layer (the nixos repo on hades, distribution packages elsewhere).
- `dotfiles.yubikey.enable` and `dotfiles.sops.enable`, which install `ykman` and `age-plugin-yubikey`.
- A real terminal. `age-plugin-yubikey` fails with "not a terminal" when it cannot prompt.
- With more than one key plugged in, pass `--device <serial>` to `ykman`, `--serial <serial>` to `age-plugin-yubikey`, and `-O device=/dev/hidrawN` to `ssh-keygen` (`fido2-token -L` lists the devices).

## New key

1. Set the FIDO2 PIN, which resident credentials require:
   `ykman --device <serial> fido access change-pin`
2. Create the SSH credential. The application name fixes the handle file name the ssh config expects:
   `ssh-keygen -t ed25519-sk -O resident -O application=ssh:<name> -C erik@yubikey-<name> -f ~/.ssh/id_ed25519_sk_rk_<name>`
   Add the `.pub` contents to `home/ssh.nix`, and to GitHub as an authentication key.
3. Replace the PIV defaults (PIN `123456`, PUK `12345678`, and the management key):
   `ykman --device <serial> piv access change-pin`
   `ykman --device <serial> piv access change-puk`
   `ykman --device <serial> piv access change-management-key -a TDES --generate --protect`
   The management key must be TDES: age-plugin-yubikey 0.5.1 cannot authenticate with an AES one, and firmware 5.7 defaults to AES.
4. Create the age identity:
   `age-plugin-yubikey --generate --serial <serial> --slot 1 --name age-<name> --pin-policy once --touch-policy cached >> ~/.config/sops/age/yubikey.txt`
   Add the printed `age1yubikey1…` recipient to `.sops.yaml`, then run `sops updatekeys home/secrets/*.yaml`.
5. Register the key for WebAuthn wherever the other keys are, and enroll TOTP accounts in Yubico Authenticator one service at a time, since OATH secrets cannot be copied between keys.

An existing key that already has a FIDO2 PIN skips step 1, and step 2 leaves its other FIDO credentials untouched.

## New machine

- `cd ~/.ssh && ssh-keygen -K` writes each key's handle as `id_ed25519_sk_rk_<name>`, the file the ssh config offers.
- `age-plugin-yubikey --identity` prints the identity lines for `~/.config/sops/age/yubikey.txt`.

## Recovery

With a machine's software age key gone, any YubiKey decrypts the secrets:

`SOPS_AGE_KEY_FILE=~/.config/sops/age/yubikey.txt sops -d home/secrets/<file>.yaml`

sops also reads the default `~/.config/sops/age/keys.txt` whatever `SOPS_AGE_KEY_FILE` says, so on a machine that still has its software key, that key decrypts first and the YubiKey is never asked.
To test the YubiKey path there, hide the default: prefix the command with `XDG_CONFIG_HOME=$(mktemp -d)`.

`yubikey.txt` stays separate from `keys.txt`, because sops-nix reads `keys.txt` unattended at activation and a YubiKey identity would stall it waiting for a PIN.

## Troubleshooting

- `ykman … piv` reports "Failed connecting" and the pcscd log shows `LIBUSB_ERROR_ACCESS`: the key was plugged in before the udev rules existed. Re-plug it, or run `sudo udevadm trigger --action=add --subsystem-match=usb --attr-match=idVendor=1050`.
- The pcscd log shows `LIBUSB_ERROR_BUSY`: an `scdaemon` started before `pcsc-shared` was configured holds the key over its internal CCID driver. Run `gpgconf --kill scdaemon`, then trigger udev as above.
