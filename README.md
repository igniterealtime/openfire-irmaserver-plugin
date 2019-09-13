# IRMA Plugin for openfire

I Reveal My Attributes to Openfire

IRMA is the unique platform that makes you digitally self-sovereign and gives you full control over your personal data: with IRMA on your phone you are empowered not only to prove who you are, but also to digitally sign statements. See https://privacybydesign.foundation/en/

This plugin does the following:

* Embeds [irmago](https://github.com/privacybydesign/irmago) the IRMA server, client, and tooling component
* Exposes irmago web services from openfire using a reverse proxy. Endpoint by default is https://your_server:7443/irmaproxy
* Provides an Admin UI to configure irmago settings
* Controls the irmago binary process, starting and stopping the Linux/Windows image.

## How to use

Include [irmajs](https://github.com/privacybydesign/irmajs) in your web app and do something like this to request a web site visitor to reveal their verified mobile phone number as IRMA attribute

```
const request = {
  '@context': 'https://irma.app/ld/request/disclosure/v2',
  'disclose': [
    [
      [ 'pbdf.pbdf.mobilenumber.mobilenumber' ]
    ]
  ]
};

irma.startSession("https://your_server:7443/irmaproxy", request)
    .then(({ sessionPtr, token }) => irma.handleSession(sessionPtr, {server, token}))
    .then(result => console.log('Done', result));
```

## TODO
Enable admin UI to edit all the irmago server config settings.
