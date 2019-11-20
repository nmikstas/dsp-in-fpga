#include <ap_fixed.h>
#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <sstream>
#include <string>
#include <stdio.h>

#include "FIR_LTE.h"

float rms_error(unsigned long n, float e)
{
	return sqrt(e/n);
}

int main()
{
	idata_t input_real[INPUT_ENTRIES];
	idata_t input_imag[INPUT_ENTRIES];
	odata_t golden_real[INPUT_ENTRIES];
	odata_t golden_imag[INPUT_ENTRIES];

	//Create input streams.
	std::ifstream in_real;
	std::ifstream in_imag;
	std::ifstream gd_real;
	std::ifstream gd_imag;
	std::ofstream ot_real;
	std::ofstream ot_imag;

	//Open files
    in_real.open("LTE_input_real.dat", std::ios_base::in);
    in_imag.open("LTE_input_imag.dat", std::ios_base::in);
    gd_real.open("LTE_output_real.dat", std::ios_base::in);
    gd_imag.open("LTE_output_imag.dat", std::ios_base::in);
    ot_real.open("../../../../LTE_result_real.dat", std::ios_base::out);
    ot_imag.open("../../../../LTE_result_imag.dat", std::ios_base::out);

    std::string line;
    float temp;

    //Read data into files.
	for(int i = 0; i < INPUT_ENTRIES; i++)
	{
		std::getline(in_real, line);
	    std::istringstream in(line);
	    in >> input_real[i];
	}

	for(int i = 0; i < INPUT_ENTRIES; i++)
	{
		std::getline(in_imag, line);
		std::istringstream in(line);
		in >> input_imag[i];
	}

	for(int i = 0; i < INPUT_ENTRIES; i++)
	{
		std::getline(gd_real, line);
	    std::istringstream in(line);
	    in >> golden_real[i];
	}

	for(int i = 0; i < INPUT_ENTRIES; i++)
	{
		std::getline(gd_imag, line);
	    std::istringstream in(line);
	    in >> golden_imag[i];
	}

	//Close files
    in_real.close();
    in_imag.close();
    gd_real.close();
    gd_imag.close();

	//Array of computed values.
	odata_t output_real[INPUT_ENTRIES];
	odata_t output_imag[INPUT_ENTRIES];

	//Error calculation variables.
	float diff_real, diff_imag;
	float diff_sqrd_real = 0, diff_sqrd_imag = 0;
	float rms_err_real, rms_err_imag;

	for(int i = 0; i < INPUT_ENTRIES; i++)
	{
		//Run filter.
		fir(input_real[i], input_imag[i], &output_real[i], &output_imag[i]);

		//Calculate difference between Matlab calculation and Vivado calculation.
		diff_real = float(golden_real[i] - output_real[i]);
		diff_imag = float(golden_imag[i] - output_imag[i]);

		//Calculate rms squared error.
		diff_sqrd_real += diff_real * diff_real;
		diff_sqrd_imag += diff_imag * diff_imag;

		//Print golden reference number.
		std::cout << "Ref=" << golden_real[i];
		if(golden_imag[i].is_neg()) std::cout << golden_imag[i] << "i, ";
		else std::cout << "+" << golden_imag[i] << "i, ";

		//Print calculated number.
		std::cout << "Calc=" << output_real[i];
		if(output_imag[i].is_neg()) std::cout << output_imag[i] << "i, ";
		else std::cout << "+" << output_imag[i] << "i, ";

		//Print real difference.
		std::cout << "Difr=" << diff_real << ", Difi=" << diff_imag;

		std::cout << std::endl;

		//Write result to file.
		ot_real << std::setprecision(20) << output_real[i] << std::endl;
		ot_imag << std::setprecision(20) << output_imag[i] << std::endl;
	}

	std::cout << diff_sqrd_real << std::endl;
	rms_err_real = rms_error(INPUT_ENTRIES, diff_sqrd_real);
	rms_err_imag = rms_error(INPUT_ENTRIES, diff_sqrd_imag);

	std::cout << std::endl;
	std::cout << "number of test vectors = " << INPUT_ENTRIES << std::endl;
	std::cout << "Real rms error = " << rms_err_real << std::endl;
	std::cout << "% Real rms error = " << rms_err_real*100 << "%" << std::endl;
	std::cout << "Imaginary rms error = " << rms_err_imag << std::endl;
	std::cout << "% Imaginary rms error = " << rms_err_imag*100 << "%" << std::endl;

	//Close the output files.
	ot_real.close();
	ot_imag.close();

	return 0;
}


