#include <ap_fixed.h>
#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <sstream>
#include <string>
#include <stdio.h>
#include <hls_stream.h>
#include "DUC1.h"

int main()
{
	//Create HLS stream for output data.
	hls::stream<odata_t> out_h;

	//Create file streams.
	std::ifstream in_f;
	std::ifstream golden_f;
	std::ofstream out_f;

	//Open files.
	in_f.open("inQ.dat", std::ios_base::in);
	golden_f.open("golden.dat", std::ios_base::in);
	out_f.open("../../../../out.dat", std::ios_base::out);

	std::string line1, line2, line3;
	Comp_err err; //Error calculation object.

	//Data holders while reading from HLS streams.
	double golden_r0, golden_r1, golden_i0, golden_i1;
	odata_t out_r0, out_r1, out_i0, out_i1;
	idata_t in_r, in_i;

	while(true)
	{
		//Get data from the file and load it into the stream.
		std::getline(in_f, line1);
		std::getline(golden_f, line2);
		std::getline(golden_f, line3);

		if(in_f.eof())break; //Exit if done reading files.

		std::istringstream in1(line1);
		std::istringstream in2(line2);
		std::istringstream in3(line3);

		//Move data into variables.
		in1 >> in_r;
		in1 >> in_i;
		in2 >> golden_r0;
		in2 >> golden_i0;
		in3 >> golden_r1;
		in3 >> golden_i1;

		//Run filter.
		hb(in_r, in_i, &out_h);

		//Read data from the HLS stream.
		out_h.read(out_r0);
		out_h.read(out_i0);
		out_h.read(out_r1);
		out_h.read(out_i1);

		//Update error calculations.
		err.update_error(golden_r0, golden_i0, double(out_r0), double(out_i0));
		err.update_error(golden_r1, golden_i1, double(out_r1), double(out_i1));

		//Write results to file.
		out_f << std::setprecision(20) << out_r0 << " " << out_i0 << std::endl;
		out_f << std::setprecision(20) << out_r1 << " " << out_i1 << std::endl;
	}

	err.rms_error(); //Calculate RMS error.

	//Close files.
	in_f.close();
	golden_f.close();
	out_f.close();
	return 0;
}

//Comp_err constructor.
Comp_err::Comp_err():
		rms_err_real(0), rms_err_imag(0), diff_real(0), diff_imag(0),
		diff_sqrd_real(0), diff_sqrd_imag(0), count(0){}

//Calculate Current error.
void Comp_err::update_error(double g_r, double g_i, double o_r, double o_i)
{
	count++;

	diff_real = g_r - o_r;
	diff_imag = g_i - o_i;

	diff_sqrd_real += diff_real * diff_real;
	diff_sqrd_imag += diff_imag * diff_imag;

	//Print golden reference number.
	std::cout << "Ref=" << g_r;
	if(g_i < 0) std::cout << g_i << "i, ";
	else std::cout << "+" << g_i << "i, ";

	//Print calculated number.
	std::cout << "Calc=" << o_r;
	if(o_i < 0) std::cout << o_i << "i, ";
	else std::cout << "+" << o_i << "i, ";

	//Print difference.
	std::cout << "Difr=" << diff_real << ", Difi=" << diff_imag;
	std::cout << std::endl;
}

//Calculate total RMS error.
void Comp_err::rms_error()
{
	rms_err_real = sqrt(diff_sqrd_real / count);
	rms_err_imag = sqrt(diff_sqrd_imag / count);

	std::cout << std::endl;
	std::cout << "number of input test vectors = " << count/2 << std::endl;
	std::cout << "number of output test vectors = " << count << std::endl;
	std::cout << "Real rms error = " << rms_err_real << std::endl;
	std::cout << "% Real rms error = " << rms_err_real*100 << "%" << std::endl;
	std::cout << "Imaginary rms error = " << rms_err_imag << std::endl;
	std::cout << "% Imaginary rms error = " << rms_err_imag*100 << "%" << std::endl;
}
