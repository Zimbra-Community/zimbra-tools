<?php

require_once('/var/www/simplesaml/lib/_autoload.php');

$as = new SimpleSAML_Auth_Simple('default-sp');
$as->requireAuth();

if($as->isAuthenticated()) {
    $attributes = $as->getAttributes();
    $email = $attributes['mail'][0];
    preauth($email);
}
else {
    header("Location: URL TO YOUR LOGIN PAGE HERE");
}

function hmac_sha1($key, $data)
{
    // Adjust key to exactly 64 bytes
    if (strlen($key) > 64) {
        $key = str_pad(sha1($key, true), 64, chr(0));
    }
    if (strlen($key) < 64) {
        $key = str_pad($key, 64, chr(0));
    }

    // Outter and Inner pad
    $opad = str_repeat(chr(0x5C), 64);
    $ipad = str_repeat(chr(0x36), 64);

    // Xor key with opad & ipad
    for ($i = 0; $i < strlen($key); $i++) {
        $opad[$i] = $opad[$i] ^ $key[$i];
        $ipad[$i] = $ipad[$i] ^ $key[$i];
    }

    return sha1($opad.sha1($ipad.$data, true));
}

function preauth($email)
{
   header("Cache-Control: no-cache, must-revalidate"); // HTTP/1.1
   header("Expires: Sat, 26 Jul 1997 05:00:00 GMT"); // Date in the past

   $domain = "https://zimbra.example.com";
   $preAuthKey = "PUT YOUR PREAUTH KEY HERE";

   $time = round(microtime(true) * 1000);
   $input_xml='<?xml version="1.0" encoding="utf-8"?>' .
                '<soapenv:Envelope ' .
                    'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' .
                    'xmlns:api="http://127.0.0.1/Integrics/Enswitch/API" ' .
                    'xmlns:xsd="http://www.w3.org/2001/XMLSchema" ' .
                    'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' .
                    '<soapenv:Body>' .
                    '<AuthRequest xmlns="urn:zimbraAccount">' .
                    '<account>'.$email.'</account>' .
                    '<preauth timestamp="'.$time.'" expires="0">'.hmac_sha1($preAuthKey,$email.'|name|0|'.$time).'</preauth>' .
                    '</AuthRequest>' .
                    '</soapenv:Body>' .
                '</soapenv:Envelope>';

       //setting the curl parameters.
        $ch = curl_init();
        $ip = $_SERVER['REMOTE_ADDR'];
        curl_setopt($ch, CURLOPT_URL, $domain."/service/soap/preauth");
        curl_setopt($ch, CURLOPT_POSTFIELDS, $input_xml);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 300);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_HTTPHEADER, array("X-Forwarded-For: $ip"));
        $data = curl_exec($ch);
        curl_close($ch);

        $token = preg_match("/<authToken>.*?<\/authToken>/",$data,$matches);

        if(token)
        {
           if($matches[0])
           {
              $matches[0] = substr($matches[0], 11);//remove <authToken>
              $matches[0] = substr($matches[0], 0, strlen($matches[0])-12);//remove </authToken>
              header ("Location: ".$domain."/service/preauth?authtoken=$matches[0]");
           }
           else
           {
              header ("Location: ".$domain);
           }
        }
        else
        {
           header ("Location: ".$domain);
        }
}

?>
