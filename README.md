# meta-phyflex-stm32mp2-m33

[![Platforms](https://img.shields.io/badge/Platform-phyFLEX--STM32MP25x-teal)](https://www.phytec.com/product/phyflex-stm32mp25x/)

STM32CubeMP2 Cortex-M33 examples ported to the phyFLEX-STM32MP25x Development Kit. 

With the phyFLEX-STM32MP25x Cortex-A35 cluster running Linux, the firmware introduced by this Yocto meta layer runs on the Cortex-M33 co-processor in parallel. This is a reference for off-loading critical, real-time tasks from Linux to the on-chip MCU and how the two cores can exchange messages.

* Verified with the following HW revisions:

  * 1633.1 SOM
  * 1618.2 Libra CB

* Requires the following additional hardware in order to evaluate all examples:

  * 6x M-M Jumper Cables
  * Push Button
  * LED and current-limiting series resistor (~100 Ohm)
  * Bread Board for circuit prototyping

This was tested with BSP-Yocto-OpenSTLinux-STM32MP2-PD26.2.0 and was based on STM32CubeMP2 v1.3.2.

>[!NOTE]
> **The Cortex-M33 firmware introduced by this meta layer cannot be used while a PEB-AV-10 device tree overlay is enabled at the same time (these are disabled by default in BSP-Yocto-OpenSTLinux-STM32MP2-PD26.2.0) due to pin resource conflicts**

## BSP Integration

Navigate to your BSP's sources directory:

```sh
cd $BUILDDIR/../layers/
```

Clone this repo and branch:

```sh
git clone https://github.com/tloanPhytec/meta-phyflex-stm32mp2-m33.git -b scarthgap
```

Add the layers to the PHYTEC BSP:

```sh
cd $BUILDDIR
bitbake-layers add-layer $BUILDDIR/../layers/meta-phyflex-stm32mp2-m33/
```
Rebuild the phyFLEX-STM32MP25x Development Kit image:

```sh
DISTRO=openstlinux-weston MACHINE=stm32mp25x-phyflex-libra-rdk-3 bitbake st-image-core
```

Prepare a bootable SD Card for your phyFLEX-STM32MP25x Development Kit with the resulting image.

### Cortex-M33 in Production

For MACHINE=stm32mp25x-phyflex-libra-rdk-3, add the following to your BSP's conf/local.conf before building the image:

```bitbake
M33_PRODUCTION_ENABLE = "1"
```

This enables the M33 device tree overlay in the default boot environment and selects GPIO_EXTI as the default firmware loaded by `st-m33firmware-load.service`. With M33_PRODUCTION_ENABLE set, no manual overlay activation or reboot is required on the first boot, and your M33 firmware starts automatically without user interaction.

## Hardware Hookup

### LED and Button Hookup

On the X50 Connector (located on the top-side of the 1618.2 phyFLEX Carrier Board), you must:

* wire a Push Button between pins 14 and 16
* wire the LED and series resistor between pins 18 and 26

  <img width="986" height="1051" alt="STM32MP2-blink-wire-diagram" src="https://github.com/user-attachments/assets/f5f920d9-d483-4086-8b9f-5ad97bf6d16b" />

### SPI Hookup

On the X115 Connector (located on the bottom-side of the 1618.2 phyFLEX Carrier Board), you must:

* use 2x jumper cables and a breadboard to short pins 7 and 8 (the breadboard will allow you to open and close the MISO/MOSI short easily while the development kit is right-side up).

  <img width="1046" height="999" alt="SPI" src="https://github.com/user-attachments/assets/752c1bc2-7aef-48fd-8eb9-3fbaa14bba1e" />

### UART5 Output

The USART, I2C, SPI, ADC, and OpenAMP examples all print something to UART5. In order to access this, open a serial terminal configured for 115200 baud, 8n1 data with no flow control using the 2nd COM/serial port exposed by the Development Kit's X14 USB Debug port alongside your Linux shell (which is accessed on the 1st COM/serial port). 

## Verification

### Configure Software on First Boot

Prior to running the Cortex-M33 firmware introduced by this meta layer, we must instruct the kernel to disable the various peripheral interfaces they use in order to avoid resouce conflicts (those peripherals are allocated for Linux in the default BSP-Yocto-OpenSTLinux-STM32MP2-PD26.2.0 pre-built images).

This meta layer introduces a new device tree overlay that accomplishes just that (/boot/stm32mp2-phyflex-libra-rdk-m33-examples.dtbo, but technically the loaded into memory is built into the kernel fitImage), we just need to enable it on the first boot and then reboot:

```sh
echo "$(cat /boot/overlays.txt)#conf-stm32mp2-phyflex-libra-rdk-m33-examples.dtbo" > /boot/overlays.txt
reboot
```

### Using the Cortex-M33 Examples

The installed examples are under `/usr/local/Cube-M33-examples/STM32MP257F-PHYFLEX_tloan/`.

| Example | Directory relative to the install root |
| --- | --- |
| GPIO Blink | `Examples/GPIO/GPIO_EXTI` |
| USART Hello World | `Examples_LL/USART/USART_Communication_Rx_IT` |
| I2C Temperature Sensor | `Examples/I2C/I2C_TwoBoards_ComPolling` |
| SPI Loopback | `Examples/SPI/SPI_FullDuplex_ComDMA` |
| ADC SOM Current | `Examples/ADC/ADC_RegularConversion_Polling` |
| OpenAMP TTY Echo | `Applications/OpenAMP/OpenAMP_TTY_echo` |

Navigate to the directory for the example you want to run and use included fw_cortex_m33.sh script to start and stop it.

For USART Hello World, use the following commands.

```sh
cd /usr/local/Cube-M33-examples/STM32MP257F-PHYFLEX_tloan/Examples_LL/USART/USART_Communication_Rx_IT
```

Start the Cortex-M33 example:

```sh
./fw_cortex_m33.sh start
```

Stop the Cortex-M33 example:

```sh
./fw_cortex_m33.sh stop
```

| Example | Usage Instruction |
| --- | --- |
| GPIO Blink | Press the push button in order to toggle the blinking LED on and off. |
| USART Hello World | Prints "Hello World" continuously to UART5. Button presses toggle this on and off. |
| I2C Temperature Sensor | Prints the temperature seen by the development kit's on-board I2C temp sensor to UART5. |
| SPI Loopback | Button presses initiate a SPI Loopback. With MOSI/MISO shorted it will pass, the loopback fails when the connection is open. The Tx and Rx data is printed to UART5. |
| ADC SOM Current | The current consumption of the SOM is printed continuously to UART5. |

For OpenAMP TTY Echo, start the firmware and then look for the two RPMsg TTY devices in Linux. Both channels will become available as `/dev/ttyRPMSG0` and `/dev/ttyRPMSG1`. 

Using your Linux console, configure the virtual serial devices and 'cat' their outputs in the background:

```sh
stty -onlcr -echo -F /dev/ttyRPMSG0
cat /dev/ttyRPMSG0 &
stty -onlcr -echo -F /dev/ttyRPMSG1
cat /dev/ttyRPMSG1 &
```

Then you can initiate transfers from Linux to the Cortex-M33 using the two RPMsg channels like so:

```sh
echo "Hello Virtual UART0" >/dev/ttyRPMSG0
echo "Hello Virtual UART1" >/dev/ttyRPMSG1
```

The Cortex-M33 will echo back these messages with a message prefix attached.

## Verbose Description

This meta-phyflex-stm32mp2-m33 Yocto Meta Layer serves to improve the STM32CubeMP2 evaluation experience using the default BSP-Yocto-OpenSTLinux-STM32MP2-PD26.2.0 release. The default STM32CubeMP2 examples included in the BSP work but there are a couple quality-of-life issues for developers using it as a basis for development:

* the default GPIO_EXTI example configures the Cortex-M33's input interrupt GPIO on a Fan Connector (X68) pin, thus it's not very safe or convenient to access and pull low.
* the default GPIO_EXTI example lacked debounce logic, where one button press could look like nothing happened due to the bounce in the contact (when two button presses occur very quickly, the second one can cancel the first).
* the default GPIO_EXTI example comes from [PHYTEC's fork of STM32CubeMP2](https://github.com/phytec/STM32CubeMP2/tree/v1.2.0-phy). It lags ST's upstream development and does not port a majority of interface examples (WIP). Most developers will probably want to start from ST's latest examples since there are more examples available to help address more use cases.
* The only other STM32CubeMP2 example included in the default BSP was OpenAMP TTY Echo.

This meta layer improves and expands on those default examples in the following ways (this is a high-level summary, for a more in-depth overview see the commit messages within the m33projects-stm32mp2 series patches introduced by the layer):

* Pin muxing was adjusted to make evaluation as easy as possible using a single phyFLEx-STM32MP257 Development Kit.
* Additional Peripheral Examples were ported.
* Button debounce magic was added to avoid multiple button presses from being triggered too quickly.

    * The LED behavior was changed in some examples from toggling solid-on/solid-off to blinking/solid-off (for some pizazz).
 
* The upstream source for the examples was changed from PHYTEC's fork to the [upstream STM32CubeMP2](https://github.com/STMicroelectronics/STM32CubeMP2) (tag=v1.3.2) repository (that is no longer the latest but it was when this development began).
 
    * The patches introduced by this layer's .bbappend along with a side-by-side comparison of the PHYTEC phyFLEX Development Kit and ST STM32MP257-EV1 kit schematics helps clarify how the examples, and by extension others intended for the STM32MP257-EV1 kit can be modified in order to work on PHYTEC's phyFLEX-STM32MP25x Development Kit (in order to account for Soc implementation/pin muxing differences of the two platforms).
