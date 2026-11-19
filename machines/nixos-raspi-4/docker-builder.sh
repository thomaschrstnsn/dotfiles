#!/bin/sh
# Entrypoint for the `raspi-builder` container (see `just raspi-builder-up`).
# Turns a stock nixos/nix container into an ssh-reachable aarch64-linux Nix
# store that nh can use as `--build-host`. State that should survive container
# re-creation (openssh, host key) lives on the /nix volume.
set -eu

: "${AUTHORIZED_KEYS:?AUTHORIZED_KEYS must contain the ssh public keys allowed to log in}"

state=/nix/var/raspi-builder
mkdir -p "$state"

if ! grep -q thomaschrstnsn /etc/nix/nix.conf; then
	printf '%s\n' \
		"experimental-features = nix-command flakes" \
		"extra-substituters = https://nix-community.cachix.org https://thomaschrstnsn.cachix.org" \
		"extra-trusted-public-keys = nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= thomaschrstnsn.cachix.org-1:jPfgdkADpT48y0uP/E3fPKCJuHHDe/JpRJrfyEYdxPA=" \
		"max-jobs = auto" \
		>>/etc/nix/nix.conf
fi

# The out-link doubles as a GC root, so openssh survives `nix store gc`.
if [ ! -x "$state/openssh/bin/sshd" ]; then
	nix build --out-link "$state/openssh" nixpkgs#openssh
fi

grep -q '^sshd:' /etc/passwd || echo 'sshd:x:74:74:sshd privsep:/var/empty:/bin/false' >>/etc/passwd
grep -q '^sshd:' /etc/group || echo 'sshd:x:74:' >>/etc/group
# root ships locked ('!'), which sshd refuses even for pubkey auth; '*' = no password, not locked
if grep -q '^root:!' /etc/shadow; then
	{
		grep -v '^root:' /etc/shadow
		echo 'root:*:1::::::'
	} >/etc/shadow.new
	mv /etc/shadow.new /etc/shadow
fi
mkdir -p /var/empty /root/.ssh
chmod 700 /root/.ssh
printf '%s\n' "$AUTHORIZED_KEYS" >/root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

if [ ! -f "$state/ssh_host_ed25519_key" ]; then
	"$state/openssh/bin/ssh-keygen" -q -t ed25519 -N "" -f "$state/ssh_host_ed25519_key"
fi

profile=/nix/var/nix/profiles/default
cat >"$state/sshd_config" <<EOF
Port 22
HostKey $state/ssh_host_ed25519_key
PermitRootLogin prohibit-password
PasswordAuthentication no
KbdInteractiveAuthentication no
PidFile none
# Long silent builds otherwise let docker's port-forwarder drop the idle TCP
# connection, leaving nh waiting forever for the remote \`nix build\` to exit.
ClientAliveInterval 15
# ssh sessions don't inherit the image's ENV; nix must be on PATH for
# \`nix-daemon --stdio\` (ssh-ng://) and nh's remote \`nix build\`.
SetEnv PATH=/root/.nix-profile/bin:$profile/bin:$profile/sbin NIX_SSL_CERT_FILE=$profile/etc/ssl/certs/ca-bundle.crt SSL_CERT_FILE=$profile/etc/ssl/certs/ca-bundle.crt
EOF

echo "raspi-builder: sshd listening"
exec "$state/openssh/bin/sshd" -D -e -f "$state/sshd_config"
