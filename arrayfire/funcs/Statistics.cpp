#include "../funcs.h"

/*

AFAPI af_err af_var	(	af_array * 	out,
const af_array 	in,
const bool 	isbiased,
const dim_t 	dim 
)	

AFAPI af_err af_var_all	(	double * 	realVal,
double * 	imagVal,
const af_array 	in,
const bool 	isbiased 
)	


AFAPI af_err af_var_all_weighted	(	double * 	realVal,
double * 	imagVal,
const af_array 	in,
const af_array 	weights 
)	


AFAPI af_err af_var_weighted	(	af_array * 	out,
const af_array 	in,
const af_array 	weights,
const dim_t 	dim 
)	


AFAPI af_err af_stdev	(	af_array * 	out,
const af_array 	in,
const dim_t 	dim 
)	


AFAPI af_err af_stdev_all	(	double * 	real,
double * 	imag,
const af_array 	in 
)


AFAPI af_err af_median	(	af_array * 	out,
const af_array 	in,
const dim_t 	dim 
)	


AFAPI af_err af_median_all	(	double * 	realVal,
double * 	imagVal,
const af_array 	in 
)	

AFAPI af_err af_mean	(	af_array * 	out,
const af_array 	in,
const dim_t 	dim 
)	


AFAPI af_err af_mean_all	(	double * 	real,
double * 	imag,
const af_array 	in 
)	


AFAPI af_err af_mean_all_weighted	(	double * 	real,
double * 	imag,
const af_array 	in,
const af_array 	weights 
)	

AFAPI af_err af_mean_weighted	(	af_array * 	out,
const af_array 	in,
const af_array 	weights,
const dim_t 	dim 
)	


AFAPI af_err af_cov	(	af_array * 	out,
const af_array 	X,
const af_array 	Y,
const bool 	isbiased 
)	

AFAPI af_err af_corrcoef	(	double * 	realVal,
double * 	imagVal,
const af_array 	X,
const af_array 	Y 
)	


*/

int Statistics (lua_State * L)
{
	//	luaL_register(L, NULL, array_methods);

	return 0;
}