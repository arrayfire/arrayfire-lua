#if defined(_WIN32) || defined(_MSC_VER)
#define __EXPORT__ extern "C"  __declspec(dllexport)
#else
#define __EXPORT__ extern "C" __attribute__((visibility("default")))
#endif
