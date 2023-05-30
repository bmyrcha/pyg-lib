include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/609281088cfefc76f9d0ce82e1ff6c30cc3591e5.zip
)
# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

enable_testing()
include(GoogleTest)

set(CTEST test/csrc)
file(GLOB_RECURSE ALL_TESTS ${CTEST}/*.cpp)

foreach(test ${ALL_TESTS})
    get_filename_component(name ${test} NAME_WE)
    add_executable(${name} ${test})
    target_link_libraries(${name} ${PROJECT_NAME} gtest_main torch ${TORCH_LIBRARIES})
    if(MKL_INCLUDE_FOUND)
      target_include_directories(${PROJECT_NAME} PUBLIC ${BLAS_INCLUDE_DIR})

      get_filename_component(MKL_LIB_DIR ${MKL_LIBRARY} DIRECTORY)
      message(STATUS "Linking directory: ${MKL_LIB_DIR}")
      link_directories(${MKL_LIB_DIR})
      include_directories(${MKL_LIB_DIR})

      add_library(MKL_RANDOM SHARED IMPORTED)
      set_target_properties(MKL_RANDOM PROPERTIES IMPORTED_LOCATION ${MKL_LIBRARY})
      target_link_libraries(${PROJECT_NAME} PUBLIC MKL_RANDOM)
    endif()
    gtest_discover_tests(${name})
endforeach()
