#ifndef DDS1_H_
#define DDS1_H_

#include <math.h>
#include "ap_fixed.h"

//Number entries to access in the lookup table.
#define NUM_LOOPS 8192

#define FS   245.76 //System clock frequency in MHz.
//#define FOUT 10.457 //Target output frequency in MHz.
#define FOUT 80.957 //Target output frequency in MHz.

//Lookup table precision.
#define TRIGLUT_NBITS 16
#define TRIGLUT_NBITS_FRAC 15
#define TRIGLUT_NBITS_INT TRIGLUT_NBITS-TRIGLUT_NBITS_FRAC

//Delta phi and phase accumulator precision.
#define PHASE_NBITS 17
#define PHASE_NBITS_FRAC 2
#define PHASE_NBITS_INT PHASE_NBITS-PHASE_NBITS_FRAC

typedef ap_fixed<TRIGLUT_NBITS, TRIGLUT_NBITS_INT> TrigLUT, SinCosType;
typedef ap_fixed<PHASE_NBITS, PHASE_NBITS_INT> PhsInc, PhaseAcc;
typedef ap_uint<PHASE_NBITS_INT-4> AddrLUT;

//Define the depth of the DDS LUT.
//NOTE: The formula for figuring out the LUT table depth is:
//LUT depth = 2^(PHASE_NBITS - PHASE_NBITS_FRAC - 4).
#define LUT_DEPTH (1<<(PHASE_NBITS_INT-4))

class DDS
{
	public:
		DDS();
		void dds(PhsInc, SinCosType *, SinCosType *);

	private:
		void init_trig_lut();       //Function to initialize the LUT.

		TrigLUT trigLUT[LUT_DEPTH]; //Sine wave LUT.
		PhaseAcc phaseAcc;          //Phase accumulator.
		AddrLUT addrSIN;			//Address for sine data.
		AddrLUT addrCOS;            //Address for cosine data.
};

//Function that accesses the dds class.
void do_dds(PhsInc, SinCosType *, SinCosType *);

#endif
