# Shared build settings for the non-secure STM32CubeMP2 firmware examples.
set(BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/")
include("${BASE_DIR}/util/cortex-m33-stm32mp2.cmake")

set(cube "${BASE_DIR}/../../../../..")
set(cmsis "${cube}/Drivers/CMSIS/Device/ST/STM32MP2xx")
set(hal "${cube}/Drivers/STM32MP2xx_HAL_Driver")
set(bsp "${cube}/Drivers/BSP/STM32MP257F-EV1")
set(utilities "${cube}/Utilities")
set(scmi "${cube}/Middlewares/ST/scmiagent")
set(openamp "${cube}/Middlewares/Third_Party/OpenAMP")
set(m33_device STM32MP257Fxx)

function(add_m33_firmware)
    set(target "${PROJECT_NAME}.elf")
    add_executable("${target}" ${ARGN})
    set_property(TARGET "${target}" APPEND PROPERTY LINK_DEPENDS "${LINKER_SCRIPT}")

    target_include_directories("${target}" PRIVATE
        "${cmsis}/Include" "${cube}/Drivers/CMSIS/Core/Include"
        "${hal}/Inc" "${hal}/Inc/Legacy" "${bsp}"
        "${utilities}/CoproSync" "${utilities}/ResourcesManager"
    )
    target_compile_definitions("${target}" PRIVATE
        CORE_CM33 STM32MP25xxxx ${m33_device}
        USE_STM32MP257F_EV1 STM32MP257F_EV1 STM32MP257FAIx STM32MP25xx_EVAL
    )
    separate_arguments(compile_flags NATIVE_COMMAND "${COMMON_COMPILE_FLAGS}")
    target_compile_options("${target}" PRIVATE ${compile_flags} ${WARNING_FLAGS}
        -fdata-sections
    )
    target_link_options("${target}" PRIVATE
        ${compile_flags} "-T${LINKER_SCRIPT}"
        "-Wl,-Map=${PROJECT_NAME}.map,--gc-sections,-z,max-page-size=4096" -static
    )
    add_custom_command(TARGET "${target}" POST_BUILD
        COMMAND "${CMAKE_OBJCOPY}" -Oihex "$<TARGET_FILE:${target}>" "${PROJECT_NAME}.hex"
        COMMAND "${CMAKE_OBJCOPY}" -Obinary "$<TARGET_FILE:${target}>" "${PROJECT_NAME}.bin"
        COMMAND "${CMAKE_SIZE_UTIL}" --format=berkeley "$<TARGET_FILE:${target}>"
        COMMAND "${CMAKE_OBJCOPY}" -S "$<TARGET_FILE:${target}>" "${PROJECT_NAME}_stripped.elf"
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        VERBATIM
    )
endfunction()
