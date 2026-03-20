#ifdef NSAMPLER
   #define CTRPOINT(_sid_) __NOP
#else

   #include "sampler.h"

   #ifndef CTRPOINT
      #define CTRPOINT(_sid_) __throw_sampler(__FILE__,(_sid_))
   #endif //CTRPOINT

#endif   // NSAMPLER
