cmake_minimum_required(VERSION 3.4.1)

include_directories(
    opencv/include
)

add_library(lib_opencv SHARED IMPORTED)

set_target_properties(lib_opencv PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/libopencv_java4.so)

add_library(
    camera_detection 
    SHARED 
    ../ios/Classes/camera_detection.cpp
)
target_link_libraries(camera_detection lib_opencv)