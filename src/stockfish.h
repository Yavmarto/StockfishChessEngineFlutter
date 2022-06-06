#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#if _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

// A very short-lived native function.
//
// Initialisation of Stockfish.
extern "C" __attribute__((visibility("default"))) __attribute__((used))
FFI_PLUGIN_EXPORT int stockfish_init();

// A longer lived native function, which occupies the thread calling it.
//
// Stockfish main loop.
extern "C" __attribute__((visibility("default"))) __attribute__((used))
FFI_PLUGIN_EXPORT int stockfish_main();

// A very short-lived native function.
//
// Writing to Stockfish STDIN.
extern "C" __attribute__((visibility("default"))) __attribute__((used))
FFI_PLUGIN_EXPORT ssize_t stockfish_stdin_write(char *data);

// A very short-lived native function.
//
// Reading Stockfish STDOUT
extern "C" __attribute__((visibility("default"))) __attribute__((used))
FFI_PLUGIN_EXPORT char * stockfish_stdout_read();