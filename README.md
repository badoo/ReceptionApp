### About

We use `ReceptionApp` internally for tracking visitors in our office. 
It allows easy sign-in and sign-out functionality with additional following features:

* Visitors are required to input personal information, like name, company, employee they came to see.
* Visitors are required to sign "*Visitor agreement*" (creating a signature with a fingure). *Pdf with agreement, visitor name and signature will be generated later in the process*.
* This data is sent to receptionist's email.
* Badge is printed via AirPrint.
* List of employees is fetched from URL, images are supported too.
* Report of currently signed-in visitor can be generated.
* Each morning automatic report is generated stating visitors who signed-in yesterday but haven't signed-out.

## How to configure

1. Fork the repo and run `pod install`
2. Change the link to the list of employees (in `BRASettingsManager`). An example json can be found in `SampleEmployeeFile.json`
3. Once installed on device go to **settings** (*double tap on the logo on top of the screen*)
	3.1. Change pin code from default `0000`. 
	3.2. Specify email accounts (one to receive info about visitors, and one for the iPad itself).
	3.3. Choose printer.

#### You also might want to change

* Logo image
* Visitor agreement


### License
Source code is distributed under MIT license.