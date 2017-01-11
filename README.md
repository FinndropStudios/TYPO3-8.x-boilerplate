![License MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)

# TYPO3 8.x Boilerplate

This is a TYPO3 8.x boilerplate which will be configured through a step-by-step bash script.

## Features

- Fresh install of blank TYPO3 8.x instance (composer mode, also installs composer locally if not already installed globally)
- Unittesting (extendable)
- Deployment (through webhook)
- ssh keygen (php-script w/o need of root privilegues)

## Default extensions

### "require:"
- [helhum/typo3-console](https://github.com/helhum/typo3_console)
- [dimitryd/typo3-realurl](https://github.com/dmitryd/typo3-realurl)
- [mrohnstock/cookieconsent2](https://github.com/mrohnstock/cookieconsent2)
- [t3monitor/t3monitoring](https://github.com/georgringer/t3monitoring)

### "require-dev:"
- [mask/mask](https://github.com/Gernott/mask)
- [cpsit/mask-export](https://github.com/CPS-IT/TYPO3-mask_export)
- [ninecells/dev-log](https://github.com/ninecells/dev-log)

## How to

Just download and unzip or clone this repository. Open your favourite Terminal and navigate to the boilerplate's folder.

*Optional:* Modify composer.json to fit your needs

Run `./boil.sh firstinstall` to start the configuration of your project. Follow the steps and you're done and you're fresh TYPO3 instance is up and running.

## Feture usage

### ssh keygen

ssh to your server/docker container/... and run `./boil.sh keygen`. 
Follow the instructions on screen.

This feature may be needed when using a webhook (GitHub, Gitlab, ...) for deployment to set up an ssh key for the user which is running php.
This feature creates an ssh  keypair through php, so there's no need to have `sh-keygen` installed on your environment.

## Other commands

- `.boil.sh unittests update` updates unittests
- `.boil.sh unittests run` runs unittests
- `.boil.sh publish [staging|production]` deploys on staging/production environment (just works through webhook)
- `.boil.sh keygen [$homedir]` generates ssh keypair in provided folder

## ToDos

- Add unittesting
- Add deployment
- Testing

## Perfect fit:

This boilerplate integrates perfectly with our [TYPO3 docker boilerplate](https://github.com/FinndropStudios/TYPO3-docker-boilerplate).

## Credits


Thanks for your support, ideas and issues.
- [Helmut Hummel](https://github.com/helhum)
