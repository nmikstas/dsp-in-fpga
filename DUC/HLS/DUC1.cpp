#include "DUC1.h"

//Define the delay line lengths.
#define TDELAY 12 //Top delay line.
#define BDELAY 7  //Bottom delay line.

void hb(idata_t in_real, idata_t in_imag, hls::stream<odata_t> *out)
{
	//Coefficient constants.
	static const Coeff coeff[] =
	{
		-0.00137329101562500000,  0.00765991210937500000, -0.02584838867187500000,
		 0.06878662109375000000, -0.17095947265625000000,  0.62167358398437500000
	};

	//Delay lines.
	static idata_t shift_reg_real_t[TDELAY];
	static idata_t shift_reg_real_b[BDELAY];
	static idata_t shift_reg_imag_t[TDELAY];
	static idata_t shift_reg_imag_b[BDELAY];

	//Accumulators.
	Acc_real acc_real = 0;
	Acc_imag acc_imag = 0;

	//Get input data.
	shift_reg_real_t[0] = in_real;
	shift_reg_imag_t[0] = in_imag;
	shift_reg_real_b[0] = in_real;
	shift_reg_imag_b[0] = in_imag;

	//Multiply through.
	AccumLoop:
	for (int i = 0; i < TDELAY/2; i++)
	{
		acc_real += coeff[i]*(shift_reg_real_t[i] + shift_reg_real_t[TDELAY-1-i]);
		acc_imag += coeff[i]*(shift_reg_imag_t[i] + shift_reg_imag_t[TDELAY-1-i]);
	}

	//Shift all top values.
	MemUpdateTop:
	for (int i = TDELAY-1; i > 0; i--)
	{
		shift_reg_real_t[i] = shift_reg_real_t[i-1];
		shift_reg_imag_t[i] = shift_reg_imag_t[i-1];
	}

	//Shift all bottom values.
	MemUpdateBottom:
	for (int i = BDELAY-1; i > 0; i--)
	{
		shift_reg_real_b[i] = shift_reg_real_b[i-1];
		shift_reg_imag_b[i] = shift_reg_imag_b[i-1];
	}

	//Store output values.
	out->write_nb(acc_real);
	out->write_nb(acc_imag);
	out->write_nb(shift_reg_real_b[BDELAY-1]);
	out->write_nb(shift_reg_imag_b[BDELAY-1]);
}
