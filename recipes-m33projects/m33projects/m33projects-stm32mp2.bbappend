# Applied after PHYTEC by layer priority; reuse ST's build/sign/install tasks.
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
PV = "1.3.2"
SRCREV = "7daa1f4efa18bb177c93c06051e6b55b76ccedce"
SRC_URI = "git://github.com/STMicroelectronics/STM32CubeMP2.git;protocol=https;nobranch=1 \
           file://0001-phyFLEX-stm32mp2-M33-blink-example-stm32cubemp2-v1.3.patch \
           file://0002-phyFLEX-stm32mp2-M33-helloworld-example-stm32cubemp2.patch \
           file://0003-phyFLEX-stm32mp2-M33-I2C-Temp-Sensor-example-stm32cu.patch \
           file://0004-phyFLEX-stm32mp2-M33-SPI-loopback-example-stm32cubem.patch \
           file://0005-phyFLEX-stm32mp2-M33-ADC-SOM-current-example-stm32cu.patch \
           file://0006-phyFLEX-stm32mp2-M33-OpenAMP-TTY-echo-example-stm32c.patch \
           file://build-glue \
           file://st-m33firmware-load-default.sh \
           file://st-m33firmware-load.service \
           file://shutdown-stm32mp2-m33.sh \
           file://fw_cortex_m33.sh"
LIC_FILES_CHKSUM = "file://License.md;md5=012a8d78c6f636371ad889eadb15885c"
M33_BOARDS = "STM32MP257F-EV1"
PROJECTS_LIST_M33 = " \
    STM32MP257F-EV1/Examples/GPIO/GPIO_EXTI \
    STM32MP257F-EV1/Examples_LL/USART/USART_Communication_Rx_IT \
    STM32MP257F-EV1/Examples/I2C/I2C_TwoBoards_ComPolling \
    STM32MP257F-EV1/Examples/SPI/SPI_FullDuplex_ComDMA \
    STM32MP257F-EV1/Examples/ADC/ADC_RegularConversion_Polling \
    STM32MP257F-EV1/Applications/OpenAMP/OpenAMP_TTY_echo \
"

# Add project-specific build support to each patched upstream example.
python do_patch:append() {
    import shutil
    from pathlib import Path

    glue = Path(d.getVar("WORKDIR")) / "build-glue"
    projects = Path(d.getVar("S")) / "Projects"
    for project in d.getVar("PROJECTS_LIST_M33").split():
        target = projects / project
        shutil.copytree(glue / "util", target / "util", dirs_exist_ok=True)
        shutil.copyfile(glue / project / "CMakeLists.txt",
                        target / "CMakeLists.txt")
}

do_install:append() {
    mv "${D}${M33_OUTPUT_4USERFS}/STM32MP257F-EV1" \
       "${D}${M33_OUTPUT_4USERFS}/STM32MP257F-PHYFLEX_tloan"
}
