# Sourced by the rootfs builders' privileged container — not executed on its own.
#
# Optionally enables the SSH daemon and installs an authorized key, so a developer
# can `ssh root@localhost -p <port>` into an emulated guest instead of driving it
# over the serial console. Deliberately opt-in: the firmware ships sshd but leaves
# it disabled (and its default config is cert-authority-only), and an emulation
# image with a blanked root password plus an always-on sshd is a foot-gun if the
# image is ever shared. Callers invoke install_ssh only when SSH was asked for.
#
#   install_ssh <rootfs mount point>
#
# The key is read from $SSH_AUTHORIZED_KEYS, one OpenSSH public key per line. When
# it is empty, sshd is enabled with no authorized_keys — which on this image (root
# password blanked, see blank_root_password.sh) still leaves key-only login as the
# only way in, i.e. no way in until the operator adds a key by hand.
install_ssh() {
    _rootfs="${1:-/mnt/rootfs}"

    echo "--- enabling sshd for SSH login ---"
    mkdir -p "$_rootfs/etc/systemd/system/multi-user.target.wants"
    ln -sf /usr/lib/systemd/system/sshd.service \
        "$_rootfs/etc/systemd/system/multi-user.target.wants/sshd.service"

    if [ -n "${SSH_AUTHORIZED_KEYS:-}" ]; then
        echo "--- installing authorized SSH key ---"
        mkdir -p "$_rootfs/root/.ssh"
        printf '%s\n' "$SSH_AUTHORIZED_KEYS" > "$_rootfs/root/.ssh/authorized_keys"
        chmod 700 "$_rootfs/root/.ssh"
        chmod 600 "$_rootfs/root/.ssh/authorized_keys"
    fi
}
