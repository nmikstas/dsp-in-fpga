#ifndef DUC1_H_
#define DUC1_H_

#include <hls_stream.h>
#include "ap_fixed.h"

#define IDATA_NBITS 15 //17
#define ODATA_NBITS 15 //17
#define NBITS_FRAC  13 //15
#define COEFF_NBITS 13 //16
#define COEFF_FRAC  12 //15
#define IDATA_NBITS_INT IDATA_NBITS-NBITS_FRAC
#define ODATA_NBITS_INT ODATA_NBITS-NBITS_FRAC
#define COEFF_NBITS_INT COEFF_NBITS-COEFF_FRAC

// define number representation for filter accumulator
#define ACC_NBITS 21      //21
#define ACC_NBITS_FRAC 19 //19
#define ACC_NBITS_INT ACC_NBITS - ACC_NBITS_FRAC

typedef ap_fixed<IDATA_NBITS, IDATA_NBITS_INT>	idata_t;
typedef ap_fixed<ODATA_NBITS, ODATA_NBITS_INT>	odata_t;
typedef ap_fixed<COEFF_NBITS, COEFF_NBITS_INT>	Coeff;
typedef ap_fixed<ACC_NBITS, ACC_NBITS_INT>	Acc_real;
typedef ap_fixed<ACC_NBITS, ACC_NBITS_INT>	Acc_imag;

//A simple class for calculating the difference and RMS errors.
class Comp_err
{
	private:
		double rms_err_real;
		double rms_err_imag;
		double diff_real;
		double diff_imag;
		double diff_sqrd_real;
		double diff_sqrd_imag;
		int count;

	public:
		Comp_err();
		void update_error(double, double, double, double);
		void rms_error();
};

//Half-band filter function.
void hb(idata_t, idata_t, hls::stream<odata_t> *);
#endif
