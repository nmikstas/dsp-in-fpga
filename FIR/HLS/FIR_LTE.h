#ifndef FIR_LTE_H_
#define FIR_LTE_H_

#include "ap_fixed.h"

#define INPUT_ENTRIES 50000 //Number of input samples.
#define N 97 //Length of coefficients.

#define IDATA_NBITS 17 //16
#define ODATA_NBITS 18 //17
#define COEFF_NBITS 17 //16
#define NBITS_FRAC 15  //15
#define IDATA_NBITS_INT IDATA_NBITS-NBITS_FRAC
#define ODATA_NBITS_INT ODATA_NBITS-NBITS_FRAC
#define COEFF_NBITS_INT COEFF_NBITS-NBITS_FRAC

// define number representation for filter accumulator
#define ACC_NBITS 38      //21
#define ACC_NBITS_FRAC 30 //19
#define ACC_NBITS_INT ACC_NBITS - ACC_NBITS_FRAC

typedef ap_fixed<IDATA_NBITS, IDATA_NBITS_INT>	idata_t;
typedef ap_fixed<ODATA_NBITS, ODATA_NBITS_INT>	odata_t;
typedef ap_fixed<COEFF_NBITS, COEFF_NBITS_INT>	Coeff;
typedef ap_fixed<ACC_NBITS, ACC_NBITS_INT>	Acc_real;
typedef ap_fixed<ACC_NBITS, ACC_NBITS_INT>	Acc_imag;

void fir(idata_t in_real, idata_t in_imag, odata_t *out_real, odata_t *out_imag);
#endif
