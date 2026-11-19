FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:stm32mp25x-phyflex-libra-rdk-3 = " \
    file://0001-stm32mp2-phyflex-libra-rdk-improve-m33-overlay.patch \
"
