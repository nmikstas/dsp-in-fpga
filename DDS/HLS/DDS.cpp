#include "DDS.h"

void do_dds(PhsInc phaseInc, SinCosType* sin, SinCosType* cos)
{
	static DDS dds; //Instantiate dds object.
	dds.dds(phaseInc, sin, cos);
}

//Constructor to initialize the variables.
DDS::DDS():phaseAcc(0)
{init_trig_lut();}

//This function fills the LUT table with values.
void DDS::init_trig_lut()
{
	LUTInitLoop:
	for(int i = 0; i < LUT_DEPTH; i++)
	{
		trigLUT[i] = sin(2.0*M_PI*(0.5+(double)i)/(4*LUT_DEPTH));
	}
}

void DDS::dds(PhsInc phaseInc, SinCosType *sin, SinCosType *cos)
{
	//Get address bits for driving the LUT address lines.
	AddrLUT addrLUT = phaseAcc;

	//Addresses for the sine and cosine outputs.
	AddrLUT sinAddr;
	AddrLUT cosAddr;

	//Keep only upper 2 bits of the phase accumulator.
	int upperBits = ((int)phaseAcc >> (PHASE_NBITS_INT-4)) & 3;

	//Read table backwards for sine wave if in second or fourth quadrant.
	sinAddr = (upperBits == 1 || upperBits == 3) ? (AddrLUT)(LUT_DEPTH-1-addrLUT) : addrLUT;

	//Read table backwards for cosine wave if in first or third quadrant.
	cosAddr = (upperBits == 0 || upperBits == 2) ? (AddrLUT)(LUT_DEPTH-1-addrLUT) : addrLUT;

	//Get output from the LUT.
	*sin = trigLUT[sinAddr];
	*cos = trigLUT[cosAddr];

	//Invert the sine output, if necessary.
	if(upperBits == 2 || upperBits == 3) (*sin) *= -1;

	//Invert the cosine output, if necessary.
	if(upperBits == 1 || upperBits == 2) (*cos) *= -1;

	//Update phase accumulator.
	phaseAcc += phaseInc;
}
