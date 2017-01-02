<?php
include('../../libs/phpseclib/Crypt/RSA.php');

$path = $argv[1];

$rsa = new Crypt_RSA();
$rsa->setPublicKeyFormat(CRYPT_RSA_MODE_OPENSSL);
$rsa->setPrivateKeyFormat(CRYPT_RSA_PRIVATE_FORMAT_PKCS1);

$pair = $rsa->createKey(4096);

if (file_exists($path . 'id_rsa.pub')) {
    return;
}

file_put_contents($path . '/id_rsa', $pair['privatekey']);
file_put_contents($path . '/id_rsa.pub', $pair['publickey']);

chmod($path . ' . /id_rsa', 0600);
chmod($path . '/id_rsa.pub', 0600);
?>