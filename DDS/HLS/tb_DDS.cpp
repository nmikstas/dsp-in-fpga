#include <ap_fixed.h>
#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <stdio.h>
#include "DDS.h"

int main()
{
	//Create file streams.
	std::ofstream sinf;
	std::ofstream cosf;
	sinf.open("../../../sin.dat", std::ios_base::out);
	cosf.open("../../../cos.dat", std::ios_base::out);

	//Phase increment calculation = 4*LUT_DEPTH*FOUT/(FS)
	PhsInc phaseInc = (4.0*LUT_DEPTH*FOUT) / FS;

	SinCosType sin, cos;

	std::cout << "LUT Depth: " << LUT_DEPTH << std::endl;

	for(int i = 0; i < NUM_LOOPS; i++)
	{
		do_dds(phaseInc, &sin, &cos);

		//Write results to file.
		sinf << std::setprecision(20) << sin << std::endl;
		cosf << std::setprecision(20) << cos << std::endl;
	}

	//Close file streams.
	sinf.close();
	cosf.close();

	return 0;
}
