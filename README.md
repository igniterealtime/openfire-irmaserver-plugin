# IRMA Plugin for openfire

I Reveal My Attributes to Openfire

IRMA is the unique platform that makes you digitally self-sovereign and gives you full control over your personal data: with IRMA on your phone you are empowered not only to prove who you are, but also to digitally sign statements. See https://privacybydesign.foundation/en/

This plugin does the following:

* Embeds [irmago](https://github.com/privacybydesign/irmago) the IRMA server, client, and tooling component
* Exposes its web service from an openfire using a reverse proxy. Endpoint by default is https://your_server:7443/irmaproxy
* Provides an Admin UI to configure all irmago settings
* Controls the irmago binary process, starting and stopping the Linux/Windows image.
