cmake_minimum_required(VERSION 3.14)
project(singbox_plugin LANGUAGES CXX)

# Define the plugin library.
add_library(singbox_plugin SHARED singbox_plugin.cpp)

# Apply standard settings.
APPLY_STANDARD_SETTINGS(singbox_plugin)

# Link against Flutter's Windows plugin registry.
target_link_libraries(singbox_plugin PRIVATE flutter_windows_plugin_registry)

# Install the plugin library next to the executable.
install(TARGETS singbox_plugin DESTINATION "${INSTALL_BUNDLE_LIB_DIR}" COMPONENT Runtime)
