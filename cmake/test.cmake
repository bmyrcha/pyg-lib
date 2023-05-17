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

set(WITH_MKL_BLAS 0)
if(USE_MKL_BLAS AND DEFINED BLAS_INCLUDE_DIR)
  message(WARNING "YAAAAAAAAAAAAAAAAAAAAAAAY!")
  find_file(MKL_INCLUDE_FOUND mkl.h ${BLAS_INCLUDE_DIR} NO_DEFAULT_PATH)
  if(MKL_INCLUDE_FOUND)
    message(WARNING "We found MKL! YAAAAAAAAAAAAAAAAAAAAAAAY v2!")
    message(WARNING "We found MKL: ${MKL_INCLUDE_FOUND}")
    set(WITH_MKL_BLAS 1)
  else()
    if(WITH_COV)
      message(FATAL_ERROR "The mkl.h file was not found - pass the correct directory or set USE_MKL_BLAS=OFF.")
    else()
      message(WARNING "The mkl.h file was not found - building pyg-lib without MKL BLAS support.")
    endif()
  endif()
endif()

foreach(test ${ALL_TESTS})
    get_filename_component(name ${test} NAME_WE)
    add_executable(${name} ${test})
    target_link_libraries(${name} ${PROJECT_NAME} gtest_main torch)
    gtest_discover_tests(${name})
endforeach()
