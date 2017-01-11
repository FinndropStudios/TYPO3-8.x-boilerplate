<?php
$user = $argv[1];

$rsaKey = openssl_pkey_new(array(
              'private_key_bits' => 1024,
              'private_key_type' => OPENSSL_KEYTYPE_RSA));

$privKey = openssl_pkey_get_private($rsaKey);
openssl_pkey_export($privKey, $pem);
$pubKey = sshEncodePublicKey($rsaKey);

$umask = umask(0066);

if(!is_dir('ssh-keys/' . $user)) {
  shell_exec('mkdir -p ssh-keys/' . $user . '/.ssh');
  shell_exec('echo -e "' . $pem . '" >> ssh-keys/' . $user . '/.ssh/id_rsa');
  shell_exec('echo -e "' . $pubKey . '" >> ssh-keys/' . $user . '/.ssh/id_rsa.pub');
  //print "Private Key:\n $pem \n\n";
  $output = "ssh key generated\n\n";
  $keyexists = false;
} else {
  $output = "ssh key for user '" . $user . "' already exists.\n\n";
  $keyexists = true;
}

$output .= "copy the directory '.ssh' from '/app/ssh-keys/$user/' to the users home directory\n\n";
$output .= "Use this key for deployment (set it in GitHub, GitLab, ...):\n\n";
echo $output;

function sshEncodePublicKey($privKey) {
    $keyInfo = openssl_pkey_get_details($privKey);
    $buffer  = pack("N", 7) . "ssh-rsa" .
    sshEncodeBuffer($keyInfo['rsa']['e']) .
    sshEncodeBuffer($keyInfo['rsa']['n']);
    return "ssh-rsa " . base64_encode($buffer);
}

function sshEncodeBuffer($buffer) {
    $len = strlen($buffer);
    if (ord($buffer[0]) & 0x80) {
        $len++;
        $buffer = "\x00" . $buffer;
    }
    return pack("Na*", $len, $buffer);
}
