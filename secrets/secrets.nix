let
  users = {
    thomas-aeris = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIwHKfy+m8BxICqHHHcb41qWNW2W3alE3IraN/x2trQ/";
    thomas-vmnix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIChIstt+wnL5q7qyKew4mv0SjXU1uIJnVuX7DYT0k68Q";
    pi-nixos-raspi-4 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXwM4Si8bEmqpf5yDoxJD+FQ79nec21CklOje+wpq7W";
  };
  allUsers = with users; [ thomas-aeris thomas-vmnix pi-nixos-raspi-4 ];
  hosts = {
    nixos-raspi-4 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHL8ixWZ6e1vM0A2xSWd1YznNURGQSt8ldkFbKETkze";
    vmnix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUIlQwnknblWraRilViFp/yGnleN38aqK1aP8v75jHh";
  };
  allHosts = with hosts; [ nixos-raspi-4 vmnix ];
in
{
  "nixos-raspi-4.cloudflare.json.age".publicKeys = allUsers ++ [ hosts.nixos-raspi-4 ];
}
