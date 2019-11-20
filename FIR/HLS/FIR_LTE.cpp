#include "FIR_LTE.h"

void fir(idata_t in_real, idata_t in_imag, odata_t *out_real, odata_t *out_imag)
{
	static const Coeff coeff[] =
	{
		#include "LTE_coeff.dat"
	};

	//Clear values.
	static idata_t shift_reg_real[N];
	static idata_t shift_reg_imag[N];
	Acc_real acc_real = 0;
	Acc_imag acc_imag = 0;

	//Get input data.
	shift_reg_real[0] = in_real;
	shift_reg_imag[0] = in_imag;

	//Multiply through.
 	AccumLoop:
	for (int i = 0; i < N; i++)
  	{
 		acc_real += shift_reg_real[i]*coeff[i];
 		acc_imag += shift_reg_imag[i]*coeff[i];
 	}

	//Shift all values.
 	MemUpdate:
	for (int i = N - 1; i > 0; i--)
	{
		shift_reg_real[i] = shift_reg_real[i-1];
		shift_reg_imag[i] = shift_reg_imag[i-1];
	}

	//Output values.
 	*out_real = acc_real;
 	*out_imag = acc_imag;
}
