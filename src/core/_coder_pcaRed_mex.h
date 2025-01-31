/*
 * _coder_pcaRed_mex.h
 *
 * Code generation for function 'pcaRed'
 *
 */

#ifndef _CODER_PCARED_MEX_H
#define _CODER_PCARED_MEX_H

/* Include files */
#include "emlrt.h"
#include "mex.h"
#include "tmwtypes.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
MEXFUNCTION_LINKAGE void mexFunction(int32_T nlhs, mxArray *plhs[],
                                     int32_T nrhs, const mxArray *prhs[]);

emlrtCTX mexFunctionCreateRootTLS(void);

void unsafe_pcaRed_mexFunction(int32_T nlhs, mxArray *plhs[1], int32_T nrhs,
                               const mxArray *prhs[1]);

#ifdef __cplusplus
}
#endif

#endif
/* End of code generation (_coder_pcaRed_mex.h) */
