#include "../funcs.h"

/*

AFAPI af_err af_susan	(	af_features * 	out,
const af_array 	in,
const unsigned 	radius,
const float 	diff_thr,
const float 	geom_thr,
const float 	feature_ratio,
const unsigned 	edge 
)	

AFAPI af_err af_harris	(	af_features * 	out,
const af_array 	in,
const unsigned 	max_corners,
const float 	min_response,
const float 	sigma,
const unsigned 	block_size,
const float 	k_thr 
)	

AFAPI af_err af_fast	(	af_features * 	out,
const af_array 	in,
const float 	thr,
const unsigned 	arc_length,
const bool 	non_max,
const float 	feature_ratio,
const unsigned 	edge 
)	

AFAPI af_err af_dog	(	af_array * 	out,
const af_array 	in,
const int 	radius1,
const int 	radius2 
)	

AFAPI af_err af_sift	(	af_features * 	feat,
af_array * 	desc,
const af_array 	in,
const unsigned 	n_layers,
const float 	contrast_thr,
const float 	edge_thr,
const float 	init_sigma,
const bool 	double_input,
const float 	intensity_scale,
const float 	feature_ratio 
)	

AFAPI af_err af_gloh	(	af_features * 	feat,
af_array * 	desc,
const af_array 	in,
const unsigned 	n_layers,
const float 	contrast_thr,
const float 	edge_thr,
const float 	init_sigma,
const bool 	double_input,
const float 	intensity_scale,
const float 	feature_ratio 
)	


AFAPI af_err af_orb	(	af_features * 	feat,
af_array * 	desc,
const af_array 	in,
const float 	fast_thr,
const unsigned 	max_feat,
const float 	scl_fctr,
const unsigned 	levels,
const bool 	blur_img 
)	
*/

int ComputerVision (lua_State * L)
{
	//	luaL_register(L, NULL, array_methods);

	return 0;
}